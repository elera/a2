{-------------------------------------------------------------------------------

  Dosya: anasayfaform.pas

  İşlev: program ana sayfası

  Güncelleme Tarihi: 12/05/2018

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
    miDosyaAcANSI: TMenuItem;
    miDosyaAyarlar: TMenuItem;
    miDosyaAyrim2: TMenuItem;
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
    pcDosyalar: TPageControl;
    SaveDialog1: TSaveDialog;
    sbDurum: TStatusBar;
    seDosya0: TSynEdit;
    SynAssemblerSyn: TSynAnySyn;
    SynCompletion1: TSynCompletion;
    tbAyrim4: TToolButton;
    tbDosyaAyarlar: TToolButton;
    tsDosya0: TTabSheet;
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
    procedure DuzenleyiciAlaniOlustur(DosyaAdi: string);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormShow(Sender: TObject);
    procedure miDosyaAcANSIClick(Sender: TObject);
    procedure miDosyaAcClick(Sender: TObject);
    procedure miDosyaAyarlarClick(Sender: TObject);
    procedure miDosyaCikisClick(Sender: TObject);
    procedure miDosyaKaydetClick(Sender: TObject);
    procedure miDosyaSonKullanilanDosyayiAcClick(Sender: TObject);
    procedure miDosyaYeniClick(Sender: TObject);
    procedure miKodEtiketListesiClick(Sender: TObject);
    procedure miYardimAssemblerBelgeClick(Sender: TObject);
    procedure miKodDerleClick(Sender: TObject);
    function FormuOrtala(GoruntulenecekForm: TForm; SonucuBekle: Boolean): Integer;
    procedure miKodCalistirClick(Sender: TObject);
    procedure seDosya0Click(Sender: TObject);
    procedure seDosya0KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SynCompletion1Execute(Sender: TObject);
  private
    procedure DurumCubugunuGuncelle;
    procedure ProjeDosyasiAc(ADosyaAdi: string; CP1254KarakterSetiniKullan: Boolean);
    procedure ProjeDosyasiKaydet(ADosyaAdi: string);
    procedure SonKullanilanlarListesineEkle(Dosya: string);
    procedure MenuSonKullanilanlarListesiniGuncelle;
    procedure DosyayiDuzenleyiciyeYukle(Duzenleyici: TSynEdit;
      DosyaAdi: string; CP1254KarakterSetiniKullan: Boolean);
    function KodlariDerle: Integer;
  public
  end;

var
  frmAnaSayfa: TfrmAnaSayfa;

implementation

{$R *.lfm}

uses incele, genel, atamalar, dosya, derlemebilgisiform, atamalarform, asm2,
  ayarlar, yazmaclar, {$IFDEF Windows} windows, {$ENDIF} process, oneriler, komutlar, dbugintf,
  paylasim, donusum, LConvEncoding, ayarlarform, kodlama, araclar;

procedure TfrmAnaSayfa.FormCreate(Sender: TObject);
begin

  // programın üzerinde çalıştığı / derleme yaptığı sistemin mimarisi
  SistemMimari := SistemMimarisiniAl;

  GDosyaKimlikNo := 1;

  // çalışma zamanlı nesneler oluşturuluyor
  GAsm2 := TAsm2.Create;

  // dosyaların sürüklenip bırakılmasına izin ver
  Self.AllowDropFiles := True;

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
end;

procedure TfrmAnaSayfa.FormShow(Sender: TObject);
var
  i: Integer;
begin

  // test amaçlı düzenleyici alanı oluştur
  DuzenleyiciAlaniOlustur('test.asm');
  pcDosyalar.ActivePageIndex := 0;

  case SistemMimari of
    sm32Bit: sbDurum.Panels[0].Text := 'Sistem: 32 Bit';
    sm64Bit: sbDurum.Panels[0].Text := 'Sistem: 64 Bit';
    smDiger: sbDurum.Panels[0].Text := 'Sistem: ?';
  end;

  sbDurum.Panels[2].Text := 'Sürüm: ' + ProgramSurum + ' - ' + SurumTarihi;

  SynAssemblerSyn.Objects.Clear;
  for i := 0 to TOPLAM_KOMUT - 1 do
    SynAssemblerSyn.Objects.Add(UpperCase(KomutListesi[i].Komut));

  SynAssemblerSyn.KeyWords.Clear;
  for i := 0 to TOPLAM_YAZMAC - 1 do
    SynAssemblerSyn.KeyWords.Add(UpperCase(YazmacListesi[i].Ad));

  Self.Left := GProgramAyarlari.PencereSol;
  Self.Top := GProgramAyarlari.PencereUst;
  Self.Width := GProgramAyarlari.PencereGenislik;
  Self.Height := GProgramAyarlari.PencereYukseklik;
  Self.WindowState := GProgramAyarlari.PencereDurum;

  // düzenleyici (editor) yazı boyutu
  seDosya0.Font.Size := GProgramAyarlari.DuzenleyiciYaziBoyut;

  // ayarlarda, program açılışında son kullanılan dosyanın açılması varsa, aç
  if(GProgramAyarlari.SonKullanilanDosyayiAc) then
  begin

    // son kullanılan dosyaya atama yapılıp yapılmadığını kontrol et
    if(Length(GProgramAyarlari.SonKullanilanDosyalar[0]) > 0) then
      ProjeDosyasiAc(GProgramAyarlari.SonKullanilanDosyalar[0], False);
  end;
end;

procedure TfrmAnaSayfa.miDosyaAcANSIClick(Sender: TObject);
begin

  // en son açılan dosya listesinde herhangi bir dosya varsa,
  // dosyayı CP1254 karakter seti ile aç
  if(Length(GProgramAyarlari.SonKullanilanDosyalar[0]) > 0) then
    ProjeDosyasiAc(GProgramAyarlari.SonKullanilanDosyalar[0], True);
end;

procedure TfrmAnaSayfa.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  // bellek içeriğini temizle
  KodBellekDegerleriniIlklendir;

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

procedure TfrmAnaSayfa.DuzenleyiciAlaniOlustur(DosyaAdi: string);
var
  tsDosya: TTabSheet;
  seDosya: TSynEdit;
  ToplamDuzenleyici: Integer;
begin

  ToplamDuzenleyici := pcDosyalar.PageCount;

  tsDosya := pcDosyalar.AddTabSheet;
  tsDosya.Tag := GDosyaKimlikNo;
  tsDosya.Name := Format('tsDosya%d', [GDosyaKimlikNo]);
  tsDosya.Caption := DosyaAdi;
  tsDosya.ImageIndex := 9;

  seDosya := TSynEdit.Create(Self);
  seDosya.Tag := GDosyaKimlikNo;
  seDosya.Name := Format('seDosya%d', [GDosyaKimlikNo]);
  seDosya.Parent := tsDosya;
  seDosya.Align := alClient;
  seDosya.Highlighter := SynAssemblerSyn;
  seDosya.Font.Name := 'Courier New';
  seDosya.Font.Size := GProgramAyarlari.DuzenleyiciYaziBoyut;
  seDosya.Gutter.Width := 55;
  seDosya.Text := 'db	04Dh';

  pcDosyalar.ActivePageIndex := ToplamDuzenleyici;

  Inc(GDosyaKimlikNo);
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
  else ProjeDosyasiAc(FileNames[0], False);
end;

procedure TfrmAnaSayfa.miDosyaYeniClick(Sender: TObject);
begin

  // kod sayfasını temizle
  seDosya0.Clear;

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
  if(OpenDialog1.Execute) then ProjeDosyasiAc(OpenDialog1.Filename, False);
end;

procedure TfrmAnaSayfa.miDosyaAyarlarClick(Sender: TObject);
begin

  if(FormuOrtala(frmAyarlar, True) = mrOK) then
  begin

    seDosya0.Font.Size := GProgramAyarlari.DuzenleyiciYaziBoyut;
  end;
end;

procedure TfrmAnaSayfa.miDosyaCikisClick(Sender: TObject);
begin

  Close;
end;

procedure TfrmAnaSayfa.miDosyaKaydetClick(Sender: TObject);
begin

  // dosya daha önceden kaydedilmiş veya açılmış ise...
  if(Length(GAsm2.ProjeDosyaAdi) > 0) then
  begin

    seDosya0.Lines.SaveToFile(GAsm2.ProjeDizin + DirectorySeparator +
      GAsm2.ProjeDosyaAdi + '.' + GAsm2.ProjeDosyaUzanti);
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
  ProjeDosyasiAc(GProgramAyarlari.SonKullanilanDosyalar[DosyaSira], False);
end;

// kod derleme menüsü
procedure TfrmAnaSayfa.miKodDerleClick(Sender: TObject);
var
  DerlemeSonucu: Integer;
begin

  // düzenleyicideki kodları derle
  DerlemeSonucu := KodlariDerle;

  // derleme esnasında hata var ise...
  if(DerlemeSonucu > HATA_YOK) then
  begin

    if(DerlemeSonucu = HATA_PROJEYI_KAYDET) then

      ShowMessage('Lütfen programı derlemeden önce kaydediniz!')

    else if(DerlemeSonucu = HATA_PROG_DOSYA_OLUSTURMA) then
    begin

      ShowMessage('Hata: ' + GAsm2.ProgramDosyaAdi + ' dosyası oluşturulamadı!')
    end
    else
    // derleme başarılı
    begin

      ShowMessage('Hata: ' + HataKodunuAl(DerlemeSonucu)); // + ' - ' + GHataAciklama);
      seDosya0.CaretX := 1;
      seDosya0.CaretY := GAsm2.IslenenSatir;
    end;
  end
  else
  begin

    frmDerlemeBilgisi.ProjeDosyaAdi := GAsm2.ProjeDosyaAdi + '.' + GAsm2.ProjeDosyaUzanti;
    frmDerlemeBilgisi.DerlenenDosya := GAsm2.ProgramDosyaAdi;
    frmDerlemeBilgisi.DerlenenSatirSayisi := GAsm2.IslenenSatirSayisi;
    frmDerlemeBilgisi.IkiliDosyaUzunluk := KodBellekU;
    frmDerlemeBilgisi.DerlemeCevrimSayisi := GAsm2.DerlemeCevrimSayisi;
    FormuOrtala(frmDerlemeBilgisi, True);
  end
end;

procedure TfrmAnaSayfa.miKodCalistirClick(Sender: TObject);
var
  Process: TProcessUTF8;
begin

  // kodlar daha önce derlenmiş veya program derleme aşamasında hata olmamış
  // olsa bile düzenleyicideki kodları MUTLAKA bir kez derle
  KodlariDerle;

  // program; exe olarak başarılı bir şekilde derlendiyse, çalıştır
  if(GAsm2.DerlemeBasarili) and (GAsm2.CikisDosyaUzanti = 'exe') then
  begin

    Process := TProcessUTF8.Create(nil);
    try

      Process.Executable := GAsm2.ProjeDizin + '\' + GAsm2.CikisDosyaAdi + '.' +
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

procedure TfrmAnaSayfa.seDosya0Click(Sender: TObject);
begin

  DurumCubugunuGuncelle;
end;

procedure TfrmAnaSayfa.seDosya0KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  DurumCubugunuGuncelle;
end;

procedure TfrmAnaSayfa.DurumCubugunuGuncelle;
var
  DosyaAdiVeUzanti: string;
begin

  // dosya ad ve uzantısını güncelle
  if(Length(GAsm2.ProjeDosyaAdi) > 0) then
  begin

    if(Length(GAsm2.ProjeDosyaUzanti) > 0) then
      DosyaAdiVeUzanti := GAsm2.ProjeDosyaAdi + '.' + GAsm2.ProjeDosyaUzanti
    else DosyaAdiVeUzanti := GAsm2.ProjeDosyaAdi;

    pcDosyalar.Pages[0].Caption := DosyaAdiVeUzanti;
  end else pcDosyalar.Pages[0].Caption := '-';

  // klavye göstergesini (cursor) güncelle
  sbDurum.Panels[1].Text := 'Satır: ' + IntToStr(seDosya0.CaretY) + ' - Sütun: ' +
    IntToStr(seDosya0.CaretX);
end;

procedure TfrmAnaSayfa.ProjeDosyasiAc(ADosyaAdi: string; CP1254KarakterSetiniKullan: Boolean);
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
    GAsm2.ProjeDosyaAdi := DosyaAdi;
    GAsm2.ProjeDosyaUzanti := DosyaUzanti;

    SonKullanilanlarListesineEkle(ProjeDizin + DirectorySeparator + DosyaAdi +
      '.' + DosyaUzanti);

    // Öndeğer olarak a2 programı UTF-8 karakter setini kullanır
    DosyayiDuzenleyiciyeYukle(seDosya0, ProjeDizin + DirectorySeparator + DosyaAdi +
      '.' + DosyaUzanti, CP1254KarakterSetiniKullan);

    seDosya0.CaretX := 1;
    seDosya0.CaretY := 1;
    seDosya0.SetFocus;

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
  GAsm2.ProjeDosyaAdi := DosyaAdi;
  GAsm2.ProjeDosyaUzanti := DosyaUzanti;

  ShowMessage(ProjeDizin + DirectorySeparator + DosyaAdi + '.' + DosyaUzanti);

  seDosya0.Lines.SaveToFile(ProjeDizin + DirectorySeparator + DosyaAdi + '.' + DosyaUzanti);

  seDosya0.CaretX := 1;
  seDosya0.CaretY := 1;
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

procedure TfrmAnaSayfa.DosyayiDuzenleyiciyeYukle(Duzenleyici: TSynEdit;
  DosyaAdi: string; CP1254KarakterSetiniKullan: Boolean);
var
  Dosya: TextFile;
  Veri: string;
begin

  Duzenleyici.Clear;

  AssignFile(Dosya, DosyaAdi);
  {$I-} Reset(Dosya); {$I+}

  if(IOResult = 0) then
  begin

    while not EOF(Dosya) do
    begin

      ReadLn(Dosya, Veri);

      if(CP1254KarakterSetiniKullan) then
        Duzenleyici.Lines.Add(CP1254ToUTF8(Veri))
      else Duzenleyici.Lines.Add(Veri);

      Application.ProcessMessages;
    end;

    CloseFile(Dosya);
  end;
end;

function TfrmAnaSayfa.KodlariDerle: Integer;
var
  ToplamSatirSayisi, i: Integer;
  HamVeri: string;
  IslevSonuc: Integer;
  DerlemeCevrimindenCik: Boolean;
begin

  DerlemeCevrimindenCik := False;

  // mevcut etiketleri temizle
  GAsm2.AtamaListesi.Temizle;

  // ilk değer atamaları
  GAsm2.DerlemeCevrimSayisi := 0;

  while (DerlemeCevrimindenCik = False) do
  begin

    IslevSonuc := HATA_YOK;

    GEtiketHataSayisi := 0;

    // bellek değişkenleri ve bellek içeriğini ilk değerlerle yükle
    KodBellekDegerleriniIlklendir;

    ToplamSatirSayisi := seDosya0.Lines.Count;
    GAsm2.IslenenSatir := 0;
    GAsm2.IslenenSatirSayisi := 0;

    // son satıra gelinmediği ve hata olmadığı müddetçe devam et
    while (GAsm2.IslenenSatir < ToplamSatirSayisi) and (IslevSonuc = HATA_YOK) do
    begin

      HamVeri := seDosya0.Lines[GAsm2.IslenenSatir];

      if(Length(Trim(HamVeri)) > 0) then
      begin

        // satır içerik değişkenlerini ilk değerlerle yükle
        SatirIcerik.Komut.KomutTipi := ktBelirsiz;

        SatirIcerik.DigerVeri := [];
        SatirIcerik.Etiket := '';
        SatirIcerik.Aciklama := '';

        SatirIcerik.Komut.GrupNo := -1;
        SatirIcerik.BolumTip1.BolumAnaTip := batYok;
        SatirIcerik.BolumTip1.BolumAyrinti := [];
        SatirIcerik.BolumTip2.BolumAnaTip := batYok;
        SatirIcerik.BolumTip2.BolumAyrinti := [];

        // ilgili satırın incelendiği / kodların üretildiği ana çağrı
        IslevSonuc := KodUret(GAsm2.IslenenSatir, HamVeri);

        // işlenen satır sayısını artır
        i := GAsm2.IslenenSatirSayisi;
        Inc(i);
        GAsm2.IslenenSatirSayisi := i;
      end;

      // bir sonraki satıra geçiş yap
      i := GAsm2.IslenenSatir;
      Inc(i);
      GAsm2.IslenenSatir := i;
      Application.ProcessMessages;
    end;

    // hata olduğu için çıkış yap
    if(IslevSonuc > HATA_YOK) then

      DerlemeCevrimindenCik := True

    // derleme başarılı olduğu için çıkış yap
    else if(IslevSonuc = HATA_YOK) and (GAsm2.AtamaListesi.Temizle2 = 0) then

      DerlemeCevrimindenCik := True;

    // çevrim sayısını bir artır
    GAsm2.DerlemeCevrimSayisi := GAsm2.DerlemeCevrimSayisi + 1;

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
    if(Length(GAsm2.CikisDosyaAdi) > 0) then
    begin

      // dosya uzantısının olmaması durumunda dosyaya uzantı ekleme (özellikle linux için)
      if(Length(GAsm2.CikisDosyaUzanti) > 0) then
        GAsm2.ProgramDosyaAdi := GAsm2.CikisDosyaAdi + '.' + GAsm2.CikisDosyaUzanti
      else GAsm2.ProgramDosyaAdi := GAsm2.CikisDosyaAdi;

      if(ProgramDosyasiOlustur(GAsm2.ProjeDizin + DirectorySeparator + GAsm2.ProgramDosyaAdi)) then

        Result := HATA_YOK
      else Result := HATA_PROG_DOSYA_OLUSTURMA;
    end else Result := HATA_PROJEYI_KAYDET;
  end else Result := IslevSonuc;
end;

end.
