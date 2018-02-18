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

function KodUret(KodDizisi: string): Integer;

implementation

uses sysutils, anaform, donusum, yazmaclar, komutlar;

type
  TIfadeDurum = (idYok, idAciklama, idKPAc, idKPKapat);

var
  SonVeriKontrolTip: TVeriKontrolTip;     // en son işlenen veri tipini içerir
  iKomutYorumla: TAsmKomut = nil;         // assembler komutuna işaretçi (pointer)

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
  SayisalDeger: QWord;        // geçici deger değişkeni
  KPSayisi: Integer;          // köşeli parantezlerin takibini gerçekleştiren değişken
  TekTirnakSayisi: Integer;   // karakter katarı (string) takibini gerçekleştiren değişken
  SayisalDegerMevcut,         // dizi içerisinde sayısal değer olup olmadığını takip eder
  SayisalIslemYapiliyor,
  OlcekDegerMevcut: Boolean;  // dizi içerisinde ölçek değer (scale) olup olmadığını takip eder
  SonKullanilanIsleyici: Char;

  // her bir komutun yorumlanarak ilgili işleve yönlendirilmesini sağlar
  // ParcaNo değişkeninin artırma işlemini SADECE bu işlev gerçekleştirmektedir
  function KomutYorumla(AParcaNo: Integer; AVeriKontrolTip: TVeriKontrolTip; AVeri1: string;
    AVeri2: QWord): Integer;
  var
    _i: Integer;
    _AVeriKontrolTip: TVeriKontrolTip;
    _Yazmac: TYazmacDurum;
    _KomutDurum: TKomutDurum;
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

          // 1. aşamada ilgili komutun bulunmaması durumunda, 2. aşamada
          // komutun bir tanımlama olasılığına karşı tanım etiketi saklanıyor
          if(ParcaNo = 1) then
          begin

            GTanimEtiket := AVeri1;
            Result := HATA_YOK
          end
          else
          begin

            iKomutYorumla := @KomutHata;
            GHataAciklama := GTanimEtiket;
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
            Result := iKomutYorumla(AParcaNo, vktIlk, AVeri1, _KomutDurum.SiraNo);
          end
          // bildirim işlevine ilk çağrı yapılıyor
          else if(_KomutDurum.ABVT = abvtBildirim) then
          begin

            GAnaBolumVeriTipi := abvtBildirim;
            SonVeriKontrolTip := vktIlk;
            iKomutYorumla := KomutListe[_KomutDurum.SiraNo];
            Result := iKomutYorumla(AParcaNo, vktIlk, AVeri1, _KomutDurum.SiraNo);
          end
          // tanım işlevine ilk çağrı yapılıyor
          else
          begin

            GAnaBolumVeriTipi := abvtTanim;
            SonVeriKontrolTip := vktIlk;
            iKomutYorumla := KomutListe[_KomutDurum.SiraNo];

            Result := HATA_YOK;

            // verinin bir tanım ve etiket değeri olması halinde
            // 1. tanım etiketini listeye ekle
            if(ParcaNo = 2) then Result := GAsm2.Etiketler.Ekle(GTanimEtiket,
              MevcutBellekAdresi);

            // 2. hata olmaması durumunda ilgili işleve çağrıda bulun
            if(Result = HATA_YOK) then
              Result := iKomutYorumla(AParcaNo, vktIlk, '', _KomutDurum.SiraNo);
          end;
        end;
      end else Result := HATA_BILINMEYEN_KOMUT;

      Inc(ParcaNo);
    end
    // veri herhangi bir kontrole tabi tutulmadan ilgili işleve yönlendiriliyor
    else if(_AVeriKontrolTip = vktKarakterDizisi) then
    begin

      SonVeriKontrolTip := vktKarakterDizisi;
      Result := iKomutYorumla(AParcaNo, SonVeriKontrolTip, AVeri1, 0);
    end
    // karakter dizisinin yazmaç, işlem kodu ve diğer tanımlama olup olmadığının
    // kontrol edilmesi için işleme alındığı bölüm
    else if(_AVeriKontrolTip = vktKEKarakterDizisi) then
    begin

      _Yazmac := YazmacBilgisiAl(AVeri1);
      if(_Yazmac.Sonuc > -1) then
      begin

        _i := _Yazmac.Sonuc;
      end;

      SonVeriKontrolTip := vktYazmac;
      Result := iKomutYorumla(AParcaNo, SonVeriKontrolTip, '', _i);
    end
    // ölçek ve sayı verilerinin işlenmesi
    else if(_AVeriKontrolTip = vktOlcek) or (_AVeriKontrolTip = vktSayi) then
    begin

      SonVeriKontrolTip := _AVeriKontrolTip;
      Result := iKomutYorumla(AParcaNo, SonVeriKontrolTip, '', AVeri2);
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
          Result := iKomutYorumla(AParcaNo, SonVeriKontrolTip, '', _i);
        end;
      end;

      // işleyici değerini işleve yönlendir.
      { TODO : (burada virgül kontrolü tekrar ele alınmalıdır) }
      if(Result = HATA_YOK) then
      begin

        SonVeriKontrolTip := _AVeriKontrolTip;
        Result := iKomutYorumla(AParcaNo, SonVeriKontrolTip, AVeri1, _i);
      end;

      // virgül olması durumunda ParcaNo değişkenini 1 artır
      if(GAnaBolumVeriTipi = abvtIslemKodu) and (_AVeriKontrolTip = vktVirgul) then
        Inc(ParcaNo);
    end
    else if(_AVeriKontrolTip = vktSon) then
    begin

      SonVeriKontrolTip := vktSon;
      Result := iKomutYorumla(0, SonVeriKontrolTip, '', 0);
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
        end else GHataKodu := HATA_SAYISAL_DEGER;
      end else GMatematik.SayiEkle(AIsleyici, False, 0);
    end;

    // işlenen değişkenlerin ilk değer atamalarını gerçekleştir
    Komut := '';
    KomutUz := 0;
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
  SayisalDegerMevcut := False;
  SayisalIslemYapiliyor := False;
  OlcekDegerMevcut := False;
  SatirSonu := False;

  Komut := '';
  KomutUz := 0;
  SonKullanilanIsleyici := '+';

  GEtiket := '';
  GTanimEtiket := '';

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
      (C in [' ', '''', ',', ':', ';', '=', '(', ')', '[', ']', '+', '-',
        '*', '/', #9]) then
    begin

      if(C = ',') then
      begin

        if(GAnaBolumVeriTipi = abvtIslemKodu) then
        begin

          if(ParcaNo = 1) then
          begin

            GHataKodu := HATA_ISL_KULLANIM;
          end else GHataKodu := KomutYorumla(ParcaNo, vktVirgul, Komut, 0);
        end
        else if(GAnaBolumVeriTipi = abvtTanim) then
        begin

          SendDebug('Tanım: ' + Komut);

          // tanım işleminde virgül öncesi veri var ise ...
          if(KomutUz > 0) then
          begin

            // eğer veri sayısal bir değer ise...
            if(SayisalDegerMevcut) then
            begin

              if(SayiyaCevir(Komut, SayisalDeger)) then
              begin

                GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger);
                if(GHataKodu = HATA_YOK) then
                  GHataKodu := KomutYorumla(ParcaNo, vktVirgul, '', 0)
              end else GHataKodu := HATA_SAYISAL_DEGER;
            end
            else
            begin

              if(GAsm2.Etiketler.Bul(Komut, SayisalDeger)) then
                GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger)
              else GHataKodu := HATA_BILINMEYEN_HATA;
            end;
          end
          else
          begin

            GHataKodu := KomutYorumla(ParcaNo, vktVirgul, '', 0)
          end;
        end;
      end
      else if(C = '=') and (GAnaBolumVeriTipi = abvtBelirsiz) then
      begin

        // mevcut komutun yorumlanmasını sağla
        if(KomutUz > 0) then
        begin

          // burada eşittir olarak gönderdiğimiz değer KomutYorumla kısmında
          // işlem görmeyecektir. bu sebeple hata olmaması durumunda
          // eşittir ifadesini tekrar gönderiyoruz
          GHataKodu := KomutYorumla(ParcaNo, vktEsittir, Komut, 0);

          // eğer hata yok ise
          if(GHataKodu = HATA_YOK) then
          begin

            GHataKodu := KomutYorumla(ParcaNo, vktEsittir, '', 0);
          end;
        end;
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
                if(SayisalDegerMevcut) then
                begin

                  if(KomutUz > 0) then SayisalVeriyiIsle('');
                  if(GHataKodu = HATA_YOK) then
                  begin

                    GHataKodu := GMatematik.Sonuc(SayisalDeger);
                    if(GHataKodu = HATA_YOK) then
                    begin

                      SayisalDegerMevcut := False;
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

          if(KomutUz = 0) then Inc(TekTirnakSayisi);
        end
        else if(TekTirnakSayisi = 1) then
        begin

          if(KomutUz > 0) then
          begin

            GHataKodu := KomutYorumla(ParcaNo, vktKarakterDizisi, Komut, 0);
            TekTirnakSayisi := 0;
            Komut := '';
            KomutUz := 0;
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

            // etiketin mevcut olup olmadığını gerçekleştir
            GHataKodu := GAsm2.Etiketler.Ekle(Komut, MevcutBellekAdresi);
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

        if(GAnaBolumVeriTipi = abvtBelirsiz) and (KomutUz > 0) then

          GHataKodu := KomutYorumla(ParcaNo, vktBosluk, Komut, 0)
        else if(GAnaBolumVeriTipi = abvtTanim) and (TekTirnakSayisi > 0) then
        begin

          Komut += C;
          Inc(KomutUz);
        end;
      end
      // açıklama durumunun haricinde tüm bu işleyicilerin çalışma durumu
      else if((IfadeDurum <> idAciklama) and ((C = '(') or (C = ')') or (C = '+') or
        (C = '-') or (C = '*') or (C = '/'))) then
      begin

        // ölçek verisinin işlendiği bölüm
        if(KPSayisi > 0) and (C = '*') and (KomutUz > 0) then
        begin

          GHataKodu := KomutYorumla(ParcaNo, vktKEKarakterDizisi, Komut, 0);
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

            if(SayisalDegerMevcut) then
            begin

              SayisalIslemYapiliyor := True;
              SayisalVeriyiIsle(C);
            end
            else
            begin

              if(KomutUz > 0) then
              begin

                GHataKodu := KomutYorumla(ParcaNo, vktKEKarakterDizisi, Komut, 0);
                if(GHataKodu = HATA_YOK) then
                  GHataKodu := KomutYorumla(ParcaNo, vktArti, '', 0);
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

          GHataKodu := KomutYorumla(ParcaNo, vktKEKarakterDizisi, Komut, 0);
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

          if(C in ['0'..'9']) then
            SayisalDegerMevcut := True
          else SayisalDegerMevcut := False;
        end;

        Komut += C;
        Inc(KomutUz);
      end;
    end;

    if(SatirSonu) then
    begin

      if(KomutUz > 0) then
      begin

        if(SayisalDegerMevcut) then
        begin

          SayisalVeriyiIsle('');
          if(GHataKodu = HATA_YOK) then
          begin

            GHataKodu := GMatematik.Sonuc(SayisalDeger);
            if(GHataKodu = HATA_YOK) then
              GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger)
          end;
        end
        else
        begin

          if(GAnaBolumVeriTipi = abvtBelirsiz) then
          begin

            GHataKodu := KomutYorumla(ParcaNo, vktKarakterDizisi, Komut, 0);
          end
          else
          begin

            //
            if(GAnaBolumVeriTipi = abvtBildirim) then
            begin

              GHataKodu := KomutYorumla(ParcaNo, vktKarakterDizisi, Komut, 0);
            end
            else
            begin

              if(GAsm2.Etiketler.Bul(Komut, SayisalDeger)) then
                GHataKodu := KomutYorumla(ParcaNo, vktSayi, '', SayisalDeger)
              else GHataKodu := HATA_BILINMEYEN_HATA;
            end;
          end;
        end;
      end;

      // tüm satırın işlendiğine dair sonlandırma mesajı gönder
      if(GHataKodu = HATA_YOK) then GHataKodu := KomutYorumla(ParcaNo, vktSon, '', 0);
    end;

  // satır sonuna gelinceye veya hata oluncaya kadar döngüye devam et!
  until (SatirSonu) or (GHataKodu > HATA_YOK);

  Result := GHataKodu;
end;

end.
