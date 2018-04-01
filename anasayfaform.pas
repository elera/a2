{-------------------------------------------------------------------------------

  Dosya: anasayfaform.pas

  İşlev: program ana sayfası

  Güncelleme Tarihi: 31/03/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit anasayfaform;

interface

uses
  Classes, SysUtils, FileUtil, UTF8Process, SynEdit, SynHighlighterAny,
  SynCompletion, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Menus, LCLType;

type

  { TfrmAnaSayfa }

  TfrmAnaSayfa = class(TForm)
    ilAnaMenu16: TImageList;
    miDosyaAyrim0: TMenuItem;
    miDosyaAyrim1: TMenuItem;
    miDosyaCikis: TMenuItem;
    miDosyaSonKullanilanDosya5Ac: TMenuItem;
    miDosyaSonKullanilanDosya4Ac: TMenuItem;
    miDosyaSonKullanilanDosya3Ac: TMenuItem;
    miDosyaSonKullanilanDosya2Ac: TMenuItem;
    miDosyaSonKullanilanDosya1Ac: TMenuItem;
    miDosyaYeni: TMenuItem;
    miDosyaKaydet: TMenuItem;
    miDosya: TMenuItem;
    miDosyaAc: TMenuItem;
    miKodCalistir: TMenuItem;
    miKodEtiketListesi: TMenuItem;
    miKodAyrim0: TMenuItem;
    miYardim: TMenuItem;
    miYardimAssemblerBelge: TMenuItem;
    miKod: TMenuItem;
    miKodDerle: TMenuItem;
    mmAnaMenu: TMainMenu;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    sbDurum: TStatusBar;
    seAssembler: TSynEdit;
    SynAssemblerSyn: TSynAnySyn;
    SynCompletion1: TSynCompletion;
    tbAnaSayfa: TToolBar;
    tbAyrim2: TToolButton;
    tbAyrim3: TToolButton;
    tbKodDerle: TToolButton;
    tbAyrim0: TToolButton;
    tbYardimAssemblerBelge: TToolButton;
    tbKodEtiketListesi: TToolButton;
    tbKodCalistir: TToolButton;
    tbAyrim1: TToolButton;
    tbDosyaAc: TToolButton;
    tbDosyaKaydet: TToolButton;
    tbDosyaYeni: TToolButton;
    tbDosyaCikis: TToolButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormShow(Sender: TObject);
    procedure miDosyaAcClick(Sender: TObject);
    procedure miDosyaCikisClick(Sender: TObject);
    procedure miDosyaKaydetClick(Sender: TObject);
    procedure miDosyaSonKullanilanDosyayiAcClick(Sender: TObject);
    procedure miDosyaYeniClick(Sender: TObject);
    procedure miKodEtiketListesiClick(Sender: TObject);
    procedure miYardimAssemblerBelgeClick(Sender: TObject);
    procedure miKodDerleClick(Sender: TObject);
    function FormuOrtala(GoruntulenecekForm: TForm; SonucuBekle: Boolean): Integer;
    procedure miKodCalistirClick(Sender: TObject);
    procedure seAssemblerClick(Sender: TObject);
    procedure seAssemblerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SynCompletion1Execute(Sender: TObject);
  private
    procedure DurumCubugunuGuncelle;
    procedure ProjeDosyasiAc(ADosyaAdi: string);
    procedure ProjeDosyasiKaydet(ADosyaAdi: string);
    procedure SonKullanilanlarListesineEkle(Dosya: string);
    procedure MenuSonKullanilanlarListesiniGuncelle;
  public
  end;

var
  frmAnaSayfa: TfrmAnaSayfa;

implementation

{$R *.lfm}

uses incele, genel, atamalar, dosya, derlemebilgisiform, atamalarform, asm2,
  ayarlar, yazmaclar, {$IFDEF Windows} windows, {$ENDIF} process, oneriler, komutlar, dbugintf,
  paylasim, donusum, LConvEncoding;

procedure TfrmAnaSayfa.FormCreate(Sender: TObject);
begin

  // çalışma zamanlı nesneler oluşturuluyor
  GAsm2 := TAsm2.Create;

  // daha önce kaydedilen program ayarlarını oku
  GProgramAyarlari := GAsm2.ProgramAyarDosyasiniOku;

  // eğer program ilk kez çalıştırıldıysa
  if(GProgramAyarlari.PencereSol = -1) and (GProgramAyarlari.PencereUst = -1)
    and (GProgramAyarlari.PencereGenislik = -1)
    and (GProgramAyarlari.PencereYukseklik = -1) then
  begin

    GProgramAyarlari.PencereGenislik := 500;
    GProgramAyarlari.PencereYukseklik := 500;
    GProgramAyarlari.PencereSol := (Screen.Width - 500) div 2;
    GProgramAyarlari.PencereUst := (Screen.Height - 500) div 2;
  end;

  // ana menünün "Son Kullanılanlar Listesi"ni güncelle
  MenuSonKullanilanlarListesiniGuncelle;

  // dosyaların sürüklenip bırakılmasına izin ver
  Self.AllowDropFiles := True;
end;

procedure TfrmAnaSayfa.FormShow(Sender: TObject);
var
  i: Integer;
begin

  sbDurum.Panels[2].Text := 'Sürüm: ' + ProgramSurum + ' - ' + SurumTarihi;

  SynAssemblerSyn.Objects.Clear;
  for i := 0 to TOPLAM_KOMUT - 1 do
    SynAssemblerSyn.Objects.Add(UpperCase(KomutListesi[i].Komut));

  SynAssemblerSyn.KeyWords.Clear;
  for i := 0 to TOPLAM_YAZMAC - 1 do
    SynAssemblerSyn.KeyWords.Add(UpperCase(YazmacListesi[i].Ad));

  frmAnaSayfa.Left := GProgramAyarlari.PencereSol;
  frmAnaSayfa.Top := GProgramAyarlari.PencereUst;
  frmAnaSayfa.Width := GProgramAyarlari.PencereGenislik;
  frmAnaSayfa.Height := GProgramAyarlari.PencereYukseklik;
  frmAnaSayfa.WindowState := GProgramAyarlari.PencereDurum;
end;

procedure TfrmAnaSayfa.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  // program ayarlarını ini dosyasına yaz
  GProgramAyarlari.PencereSol := frmAnaSayfa.Left;
  GProgramAyarlari.PencereUst := frmAnaSayfa.Top;
  GProgramAyarlari.PencereGenislik := frmAnaSayfa.Width;
  GProgramAyarlari.PencereYukseklik := frmAnaSayfa.Height;
  GProgramAyarlari.PencereDurum := frmAnaSayfa.WindowState;

  GAsm2.ProgramAyarDosyasinaYaz(GProgramAyarlari);

  // çalışma zamanlı oluşturulan nesneler yok ediliyor
  GAsm2.Destroy;
end;

// dosyaların ana pencere üzerine sürüklenerek açma işlemi
procedure TfrmAnaSayfa.FormDropFiles(Sender: TObject; const FileNames: array of String);
var
  DosyaSayisi: Integer;
begin

  // sürüklenen dosya sayısı
  DosyaSayisi := Length(FileNames);

  if(DosyaSayisi > 1) then

    ShowMessage('Çoklu dosya açma işlemi şu anda desteklenmiyor!')
  else ProjeDosyasiAc(FileNames[0]);
end;

procedure TfrmAnaSayfa.miDosyaYeniClick(Sender: TObject);
begin

  // kod sayfasını temizle
  seAssembler.Clear;

  // ana nesneyi ilklendir
  GAsm2.Ilklendir;

  // durum çubuğunu güncelle
  DurumCubugunuGuncelle;
end;

procedure TfrmAnaSayfa.miDosyaAcClick(Sender: TObject);
begin

  OpenDialog1.Title := 'Assembler Dosyası Aç';
  OpenDialog1.Filter := 'Assembler Dosyası|*.asm';
  OpenDialog1.InitialDir := GAsm2.ProjeDizin;
  OpenDialog1.DefaultExt := 'asm';
  OpenDialog1.FileName := '';
  if(OpenDialog1.Execute) then ProjeDosyasiAc(OpenDialog1.Filename);
end;

procedure TfrmAnaSayfa.miDosyaCikisClick(Sender: TObject);
begin

  Close;
end;

procedure TfrmAnaSayfa.miDosyaKaydetClick(Sender: TObject);
begin

  // dosya daha önceden kaydedilmiş veya açılmış ise...
  if(Length(GAsm2.DosyaAdi) > 0) then
  begin

    seAssembler.Lines.SaveToFile(GAsm2.ProjeDizin + DirectorySeparator +
      GAsm2.DosyaAdi + '.' + GAsm2.ProjeDosyaUzanti);
  end
  else
  begin

    SaveDialog1.Title := 'Assembler Dosyası Kaydet';
    SaveDialog1.Filter := 'Assembler Dosyası|*.asm';
    SaveDialog1.InitialDir := GAsm2.ProjeDizin;
    SaveDialog1.DefaultExt := 'asm';
    SaveDialog1.FileName := '';
    if(SaveDialog1.Execute) then
    begin

      ProjeDosyasiKaydet(SaveDialog1.Filename);
    end;
  end;
end;

procedure TfrmAnaSayfa.miDosyaSonKullanilanDosyayiAcClick(Sender: TObject);
var
  DosyaSira: Integer;
begin

  DosyaSira := (Sender as TMenuItem).Tag;
  ProjeDosyasiAc(GProgramAyarlari.SonKullanilanDosyalar[DosyaSira]);
end;

// kod derleme menüsü
procedure TfrmAnaSayfa.miKodDerleClick(Sender: TObject);
var
  MevcutSatirSayisi, ToplamSatirSayisi,
  IslenenSatirSayisi: Integer;
  Dosya, HamVeri: string;
  IslevSonuc: Integer;
  DerlemeCevrimindenCik: Boolean;
begin

  DerlemeCevrimindenCik := False;

  // mevcut etiketleri temizle
  GAsm2.AtamaListesi.Temizle;

  // ilk değer atamaları
  GAsm2.DerlemeCevrimSayisi := 1;

  while (DerlemeCevrimindenCik = False) do
  begin

    IslevSonuc := HATA_YOK;

    GEtiketHataSayisi := 0;

    KodBellekU := 0;
    MevcutBellekAdresi := 0;

    ToplamSatirSayisi := seAssembler.Lines.Count;
    MevcutSatirSayisi := 0;
    IslenenSatirSayisi := 0;

    // son satıra gelinmediği ve hata olmadığı müddetçe devam et
    while (MevcutSatirSayisi < ToplamSatirSayisi) and (IslevSonuc = HATA_YOK) do
    begin

      HamVeri := seAssembler.Lines[MevcutSatirSayisi];

      if(Length(Trim(HamVeri)) > 0) then
      begin

        // her 2 değişken tipi de burada yok olarak belirtiliyor
        SatirIcerik.Komut.KomutTipi := ktBelirsiz;
        SatirIcerik.DigerVeri := [];

        SatirIcerik.Komut.GrupNo := -1;
        SatirIcerik.BolumTip1.BolumAnaTip := batYok;
        SatirIcerik.BolumTip1.BolumAyrinti := [];
        SatirIcerik.BolumTip2.BolumAnaTip := batYok;
        SatirIcerik.BolumTip2.BolumAyrinti := [];

        // ilgili satırın incelendiği / kodların üretildiği ana çağrı
        IslevSonuc := KodUret(MevcutSatirSayisi, HamVeri);

        // işlenen satır sayısını artır
        Inc(IslenenSatirSayisi);
      end;

      // bir sonraki satıra geçiş yap
      Inc(MevcutSatirSayisi);
      Application.ProcessMessages;
    end;

    // hata olduğu için çıkış yap
    if(IslevSonuc > HATA_YOK) then

      DerlemeCevrimindenCik := True

    // derleme başarılı olduğu için çıkış yap
    else if(IslevSonuc = HATA_YOK) and (GAsm2.AtamaListesi.Temizle2 = 0) then

      DerlemeCevrimindenCik := True

    else GAsm2.DerlemeCevrimSayisi := GAsm2.DerlemeCevrimSayisi + 1;

    Application.ProcessMessages;
  end;

  // derleme işleminin durumu, derleme sonrasında belirleniyor
  GAsm2.DerlemeBasarili := (IslevSonuc = HATA_YOK);

  // kodların yorumlanması ve çevrilmesinde herhangi bir hata yoksa
  // ikili formatta (binary file) dosya oluştur
  { TODO : oluşturulacak dosya ilk aşamada saf assembler kodların makine dili karşılıklarıdır
    ileride PE / COFF ve diğer formatlarda program dosyaları oluşturulacaktır  }
  if(GAsm2.DerlemeBasarili) then
  begin

    // dosya adının olması durumunda ...
    if(Length(GAsm2.DosyaAdi) > 0) then
    begin

      // dosya uzantısının olmaması durumunda dosyaya uzantı ekleme (özellikle linux için)
      if(Length(GAsm2.CikisDosyaUzanti) > 0) then
        Dosya := GAsm2.DosyaAdi + '.' + GAsm2.CikisDosyaUzanti
      else Dosya := GAsm2.DosyaAdi;

      if(ProgramDosyasiOlustur(GAsm2.ProjeDizin + DirectorySeparator + Dosya)) then
      begin

        frmDerlemeBilgisi.DerlenenDosya := Dosya;
        frmDerlemeBilgisi.DerlenenSatirSayisi := IslenenSatirSayisi;
        frmDerlemeBilgisi.IkiliDosyaUzunluk := KodBellekU;
        frmDerlemeBilgisi.DerlemeCevrimSayisi := GAsm2.DerlemeCevrimSayisi;
        FormuOrtala(frmDerlemeBilgisi, True);
      end else ShowMessage('Hata: ' + Dosya + ' dosyası oluşturulamadı!')
    end
    else
    begin

      GAsm2.DerlemeBasarili := False;
      ShowMessage('Lütfen programı derlemeden önce kaydediniz!');
    end;
  end
  else
  begin

    ShowMessage('Hata: ' + HataKodunuAl(IslevSonuc)); // + ' - ' + GHataAciklama);
    seAssembler.CaretX := 1;
    seAssembler.CaretY := MevcutSatirSayisi;
  end;
end;

procedure TfrmAnaSayfa.miKodCalistirClick(Sender: TObject);
var
  Process: TProcessUTF8;
begin

  // program; exe olarak başarılı bir şekilde derlendiyse, çalıştır
  if(GAsm2.DerlemeBasarili) and (GAsm2.CikisDosyaUzanti = 'exe') then
  begin

    Process := TProcessUTF8.Create(nil);
    try

      Process.Executable := GAsm2.ProjeDizin + '\' + GAsm2.DosyaAdi + '.' +
        GAsm2.CikisDosyaUzanti;
      Process.Options := Process.Options + [poWaitOnExit];
      Process.Execute;
    except

      ShowMessage('Hata: program çalıştırılamıyor!');
    end;
    FreeAndNil(Process);

  end else ShowMessage('Lütfen öncelikle programı derleyiniz!');
end;

procedure TfrmAnaSayfa.miKodEtiketListesiClick(Sender: TObject);
begin

  FormuOrtala(frmAtamalar, True);
end;

procedure TfrmAnaSayfa.miYardimAssemblerBelgeClick(Sender: TObject);
begin

  {$IFDEF Windows}
  if(ShellExecute(0, nil, PChar('notepad.exe'), PChar('assembler.txt'),
    nil, SW_SHOWNORMAL) < 33) then
  begin

    ShowMessage('Hata: yardım dosyası açılamadı!');
  end;
  {$ENDIF}
end;

function TfrmAnaSayfa.FormuOrtala(GoruntulenecekForm: TForm; SonucuBekle:
  Boolean): Integer;
var
  X, Y: Integer;
begin

  X := (frmAnaSayfa.Width - GoruntulenecekForm.Width) div 2;
  Y := (frmAnaSayfa.Height - GoruntulenecekForm.Height) div 2;
  GoruntulenecekForm.Left := frmAnaSayfa.Left + X;
  GoruntulenecekForm.Top := frmAnaSayfa.Top + Y;

  if(SonucuBekle) then
    Result := GoruntulenecekForm.ShowModal
  else GoruntulenecekForm.Show;
end;

procedure TfrmAnaSayfa.SynCompletion1Execute(Sender: TObject);
begin

  OnerileriListele(SynCompletion1.CurrentString, SynCompletion1.ItemList);
end;

procedure TfrmAnaSayfa.seAssemblerClick(Sender: TObject);
begin

  DurumCubugunuGuncelle;
end;

procedure TfrmAnaSayfa.seAssemblerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  DurumCubugunuGuncelle;
end;

procedure TfrmAnaSayfa.DurumCubugunuGuncelle;
var
  DosyaAdiVeUzanti: string;
begin

  // dosya ad ve uzantısını güncelle
  if(Length(GAsm2.DosyaAdi) > 0) then
  begin

    if(Length(GAsm2.ProjeDosyaUzanti) > 0) then
      DosyaAdiVeUzanti := GAsm2.DosyaAdi + '.' + GAsm2.ProjeDosyaUzanti
    else DosyaAdiVeUzanti := GAsm2.DosyaAdi;

    sbDurum.Panels[0].Text := 'Proje Dosyası: ' + DosyaAdiVeUzanti;
  end else sbDurum.Panels[0].Text := 'Proje Dosyası: -';

  // klavye göstergesini (cursor) güncelle
  sbDurum.Panels[1].Text := 'Satır: ' + IntToStr(seAssembler.CaretY) + ' - Sütun: ' +
    IntToStr(seAssembler.CaretX);
end;

procedure TfrmAnaSayfa.ProjeDosyasiAc(ADosyaAdi: string);
var
  ProjeDizin, k, DosyaAdi, DosyaUzanti: string;
  i: Integer;
begin

  ProjeDizin := ExtractFileDir(ADosyaAdi);
  k := ExtractFileName(ADosyaAdi);

  { TODO : dosya adında birden fazla nokta bulunması halinde gerekli tedbir alınacaktır }
  i := Pos('.', k);
  if(i > 0) then
  begin

    DosyaAdi := Copy(k, 1, i - 1);
    DosyaUzanti := LowerCase(Copy(k, i + 1, Length(k) - i));
  end
  else
  begin

    DosyaAdi := k;
    DosyaUzanti := '';
  end;

  if(DosyaUzanti <> 'asm') then

    ShowMessage('Dosya biçimi desteklenmiyor!')
  else
  begin

    // tüm dahili değişkenleri ilk değerlerle yükle
    GAsm2.Ilklendir;

    GAsm2.ProjeDizin := ProjeDizin;
    GAsm2.DosyaAdi := DosyaAdi;
    GAsm2.ProjeDosyaUzanti := DosyaUzanti;

    SonKullanilanlarListesineEkle(ProjeDizin + DirectorySeparator + DosyaAdi + '.' + DosyaUzanti);
    seAssembler.Lines.LoadFromFile(ProjeDizin + DirectorySeparator + DosyaAdi + '.' + DosyaUzanti);

    seAssembler.CaretX := 1;
    seAssembler.CaretY := 1;
    DurumCubugunuGuncelle;
  end;
end;

procedure TfrmAnaSayfa.ProjeDosyasiKaydet(ADosyaAdi: string);
var
  ProjeDizin, k, DosyaAdi, DosyaUzanti: string;
  i: Integer;
begin

  ProjeDizin := ExtractFileDir(ADosyaAdi);
  k := ExtractFileName(ADosyaAdi);

  { TODO : dosya adında birden fazla nokta bulunması halinde gerekli tedbir alınacaktır }
  i := Pos('.', k);
  if(i > 0) then
  begin

    DosyaAdi := Copy(k, 1, i - 1);
    DosyaUzanti := LowerCase(Copy(k, i + 1, Length(k) - i));
  end
  else
  begin

    DosyaAdi := k;
    DosyaUzanti := '';
  end;

  GAsm2.ProjeDizin := ProjeDizin;
  GAsm2.DosyaAdi := DosyaAdi;
  GAsm2.ProjeDosyaUzanti := DosyaUzanti;

  ShowMessage(ProjeDizin + DirectorySeparator + DosyaAdi + '.' + DosyaUzanti);

  seAssembler.Lines.SaveToFile(ProjeDizin + DirectorySeparator + DosyaAdi + '.' + DosyaUzanti);

  seAssembler.CaretX := 1;
  seAssembler.CaretY := 1;
  DurumCubugunuGuncelle;
end;

// son açılan dosyayı "Son Kullanılanlar Listesi"ne ekler
procedure TfrmAnaSayfa.SonKullanilanlarListesineEkle(Dosya: string);
var
  i, BulunanSira: Integer;
  k: string;
begin

  // eklenecek dosya "son kullanılanlar listesi"nde var mı?
  BulunanSira := -1;
  for i := 0 to 4 do
  begin

    k := GProgramAyarlari.SonKullanilanDosyalar[i];
    if(k = Dosya) then
    begin

      BulunanSira := i;
      Break;
    end;
  end;

  // eğer listenin en üst sırasında ise, listeleye eklemeye gerek yok; çık.
  if(BulunanSira = 0) then Exit;

  // listede olmaması durumunda, tüm listeyi bir alt satıra kaydır
  if(BulunanSira = -1) then
  begin

    for i := 4 downto 1 do
    begin

      k := GProgramAyarlari.SonKullanilanDosyalar[i - 1];
      GProgramAyarlari.SonKullanilanDosyalar[i] := k;
    end;
  end
  else
  // listede bulunması halinde, bulunan elemandan itibaren diğer elemanları
  // bir satır aşağıya kaydır
  begin

    for i := BulunanSira downto 1 do
    begin

      k := GProgramAyarlari.SonKullanilanDosyalar[i - 1];
      GProgramAyarlari.SonKullanilanDosyalar[i] := k;
    end;
  end;

  // dosyayı listenin en üstüne ekle
  GProgramAyarlari.SonKullanilanDosyalar[0] := Dosya;

  // menü listesini güncelle
  MenuSonKullanilanlarListesiniGuncelle;
end;

// ana menünün "Son Kullanılanlar Listesi"ni güncelle
procedure TfrmAnaSayfa.MenuSonKullanilanlarListesiniGuncelle;
var
  i, SonKullanilanlarListesi: Integer;
  k: string;
begin

  // listeye eklenmiş olan eleman sayısı
  // ayıracın açılıp açılmamasının kontrolü için
  SonKullanilanlarListesi := 0;

  // 1. "son kullanılanlar listesi"ni ana menüye ekle
  // 2. ilgili menü elemanının görünürlüğünü kontrol et
  // 3. ayıracın eklenip eklenmeyeceğini kontrol et
  for i := 0 to 4 do
  begin

    k := GProgramAyarlari.SonKullanilanDosyalar[i];

    case i of
      0:
      begin

        miDosyaSonKullanilanDosya1Ac.Caption := k;
        if(Length(k) > 0) then
        begin

          miDosyaSonKullanilanDosya1Ac.Visible := True;
          Inc(SonKullanilanlarListesi);
        end else miDosyaSonKullanilanDosya1Ac.Visible := False;
      end;
      1:
      begin

        miDosyaSonKullanilanDosya2Ac.Caption := k;
        if(Length(k) > 0) then
        begin

          miDosyaSonKullanilanDosya2Ac.Visible := True;
          Inc(SonKullanilanlarListesi);
        end else miDosyaSonKullanilanDosya2Ac.Visible := False;
      end;
      2:
      begin

        miDosyaSonKullanilanDosya3Ac.Caption := k;
        if(Length(k) > 0) then
        begin

          miDosyaSonKullanilanDosya3Ac.Visible := True;
          Inc(SonKullanilanlarListesi);
        end else miDosyaSonKullanilanDosya3Ac.Visible := False;
      end;
      3:
      begin

        miDosyaSonKullanilanDosya4Ac.Caption := k;
        if(Length(k) > 0) then
        begin

          miDosyaSonKullanilanDosya4Ac.Visible := True;
          Inc(SonKullanilanlarListesi);
        end else miDosyaSonKullanilanDosya4Ac.Visible := False;
      end;
      4:
      begin

        miDosyaSonKullanilanDosya5Ac.Caption := k;
        if(Length(k) > 0) then
        begin

          miDosyaSonKullanilanDosya5Ac.Visible := True;
          Inc(SonKullanilanlarListesi);
        end else miDosyaSonKullanilanDosya5Ac.Visible := False;
      end;
    end;
  end;

  // en az bir eleman var ise, ayıracı aktifleştir
  if(SonKullanilanlarListesi > 0) then miDosyaAyrim0.Visible := True;
end;

end.
