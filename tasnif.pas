{-------------------------------------------------------------------------------

  Dosya: tasnif.pas
  İşlev: her bir veri satırının parçalanma ve yönlendirme işlevlerini içerir
  Tarih: 13/01/2018
  Bilgi:

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

var
  ParametreTip1: TParametreTipi;
  ParametreTip2: TParametreTipi;
  IslemKodu, Yazmac1, Yazmac2, Yazmac3, BellekAdresleyenYazmacSayisi, Olcek, HizliDeger: Integer;
  P1, P2, P3: string;

function KodUret(KodDizisi: string): Integer;

implementation

uses sysutils, yorumla, anasayfa;

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
  EtiketTamam: Boolean;     // üstüste etiket değeri girilmesini engellemek için
  KontrolKarakteri: Boolean;

  function KomutSiraDegeriniAl(AParcaNo: Integer; AKomut: string): Integer;
  var
    StatementState: TKomutDurum;
  begin

    if(AParcaNo = 1) then
    begin

      StatementState := KomutBilgisiAl(AKomut);
      Result := StatementState.Sonuc;
    end;
  end;

  function KomutYorumla(AParcaNo: Integer; AKontrolKarakteri: Char;
    AKomut: string; ASatirSonu: Boolean): Integer;
  var
    _i: Integer;
  begin

    // KomutCalistir'a atama yapılmamışsa (ilk kez çağrılacaksa)
    if(iKomutYorumla = nil) then
    begin

      // komutun sıra değeri alınarak var olup olmadığı test ediliyor
      _i := KomutSiraDegeriniAl(AParcaNo, AKomut);

      // eğer komut, komut listesinde yok ise, hata ile ilgili işlev çağrılıyor
      if(_i = -1) then
      begin

        iKomutYorumla := @KomutHata;
        if(ASatirSonu) then
          Result := iKomutYorumla(AParcaNo, #255, AKomut, _i)
        else Result := iKomutYorumla(AParcaNo, AKontrolKarakteri, AKomut, _i)
      end
      else
      begin

        iKomutYorumla := KomutListe[_i];
        if(ASatirSonu) then
          Result := iKomutYorumla(AParcaNo, #255, AKomut, _i)
        else Result := iKomutYorumla(AParcaNo, AKontrolKarakteri, AKomut, _i)
      end;
    end else Result := iKomutYorumla(AParcaNo, AKontrolKarakteri, AKomut, _i);
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

  iKomutYorumla := nil;

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

          GEtiket := '';
        end else IfadeDurum := idBasladi;
      end
      // genel ayıraç. özelleştirilecek
      else if(IfadeDurum = idBasladi) and (C = ' ') then

        IfadeDurum := idTamamlandi

      // açıklama kontrolü
      else if(C = ';') and not(IfadeDurum = idAciklama) then
      begin

        // açıklama satırından önce sürmekte olan bir komut var ise çalıştır
        if(Length(Komut) > 0) then
        begin

          GHataKodu := KomutYorumla(ParcaNo, C, Komut, True);
        end;

        if(GHataKodu = 0) then
        begin

          GAciklama := '';
          IfadeDurum := idAciklama;
        end;
      end;
    end
    else
    begin

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

      if(SatirSonu) then
        GHataKodu := KomutYorumla(ParcaNo, C, Komut, True)
      else GHataKodu := KomutYorumla(ParcaNo, C, Komut, SatirSonu);

      // her bir tamamlanan ifade ile;
      // 1. Parça numarası bir artırılıyor
      // 2. Komut değeri bir sonraki döngü için sıfırlanıyor
      // 3. bir sonraki kontrol karakteri ile buraya gelinmesi için IfadeKontrol
      //    değişkeni ikBaslamadi değerine çekiliyor
      Inc(ParcaNo);
      Komut := '';
      IfadeDurum := idBaslamadi;
    end;

  // satır sonuna gelinceye veya hata oluncaya kadar döngüye devam et!
  until (KodDizisiSira > UKodDizisi) or (GHataKodu > 0);

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
