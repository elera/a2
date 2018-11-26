{-------------------------------------------------------------------------------

  Dosya: incele.pas

  İşlev: her bir veri satırının içerisindeki bölümleri inceleme ve yönlendirme
    işlevlerini içerir

  Güncelleme Tarihi: 29/04/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit incele;

interface

{
  intel / amd yönerge biçimi (Intel Instruction Format)
  -----------------------------------------------
  +--------+--------+--------+-----+------+-----+
  | prefix | opcode | modr/m | sib | disp | imm |
  +--------+--------+--------+-----+------+-----+

  ön ek (prefix): 0-4 byte
  işlem kodu (opcode): 1-3 byte
  mod yazmaç / bellek (modr/m): 1 byte
  ölçek (scale) - sıra (index) - taban (base) (sib): 1 byte
  yerini alma (displacement): 1-4 byte
  sayısal değer (immediate): 1-4 byte
}
uses genel, Dialogs, dosya, paylasim;

function KodUret(Dosya: TDosya; KodDizisi: string): Integer;
function VerileriIsle(ParcaSonuc: TParcaSonuc): Integer;
function Parcala(var SonParca: Boolean): TParcaSonuc;
function KomutYorumla(ParcaSonuc: TParcaSonuc): TParcaSonuc;
function SayisalVeriyiIsle(AIslemTipi: TIslemTipleri; AVeriTip: TVeriTipleri;
  ASayisalDeger: string): Integer;

implementation

uses atamalar, sysutils, donusum, yazmaclar, komutlar, tanimlar, onekler,
  makrolar, bildirimler, degiskenler, g10islev, g11islev, g12islev, g13islev,
  dbugintf, kodlama, hataayiklama, anasayfaform;

var
  KomutUz: Integer;

  GKodDizisi: string;
  KodDiziUzunluk, KodDiziSira: Integer;
  GTanimlanacakVeri1: string;

// her bir kod satırının yönlendirildiği, incelenerek parçalara ayrıldığı,
// assembler kodlarının üretildiği ana bölüm
function KodUret(Dosya: TDosya; KodDizisi: string): Integer;
var
  Atama: TAtama;
  C: Char;
  i, KSiraNo: Integer;
  SayisalDeger: QWord;        // geçici deger değişkeni
  KPSayisi: Integer;          // köşeli parantezlerin takibini gerçekleştiren değişken
  TekTirnakSayisi: Integer;   // karakter katarı (string) takibini gerçekleştiren değişken
  OlcekDegerMevcut: Boolean;  // dizi içerisinde ölçek değer (scale) olup olmadığını takip eder
  SonKullanilanIsleyici: Char;
  OncekiParcaSonuc, ParcaSonuc: TParcaSonuc;
  OnEk: TOnEk;
  SonParca: Boolean;
  KomutTip: TKomutTipi;
  Bildirim: TBildirim;
  VeriyiIsle: Boolean;
begin

  // ilk değer atamaları

  GKodDizisi := KodDizisi;

  GHataKodu := HATA_YOK;
  KPSayisi := 0;
  TekTirnakSayisi := 0;
  OlcekDegerMevcut := False;

  // VeriTipi'nin tvtTanimsiz olarak tanımlandığı;
  // 1. nokta KomutYorumla işlevi
  // 2. nokta SayisalVeriyiIsle işlevi
  // 3. nokta ise burasıdır
  //VeriTipi := ktTanimsiz;

  Bildirim.Esittir := False;

  //BirOncekiParcaSonuc.ParcaTipi := ptYok;
  //OncekiParcaSonuc.ParcaTipi := ptYok;
  ParcaSonuc.ParcaTipi := ptYok;

  ParcaSonuc.VeriKK := '';

  // son aşamayı temsil eden değişken
  //SonParcaSonuc.VeriKK := '';

  //GKomut := '';
  KomutUz := 0;
  SonKullanilanIsleyici := '+';

  GTanimlanacakVeri1 := '';

  GAsm2.Matematik.Temizle;      // mevcut matematisel işlemleri temizle

  GSabitDegerVG := vgHatali;
  //GBellekSabitDegerVG := vgHatali;

  // bir satırın değerlendirilme süreci
  // örnekler:
  //   mov  eax,b1 1
  //   mov  ebx,d8
  //   mov  ecx,'TEST'
  //
  // 1. kontrol - istenilen işlem nedir?
  // 2. kontrol - öndeğer bir yazmaç mı?
  // 3. kontrol - öndeğer bir sayı mı?
  // 4. kontrol - öndeğer bir sayı ise ön eki var mı?
  // 5. kontrol - öndeğer bir karakter katarı mı?
  // 6. kontrol - öndeğer bir değişken mi?

  KodDiziUzunluk := Length(KodDizisi);
  KodDiziSira := 1;

  // ->>>>> HER BİR SATIRIN PARÇA BAZLI İŞLENDİĞİ BÖLÜM
  SonParca := False;
  while not SonParca and (GHataKodu = HATA_YOK) do
  begin

    //BirOncekiParcaSonuc := OncekiParcaSonuc;
    OncekiParcaSonuc := ParcaSonuc;

    ParcaSonuc.ParcaTipi := ptTanimsiz;
    ParcaSonuc.VeriTipi := vTanimsiz;

    // verinin işlenmesi öndeğer true olarak değerlendirilecek
    VeriyiIsle := True;

    // Parçala işlemi tarafından değerlendirilerek gelen veriler:
    // 1. işlem kodlarından: =,[]+-*/()
    // 2. makro kodlarının tümü: %
    // 3. ; karakteriyle başlayan açıklama verilerinin tümü
    // 4. '..' aralığından tanımlanan karakter verilerinin tümü
    // 5. sayısal değer olan 0..9 arası sayısal değer ile başlayan, sayısal ve kayan nokta verilerinin tümü
    ParcaSonuc := Parcala(SonParca);

    //VeriBilgisiniGoruntule(ParcaSonuc);

    // parça tipinin olmaması durumunda bir sonraki parçayı al
    if(ParcaSonuc.ParcaTipi = ptYok) then Continue;

    if{(ParcaSonuc.ParcaTipi = ptVeri) and} (ParcaSonuc.VeriTipi = vAciklama) then
    begin

      //SendDebug('Açıklama: ' + ParcaSonuc.HamVeri);
      GHataKodu := HATA_YOK;
         Continue;

      {if(SI.Komut.Tip = kDegisken) then
      begin

        if(OncekiParcaSonuc.VeriTipi = vKarakterDizisi) then
        begin

          ParcaSonuc.VeriTipi := vKarakterDizisi;
          GHataKodu := VerileriIsle(ParcaSonuc);
        end
        else
        begin

          GHataKodu := GAsm2.Matematik.Sonuc(ParcaSonuc.VeriSD);
          GHataKodu := VerileriIsle(ParcaSonuc);
        end;

        VeriyiIsle := False;
        Continue;
      end
      else}
      begin

        GHataKodu := HATA_YOK;
        Continue;
      end;

    //SendDebug('GI');
    end;

    if(ParcaSonuc.ParcaTipi = ptVeri) and (ParcaSonuc.VeriTipi = vMakroDeger) then
    begin

      MakroIslev(ParcaSonuc);
    end;

    // ->>>>> TANIMLANMAMIŞ KOMUTLARIN TANIMLANMAYA ÇALIŞILDIĞI BÖLÜM
    if(SI.Komut.Tip = kTanimsiz) or (SI.Komut.Tip = kTanimlanacak) {and not(ParcaSonuc.VeriTipi = vAciklama)} then
    begin

      //SendDebug('İşlem Kodu: ' + KomutListesi[SonParcaSonuc.SiraNo].Ad);


      // komut henüz tanımlanmadı ise, etiket kontrolü
      // örnek: etiket:
      if(Length(ParcaSonuc.HamVeri) > 0) and (ParcaSonuc.HamVeri[Length(ParcaSonuc.HamVeri)] = ':') then
      begin

        if(dvEtiket in SI.DigerVeri) then

          GHataKodu := HATA_BIRDEN_FAZLA_ETIKET
        else
        begin

          SI.DigerVeri += [dvEtiket];
          SI.Etiket := Copy(ParcaSonuc.HamVeri, 1, Length(ParcaSonuc.HamVeri) - 1);

          ParcaSonuc.VeriTipi := vSayi;
          ParcaSonuc.VeriSD := MevcutBellekAdresi;

          // etiketi atama listesine ekle
          GHataKodu := GAsm2.AtamaListesi.Ekle(Dosya, atEtiket, SI.Etiket,
            ParcaSonuc);
        end;
      end
      else
      // komut daha önce tanımlanmamış ise ...
      begin

        // .. komutu yeniden tanımlamaya çalış
        if(ParcaSonuc.ParcaTipi = ptTanimsiz) then
          ParcaSonuc := KomutYorumla(ParcaSonuc);

        // tanımsız komutun birinci aşamada tanımlanamaması
        if(ParcaSonuc.ParcaTipi = ptTanimsiz) then
        begin

          if(SI.Komut.Tip = kTanimsiz) then
          begin

            SI.Komut.Tip := kTanimlanacak;
            GTanimlanacakVeri1 := ParcaSonuc.HamVeri;
            VeriyiIsle := False;
          end
          else if(SI.Komut.Tip = kTanimlanacak) then
          begin

            //SI.Komut.Tip := kTanimlanacak;
            //GTanimlanacakVeri1 := ParcaSonuc.HamVeri;
            //VeriyiIsle := False;
            GHataKodu := HATA_BILINMEYEN_KOMUT;
          end;
        end
        // komutun tanımlanabilmesi halinde
        else if(ParcaSonuc.ParcaTipi = ptKomut) then
        begin

          SI.Komut.Tip := ParcaSonuc.Komut.Tip;
          SI.Komut.Ad := ParcaSonuc.Komut.Ad;
          SI.Komut.SNo := ParcaSonuc.Komut.SNo;
          SI.Komut.GNo := ParcaSonuc.Komut.GNo;
          //SI.VeriKK := GTanimlanacakVeri1;    // ?

          //KomutBilgisiniGoruntule;

          //ParcaSonuc.VeriTipi := vSayi;   // ?
          //ParcaSonuc.VeriSD := MevcutBellekAdresi; // ?

          // komut tanım verisi işlenmeyecektir
          VeriyiIsle := False;
        end
        // 1. aşamada tanımlanamayan komutun 2. aşamada tanımlanabilmesi
        else if(ParcaSonuc.ParcaTipi = ptIslem) and (ParcaSonuc.IslemTipi = iEsittir)
          and (SI.Komut.Tip = kTanimlanacak) then
        begin

          //SendDebug('İşlem Kodu5: ' + GTanimlanacakVeri1);

          SI.Komut.Tip := kTanim;
          SI.VeriKK := GTanimlanacakVeri1;
          //GTanimlanacakVeri1 := ParcaSonuc.HamVeri;
          //SendDebug('Tanım: Eşittir');
          //GHataKodu := 1;

          VeriyiIsle := False;
        end
        else
        // tanımsız komutun ilk aşamada tanımlanması
        begin

          GHataKodu := 1;

          {SI.KomutSiraNo := ParcaSonuc.SiraNo;
          SI.Komut.Tip := ParcaSonuc.KomutTipi;
          SI.Komut.Ad := KomutListesi[ParcaSonuc.SiraNo].Ad;
          SI.Komut.GrupNo := KomutListesi[ParcaSonuc.SiraNo].GrupNo;

          // ParcaNo değişkeninin değeri SADECE burada artırılmaktadır
          Inc(GParcaNo);

          VeriyiYonlendir := False;}

          //SendDebug('Komut: ' + IntToStr(SI.Komut.GrupNo));
          //SendDebug('Komut: ' + SI.Komut.Ad);
        end;
      end;
    end
    // <<<<<- TANIMLANMAMIŞ KOMUTLARIN TANIMLANMAYA ÇALIŞILDIĞI BÖLÜM
    else
    // ->>>>> BU AŞAMADA KOMUT TANIMLANMIŞ
    // ->>>>> TANIMLANMAMIŞ PARÇALARININ TANIMLANMAYA ÇALIŞILDIĞI BÖLÜM
    begin

      // parcala işlevinden herhangi bir veri tipi dönmüşse
      // ptYok = hiçbir veri yok
      if not(ParcaSonuc.ParcaTipi = ptYok) then
      begin

        // kontrol edilsin
        {if(ParcaSonuc.ParcaTipi = ptIslem) and
          ((ParcaSonuc.IslemTipi = iTopla) or (ParcaSonuc.IslemTipi = iEsittir) or
          (ParcaSonuc.IslemTipi = iVirgul)) then
          Inc(GParcaNo)

        else}

        // -> TANIMSIZ verilerin tanımlanmaya çalışılması
        // ----------------------------------------------
        if(ParcaSonuc.ParcaTipi = ptTanimsiz) then
        begin

          if(SI.Komut.Tip = kDegisken) then
          begin

            Atama := GAsm2.AtamaListesi.Bul(Dosya, ParcaSonuc.HamVeri);
            if(Atama <> nil) then
            begin

              SendDebug('Tanımlı Veri: ' + ParcaSonuc.HamVeri);

              case Atama.Tip of
                atEtiket:
                begin

                  ParcaSonuc.VeriTipi := vSayi;
                  GHataKodu := SayisalVeriyiIsle(OncekiParcaSonuc.IslemTipi, vSayi,
                    IntToStr(Atama.BellekAdresi));
                  VeriyiIsle := False;
                  //SendDebug('Tanımsız-Etiket: ' + IntToStr(Atama.BellekAdresi));
                end
                else
                begin

                  if(Atama.VeriTipi = vSayi) then
                  begin

                    ParcaSonuc.VeriTipi := vSayi;
                    GHataKodu := SayisalVeriyiIsle(OncekiParcaSonuc.IslemTipi,
                      vSayi, IntToStr(Atama.iDeger));
                    VeriyiIsle := False;
                    //SendDebug('Tanımsız-Sayı: ' + IntToStr(Atama.iDeger))
                  end
                  else if(Atama.VeriTipi = vKarakterDizisi) then
                  begin

                    ParcaSonuc.VeriTipi := vKarakterDizisi;
                    ParcaSonuc.VeriKK := ParcaSonuc.VeriKK + Atama.sDeger;
                    VeriyiIsle := False;

                    //SendDebug('Tanımsız-Karakter: ' + Atama.sDeger);
                  end;
                end;
              end;
              //SendDebug('sDeğer: ' + ParcaSonuc.HamVeri);
            end
            else
            begin

              frmAnaSayfa.mLog.Lines.Add('Tanımsız Veri: ' + ParcaSonuc.HamVeri);

              // sonradan tanımlanan değerlerin işlenmesi
              ParcaSonuc.ParcaTipi := ptVeri;
              ParcaSonuc.VeriTipi := vSayi;
              ParcaSonuc.HamVeri := '500000';

              Inc(GEtiketHataSayisi);

              //GHataKodu := SayisalVeriyiIsle(OncekiParcaSonuc.IslemTipi, vSayi, ParcaSonuc.HamVeri);
              //VeriyiIsle := False;
            end;
          end
          else
          begin

            ParcaSonuc := KomutYorumla(ParcaSonuc);
            {if(ParcaSonuc.ParcaTipi = ptVeri) and (ParcaSonuc.VeriTipi = vYazmac) then
              ParcaSonuc.VeriSD := KSiraNo;}
          end;
        end;
        // ----------------------------------------------
        // <- TANIMSIZ verilerin tanımlanmaya çalışılması


        if(ParcaSonuc.ParcaTipi = ptVeri) and (ParcaSonuc.VeriTipi = vYazmac) then
        begin

          GHataKodu := VerileriIsle(ParcaSonuc);
          VeriyiIsle := False;
        end

        // -> her bir veri parçasının / tipinin değerlendirilmesi
        // toplama işlemi yönlendirilmeyecek - geçici çözüm
        else if(ParcaSonuc.ParcaTipi = ptIslem) and ((ParcaSonuc.IslemTipi = iTopla) or
          (ParcaSonuc.IslemTipi = iCikart) or (ParcaSonuc.IslemTipi = iCarp) or
          (ParcaSonuc.IslemTipi = iBol)) then
        begin

          //frmAnaSayfa.Memo1.Lines.Add('Çıkart');
          VeriyiIsle := False
        end
        else if(ParcaSonuc.ParcaTipi = ptIslem) and (ParcaSonuc.IslemTipi = iVirgul) then
        begin

          if(SI.Komut.Tip = kDegisken) and (OncekiParcaSonuc.VeriTipi = vSayi) then
          begin
          // önceki değerin sayı olması durumunda aşağıdaki komutlar devreye sokulaca ve yapılandırılacak
          GHataKodu := GAsm2.Matematik.Sonuc(ParcaSonuc.VeriSD);
          //SendDebug('Sayısal Veri:' + IntToStr(ParcaSonuc.VeriSD));

          ParcaSonuc.ParcaTipi := ptVeri;
          ParcaSonuc.VeriTipi := vSayi;

          GHataKodu := VerileriIsle(ParcaSonuc);
          //SonParcaSonuc.VeriKK := '';
          //SonParcaSonuc.VeriSD := 0;

          ParcaSonuc.VeriKK := '';
          ParcaSonuc.VeriSD := 0;

          VeriyiIsle := False;

          GAsm2.Matematik.Temizle;
          end;
        end
        else if(ParcaSonuc.ParcaTipi = ptVeri) and (ParcaSonuc.VeriTipi = vSayi) then
        begin

          //SendDebug('Sayısal Veri:' + ParcaSonuc.HamVeri);
          GHataKodu := SayisalVeriyiIsle(OncekiParcaSonuc.IslemTipi, vSayi, ParcaSonuc.HamVeri);
          VeriyiIsle := False;
        end
        else if(ParcaSonuc.ParcaTipi = ptVeri) and (ParcaSonuc.VeriTipi = vKayanNokta) then
        begin

          // birden fazla değerin matematiksel işleme tabi tutulması burada gerçekleştirilecek

          //SendDebug('Sayısal Veri:' + ParcaSonuc.HamVeri);
          ParcaSonuc.VeriTipi := vKayanNokta;
          ParcaSonuc.VeriKK := ParcaSonuc.HamVeri;
          //GHataKodu := SayisalVeriyiIsle(vSayi, ParcaSonuc.HamVeri, OncekiParcaSonuc.IslemTipi);
          VeriyiIsle := False;
        end
        else if(ParcaSonuc.ParcaTipi = ptVeri) and (ParcaSonuc.VeriTipi = vKarakterDizisi) then
        begin

          ParcaSonuc.VeriTipi := vKarakterDizisi;
          ParcaSonuc.VeriKK := ParcaSonuc.VeriKK + ParcaSonuc.HamVeri;
          VeriyiIsle := False;
          //SendDebug('Sayısal Veri:' + SonParcaSonuc.VeriKK)
        end
        else if(ParcaSonuc.ParcaTipi = ptIslem) and (ParcaSonuc.IslemTipi = iKPKapat) then
        begin

          if(OncekiParcaSonuc.ParcaTipi = ptVeri) and (OncekiParcaSonuc.VeriTipi = vSayi) then
          begin

            ParcaSonuc.ParcaTipi := ptVeri;
            ParcaSonuc.VeriTipi := vSayi;
            GHataKodu := GAsm2.Matematik.Sonuc(ParcaSonuc.VeriSD);
            if(GHataKodu = HATA_YOK) then GHataKodu := VerileriIsle(ParcaSonuc);

            ParcaSonuc.ParcaTipi := ptIslem;
            ParcaSonuc.IslemTipi := iKPKapat;
          end;
        end
        else if(ParcaSonuc.ParcaTipi = ptIslem) and (ParcaSonuc.IslemTipi = iEsittir) then
        begin

          if(SI.Komut.Tip = kBildirim) then
          begin

            if(Bildirim.Esittir = False) then
              Bildirim.Esittir := True
            else GHataKodu := HATA_BEKLENMEYEN_IFADE;

            VeriyiIsle := False;   // ??
          end;
        end;
        // <- her bir veri parçasının / tipinin değerlendirilmesi

        if(SonParca) then
        begin

          if(ParcaSonuc.VeriTipi = vSayi) then
          begin

            //MesajGoruntule('Sayı', 'Sayı');

            GHataKodu := GAsm2.Matematik.Sonuc(ParcaSonuc.VeriSD);
          {else if(ParcaSonuc.ParcaTipi = ptVeri) and (ParcaSonuc.VeriTipi = vKarakterDizisi) then
            ParcaSonuc.VeriKK := ParcaSonuc.VeriKK + ParcaSonuc.HamVeri;}

            if(SI.Komut.Tip = kIslemKodu) then
            begin

              //MesajGoruntule('Sayı', IntToStr(ParcaSonuc.VeriSD));
              GHataKodu := VerileriIsle(ParcaSonuc);
              VeriyiIsle := False;
            end
            {else if(SI.Komut.Tip = kDegisken) {and (VeriyiYonlendir)} then
            begin

              GHataKodu := VerileriIsle(ParcaSonuc);
              VeriyiIsle := False;
            end;}
          end;
        end;

        if(VeriyiIsle) then
        begin

          // sadece aritmetiksel işlemlerin gerçekleştirilmesi için ( ve )
          // işleyicilerin yürütülmesi için eklenmiştir
          if(ParcaSonuc.ParcaTipi = ptIslem) and ((ParcaSonuc.IslemTipi = iPAc) or
            (ParcaSonuc.IslemTipi = iPKapat)) then
          begin

            // eğer dizi "x + y + (" biçimindeyse
            if((ParcaSonuc.ParcaTipi = ptIslem) and (ParcaSonuc.IslemTipi = iPAc)) then
            begin

              if((OncekiParcaSonuc.ParcaTipi = ptIslem) and ((OncekiParcaSonuc.IslemTipi = iTopla) or
                (OncekiParcaSonuc.IslemTipi = iCikart) or (OncekiParcaSonuc.IslemTipi = iCarp) or
                (OncekiParcaSonuc.IslemTipi = iBol))) then
              begin

                GHataKodu := SayisalVeriyiIsle(OncekiParcaSonuc.IslemTipi, vSayi, '');
              end;
            end;

            GHataKodu := SayisalVeriyiIsle(ParcaSonuc.IslemTipi, vSayi, '');

            // bir sonraki gelecek değerin sayısal değer olması ihtimaline karşı
            // işleve tekrar ( işleyicinin gitmemesi için islem tipi iBelirsiz olarak belirleniyor
            ParcaSonuc.IslemTipi := iBelirsiz;

          end else if(SI.Komut.Tip = kIslemKodu) then GHataKodu := VerileriIsle(ParcaSonuc)
        end;
      end;
    end;
    // <<<<<- BU AŞAMADA KOMUT TANIMLANMIŞ
    // <<<<<- TANIMLANMAMIŞ PARÇALARININ TANIMLANMAYA ÇALIŞILDIĞI BÖLÜM
  end;
  // <<<<<- HER BİR SATIRIN PARÇA BAZLI İŞLENDİĞİ BÖLÜM

  // ->>>>> BU AŞAMADA TÜM KOMUT VE PARÇALARI YORUMLANDI
  // ->>>>> EĞER VARSA, SON İŞLEMLER
  if(GHataKodu = HATA_YOK) then
  begin

    if(SI.Komut.Tip = kBildirim) then
    begin

      {SendDebug('Bildirim: ' + SonParcaSonuc.VeriKK);
      Result := HATA_YOK;
      Exit;}

      Bildirim.SiraNo := SI.Komut.SNo;
      Bildirim.GrupNo := SI.Komut.GNo;
      Bildirim.Ad := SI.Komut.Ad;
      Bildirim.VeriTipi := ParcaSonuc.VeriTipi;
      Bildirim.VeriKK := ParcaSonuc.VeriKK;

      if(Bildirim.VeriTipi = vSayi) then
        GHataKodu := GAsm2.Matematik.Sonuc(Bildirim.VeriSD);

      GHataKodu := BildirimleriTamamla(Bildirim);
    end
    else if(SI.Komut.Tip = kDegisken) then
    begin

      GHataKodu := GAsm2.Matematik.Sonuc(ParcaSonuc.VeriSD);

      //frmAnaSayfa.mLog.Lines.Add('Değişken Değer: ' + IntToStr(ParcaSonuc.VeriSD));

      if(GHataKodu = HATA_YOK) then GHataKodu := DegiskenleriTamamla(ParcaSonuc)

      //GHataKodu := DegiskenleriTamamla(Dosya^.IslenenToplamSatir, ParcaNo, vktBosluk, '', 0)
    end
    else if(SI.Komut.Tip = kTanim) then
    begin

      //SendDebug('Tanım Değer: ' + IntToStr(SonParcaSonuc.VeriSD));
      GHataKodu := TanimlariTamamla(ParcaSonuc)
    end

    else if(SI.Komut.Tip = kIslemKodu) then
    begin

      //SendDebug('İşlem Kodu: ' + KomutListesi[SonParcaSonuc.SiraNo].Ad);

      case (SI.Komut.GNo shr 16) of

        $10: GHataKodu := Grup10Islev;
        $11: GHataKodu := Grup11Islev;
        $12: GHataKodu := Grup12Islev;
        $13: GHataKodu := Grup13Islev;
        else GHataKodu := 1;
      end;
    end;
  end;
  // <<<<<- BU AŞAMADA TÜM KOMUT VE PARÇALARI YORUMLANDI
  // <<<<<- EĞER VARSA, SON İŞLEMLER
  Result := GHataKodu;
end;

function VerileriIsle(ParcaSonuc: TParcaSonuc): Integer;
begin

  case SI.Komut.Tip of
    // kBildirim:
    kDegisken:
    begin

      //SendDebug('Değer: ' + IntToStr(ParcaSonuc.VeriSD));
      Result := DegiskenleriTamamla(ParcaSonuc);
    end;
    //kTanim: Result := TanimlariIsle(ParcaNo, ParcaSonuc);
    kIslemKodu: Result := IslemKodlariniIsle(ParcaSonuc);
  end;
end;


// her bir komutun yorumlanarak ilgili işleve yönlendirilmesini sağlar
// ParcaNo değişkeninin artırma işlemini SADECE bu işlev gerçekleştirmektedir
function KomutYorumla(ParcaSonuc: TParcaSonuc): TParcaSonuc;
var
  PS: TParcaSonuc;
  Komut: TKomut;
begin

  Result := ParcaSonuc;
  Result.ParcaTipi := ptTanimsiz;

  // iKomutYorumla çağrı değişkenine atama YAPILMAMIŞSA (ilk kez çağrı yapılacaksa)
  // burada ilk 2 verinin ne olduğu kararlaştırılmakta ve verinin devamlılığı bu karara
  // göre gelişmektedir. 1. aşamada verinin işlem kodu (opcode), 2. aşamada ise verinin
  // tanımlama olması gerekmektedir. aksi durumda işlem diğer aşamalarda kesilecektir.
  //if(iKomutYorumla = nil) then
  if(SI.Komut.Tip = kTanimsiz) then
  begin

    // komutun, komut listesinde olup olmadığı test ediliyor
    // eğer komut, komut listesinde yok ise, öndeğere sahip
    // hata işlevini çağrı değişkenine ata
    Komut := KomutBilgisiAl(ParcaSonuc.HamVeri);
    if(Komut.Tip <> kTanimsiz) then
    begin

      Result.ParcaTipi := ptKomut;
      Result.Komut.Tip := Komut.Tip;
      Result.Komut.Ad := Komut.Ad;
      Result.Komut.SNo := Komut.SNo;
      Result.Komut.GNo := Komut.GNo;
    end;
  end
  else
  begin

    PS := YazmacBilgisiAl(ParcaSonuc);
    if(PS.VeriTipi = vYazmac) then
    begin

      Result.ParcaTipi := ptVeri;
      Result.VeriTipi := PS.VeriTipi;
      Result.SiraNo := PS.SiraNo;
    end;
  end;
end;

// işlev içerisinde kullanılan karakter katarlarını yönetir
function KarakterKatarVerisiniIsle(KK: string): Integer;
begin

  {if(GVT = ktTanimsiz) then
  begin

    GVT := ktKarakterDizisi;
    GKK := KK;
    Result := HATA_YOK;
  end
  else if(GVT = ktKarakterDizisi) then
  begin

    if(GIslem = iTopla) then
    begin

      GKK := GKK + KK;
      GIslem := iBelirsiz;
      Result := HATA_YOK;
    end else Result := HATA_VERI_TIPI;
  end else Result := HATA_VERI_TIPI;}

  //GKomut := '';
  KomutUz := 0;
end;

// sayısal çoklu veriyi işleme işlevi
// etiket ve tanım sayısal veriler burada işlenecek ve sonuçları alınacak
// hesaplanan verilerin sıfırlanması diğer işlevler tarafından gerçekleştirilecektir
function SayisalVeriyiIsle(AIslemTipi: TIslemTipleri; AVeriTip: TVeriTipleri;
  ASayisalDeger: string): Integer;
var
  SayisalDeger: QWord;
begin

  if(AIslemTipi = iPAc) then
  begin

    //SendDebug('Parantez (: ' + ASayisalDeger);

    //if(Length(ASayisalDeger) > 0) then
      //Result := GAsm2.Matematik.ParantezEkle(AIslemTipi, True, StrToInt(ASayisalDeger))
    //else
    Result := GAsm2.Matematik.ParantezEkle(AIslemTipi, False, 0);
  end
  else if(AIslemTipi = iPKapat) then
  begin

    //SendDebug('Parantez ): ' + ASayisalDeger);

    {if(KomutUz > 0) then
      Result := GAsm2.Matematik.ParantezEkle(AIslemTipi, True, StrToInt(ASayisalDeger))
    else} Result := GAsm2.Matematik.ParantezEkle(AIslemTipi, False, 0);
  end
  else
  begin

    //SendDebug('Sayısal Str: ' + ASayisalDeger);

    if(Length(ASayisalDeger) > 0) then
    begin

      if(AVeriTip = vSayi) then
      begin

        if(SayiyaCevir(ASayisalDeger, SayisalDeger)) then
        begin

          GAsm2.Matematik.SayiEkle(AIslemTipi, SayisalDeger);
        end;

        Result := HATA_YOK;
      end else Result := HATA_SAYISAL_DEGER;
    end //else GAsm2.Matematik.SayiEkle(AIsleyici, False, 0);
  end;
end;

// satır verisini parçalara bölerek her bir parçayı geri döndürür
function Parcala(var SonParca: Boolean): TParcaSonuc;
var
  VD: TVeriDurum;
  C: Char;
  PS: TParcaSonuc;
begin

  Result.ParcaTipi := ptYok;

  PS.ParcaTipi := ptYok;
  PS.HamVeri := '';

  VD := vdBaslamadi;

  while (KodDiziSira <= KodDiziUzunluk) and
    (GKodDizisi[KodDiziSira] in [' ', #9]) do Inc(KodDiziSira);

  if(KodDiziSira > KodDiziUzunluk) then Exit;

  // satır sonuna gelinceye veya ilgili parça bulununcaya kadar döngüye devam et
  while (KodDiziSira <= KodDiziUzunluk) and (VD <> vdTamamlandi) do
  begin

    // karakter değerini al
    C := GKodDizisi[KodDiziSira];

    // alınacak parça değerinin hangi karakterlerden BAŞLAMAMASI gerekiyor
    if(VD = vdBaslamadi) then
    begin

      if(C = '=') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptIslem;
        PS.IslemTipi := iEsittir;
        VD := vdTamamlandi;
      end
      else if(C = ',') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptIslem;
        PS.IslemTipi := iVirgul;
        VD := vdTamamlandi;
      end
      else if(C = '[') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptIslem;
        PS.IslemTipi := iKPAc;
        VD := vdTamamlandi;
      end
      else if(C = ']') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptIslem;
        PS.IslemTipi := iKPKapat;
        VD := vdTamamlandi;
      end
      else if(C = '+') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptIslem;
        PS.IslemTipi := iTopla;
        VD := vdTamamlandi;
      end
      else if(C = '-') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptIslem;
        PS.IslemTipi := iCikart;
        VD := vdTamamlandi;
      end
      else if(C = '*') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptIslem;
        PS.IslemTipi := iCarp;
        VD := vdTamamlandi;
      end
      else if(C = '/') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptIslem;
        PS.IslemTipi := iBol;
        VD := vdTamamlandi;
      end
      else if(C = '(') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptIslem;
        PS.IslemTipi := iPAc;
        VD := vdTamamlandi;
      end
      else if(C = ')') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptIslem;
        PS.IslemTipi := iPKapat;
        VD := vdTamamlandi;
      end
      else if(C = '%') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptVeri;
        PS.VeriTipi := vMakroDeger;
        VD := vdBasladi;
      end
      else if(C = '''') then
      begin

        Inc(KodDiziSira);
        PS.ParcaTipi := ptVeri;
        PS.VeriTipi := vKarakterDizisi;
        VD := vdBasladi;
      end
      else if(C = ';') then
      begin

        Inc(KodDiziSira);
        VD := vdBasladi;
        PS.ParcaTipi := ptVeri;
        PS.VeriTipi := vAciklama;
        PS.HamVeri := C;
      end
      else
      begin

        if(C in ['0'..'9']) then
        begin

          PS.ParcaTipi := ptVeri;
          PS.VeriTipi := vSayi;
        end else PS.ParcaTipi := ptTanimsiz;

        Inc(KodDiziSira);
        VD := vdBasladi;

        PS.HamVeri := C;
      end
    end
    else if(VD = vdBasladi) then
    begin

      if(PS.ParcaTipi = ptVeri) and (PS.VeriTipi = vAciklama) then
      begin

        Inc(KodDiziSira);
        PS.HamVeri := PS.HamVeri + C;
      end
      else if(PS.ParcaTipi = ptVeri) and (PS.VeriTipi = vSayi) and
        (C = '.') then
      begin

        Inc(KodDiziSira);
        PS.HamVeri := PS.HamVeri + C;
        PS.VeriTipi := vKayanNokta;
      end
      else if(PS.ParcaTipi = ptVeri) and (C in ['''']) then
      begin

        if(Length(PS.HamVeri) > 0) then
        begin

          Inc(KodDiziSira);
          VD := vdTamamlandi;
        end;
      end
      else if(C in ['=', ',', '[', ']', '+', '-', '*', '/', '(', ')', ' ', #9]) then
      begin

        // db 'karakter verisi' türünde veriler için
        if(PS.ParcaTipi = ptVeri) and ((PS.VeriTipi = vKarakterDizisi) or (PS.VeriTipi = vAciklama)) then
        begin

          Inc(KodDiziSira);
          PS.HamVeri := PS.HamVeri + C;
        end
        else if(Length(PS.HamVeri) > 0) then
        begin

          VD := vdTamamlandi;
        end;
      end
      else
      begin

        Inc(KodDiziSira);
        PS.HamVeri := PS.HamVeri + C;
      end;
    end;
  end;

  // verinin sonuna gelindi mi?
  SonParca := (KodDiziSira > KodDiziUzunluk);

  Result := PS;
end;

end.
