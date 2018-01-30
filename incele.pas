{-------------------------------------------------------------------------------

  Dosya: incele.pas

  İşlev: her bir veri satırının içerisindeki bölümleri inceleme ve yönlendirme
    işlevlerini içerir

  Güncelleme Tarihi: 30/01/2018

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
uses genel, Dialogs;

type
  TIfadeDurum = (idYok, idAciklama, idEtiket, idKPAc, idKPKapat);

function KodUret(KodDizisi: string): Integer;

implementation

uses sysutils, yorumla, anasayfa, sayilar;

var
  iKomutYorumla: TAsmKomut = nil;     // assembler komutuna işaretçi (pointer)

// her bir kod satırının yönlendirildiği, incelenerek parçalara ayrıldığı,
// assembler kodlarının üretildiği ana bölüm
function KodUret(KodDizisi: string): Integer;
var
  Komut: string;
  KomutUz: Integer;
  UKodDizisi, KodDizisiSira: Integer;
  C: Char;
  ParcaNo, i: Integer;
  IfadeDurum: TIfadeDurum;
  SatirSonu: Boolean;
  EtiketTamam: Boolean;       // üstüste etiket değeri girilmesini engellemek için
  SayisalDeger: Integer;      // geçici deger değişkeni
  KPSayisi: Integer;          // köşeli parantezlerin takibini gerçekleştiren değişken
  SayisalDegerMevcut,         // dizi içerisinde sayısal değer olup olmadığını takip eder
  SayisalIslemYapiliyor,
  OlcekDegerMevcut: Boolean;  // dizi içerisinde ölçek değer (scale) olup olmadığını takip eder
  SonKullanilanIsleyici: Char;

  // her bir komutun yorumlanarak ilgili işleve yönlendirilmesini sağlar
  // ParcaNo değişkeninin artırma işlemini SADECE bu işlev gerçekleştirmektedir
  function KomutYorumla(AParcaNo: Integer; AVeriTipi: TVeriTipi; AVeri1: string;
    AVeri2: Integer): Integer;
  var
    _i: Integer;
    _AVeriTipi: TVeriTipi;
    _Yazmac: TYazmacDurum;
    _KomutDurum: TKomutDurum;
  begin

    _AVeriTipi := AVeriTipi;

    // iKomutYorumla çağrı değişkenine atama YAPILMAMIŞSA (ilk kez çağrı yapılacaksa)
    if(iKomutYorumla = nil) then
    begin

      // komutun sıra değeri alınarak var olup olmadığı test ediliyor
      _KomutDurum := KomutBilgisiAl(AVeri1);

      // eğer komut, komut listesinde yok ise, öndeğere sahip
      // hata işlevini çağrı değişkenine ata
      if(_KomutDurum.Sonuc = -1) then

        iKomutYorumla := @KomutHata
      else
      begin

        iKomutYorumla := KomutListe[_KomutDurum.Sonuc];
      end;

      GSonIslenenVeriTipi := vtIslemKodu;
      Result := iKomutYorumla(AParcaNo, GSonIslenenVeriTipi, AVeri1, _KomutDurum.Sonuc);
      Inc(ParcaNo);
    end
    // vtKarakterDizisi tipinde olan verinin incelenmesi
    else if(_AVeriTipi = vtKarakterDizisi) then
    begin

      _Yazmac := YazmacBilgisiAl(AVeri1);
      if(_Yazmac.Sonuc > -1) then
      begin

        _i := _Yazmac.Sonuc;
      end;

      GSonIslenenVeriTipi := vtYazmac;
      Result := iKomutYorumla(AParcaNo, GSonIslenenVeriTipi, '', _i);
    end
    // ölçek ve sayı verilerinin işlenmesi
    else if(_AVeriTipi = vtOlcek) or (_AVeriTipi = vtSayi) then
    begin

      GSonIslenenVeriTipi := _AVeriTipi;
      Result := iKomutYorumla(AParcaNo, GSonIslenenVeriTipi, '', AVeri2);
    end
    else if(_AVeriTipi = vtArti) or (_AVeriTipi = vtKPAc) or (_AVeriTipi = vtKPKapat) or
      (_AVeriTipi = vtVirgul) then
    begin

      // öntanımlı değer
      Result := 0;

      // ilgili işleyicilerden önce bir veri var ise değerlendir
      if(Length(AVeri1) > 0) then
      begin

        _Yazmac := YazmacBilgisiAl(AVeri1);
        if(_Yazmac.Sonuc > -1) then
        begin

          _i := _Yazmac.Sonuc;
          GSonIslenenVeriTipi := vtYazmac;
          Result := iKomutYorumla(AParcaNo, GSonIslenenVeriTipi, '', _i);
        end;
      end;

      // işleyici değerini işleve yönlendir
      if(Result = 0) then
      begin

        GSonIslenenVeriTipi := _AVeriTipi;
        Result := iKomutYorumla(AParcaNo, GSonIslenenVeriTipi, AVeri1, _i);
      end;

      // virgül olması durumunda ParcaNo değişkenini 1 artır
      if(_AVeriTipi = vtVirgul) then Inc(ParcaNo);
    end
    else if(_AVeriTipi = vtSon) then
    begin

      GSonIslenenVeriTipi := vtSon;
      Result := iKomutYorumla(0, GSonIslenenVeriTipi, '', 0);
    end;

    // işlenen değişkenlerin ilk değer atamalarını gerçekleştir
    Komut := '';
    KomutUz := 0;
  end;

  // sayısal çoklu veriyi işleme işlevi
  procedure SayisalVeriyiIsle(AIsleyici: string);
  begin

    if(AIsleyici = '(') then
    begin

      if(KomutUz > 0) then
        GHataKodu := GMatematik.ParantezEkle(AIsleyici[1], True, StrToInt(Komut))
      else GHataKodu := GMatematik.ParantezEkle(AIsleyici[1], False, 0);
    end
    else if(AIsleyici = ')') then
    begin

      if(KomutUz > 0) then
        GMatematik.ParantezEkle(AIsleyici[1], True, StrToInt(Komut))
      else GMatematik.ParantezEkle(AIsleyici[1], False, 0);
    end
    else
    begin

      if(KomutUz > 0) then
      begin

        // 1. sayıya çevirme işlemi şu aşamada ondalık sayılarla ilgilidir
        // 2. ikili, onaltılı sayı sistemlerinden başka bellek etiket değerleri
        //   de sayısal ifadelerin içerisinde yer alacaktır
        if(SayiyaCevir(Komut, SayisalDeger)) then
        begin

          if(Length(AIsleyici) > 0) then
          begin

            GMatematik.SayiEkle(SonKullanilanIsleyici, True, SayisalDeger);
            SonKullanilanIsleyici := AIsleyici[1];
          end
          else
          begin

            GMatematik.SayiEkle(SonKullanilanIsleyici, True, SayisalDeger);
            SonKullanilanIsleyici := '+';     // geçici değer
          end;
        end;
      end else GMatematik.SayiEkle(AIsleyici, False, 0);
    end;

    // işlenen değişkenlerin ilk değer atamalarını gerçekleştir
    Komut := '';
    KomutUz := 0;
  end;
begin

  // ilk değer atamaları

  UKodDizisi := Length(KodDizisi);

  GSonIslenenVeriTipi := vtYok;
  ParcaNo := 1;
  KodDizisiSira := 1;
  GHataKodu := HATA_YOK;
  KPSayisi := 0;
  SayisalDegerMevcut := False;
  SayisalIslemYapiliyor := False;
  OlcekDegerMevcut := False;
  SatirSonu := False;

  Komut := '';
  KomutUz := 0;
  SonKullanilanIsleyici := '+';

  EtiketTamam := False;
  GEtiket := '';

  GKomutTipi := ktBilinmiyor;
  IfadeDurum := idYok;

  iKomutYorumla := nil;

  GMatematik.Temizle;     // mevcut matematisel işlemleri temizle

  repeat

    // karakter değerini al
    C := KodDizisi[KodDizisiSira];

    // satırın sonuna gelinmiş mi? kontrol et!
    Inc(KodDizisiSira);
    if(KodDizisiSira > UKodDizisi) then SatirSonu := True;

    // satır içeriğini kontrol edecek kontrol değer kahramanları
    if(IfadeDurum <> idAciklama) and
      (C in [' ', ':', ',', '[', '(', ')', ']', ';', '+', '-', '*', '/']) then
    begin

      if(C = ',') or (C = '[') or (C = ']') then
      begin

        // bu işleyiciler SADECE 2 ve sonraki aşamalarda kullanılabilir
        if(ParcaNo = 1) then
        begin

          GHataKodu := HATA_HATALI_ISL_KULLANIM;
        end
        else
        begin

          case C of
            ',': GHataKodu := KomutYorumla(ParcaNo, vtVirgul, Komut, 0);
            '[':
            begin

              Inc(KPSayisi);
              GHataKodu := KomutYorumla(ParcaNo, vtKPAc, Komut, 0);
            end;
            ']':
            begin

              // ölçek değerin olması durumunda işleve ölçek değer yönlendiriliyor
              if(OlcekDegerMevcut) then
              begin

                if(KomutUz > 0) then
                begin

                  i := StrToInt(Komut);
                  GHataKodu := KomutYorumla(ParcaNo, vtOlcek, '', i);
                end else GHataKodu := HATA_OLCEK_DEGER_GEREKLI;

                OlcekDegerMevcut := False;
              end;

              // eğer varsa sayısal sabit değer işleve yönlendiriliyor
              if(GHataKodu = HATA_YOK) then
              begin
                // satır sonuna gelinmesi durumunda, işlenen değer ilgili
                // komuta yönlendirilmektedir
                if(SayisalDegerMevcut) then
                begin

                  if(KomutUz > 0) then SayisalVeriyiIsle('');
                  GHataKodu := GMatematik.Sonuc(i);
                  if(GHataKodu = HATA_YOK) then
                  begin

                    SayisalDegerMevcut := False;
                    GHataKodu := KomutYorumla(ParcaNo, vtSayi, '', i);
                  end;
                end;

                if(GHataKodu = HATA_YOK) then
                begin

                  Dec(KPSayisi);
                  GHataKodu := KomutYorumla(ParcaNo, vtKPKapat, Komut, 0);
                end;
              end;
            end;
          end;
        end;
      end
      // etiket kontrol işlemi
      else if(C = ':') and (ParcaNo = 1) and not(EtiketTamam) then
      begin

        if(KomutUz > 0) then
        begin

          IfadeDurum := idEtiket;

          // etiketin mevcut olup olmadığını gerçekleştir
          GHataKodu := GEtiketler.Ekle(Komut, 0, False);
          if(GHataKodu = HATA_YOK) then
          begin

            GEtiket := Komut;
            EtiketTamam := True;    // üstüste etiket tanımlamasını engellemek için
            Komut := '';
            KomutUz := 0;
          end else GHataAciklama := Komut;    // hata olması durumunda
        end;
      end
      // boşluk karakteri SADECE işlem kodunu almak için kullanılıyor
      else if(C = ' ') and (GKomutTipi = ktBilinmiyor) and (KomutUz > 0) then
      begin

        GHataKodu := KomutYorumla(ParcaNo, vtBosluk, Komut, 0)
      end
      // açıklama durumunun haricinde tüm bu işleyicilerin çalışma durumu
      else if((IfadeDurum <> idAciklama) and ((C = '(') or (C = ')') or (C = '+') or
        (C = '-') or (C = '*') or (C = '/'))) then
      begin

        // ölçek verisinin işlendiği bölüm
        if(KPSayisi > 0) and (C = '*') and (KomutUz > 0) then
        begin

          GHataKodu := KomutYorumla(ParcaNo, vtKarakterDizisi, Komut, 0);
          if(GSonIslenenVeriTipi = vtYazmac) then OlcekDegerMevcut := True;
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

              GHataKodu := HATA_HATALI_ISL_KULLANIM
            else
            begin

              i := StrToInt(Komut);
              GHataKodu := KomutYorumla(ParcaNo, vtOlcek, Komut, i);
              OlcekDegerMevcut := False;
              SonKullanilanIsleyici := C;
            end;
          end
          else
          begin

            if(SayisalDegerMevcut) then
            begin

              SayisalIslemYapiliyor := True;
              SayisalVeriyiIsle(C);
            end
            else
            begin

              if(KomutUz > 0) then
              begin

                GHataKodu := KomutYorumla(ParcaNo, vtKarakterDizisi, Komut, 0);
                if(GHataKodu = HATA_YOK) then
                  GHataKodu := KomutYorumla(ParcaNo, vtArti, '', 0);
              end;
            end;
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

          GHataKodu := KomutYorumla(ParcaNo, vtKarakterDizisi, Komut, 0);
        end;

        // eğer hata yok ise ifade durumunu AÇIKLAMA olarak belirle
        if(GHataKodu = HATA_YOK) then
        begin

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

        if(KomutUz = 0) then
        begin

          if(C in ['0'..'9']) then
            SayisalDegerMevcut := True
          else SayisalDegerMevcut := False;
        end;

        Komut += C;
        Inc(KomutUz);
      end;

      if(SatirSonu) and (KomutUz > 0) then
      begin

        if(SayisalDegerMevcut) then
        begin

          SayisalVeriyiIsle('');
          GHataKodu := GMatematik.Sonuc(i);
          if(GHataKodu = HATA_YOK) then
            GHataKodu := KomutYorumla(ParcaNo, vtSayi, '', i)
        end else GHataKodu := KomutYorumla(ParcaNo, vtKarakterDizisi, Komut, 0);
      end;
    end;

  // satır sonuna gelinceye veya hata oluncaya kadar döngüye devam et!
  until (SatirSonu) or (GHataKodu > HATA_YOK);

  // işlem kodunu işleyen çağrıya, tüm satırın işlendiğine dair sonlandırma mesajı gönder
  if(GHataKodu = HATA_YOK) and (GKomutTipi = ktIslemKodu) then

    GHataKodu := KomutYorumla(0, vtSon, '', 0)

  // satır SADECE açıklama içeriyorsa ifadenin türünü AÇIKLAMA olarak değiştir
  else if(IfadeDurum = idAciklama) and (GKomutTipi = ktBilinmiyor)
    and (GHataKodu = HATA_YOK) then GKomutTipi := ktAciklama

  // ifade içerisinde SADECE etiket veya açıklama + etiket mevcut ise
  // ifadenin türünü etiket olarak değiştir
  else if(IfadeDurum = idEtiket) and (ParcaNo = 1) and (Length(GEtiket) > 0) then
  begin

    GKomutTipi := ktEtiket;
    GHataKodu := HATA_YOK;
  end;

  Result := GHataKodu;
end;

end.
