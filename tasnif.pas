{-------------------------------------------------------------------------------

  Dosya: tasnif.pas

  İşlev: her bir veri satırının parçalanma ve yönlendirme işlevlerini içerir

  Güncelleme Tarihi: 21/01/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit tasnif;

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
uses genel;

type
  TIfadeDurum = (idBaslamadi, idBasladi, idTamamlandi, idAciklama, idEtiket);

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
  UKodDizisi, KodDizisiSira: Integer;
  C: Char;
  ParcaNo: Integer;
  IfadeDurum: TIfadeDurum;
  SatirSonu: Boolean;
  EtiketTamam: Boolean;       // üstüste etiket değeri girilmesini engellemek için
  KontrolKarakteri: Boolean;
  VeriSayiMi: Boolean;        // sayısal değer algılandığında "doğru" değerini alır
  SayisalDeger: Integer;      // geçici deger değişkeni
  SayiToplam: Integer;        // derleyicinin kullanacağı geçici sayısal değer
  Isleyici: string;           // derleyicinin yapacağı matematiksel işlem

  function KomutSiraDegeriniAl(AParcaNo: Integer; AKomut: string): Integer;
  var
    KomutDurum: TKomutDurum;
  begin

    if(AParcaNo = 1) then
    begin

      KomutDurum := KomutBilgisiAl(AKomut);
      Result := KomutDurum.Sonuc;
    end;
  end;

  function KomutYorumla(ASatirSonu: Boolean; AParcaNo: Integer; AVeriTipi:
    TVeriTipi; AVeri1: string; AVeri2: Integer): Integer;
  var
    _i: Integer;
  begin

    // KomutCalistir'a atama yapılmamışsa (ilk kez çağrılacaksa)
    if(iKomutYorumla = nil) then
    begin

      // komutun sıra değeri alınarak var olup olmadığı test ediliyor
      _i := KomutSiraDegeriniAl(AParcaNo, AVeri1);

      // eğer komut, komut listesinde yok ise, hata ile ilgili işlev çağrılıyor
      if(_i = -1) then
        iKomutYorumla := @KomutHata
      else iKomutYorumla := KomutListe[_i];
    end;

    if(AParcaNo = 1) then
      Result := iKomutYorumla(ASatirSonu, AParcaNo, AVeriTipi, AVeri1, _i)
    else Result := iKomutYorumla(ASatirSonu, AParcaNo, AVeriTipi, AVeri1, AVeri2)
  end;
begin

  // ilk değer atamaları

  UKodDizisi := Length(KodDizisi);

  ParcaNo := 1;

  KodDizisiSira := 1;

  Komut := '';

  IfadeDurum := idBaslamadi;

  SatirSonu := False;

  GHataKodu := 0;

  GKomutTipi := ktBilinmiyor;

  EtiketTamam := False;
  GEtiket := '';

  VeriSayiMi := False;
  SayiToplam := 0;
  Isleyici := '+';        // öntanımlı işlem = toplama

  iKomutYorumla := nil;

  GMatematik.Temizle;     // mevcut matematisel işlemleri temizle

  repeat

    // karakter değerini al
    C := KodDizisi[KodDizisiSira];

    // satırın sonuna gelinmiş mi; kontrol et
    Inc(KodDizisiSira);
    if(KodDizisiSira > UKodDizisi) then SatirSonu := True;

    // satır içeriğini kontrol edecek kontrol değer kahramanları
    if(C in [' ', ':', ',', '[', '(', ')', ']', ';', '+', '-', '*', '/']) then
    begin

      KontrolKarakteri := True;

      // etiket kontrol işlemi
      if(C = ':') and (ParcaNo = 1) and not(EtiketTamam) then
      begin

        if(Length(Komut) > 0) then
        begin

          IfadeDurum := idEtiket;

          // etiketin mevcut olup olmadığını gerçekleştir
          GHataKodu := GEtiketler.Ekle(Komut, 0, False);
          if(GHataKodu = 0) then
          begin

            GEtiket := Komut;
            EtiketTamam := True;    // üstüste etiket tanımlamasını engellemek için
            Komut := '';
          end else GHataAciklama := Komut;    // hata olması durumunda
        end else IfadeDurum := idBasladi;
      end
      // boşluk karakterinin şu aşamdaki işlevi
      // ilk parçada, birden fazla parametre olması durumunda her zaman boşluk
      // karakterinin gelmesi gerekmekte. diğer durumlarda kontrol karakteri olarak
      // algılanması GEREKMEMEKTE. (boşluk karakteri gözardı edilmekte)
      else if(IfadeDurum = idBasladi) and (C = ' ') then
      begin

        if(ParcaNo = 1) then
          IfadeDurum := idTamamlandi
        else IfadeDurum := idBaslamadi;
      end
      // açıklama durumunun haricinde tüm bu işleyicilerin çalışma durumu
      else if((IfadeDurum <> idAciklama) and ((C = '(') or (C = ')') or (C = '+') or
        (C = '-') or (C = '*') or (C = '/'))) then
      begin

        Isleyici := C;
        IfadeDurum := idTamamlandi;
      end
      // açıklama kontrolü
      else if(C = ';') and not(IfadeDurum = idAciklama) then
      begin

        // açıklama satırından önce sürmekte olan bir komut var ise
        // mevcut komutun yorumlanmasını sağla
        if(Length(Komut) > 0) then
        begin

          GHataKodu := KomutYorumla(True, ParcaNo, vtIslemKodu, Komut, 0);
        end;

        // eğer hata yok ise ifade durumunu AÇIKLAMA olarak belirle
        if(GHataKodu = 0) then
        begin

          GAciklama := '';
          IfadeDurum := idAciklama;
        end;
      end;
    end
    else
    begin

      // kontrol karakteri OLMAMASI ve ifadenin açıklama OLMAMASI durumunda
      // ifadenin durumunu her zaman BAŞLADI olarak belirle
      if(IfadeDurum <> idAciklama) then
      begin

        IfadeDurum := idBasladi;
        KontrolKarakteri := False;
      end;
    end;

    // komut ve açıklama içerik güncellemeleri
    if(IfadeDurum = idBasladi) then
      Komut := Komut + C
    else if(IfadeDurum = idAciklama) then
      GAciklama := GAciklama + C;

    // satır sonuna gelinmesi durumunda komutun yorumlanmasını sağla
    if(SatirSonu) and (IfadeDurum <> idAciklama) and (IfadeDurum <> idEtiket) then
      IfadeDurum := idTamamlandi;

    // ifade yorumlanmak üzere tamamlanmış ise komutu yorumla
    if(IfadeDurum = idTamamlandi) then
    begin

      if(ParcaNo = 1) then
      begin

        if(SatirSonu) then
          GHataKodu := KomutYorumla(True, ParcaNo, vtIslemKodu, Komut, 0)
        else GHataKodu := KomutYorumla(False, ParcaNo, vtIslemKodu, Komut, 0);

        // her bir tamamlanan ifade ile;
        // 1. Parça numarası bir artırılıyor
        // 2. Komut değeri bir sonraki döngü için sıfırlanıyor
        // 3. bir sonraki kontrol karakteri ile buraya gelinmesi için IfadeKontrol
        //    değişkeni ikBaslamadi değerine çekiliyor
        Inc(ParcaNo);
      end
      else if(ParcaNo > 1) then
      begin

        // 2. parça (bu kısım) sayısal çoklu değer ve parantez işlemlerinin
        // gerçekleştirilmesi amacıyla yapılandırılmıştır
        // test amaçlı olarak int komutunun 2. parametresi olarak kullanılmıştır
        if(Isleyici = '(') then
        begin

          if(Length(Komut) > 0) then
            GHataKodu := GMatematik.ParantezEkle(Isleyici[1], True, StrToInt(Komut))
          else GHataKodu := GMatematik.ParantezEkle(Isleyici[1], False, 0);
        end
        else if(Isleyici = ')') then
        begin

          if(Length(Komut) > 0) then
            GMatematik.ParantezEkle(Isleyici[1], True, StrToInt(Komut))
          else GMatematik.ParantezEkle(Isleyici[1], False, 0);
        end
        else
        begin

          if(Length(Komut) > 0) then
          begin

            // sayıya çevirme işlemi şu aşamada ondalık sayılarla ilgilidir
            // sayısal ifade test işlemleri SADECE int komutu üzerinde
            // gerçekleştirilmiştir. çalışma genişletilecektir.
            // ikili, onaltılı sayı sistemlerinden başka bellek etiket değerleri
            // de sayısal ifadelerin içerisinde yer alacaktır
            if(SayiyaCevir(Komut, SayisalDeger)) then
            begin

              VeriSayiMi := True;
              if(Length(Isleyici) > 0) then GMatematik.SayiEkle(Isleyici, True, SayisalDeger);
            end;
          end else GMatematik.SayiEkle(Isleyici, False, 0);
        end;

        // satır sonuna gelinmesi durumunda, işlenen değer ilgili
        // komuta yönlendirilmektedir
        if(SatirSonu) then
        begin

          GHataKodu := GMatematik.Sonuc(SayiToplam);
          if(GHataKodu = 0) then
          begin

            GHataKodu := KomutYorumla(True, ParcaNo, vtSayi, Komut, SayiToplam);
          end;
        end;
      end;

      Isleyici := '';
      Komut := '';
      IfadeDurum := idBaslamadi;
    end;

  // satır sonuna gelinceye veya hata oluncaya kadar döngüye devam et!
  until (SatirSonu) or (GHataKodu > 0);

  // satır SADECE açıklama içeriyorsa ifadenin türünü AÇIKLAMA olarak değiştir
  if(IfadeDurum = idAciklama) and (GKomutTipi = ktBilinmiyor)
    and (GHataKodu = 0) then GKomutTipi := ktAciklama;

  // ifade içerisinde SADECE etiket veya açıklama + etiket mevcut ise
  // ifadenin türünü etiket olarak değiştir
  if(IfadeDurum = idEtiket) and (ParcaNo = 1) and (Length(GEtiket) > 0) then
  begin

    GKomutTipi := ktEtiket;
    GHataKodu := 0;
  end;

  Result := GHataKodu;
end;

end.
