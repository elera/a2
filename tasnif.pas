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
  TIfadeKontrol = (ikBaslamadi, ikBasladi, ikTamamlandi);

var
  ParametreTip1: TParametreTipi;
  ParametreTip2: TParametreTipi;
  IslemKodu, Yazmac1, Yazmac2, Yazmac3, BellekAdresleyenYazmacSayisi, Olcek, HizliDeger: Integer;
  Aciklama, Etiket: string;
  P1, P2, P3: string;

function KodUret(KodDizisi: string): Integer;

implementation

uses sysutils, yorumla;

var
  KomutCalistir: TAsmKomut = nil;

// her bir kod satırının yönlendirildiği, incelenerek parçalara ayrıldığı,
// assembler kodlarının üretildiği ana bölüm
function KodUret(KodDizisi: string): Integer;
var
  Komut: string;
  UKodDizisi, i, KodDizisiSira: Integer;
  C: Char;
  ParcaNo: Integer;
  IfadeKontrol: TIfadeKontrol;
  SatirSonu: Boolean;
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
begin

  // ilk değer atamaları

  UKodDizisi := Length(KodDizisi);

  ParcaNo := 1;

  KodDizisiSira := 1;

  Komut := '';

  IfadeKontrol := ikBaslamadi;

  SatirSonu := False;

  HataKodu := 0;

  KomutCalistir := nil;

  repeat

    // karakter değerini al
    C := KodDizisi[KodDizisiSira];

    // satırın sonuna gelinmiş mi; kontrol et
    Inc(KodDizisiSira);
    if(KodDizisiSira > UKodDizisi) then SatirSonu := True;

    // satır içeriğini kontrol edecek kontrol değer kahramanları
    if(C in [' ', ':', ',', '[', '(', ')', ']', ';', '+', '-', '*', '/']) then
    begin

      //frmMain.mmAsmLinesOutput.Lines.Add('Val1: ' + Data);
      KontrolKarakteri := True;
      IfadeKontrol := ikTamamlandi;
    end
    else if(SatirSonu) then
    begin

      //Data := Data + C;
      KontrolKarakteri := False;
      IfadeKontrol := ikTamamlandi;
    end
    else
    begin

      KontrolKarakteri := False;
    end;

    // kontrol karakteri gelmediği müddetçe Komut içeriği sürekli güncellenecektir
    if not(KontrolKarakteri) then Komut := Komut + C;

    // bir kontrol karakteri ile ifade tamamlanmış veya satırın sonuna gelindiyse
    // ilgili ifadeye yorumlamak için işleve yönlendir
    if(IfadeKontrol = ikTamamlandi) then
    begin

      // KomutCalistir'a atama yapılmamışsa (ilk kez çağrılacaksa)
      if(KomutCalistir = nil) then
      begin

        // komutun sıra değeri alınarak var olup olmadığı test ediliyor
        i := KomutSiraDegeriniAl(ParcaNo, Komut);

        // eğer komut, komut listesinde yok ise, hata ile ilgili işlev çağrılıyor
        if(i = -1) then
        begin

          KomutCalistir := @KomutHata;
          if(SatirSonu) then
            HataKodu := KomutCalistir(ParcaNo, #255, Komut, i)
          else HataKodu := KomutCalistir(ParcaNo, C, Komut, i)
        end
        else
        begin

          KomutCalistir := KomutListe[i];
          if(SatirSonu) then
            HataKodu := KomutCalistir(ParcaNo, #255, Komut, i)
          else HataKodu := KomutCalistir(ParcaNo, C, Komut, i)
        end;
      end else HataKodu := KomutCalistir(ParcaNo, C, Komut, i);

      // her bir tamamlanan ifade ile;
      // 1. Parça numarası bir artırılıyor
      // 2. Komut değeri bir sonraki döngü için sıfırlanıyor
      // 3. bir sonraki kontrol karakteri ile buraya gelinmesi için IfadeKontrol
      //    değişkeni ikBaslamadi değerine çekiliyor
      Inc(ParcaNo);
      Komut := '';
      IfadeKontrol := ikBaslamadi;
    end;

  // satır sonuna gelinceye veya hata oluncaya kadar döngüye devam et!
  until (KodDizisiSira > UKodDizisi) or (HataKodu > 0);

  Result := HataKodu;
end;

end.
