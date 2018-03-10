{-------------------------------------------------------------------------------

  Dosya: incele.pas

  İşlev: her bir veri satırının içerisindeki bölümleri inceleme ve yönlendirme
    işlevlerini içerir

  Güncelleme Tarihi: 18/02/2018

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
uses genel, Dialogs, dbugintf;

function KodUret(SatirNo: Integer; KodDizisi: string): Integer;

implementation

uses atamalar, sysutils, donusum, yazmaclar, komutlar, paylasim, g00islev;

type
  TIfadeDurum = (idYok, idAciklama, idKPAc, idKPKapat);

var
  SonVeriKontrolTip: TVeriKontrolTip;     // en son işlenen veri tipini içerir
  iKomutYorumla: TAsmKomut = nil;         // assembler komutuna işaretçi (pointer)

// her bir kod satırının yönlendirildiği, incelenerek parçalara ayrıldığı,
// assembler kodlarının üretildiği ana bölüm
function KodUret(SatirNo: Integer; KodDizisi: string): Integer;
var
  Atama: TAtama;
  Komut, s: string;
  KomutUz: Integer;
  UKodDizisi, KodDizisiSira: Integer;
  C: Char;
  ParcaNo, i: Integer;
  IfadeDurum: TIfadeDurum;
  SatirSonu: Boolean;
  SayisalDeger: QWord;        // geçici deger değişkeni
  KPSayisi: Integer;          // köşeli parantezlerin takibini gerçekleştiren değişken
  TekTirnakSayisi: Integer;   // karakter katarı (string) takibini gerçekleştiren değişken
  OlcekDegerMevcut: Boolean;  // dizi içerisinde ölçek değer (scale) olup olmadığını takip eder
  SonKullanilanIsleyici: Char;
  VeriTipi: TTemelVeriTipi;  // dizi içerisinde veri tiplerini tanımlamak için

  // her bir komutun yorumlanarak ilgili işleve yönlendirilmesini sağlar
  // ParcaNo değişkeninin artırma işlemini SADECE bu işlev gerçekleştirmektedir
  function KomutYorumla(AParcaNo: Integer; AVeriKontrolTip: TVeriKontrolTip;
    AVeri1: string; AVeri2: QWord): Integer;
  var
    _VeriUzunlugu, _i: Integer;
    _AVeriKontrolTip: TVeriKontrolTip;
    _Yazmac: TYazmacDurum;
    _KomutDurum: TKomutDurum;
    _Komut: TKomut;
  begin

    _AVeriKontrolTip := AVeriKontrolTip;

    // iKomutYorumla çağrı değişkenine atama YAPILMAMIŞSA (ilk kez çağrı yapılacaksa)
    // burada ilk 2 verinin ne olduğu kararlaştırılmakta ve verinin devamlılığı bu karara
    // göre gelişmektedir. 1. aşamada verinin işlem kodu (opcode), 2. aşamada ise verinin
    // tanımlama olması gerekmektedir. aksi durumda işlem diğer aşamalarda kesilecektir.
    if(iKomutYorumla = nil) then
    begin

      // ParcaNo = 1 = İşlem Kodu, ParcaNo = 2 = Tanımlama
      // İşlem Kodu 1. aşamada, Tanımlama 2. aşamada gerçekleşir
      if(ParcaNo < 3) then
      begin

        // komutun sıra değeri alınarak var olup olmadığı test ediliyor
        _KomutDurum := KomutBilgisiAl(AVeri1);

        // eğer komut, komut listesinde yok ise, öndeğere sahip
        // hata işlevini çağrı değişkenine ata
        if(_KomutDurum.SiraNo = -1) then
        begin

          //if(AVeriKontrolTip = vktEsittir) then SendDebug('ParcaNo: ' + IntToStr(ParcaNo));
          //SendDebug('GTanimlanacakVeri111');

          // 1. aşamada ilgili komutun bulunamaması durumunda, 2. aşamada
          // komutun bir değişken veya tanım olasılığına karşı veri saklanıyor
          if(ParcaNo = 1) then
          begin

            { TODO : boşluk olmaksızın açıklama gelmesi durumunda veri buraya
              gelmektedir. Her ne kadar sonuç olarak bir problem olmasa da çözümlenmesi
              gerekmektedir. }
            //SendDebug('GTanimlanacakVeri: ' + AVeri1);
            GTanimlanacakVeri := AVeri1;
            Result := HATA_YOK
          end
          else if(ParcaNo = 2) and (AVeriKontrolTip = vktEsittir) then
          begin

            GAnaBolumVeriTipi := abvtTanim;
            SonVeriKontrolTip := vktIlk;

            iKomutYorumla := @Grup00Islev;
            Result := iKomutYorumla(SatirNo, AParcaNo - 1, SonVeriKontrolTip,
              GTanimlanacakVeri, 0);

            SonVeriKontrolTip := vktEsittir;
            Result := iKomutYorumla(SatirNo, AParcaNo, SonVeriKontrolTip, '', 0);
          end
          else
          begin

            iKomutYorumla := @KomutHata;
            GHataAciklama := GTanimlanacakVeri;
            Result := HATA_BILINMEYEN_KOMUT;
          end;
        end
        else
        begin

          // işlem kodu işlevine ilk çağrı yapılıyor
          if(_KomutDurum.ABVT = abvtIslemKodu) then
          begin

            GAnaBolumVeriTipi := abvtIslemKodu;
            SonVeriKontrolTip := vktIlk;
            iKomutYorumla := KomutListe[_KomutDurum.SiraNo];
            Result := iKomutYorumla(SatirNo, AParcaNo, vktIlk, AVeri1, _KomutDurum.SiraNo);
          end
          // bildirim işlevine ilk çağrı yapılıyor
          else if(_KomutDurum.ABVT = abvtBildirim) then
          begin

            //SendDebug('Bildirim: ' + IntToStr(_KomutDurum.SiraNo));
            GAnaBolumVeriTipi := abvtBildirim;
            SonVeriKontrolTip := vktIlk;
            iKomutYorumla := KomutListe[_KomutDurum.SiraNo];
            Result := iKomutYorumla(SatirNo, AParcaNo, vktIlk, AVeri1, _KomutDurum.SiraNo);
            //SendDebug('Bildirim2: ' + AVeri1);

            // boşluktan önce eşittir verisinin gelmesi durumunda,
            // veri ilgili işleve gönderiliyor
            if(Result = HATA_YOK) and (AVeriKontrolTip = vktEsittir) then
            begin

              SonVeriKontrolTip := vktEsittir;
              Result := iKomutYorumla(SatirNo, AParcaNo, SonVeriKontrolTip, '', 0);
            end;
          end
          // değişken işlevine ilk çağrı yapılıyor
          else
          begin

            GAnaBolumVeriTipi := abvtDegisken;
            SonVeriKontrolTip := vktIlk;

            _Komut := KomutListesi[_KomutDurum.SiraNo];
            case _Komut.GrupNo of
              GRUP02_DB: _VeriUzunlugu := 1;
              GRUP02_DW: _VeriUzunlugu := 2;
              GRUP02_DD: _VeriUzunlugu := 4;
              GRUP02_DQ: _VeriUzunlugu := 8;
            end;

            iKomutYorumla := KomutListe[_KomutDurum.SiraNo];

            Result := HATA_YOK;

            // 1. tanım etiketini listeye ekle
            if(ParcaNo = 2) then Result := GAsm2.AtamaListesi.Ekle(SatirNo, GTanimlanacakVeri,
              etEtiket, MevcutBellekAdresi, tvtTanimsiz, _VeriUzunlugu, '', 0);

            // 2. hata olmaması durumunda ilgili işleve çağrıda bulun
            if(Result = HATA_YOK) then
              Result := iKomutYorumla(SatirNo, AParcaNo, vktIlk, '', _KomutDurum.SiraNo);
          end;
        end;
      end else Result := HATA_BILINMEYEN_KOMUT;

      Inc(ParcaNo);
    end
    // veri herhangi bir kontrole tabi tutulmadan ilgili işleve yönlendiriliyor
    else if(_AVeriKontrolTip = vktKarakterDizisi) then
    begin

      SonVeriKontrolTip := vktKarakterDizisi;
      Result := iKomutYorumla(SatirNo, AParcaNo, SonVeriKontrolTip, AVeri1, 0);
    end
    // değişken verisinin yazmaç, işlem kodu ve diğer tanımlama olup olmadığının
    // kontrol edilmesi için işleme alındığı bölüm
    else if(_AVeriKontrolTip = vktDegisken) then
    begin

      if(GAnaBolumVeriTipi = abvtTanim) then
      begin

        SonVeriKontrolTip := vktDegisken;
        Result := iKomutYorumla(SatirNo, AParcaNo, SonVeriKontrolTip, AVeri1, 0)
      end
      else
      begin

        _Yazmac := YazmacBilgisiAl(AVeri1);
        if(_Yazmac.Sonuc > -1) then
        begin

          _i := _Yazmac.Sonuc;
        end;

        SonVeriKontrolTip := vktYazmac;
        Result := iKomutYorumla(SatirNo, AParcaNo, SonVeriKontrolTip, '', _i);
      end;
    end
    // ölçek ve sayı verilerinin işlenmesi
    else if(_AVeriKontrolTip = vktOlcek) or (_AVeriKontrolTip = vktSayi) then
    begin

      SonVeriKontrolTip := _AVeriKontrolTip;
      Result := iKomutYorumla(SatirNo, AParcaNo, SonVeriKontrolTip, '', AVeri2);
    end
    else if(_AVeriKontrolTip = vktArti) or (_AVeriKontrolTip = vktKPAc) or
      (_AVeriKontrolTip = vktKPKapat) or (_AVeriKontrolTip = vktVirgul) or
      (_AVeriKontrolTip = vktEsittir) then
    begin

      // öntanımlı değer
      Result := HATA_YOK;

      // ilgili işleyicilerden önce bir veri var ise değerlendir
      if(Length(AVeri1) > 0) then
      begin

        _Yazmac := YazmacBilgisiAl(AVeri1);
        if(_Yazmac.Sonuc > -1) then
        begin

          _i := _Yazmac.Sonuc;
          SonVeriKontrolTip := vktYazmac;
          Result := iKomutYorumla(SatirNo, AParcaNo, SonVeriKontrolTip, '', _i);
        end;
      end;

      // işleyici değerini işleve yönlendir.
      { TODO : (burada virgül kontrolü tekrar ele alınmalıdır) }
      if(Result = HATA_YOK) then
      begin

        // tanım işleminde = verisinin gönderilmesi için
        if(_AVeriKontrolTip = vktEsittir) then
        begin

          SonVeriKontrolTip := vktEsittir;
          Result := iKomutYorumla(SatirNo, AParcaNo, SonVeriKontrolTip, '', 0);
        end
        else
        begin

          SonVeriKontrolTip := _AVeriKontrolTip;
          Result := iKomutYorumla(SatirNo, AParcaNo, SonVeriKontrolTip, AVeri1, _i);
        end;
      end;

      // virgül olması durumunda ParcaNo değişkenini 1 artır
      if(GAnaBolumVeriTipi = abvtIslemKodu) and (_AVeriKontrolTip = vktVirgul) then
        Inc(ParcaNo);
    end
    else if(_AVeriKontrolTip = vktSon) then
    begin

      SonVeriKontrolTip := vktSon;
      Result := iKomutYorumla(SatirNo, 0, SonVeriKontrolTip, '', 0);
    end;

    // işlenen değişkenlerin ilk değer atamalarını gerçekleştir
    Komut := '';
    KomutUz := 0;
    VeriTipi := tvtTanimsiz;
  end;

  // sayısal çoklu veriyi işleme işlevi
  // etiket ve tanım sayısal veriler burada işlenecek ve sonuçları alınacak
  // hesaplanan verilerin sıfırlanması diğer işlevler tarafından gerçekleştirilecektir
  function SayisalVeriyiIsle(AIsleyici: string): Integer;
  var
    _Atama: TAtama;
  begin

    if(AIsleyici = '(') then
    begin

      if(KomutUz > 0) then
        Result := GAsm2.Matematik.ParantezEkle(AIsleyici[1], True, StrToInt(Komut))
      else Result := GAsm2.Matematik.ParantezEkle(AIsleyici[1], False, 0);
    end
    else if(AIsleyici = ')') then
    begin

      if(KomutUz > 0) then
        Result := GAsm2.Matematik.ParantezEkle(AIsleyici[1], True, StrToInt(Komut))
      else Result := GAsm2.Matematik.ParantezEkle(AIsleyici[1], False, 0);
    end
    else
    begin

      if(KomutUz > 0) then
      begin

        if(VeriTipi = tvtSayi) then
        begin

          if(SayiyaCevir(Komut, SayisalDeger)) then
          begin

            if(Length(AIsleyici) > 0) then
            begin

              //GAsm2.Matematik.SayiEkle(SonKullanilanIsleyici, True, SayisalDeger);
              GAsm2.Matematik.SayiEkle(AIsleyici[1], True, SayisalDeger);
              SonKullanilanIsleyici := AIsleyici[1];
            end
            else
            begin

              GAsm2.Matematik.SayiEkle('+', True, SayisalDeger);
              //GAsm2.Matematik.SayiEkle(SonKullanilanIsleyici, True, SayisalDeger);
              SonKullanilanIsleyici := '+';     // geçici değer
            end;

            Result := HATA_YOK;
          end else Result := HATA_SAYISAL_DEGER;
        end
        // aksi durumda veri bir değişkendir
        // bilgi: karaktersel veriler ana bölümde ele alınmaktadır
        else // if(VeriTipi = tvtDiger) then
        begin

          _Atama := GAsm2.AtamaListesi.Bul(Komut);
          if(_Atama = nil) then
          begin

            //SendDebug('Bilinmeyen Etiket: ' + Komut);

            // Sayısal değerin öndeğer 0 olarak belirlenmesi bölme işleminde
            // problem oluşturabilir
            SayisalDeger := $FFFFFF0;    // etiketin bulunamaması durumunda öndeğer alacak
            GEtiketHatasiMevcut := True;
            Inc(GEtiketHataSayisi);
            SendDebug('Satır No: ' + IntToStr(SatirNo));

            if(Length(AIsleyici) > 0) then
            begin

              //GAsm2.Matematik.SayiEkle(SonKullanilanIsleyici, True, SayisalDeger);
              GAsm2.Matematik.SayiEkle(AIsleyici[1], True, SayisalDeger);
              SonKullanilanIsleyici := AIsleyici[1];
            end
            else
            begin

              //GAsm2.Matematik.SayiEkle(SonKullanilanIsleyici, True, SayisalDeger);
              GAsm2.Matematik.SayiEkle('+', True, SayisalDeger);
              SonKullanilanIsleyici := '+';     // geçici değer
            end;

            //Result := HATA_ETIKET_TANIMLANMAMIS;
            Result := HATA_YOK;
          end
          else
          begin

            //SendDebug('İşleyici: ' + AIsleyici);
            //SendDebug('İşleyici Değişken: ' + Komut);
            //SendDebug('SonKullanilanIsleyici: ' + SonKullanilanIsleyici);

            //if(_Degisken.VeriTipi = tvtSayi) or (_Degisken.VeriTipi = tvtDiger) or
//              (_Degisken.VeriTipi = tvtTanimsiz) then
            //begin

              if(_Atama.Tip = etEtiket) then
                SayisalDeger := _Atama.BellekAdresi
              else //if(_Degisken.VeriTipi = tvtSayi) then
                SayisalDeger := _Atama.iDeger;
              //else if(_Degisken.VeriTipi = tvtDiger) then   // karakterdizisi
                //SayisalDeger := _Degisken.BellekAdresi
            //end;

            //SendDebug('Etiket SayisalDeger: ' + IntToStr(SayisalDeger));

            if(Length(AIsleyici) > 0) then
            begin

              //GAsm2.Matematik.SayiEkle(SonKullanilanIsleyici, True, SayisalDeger);
              GAsm2.Matematik.SayiEkle(AIsleyici[1], True, SayisalDeger);
              SonKullanilanIsleyici := AIsleyici[1];
            end
            else
            begin

              //GAsm2.Matematik.SayiEkle(SonKullanilanIsleyici, True, SayisalDeger);
              GAsm2.Matematik.SayiEkle('+', True, SayisalDeger);
              SonKullanilanIsleyici := '+';     // geçici değer
            end;

            // gerekli olup olmadığı incelensin
            GAsm2.Matematik.Sonuc(SayisalDeger);
            //SendDebug('Sonuç: ' + IntToStr(SayisalDeger));
            //SendDebug('İşleyici Değişken: ' + Komut);

            Result := HATA_YOK;
          end;
        end;  //?? { TODO : karaktersel veri tipi buraya eklenecek }
      end //else GAsm2.Matematik.SayiEkle(AIsleyici, False, 0);
    end;

    // işlenen değişkenlerin ilk değer atamalarını gerçekleştir
    Komut := '';
    KomutUz := 0;
    VeriTipi := tvtTanimsiz;
  end;
begin

  // ilk değer atamaları

  UKodDizisi := Length(KodDizisi);

  SonVeriKontrolTip := vktYok;
  ParcaNo := 1;
  KodDizisiSira := 1;
  GHataKodu := HATA_YOK;
  KPSayisi := 0;
  TekTirnakSayisi := 0;
  OlcekDegerMevcut := False;
  SatirSonu := False;

  VeriTipi := tvtTanimsiz;

  Komut := '';
  KomutUz := 0;
  SonKullanilanIsleyici := '+';

  GEtiket := '';
  GTanimlanacakVeri := '';

  IfadeDurum := idYok;

  iKomutYorumla := nil;

  GAsm2.Matematik.Temizle;      // mevcut matematisel işlemleri temizle

  GEtiketHatasiMevcut := False;

  repeat

    // karakter değerini al
    C := KodDizisi[KodDizisiSira];

    // satırın sonuna gelinmiş mi? kontrol et!
    Inc(KodDizisiSira);
    if(KodDizisiSira > UKodDizisi) then SatirSonu := True;

    // satır içeriğini kontrol edecek kontrol değer kahramanları
    if(IfadeDurum <> idAciklama) and
      (C in [' ', '''', ',', ':', ';', '=', '(', ')', '[', ']', '+', '-',
        '*', '/', #9]) then
    begin

      if(C = ',') then
      begin

        if(GAnaBolumVeriTipi = abvtIslemKodu) then
        begin

          if(ParcaNo = 1) then
          begin

            //SendDebug('Virgül: ' + Komut);
            GHataKodu := HATA_ISL_KULLANIM;
          end else GHataKodu := KomutYorumla(ParcaNo, vktVirgul, Komut, 0);
        end
        else if(GAnaBolumVeriTipi = abvtDegisken) then
        begin

          // tanım işleminde virgül öncesi veri var ise ...
          if(KomutUz > 0) then
          begin

            // eğer veri sayısal bir değer ise...
            if(VeriTipi = tvtSayi) then
            begin

              GHataKodu := SayisalVeriyiIsle('');
              GHataKodu := GAsm2.Matematik.Sonuc(SayisalDeger);
              //SendDebug('DD Virgül: ' + Komut);

              GHataKodu := iKomutYorumla(SatirNo, ParcaNo, vktSayi,
                '', SayisalDeger);

              GHataKodu := iKomutYorumla(SatirNo, ParcaNo, vktVirgul,
                '', 0);

              GAsm2.Matematik.Temizle;

              //if(SayiyaCevir(Komut, SayisalDeger)) then
              //begin

                //GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger);
//                if(GHataKodu = HATA_YOK) then
//                  GHataKodu := KomutYorumla(ParcaNo, vktVirgul, '', 0)
              //end else GHataKodu := HATA_SAYISAL_DEGER;
            end
            else
            begin

              {Atama := GAsm2.AtamaListesi.Bul(Komut);
              if(Atama <> nil) then
              begin

                if(Atama.VeriTipi = tvtSayi) then
                begin

                  SayisalDeger := Atama.iDeger;
                  GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger);

                  if(GHataKodu = HATA_YOK) then
                    GHataKodu := KomutYorumla(ParcaNo, vktVirgul, '', 0)
                end; // ??
              end
              else
              begin

                GEtiketHatasiMevcut := True;
                Inc(GEtiketHataSayisi);
                SendDebug('Satır No: ' + IntToStr(SatirNo));

                //SendDebug('Değişken1 Ad: ' + Komut);
                SayisalDeger := $FFFFFF0;
                GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger);

                if(GHataKodu = HATA_YOK) then
                  GHataKodu := KomutYorumla(ParcaNo, vktVirgul, '', 0)

                //GHataKodu := HATA_BILINMEYEN_HATA; SendDebug('Test: ' + Komut); end;
              end;}

              GHataKodu := SayisalVeriyiIsle('');

              if(GHataKodu = HATA_YOK) then
              begin

                GHataKodu := GAsm2.Matematik.Sonuc(SayisalDeger);

                if(GHataKodu = HATA_YOK) then
                  GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger);

                // tüm satırın işlendiğine dair sonlandırma mesajı gönder
                if(GHataKodu = HATA_YOK) then GHataKodu := KomutYorumla(ParcaNo, vktVirgul, '', 0);

                GAsm2.Matematik.Temizle;
              end //else GHataKodu := HATA_YOK;

            end;
          end
          else
          begin

            GHataKodu := KomutYorumla(ParcaNo, vktVirgul, '', 0)
          end;
        end;
      end
      else if(C = '=') then
      begin

        // bu veri tipi geçici olarak eklendi. daha sonra iptal edilecek - 28022018
        VeriTipi := tvtTanimsiz;

        // abvtBildirim ve abvtTanim işlevlerinin bu işleyiciyi yorumlamasını sağla
        GHataKodu := KomutYorumla(ParcaNo, vktEsittir, Komut, 0);
      end
      else if(C = '[') or (C = ']') then
      begin

        // bu işleyiciler SADECE 2 ve sonraki aşamalarda kullanılabilir
        if(ParcaNo = 1) then
        begin

          GHataKodu := HATA_ISL_KULLANIM;
        end
        else
        begin

          case C of
            //',': GHataKodu := KomutYorumla(ParcaNo, vktVirgul, Komut, 0);
            '[':
            begin

              Inc(KPSayisi);
              GHataKodu := KomutYorumla(ParcaNo, vktKPAc, Komut, 0);
            end;
            ']':
            begin

              // ölçek değerin olması durumunda işleve ölçek değer yönlendiriliyor
              if(OlcekDegerMevcut) then
              begin

                if(KomutUz > 0) then
                begin

                  i := StrToInt(Komut);
                  GHataKodu := KomutYorumla(ParcaNo, vktOlcek, '', i);
                end else GHataKodu := HATA_OLCEK_DEGER_GEREKLI;

                OlcekDegerMevcut := False;
              end;

              // eğer varsa sayısal sabit değer işleve yönlendiriliyor
              if(GHataKodu = HATA_YOK) then
              begin
                // satır sonuna gelinmesi durumunda, işlenen değer ilgili
                // komuta yönlendirilmektedir
                if(VeriTipi = tvtSayi) then
                begin

                  if(KomutUz > 0) then GHataKodu := SayisalVeriyiIsle('');
                  if(GHataKodu = HATA_YOK) then
                  begin

                    GHataKodu := GAsm2.Matematik.Sonuc(SayisalDeger);
                    if(GHataKodu = HATA_YOK) then
                    begin

                      VeriTipi := tvtTanimsiz;
                      GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger);
                    end;
                  end;
                end;

                if(GHataKodu = HATA_YOK) then
                begin

                  Dec(KPSayisi);
                  GHataKodu := KomutYorumla(ParcaNo, vktKPKapat, Komut, 0);
                end;
              end;
            end;
          end;
        end;
      end
      // tek tırnak kontrol işlemi
      else if(C = '''') {and (GAnaBolumVeriTipi = abvtTanim) idi} then
      begin

        if(TekTirnakSayisi = 0) then
        begin

          if(KomutUz = 0) then
          begin

            VeriTipi := tvtKarakterDizisi;
            Inc(TekTirnakSayisi);
          end;
        end
        else if(TekTirnakSayisi = 1) then
        begin

          if(KomutUz > 0) then
          begin

            GHataKodu := KomutYorumla(ParcaNo, vktKarakterDizisi, Komut, 0);
            TekTirnakSayisi := 0;
            Komut := '';
            KomutUz := 0;
            VeriTipi := tvtTanimsiz;

            // vktSon bir burada bir de aşağıda tanımlanmıştır. ortak noktada birleşebilir
            // tüm satırın işlendiğine dair sonlandırma mesajı gönder
            if(GHataKodu = HATA_YOK) then GHataKodu := KomutYorumla(ParcaNo, vktSon, '', 0);
          end;
        end;
      end
      // etiket kontrol işlemi
      else if(C = ':') and (ParcaNo = 1) then
      begin

        if(KomutUz > 0) then
        begin

          if(ikabEtiket in GIslemKodAnaBolum) then

            GHataKodu := HATA_BIRDEN_FAZLA_ETIKET
          else
          begin

            GIslemKodAnaBolum += [ikabEtiket];

            //SendDebug('Bellek Adresi1: ' + IntToStr(GMevcutBellekAdresi));

            // etiketin mevcut olup olmadığını gerçekleştir
            { TODO : Veri tip uzunluğunun gerekliliği kontrol edilecek }
            GHataKodu := GAsm2.AtamaListesi.Ekle(SatirNo, Komut, etEtiket,
              MevcutBellekAdresi, tvtSayi, 0, '', 0);

            //SendDebug('Bellek Adresi2: ' + IntToStr(GMevcutBellekAdresi));

            if(GHataKodu = HATA_YOK) then
            begin

              GEtiket := Komut;
              Komut := '';
              KomutUz := 0;
            end else GHataAciklama := Komut;    // hata olması durumunda
          end;
        end;
      end
      // boşluk karakteri SADECE işlem kodunu almak için kullanılıyor
      else if(C = ' ') or (C = #9) then
      begin

        if(GAnaBolumVeriTipi = abvtTanim) and (KomutUz > 0) then
        begin

          GHataKodu := SayisalVeriyiIsle('');
        end
        else if((GAnaBolumVeriTipi = abvtBelirsiz) or (GAnaBolumVeriTipi = abvtBildirim))
          and (KomutUz > 0) then

          GHataKodu := KomutYorumla(ParcaNo, vktBosluk, Komut, 0)
        else if(GAnaBolumVeriTipi = abvtDegisken) and (TekTirnakSayisi > 0) then
        begin

          Komut += C;
          Inc(KomutUz);
        end;
      end
      // açıklama durumunun haricinde tüm bu işleyicilerin çalışma durumu
      else if((IfadeDurum <> idAciklama) and ((C = '(') or (C = ')') or (C = '+') or
        (C = '-') or (C = '*') or (C = '/'))) then
      begin

        //SendDebug('DD ++: ' + Komut);

        // ölçek verisinin işlendiği bölüm
        if(KPSayisi > 0) and (C = '*') and (KomutUz > 0) then
        begin

          GHataKodu := KomutYorumla(ParcaNo, vktDegisken, Komut, 0);
          if(SonVeriKontrolTip = vktYazmac) then OlcekDegerMevcut := True;
        end
        else
        begin

          // ölçek işleyici (*) mevcut iken değer mevcut değil ise ...
          if(OlcekDegerMevcut) and (KomutUz = 0) then
          begin

            GHataKodu := HATA_OLCEK_DEGER_GEREKLI;
          end
          else if(OlcekDegerMevcut) and (KomutUz > 0) then
          begin

            // ölçek değerinden sonra bir işleyici (op) gelecekse bu işleyicinin
            // + veya - (işaretli veya işaretsiz) sayısal değer veya + yazmaç olması gerekmektedir
            if not((C = '+') or (C = '-')) then

              GHataKodu := HATA_ISL_KULLANIM
            else
            begin

              i := StrToInt(Komut);
              GHataKodu := KomutYorumla(ParcaNo, vktOlcek, Komut, i);
              OlcekDegerMevcut := False;
              SonKullanilanIsleyici := C;
            end;
          end
          else
          begin

            // açıklama haline getirilen satırlar bağlam noktasında anlamsızdır
            if(VeriTipi = tvtSayi) or (VeriTipi = tvtDiger) then
            begin

              //SendDebug('DD +: ' + Komut);
              GHataKodu := SayisalVeriyiIsle(C);
            end
            else
            begin

              Komut += C;
              Inc(KomutUz);
            end;
            {else
            begin

              if(KomutUz > 0) then
              begin

                GHataKodu := KomutYorumla(ParcaNo, vktDegisken, Komut, 0);
                if(GHataKodu = HATA_YOK) then
                  GHataKodu := KomutYorumla(ParcaNo, vktArti, '', 0);
              end;
            end; } // bu kısım SayisalVeriyiIsle kısmında değerlendirşlmektedir
          end;
        end;
      end
      // açıklama kontrolü
      else if(C = ';') and not(IfadeDurum = idAciklama) then
      begin

        // açıklama satırından önce sürmekte olan bir komut var ise
        // mevcut komutun yorumlanmasını sağla
        if(KomutUz > 0) then
        begin

          GHataKodu := KomutYorumla(ParcaNo, vktDegisken, Komut, 0);
        end;

        // eğer hata yok ise ifade durumunu AÇIKLAMA olarak belirle
        if(GHataKodu = HATA_YOK) then
        begin

          GIslemKodAnaBolum += [ikabAciklama];
          GAciklama := '';
          IfadeDurum := idAciklama;
        end;
      end;
    end
    else
    begin

      if(IfadeDurum = idAciklama) then

        GAciklama := GAciklama + C
      else
      begin

        if(KomutUz = 0) and (TekTirnakSayisi = 0) then
        begin

          // 3 veri tipinden ikisi burada kontrol ediliyor
          // diğer bir tanesi ise ''' olarak yukarıda
          if(VeriTipi = tvtTanimsiz) then
          begin

            if(C in ['0'..'9']) then

              VeriTipi := tvtSayi
            else VeriTipi := tvtDiger;
          end;
        end;

        Komut += C;
        Inc(KomutUz);
      end;
    end;

    if(SatirSonu) then
    begin

      if(KomutUz > 0) then
      begin

        // tek kelimelik komut tiplerinin olması durumunda. cld, cli gibi
        if(GAnaBolumVeriTipi = abvtBelirsiz) then
        begin

          GHataKodu := KomutYorumla(ParcaNo, vktKarakterDizisi, Komut, 0);

          // tüm satırın işlendiğine dair sonlandırma mesajı gönder
          if(GHataKodu = HATA_YOK) then GHataKodu := KomutYorumla(ParcaNo, vktSon, '', 0);
        end
        else
        begin

          if(VeriTipi = tvtKarakterDizisi) then
          begin

            GHataKodu := KomutYorumla(ParcaNo, vktKarakterDizisi, Komut, 0);
          end
          else if(VeriTipi = tvtSayi) or (VeriTipi = tvtDiger) then
          begin

            // SayisalVeriyiIsle işlevinden dönen değer SADECE bu işlevi bilgilendirmek
            // içindir. SayisalVeriyiIsle işlevi her zaman öndeğerli değerleri işler
            GHataKodu := SayisalVeriyiIsle('');

            //SendDebug('Etiket Kodu: ' + Komut);
            if(GHataKodu = HATA_YOK) then
            begin

              GHataKodu := GAsm2.Matematik.Sonuc(SayisalDeger);

              if(GHataKodu = HATA_YOK) then
                GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger);

              // tüm satırın işlendiğine dair sonlandırma mesajı gönder
              if(GHataKodu = HATA_YOK) then GHataKodu := KomutYorumla(ParcaNo, vktSon, '', 0);
            end //else GHataKodu := HATA_YOK;
          end
          {else if(VeriTipi = tvtDiger) then
          begin

            Etiket := GAsm2.Etiketler.Bul(Komut);
            if(Etiket <> nil) then
            begin

              if(Etiket.VeriTipi = tvtSayi) then
              begin

                SayisalDeger := Etiket.iDeger;
                GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger)
              end
              {else
              begin

                SayisalDeger := Etiket.BellekAdresi;
                GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger)
              end}
            end; // else begin GHataKodu := HATA_BILINMEYEN_HATA; SendDebug('Test2: ' + Komut); end;
          end;}
        end;
      end;
    end;

  // satır sonuna gelinceye veya hata oluncaya kadar döngüye devam et!
  until (SatirSonu) or (GHataKodu > HATA_YOK);

  Result := GHataKodu;
end;

end.
