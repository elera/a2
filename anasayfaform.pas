{-------------------------------------------------------------------------------

  Dosya: anasayfaform.pas

  İşlev: program ana sayfası

  Güncelleme Tarihi: 11/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit anasayfaform;

interface

uses
  Classes, SysUtils, FileUtil, UTF8Process, SynEdit, SynHighlighterAny,
  SynCompletion, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Menus, LCLType, dosya;

type

  { TfrmAnaSayfa }

  TfrmAnaSayfa = class(TForm)
    ilAnaMenu16: TImageList;
    ilDuzenleyiciMenu: TImageList;
    miDuzenleyiciAyirac0: TMenuItem;
    miDuzenleyiciSayfayiSagaTasi: TMenuItem;
    miDuzenleyiciSayfayiSolaTasi: TMenuItem;
    miDuzenleyiciAyirac1: TMenuItem;
    miDuzenleyiciSayfadakiDosyayiAc: TMenuItem;
    miDuzenleyiciSayfayiKapat: TMenuItem;
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
    pmDuzenleyici: TPopupMenu;
    SaveDialog1: TSaveDialog;
    sbDurum: TStatusBar;
    SynAssemblerSyn: TSynAnySyn;
    SynCompletion1: TSynCompletion;
    tbAyrim4: TToolButton;
    tbDosyaAyarlar: TToolButton;
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
    function DuzenleyiciAlaniOlustur(Dosya: TDosya): TSynEdit;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const Dosyalar: array of string);
    procedure FormShow(Sender: TObject);
    procedure miDuzenleyiciSayfayiSagaTasiClick(Sender: TObject);
    procedure miDuzenleyiciSayfayiSolaTasiClick(Sender: TObject);
    procedure miDuzenleyiciSayfadakiDosyayiAcClick(Sender: TObject);
    procedure miDosyaAcANSIClick(Sender: TObject);
    procedure miDosyaAcClick(Sender: TObject);
    procedure miDosyaAyarlarClick(Sender: TObject);
    procedure miDosyaCikisClick(Sender: TObject);
    procedure miDosyaKaydetClick(Sender: TObject);
    procedure miDosyaSonKullanilanDosyayiAcClick(Sender: TObject);
    procedure miDosyaYeniClick(Sender: TObject);
    procedure miDuzenleyiciSayfayiKapatClick(Sender: TObject);
    procedure miKodEtiketListesiClick(Sender: TObject);
    procedure miYardimAssemblerBelgeClick(Sender: TObject);
    procedure miKodDerleClick(Sender: TObject);
    function FormuOrtala(GoruntulenecekForm: TForm; SonucuBekle: Boolean): Integer;
    procedure miKodCalistirClick(Sender: TObject);
    procedure pcDosyalarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure seDosya0Click(Sender: TObject);
    procedure seDosya0KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SynCompletion1Execute(Sender: TObject);
    procedure SynEdit1Change(Sender: TObject);
  private
    procedure DurumCubugunuGuncelle;
    procedure ProjeDosyasiYukle(seDosya: TSynEdit; Dosya: TDosya;
      CP1254KarakterSetiniKullan: Boolean);
    procedure SonKullanilanlarListesineEkle(Dosya: string);
    procedure MenuSonKullanilanlarListesiniGuncelle;
    procedure DosyayiDuzenleyiciyeYukle(Duzenleyici: TSynEdit; Dosya: TDosya;
      CP1254KarakterSetiniKullan: Boolean);
    function KodlariDerle(AktifDuzenleyici: TSynEdit): Integer;
    function DosyaDuzenleyiciSiraNumarasiAl(DosyaKimlik: Integer): Integer;
  public
  end;

var
  frmAnaSayfa: TfrmAnaSayfa;

implementation

{$R *.lfm}

uses incele, genel, atamalar, derlemebilgisiform, atamalarform, asm2,
  ayarlar, yazmaclar, {$IFDEF Windows} windows, {$ENDIF} process, oneriler, komutlar, dbugintf,
  paylasim, donusum, LConvEncoding, ayarlarform, kodlama, araclar, dateutils, LCLIntf;

procedure TfrmAnaSayfa.FormCreate(Sender: TObject);
begin

  // programın üzerinde çalıştığı / derleme yaptığı sistemin mimarisi
  SistemMimari := SistemMimarisiniAl;

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
  seDosya: TSynEdit;
  i: Integer;
begin

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

  // ayarlarda, daha önce açık olan dosyaların tab alanında yeniden açılması
  // işaretlenmişse...
  // bilgi: bu dosya listesi, program ilk başladığında ayarlar /
  // INIDosyasiniOku işlevi tarafından dosya listesine eklenir
  if(GProgramAyarlari.AcikDosyalariTabAlanindaAc) then
  begin

    // daha önce açık iken kaydedilen düzenleyici dosyalar var ise...
    if(GAsm2.Dosyalar.Toplam > 0) then
    begin

      for i := 0 to GAsm2.Dosyalar.Toplam - 1 do
      begin

        GAktifDosya := GAsm2.Dosyalar.Eleman[i];

        seDosya := DuzenleyiciAlaniOlustur(GAktifDosya);
        if(seDosya = nil) then
        begin

          ShowMessage('Hata: daha fazla düzenleyici alanı açılamıyor!');
        end
        else
        begin

          GAktifDuzenleyici := seDosya;
          ProjeDosyasiYukle(seDosya, GAktifDosya, False);
        end;
      end;

      if(pcDosyalar.PageCount > 0) then
      begin

        pcDosyalar.ActivePageIndex := 0;

        GAktifDosya := GAsm2.Dosyalar.Bul(pcDosyalar.ActivePage.Tag);
        GAktifDuzenleyici := TSynEdit(FindComponent('seDosya' + IntToStr(pcDosyalar.ActivePage.Tag)));

        DurumCubugunuGuncelle;
      end;
    end else miDosyaYeniClick(Self);
  end else miDosyaYeniClick(Self);
end;

procedure TfrmAnaSayfa.miDuzenleyiciSayfayiSagaTasiClick(Sender: TObject);
var
  CurrentIndex: Integer;
begin

  CurrentIndex := pcDosyalar.ActivePageIndex;

  if(CurrentIndex < (pcDosyalar.PageCount - 1)) then

    pcDosyalar.Pages[CurrentIndex].PageIndex := CurrentIndex + 1;
end;

procedure TfrmAnaSayfa.miDuzenleyiciSayfayiSolaTasiClick(Sender: TObject);
var
  CurrentIndex: Integer;
begin

  CurrentIndex := pcDosyalar.ActivePageIndex;

  if(CurrentIndex > 0) then

    pcDosyalar.Pages[CurrentIndex].PageIndex := CurrentIndex - 1;
end;

procedure TfrmAnaSayfa.miDuzenleyiciSayfadakiDosyayiAcClick(Sender: TObject);
var
  Dosya: TDosya;
begin

  Dosya := GAsm2.Dosyalar.Bul(pcDosyalar.ActivePage.Tag);
  OpenDocument(Dosya.ProjeDizin);
end;

procedure TfrmAnaSayfa.miDosyaAcANSIClick(Sender: TObject);
var
  seDosya: TSynEdit;
  Dosya: TDosya;
begin

  if(pcDosyalar.PageCount > 0) then
  begin

    Dosya := GAsm2.Dosyalar.Bul(pcDosyalar.ActivePage.Tag);
    if not(Dosya = nil) then
    begin

      seDosya := FindComponent('seDosya' + IntToStr(pcDosyalar.ActivePage.Tag)) as TSynEdit;

      // açılan dosyayı CP1254 karakter seti ile yeniden aç
      ProjeDosyasiYukle(seDosya, Dosya, True);
    end;
  end;
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

// açılacak dosya için düzenleyicide (editor) nesneleri oluşturur
function TfrmAnaSayfa.DuzenleyiciAlaniOlustur(Dosya: TDosya): TSynEdit;
var
  tsDosya: TTabSheet;
  seDosya: TSynEdit;
  ToplamDuzenleyici: Integer;
begin

  if not(Dosya = nil) then
  begin

    ToplamDuzenleyici := pcDosyalar.PageCount;

    tsDosya := pcDosyalar.AddTabSheet;
    tsDosya.Tag := Dosya.Kimlik;
    tsDosya.Name := Format('tsDosya%d', [Dosya.Kimlik]);
    tsDosya.Caption := Dosya.ProjeDosyaAdi + '.' + Dosya.ProjeDosyaUzanti;
    tsDosya.ImageIndex := 9;

    seDosya := TSynEdit.Create(Self);
    seDosya.Tag := Dosya.Kimlik;
    seDosya.Name := Format('seDosya%d', [Dosya.Kimlik]);
    seDosya.Parent := tsDosya;
    seDosya.Align := alClient;
    seDosya.Highlighter := SynAssemblerSyn;
    seDosya.Font.Name := 'Courier New';
    seDosya.Font.Size := GProgramAyarlari.DuzenleyiciYaziBoyut;
    seDosya.Gutter.Width := 55;
    seDosya.Options := [eoBracketHighlight, eoGroupUndo, eoTabsToSpaces, eoTrimTrailingSpaces];
    seDosya.ClearAll;
    seDosya.OnClick := @seDosya0Click;
    seDosya.OnKeyDown := @seDosya0KeyDown;

    pcDosyalar.ActivePageIndex := ToplamDuzenleyici;

    Result := seDosya;

  end else Result := nil;
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

// dosyaların ana pencere üzerine sürüklenerek açma işlemi
procedure TfrmAnaSayfa.FormDropFiles(Sender: TObject; const Dosyalar: array of string);
var
  Dosya: TDosya;
  seDosya: TSynEdit;
  DosyaSayisi, i, DosyaDuzenleyiciSiraNumarasi: Integer;
  DosyaAcik: Boolean;
begin

  // sürüklenen dosya sayısı
  DosyaSayisi := Length(Dosyalar);

  if(DosyaSayisi > 0) then
  begin

    for i := 0 to DosyaSayisi - 1 do
    begin

      Dosya := GAsm2.Dosyalar.Ekle(Dosyalar[i], False, DosyaAcik);
      if not(Dosya = nil) then
      begin

        GAktifDosya := Dosya;

        // dosya daha önce açık ise, açık olan dosyayı düzenleyici alanında etkinleştir
        if(DosyaAcik) then
        begin

          DosyaDuzenleyiciSiraNumarasi := DosyaDuzenleyiciSiraNumarasiAl(Dosya.Kimlik);
          if(DosyaDuzenleyiciSiraNumarasi > -1) then
          begin

            pcDosyalar.ActivePageIndex := DosyaDuzenleyiciSiraNumarasi;

            GAktifDuzenleyici := TSynEdit(FindComponent('seDosya' + IntToStr(Dosya.Kimlik)));

            DurumCubugunuGuncelle;
          end;
        end
        else
        begin

          seDosya := DuzenleyiciAlaniOlustur(Dosya);
          if(seDosya = nil) then
          begin

            ShowMessage('Hata: daha fazla düzenleyici alanı açılamıyor!');
          end
          else
          begin

            GAktifDuzenleyici := seDosya;

            ProjeDosyasiYukle(seDosya, Dosya, False);
          end;
        end;
      end else ShowMessage('Hata: daha fazla düzenleyici alanı açılamıyor!');
    end;
  end;
end;

procedure TfrmAnaSayfa.miDosyaYeniClick(Sender: TObject);
var
  Dosya: TDosya;
  seDosya: TSynEdit;
  DosyaAcik: Boolean;
begin

  // düzenleyici için yeni dosya yapısı oluştur
  Dosya := GAsm2.Dosyalar.Ekle('', True, DosyaAcik);
  if not(Dosya = nil) then
  begin

    seDosya := DuzenleyiciAlaniOlustur(Dosya);
    if(seDosya = nil) then

      ShowMessage('Hata: daha fazla düzenleyici alanı açılamıyor!')
    else
    begin

      GAktifDosya := Dosya;
      GAktifDuzenleyici := seDosya;

      DurumCubugunuGuncelle;
    end;
  end else ShowMessage('Hata: daha fazla düzenleyici alanı açılamıyor!')
end;

procedure TfrmAnaSayfa.miDuzenleyiciSayfayiKapatClick(Sender: TObject);
var
  tsDosya: TTabSheet;
  seDosya: TSynEdit;
  KimlikNo: Integer;
begin

  // en son oluşturulan nesneden ilk nesneye kadar dinamik olarak
  // oluşturulmuş nesneleri yok et
  KimlikNo := pcDosyalar.ActivePage.Tag;

  // dosya ile ilgili bilgilerin tutulduğu yapıyı sil
  GAsm2.Dosyalar.Sil(KimlikNo);

  seDosya := FindComponent('seDosya' + IntToStr(KimlikNo)) as TSynEdit;
  seDosya.Free;

  tsDosya := FindComponent('tsDosya' + IntToStr(KimlikNo)) as TTabSheet;
  tsDosya.Free;

  // tab alanını sil
  pcDosyalar.Pages[pcDosyalar.ActivePageIndex].Free;

  // aktif düzenleyicinin aktif nesnelerini yeniden belirle
  if(pcDosyalar.PageCount > 0) then
  begin

    KimlikNo := pcDosyalar.ActivePage.Tag;
    GAktifDosya := GAsm2.Dosyalar.Bul(KimlikNo);
    GAktifDuzenleyici := TSynEdit(FindComponent('seDosya' + IntToStr(KimlikNo)));

    DurumCubugunuGuncelle;
  end
  else
  begin

    GAktifDosya := nil;
    GAktifDuzenleyici := nil;
  end;
end;

procedure TfrmAnaSayfa.miDosyaAcClick(Sender: TObject);
var
  Dosya: TDosya;
  seDosya: TSynEdit;
  DosyaAcik: Boolean;
  DosyaDuzenleyiciSiraNumarasi: Integer;
begin

  OpenDialog1.Title := 'Assembler Dosyası Aç';
  OpenDialog1.Filter := 'Assembler Dosyası|*.asm';
  OpenDialog1.InitialDir := GSonKullanilanDizin;
  OpenDialog1.DefaultExt := 'asm';
  OpenDialog1.FileName := '';
  if(OpenDialog1.Execute) then
  begin

    // son kullanılan dizini güncelle
    GSonKullanilanDizin := OpenDialog1.InitialDir;

    Dosya := GAsm2.Dosyalar.Ekle(OpenDialog1.Filename, False, DosyaAcik);
    if not(Dosya = nil) then
    begin

      GAktifDosya := Dosya;

      // dosya daha önce açık ise, açık olan dosyayı düzenleyici alanında etkinleştir
      if(DosyaAcik) then
      begin

        DosyaDuzenleyiciSiraNumarasi := DosyaDuzenleyiciSiraNumarasiAl(Dosya.Kimlik);
        if(DosyaDuzenleyiciSiraNumarasi > -1) then
        begin

          pcDosyalar.ActivePageIndex := DosyaDuzenleyiciSiraNumarasi;

          GAktifDuzenleyici := TSynEdit(FindComponent('seDosya' + IntToStr(Dosya.Kimlik)));

          DurumCubugunuGuncelle;
        end;
      end
      else
      begin

        seDosya := DuzenleyiciAlaniOlustur(Dosya);
        if(seDosya = nil) then

          ShowMessage('Hata: daha fazla düzenleyici alanı açılamıyor!')
        else
        begin

          GAktifDuzenleyici := seDosya;

          ProjeDosyasiYukle(seDosya, Dosya, False);
        end;
      end;
    end else ShowMessage('Hata: daha fazla düzenleyici alanı açılamıyor!')
  end;
end;

procedure TfrmAnaSayfa.ProjeDosyasiYukle(seDosya: TSynEdit; Dosya: TDosya;
  CP1254KarakterSetiniKullan: Boolean);
begin

  if(Dosya.ProjeDosyaUzanti <> 'asm') then

    ShowMessage('Dosya biçimi desteklenmiyor!')
  else
  begin

    SonKullanilanlarListesineEkle(Dosya.ProjeDizin + DirectorySeparator +
      Dosya.ProjeDosyaAdi + '.' + Dosya.ProjeDosyaUzanti);

    // öndeğer olarak a2 programı UTF-8 karakter setini kullanır
    DosyayiDuzenleyiciyeYukle(seDosya, Dosya, CP1254KarakterSetiniKullan);

    seDosya.CaretX := 1;
    seDosya.CaretY := 1;
    seDosya.SetFocus;

    GAktifDuzenleyici := seDosya;

    DurumCubugunuGuncelle;
  end;
end;

procedure TfrmAnaSayfa.miDosyaAyarlarClick(Sender: TObject);
var
  seDosya: TSynEdit;
  i: Integer;
begin

  if(FormuOrtala(frmAyarlar, True) = mrOK) then
  begin

    if(pcDosyalar.PageCount > 0) then
    begin

      for i := 0 to pcDosyalar.PageCount - 1 do
      begin

        seDosya := FindComponent('seDosya' + IntToStr(pcDosyalar.Pages[i].Tag)) as TSynEdit;
        seDosya.Font.Size := GProgramAyarlari.DuzenleyiciYaziBoyut;
      end;
    end;
  end;
end;

procedure TfrmAnaSayfa.miDosyaCikisClick(Sender: TObject);
begin

  Close;
end;

procedure TfrmAnaSayfa.miDosyaKaydetClick(Sender: TObject);
var
  seDosya: TSynEdit;
  Dosya: TDosya;
  Dizin, DosyaAdi, DosyaUzanti: string;
  DosyaDuzenleyiciSiraNumarasi: Integer;
begin

  if(pcDosyalar.PageCount > 0) then
  begin

    Dosya := GAsm2.Dosyalar.Bul(pcDosyalar.ActivePage.Tag);
    if not(Dosya = nil) then
    begin

      if(Dosya.Durum = ddYeni) then
      begin

        SaveDialog1.Title := 'Assembler Dosyası Kaydet';
        SaveDialog1.Filter := 'Assembler Dosyası|*.asm';
        SaveDialog1.InitialDir := Dosya.ProjeDizin;
        SaveDialog1.DefaultExt := Dosya.ProjeDosyaUzanti;
        SaveDialog1.FileName := Dosya.ProjeDosyaAdi;
        if(SaveDialog1.Execute) then
        begin

          // son kullanılan dizini güncelle
          GSonKullanilanDizin := OpenDialog1.InitialDir;

          if(DosyaYolunuAyristir(SaveDialog1.Filename, Dizin, DosyaAdi, DosyaUzanti)) then
          begin

            Dosya.ProjeDizin := Dizin;
            Dosya.ProjeDosyaAdi := DosyaAdi;
            Dosya.ProjeDosyaUzanti := DosyaUzanti;
            Dosya.Durum := ddKaydedildi;

            // dosya ad ve uzantısı değişmiş olabilir, değiştir.
            DosyaDuzenleyiciSiraNumarasi := DosyaDuzenleyiciSiraNumarasiAl(Dosya.Kimlik);
            if(Length(DosyaUzanti) > 0) then
              pcDosyalar.Pages[DosyaDuzenleyiciSiraNumarasi].Caption := DosyaAdi + '.' + DosyaUzanti
            else pcDosyalar.Pages[DosyaDuzenleyiciSiraNumarasi].Caption := DosyaAdi;

            seDosya := TSynEdit(FindComponent('seDosya' + IntToStr(Dosya.Kimlik)));

            seDosya.Lines.SaveToFile(Dosya.ProjeDizin + DirectorySeparator +
              Dosya.ProjeDosyaAdi + '.' + Dosya.ProjeDosyaUzanti);
          end;
        end;
      end
      // dosya kaydedilmiş veya değiştirilmiş ise...
      else // if(Dosya.Durum = ddKaydedildi) or (Dosya.Durum = ddDegistirildi) then
      begin

        seDosya := FindComponent('seDosya' + IntToStr(pcDosyalar.ActivePage.Tag)) as TSynEdit;

        seDosya.Lines.SaveToFile(Dosya.ProjeDizin + DirectorySeparator +
          Dosya.ProjeDosyaAdi + '.' + Dosya.ProjeDosyaUzanti);
      end;
    end;
  end;
end;

procedure TfrmAnaSayfa.miDosyaSonKullanilanDosyayiAcClick(Sender: TObject);
var
  Dosya: TDosya;
  seDosya: TSynEdit;
  DosyaSira,
  DosyaDuzenleyiciSiraNumarasi: Integer;
  DosyaAcik: Boolean;
begin

  DosyaSira := (Sender as TMenuItem).Tag;

  Dosya := GAsm2.Dosyalar.Ekle(GProgramAyarlari.SonKullanilanDosyalar[DosyaSira],
    False, DosyaAcik);
  if not(Dosya = nil) then
  begin

    GAktifDosya := Dosya;

    // dosya daha önce açık ise, açık olan dosyayı düzenleyici alanında etkinleştir
    if(DosyaAcik) then
    begin

      DosyaDuzenleyiciSiraNumarasi := DosyaDuzenleyiciSiraNumarasiAl(Dosya.Kimlik);
      if(DosyaDuzenleyiciSiraNumarasi > -1) then
      begin

        pcDosyalar.ActivePageIndex := DosyaDuzenleyiciSiraNumarasi;

        GAktifDuzenleyici := TSynEdit(FindComponent('seDosya' + IntToStr(Dosya.Kimlik)));

        DurumCubugunuGuncelle;
      end;
    end
    else
    begin

      seDosya := DuzenleyiciAlaniOlustur(Dosya);
      if(seDosya = nil) then

        ShowMessage('Hata: daha fazla düzenleyici alanı açılamıyor!')
      else
      begin

        GAktifDuzenleyici := seDosya;

        ProjeDosyasiYukle(seDosya, Dosya, False);
      end;
    end;
  end else ShowMessage('Hata: daha fazla düzenleyici alanı açılamıyor!')
end;

// farenin sağ / sol tuşu ile düzenleyicideki bir dosya seçildiğinde
procedure TfrmAnaSayfa.pcDosyalarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  Pt: TPoint;
begin

  if(Button = mbRight) then
  begin

    i := pcDosyalar.IndexOfTabAt(X, Y);
    pcDosyalar.PageIndex := i;
  end;

  GAktifDosya := GAsm2.Dosyalar.Bul(pcDosyalar.ActivePage.Tag);
  GAktifDuzenleyici := TSynEdit(FindComponent('seDosya' + IntToStr(pcDosyalar.ActivePage.Tag)));

  DurumCubugunuGuncelle;

  if(Button = mbRight) then
  begin

    Pt.x := X;
    Pt.y := Y;
    Pt := pcDosyalar.ClientToScreen(Pt);

    pmDuzenleyici.PopUp(Pt.X, Pt.Y);
  end;
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

procedure TfrmAnaSayfa.SynEdit1Change(Sender: TObject);
begin

  ShowMessage('changed');
end;

procedure TfrmAnaSayfa.DurumCubugunuGuncelle;
begin

  GAktifDuzenleyici.SetFocus;

  // klavye göstergesini (cursor) güncelle
  sbDurum.Panels[1].Text := 'Satır: ' + IntToStr(GAktifDuzenleyici.CaretY) +
    ' - Sütun: ' + IntToStr(GAktifDuzenleyici.CaretX);
end;

// kod derleme menüsü
procedure TfrmAnaSayfa.miKodDerleClick(Sender: TObject);
var
  DerlemeSonucu: Integer;
begin

  if(pcDosyalar.PageCount = 0) then
  begin

    ShowMessage('Lütfen derlenecek kodları düzenleyicide açınız!');
    Exit;
  end;

  GAsm2.AtamaListesi.Temizle;
  GAsm2.Matematik.Temizle;

  GAktifDosya.Bicim := dbIkili;

  // düzenleyicideki kodları derle
  DerlemeSonucu := KodlariDerle(GAktifDuzenleyici);

  // derleme esnasında hata var ise...
  if(DerlemeSonucu > HATA_YOK) then
  begin

    if(DerlemeSonucu = HATA_PROJEYI_KAYDET) then

      ShowMessage('Lütfen programı derlemeden önce kaydediniz!')

    else if(DerlemeSonucu = HATA_PROG_DOSYA_OLUSTURMA) then
    begin

      ShowMessage('Hata: ' + GAktifDosya.ProjeDosyaAdi + ' dosyası oluşturulamadı!')
    end
    else
    // derleme başarılı
    begin

      ShowMessage('Hata: ' + HataKodunuAl(DerlemeSonucu)); // + ' - ' + GHataAciklama);
      GAktifDuzenleyici.CaretX := 1;
      GAktifDuzenleyici.CaretY := GAktifDosya.IslenenSatir;
    end;
  end
  else
  begin

    frmDerlemeBilgisi.ProjeDosyaAdi := GAktifDosya.ProjeDosyaAdi + '.' +
      GAktifDosya.ProjeDosyaUzanti;
    frmDerlemeBilgisi.DerlenenDosya := GAktifDosya.CikisDosyaAdi + '.' +
      GAktifDosya.CikisDosyaUzanti;
    frmDerlemeBilgisi.DerlenenSatirSayisi := GAktifDosya.IslenenSatirSayisi;
    frmDerlemeBilgisi.IkiliDosyaUzunluk := KodBellekU;
    frmDerlemeBilgisi.DerlemeCevrimSayisi := GAktifDosya.DerlemeCevrimSayisi;
    FormuOrtala(frmDerlemeBilgisi, True);
  end
end;

function TfrmAnaSayfa.KodlariDerle(AktifDuzenleyici: TSynEdit): Integer;
var
  ToplamSatirSayisi, i: Integer;
  HamVeri, s: string;
  IslevSonuc: Integer;
  DerlemeCevrimindenCik: Boolean;
begin

  DerlemeCevrimindenCik := False;

  // mevcut etiketleri temizle
  GAsm2.AtamaListesi.Temizle;

  // ilk değer atamaları
  GAktifDosya.DerlemeCevrimSayisi := 0;

  while (DerlemeCevrimindenCik = False) do
  begin

    IslevSonuc := HATA_YOK;

    GEtiketHataSayisi := 0;

    // bellek değişkenleri ve bellek içeriğini ilk değerlerle yükle
    KodBellekDegerleriniIlklendir;

    ToplamSatirSayisi := AktifDuzenleyici.Lines.Count;
    GAktifDosya.IslenenSatir := 0;
    GAktifDosya.IslenenSatirSayisi := 0;

    // son satıra gelinmediği ve hata olmadığı müddetçe devam et
    while (GAktifDosya.IslenenSatir < ToplamSatirSayisi) and (IslevSonuc = HATA_YOK) do
    begin

      HamVeri := AktifDuzenleyici.Lines[GAktifDosya.IslenenSatir];

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
        SatirIcerik.BolumTip3.BolumAnaTip := batYok;
        SatirIcerik.BolumTip3.BolumAyrinti := [];

        // ilgili satırın incelendiği / kodların üretildiği ana çağrı
        IslevSonuc := KodUret(GAktifDosya.IslenenSatir, HamVeri);

        // işlenen satır sayısını artır
        i := GAktifDosya.IslenenSatirSayisi;
        Inc(i);
        GAktifDosya.IslenenSatirSayisi := i;
      end;

      // bir sonraki satıra geçiş yap
      i := GAktifDosya.IslenenSatir;
      Inc(i);
      GAktifDosya.IslenenSatir := i;
      Application.ProcessMessages;
    end;

    // hata olduğu için çıkış yap
    if(IslevSonuc > HATA_YOK) then

      DerlemeCevrimindenCik := True

    // derleme başarılı olduğu için çıkış yap
    else if(IslevSonuc = HATA_YOK) and (GAsm2.AtamaListesi.Temizle2 = 0) then

      DerlemeCevrimindenCik := True;

    // çevrim sayısını bir artır
    GAktifDosya.DerlemeCevrimSayisi := GAktifDosya.DerlemeCevrimSayisi + 1;

    Application.ProcessMessages;
  end;

  // derleme işleminin durumu, derleme sonrasında belirleniyor
  GAktifDosya.DerlemeBasarili := (IslevSonuc = HATA_YOK);

  // kodların yorumlanması ve çevrilmesinde herhangi bir hata yoksa
  // ikili formatta (binary file) dosya oluştur
  { TODO : oluşturulacak dosya ilk aşamada saf assembler kodların makine dili karşılıklarıdır
    ileride PE / COFF ve diğer formatlarda program dosyaları oluşturulacaktır  }
  if(GAktifDosya.DerlemeBasarili) then
  begin

    // dosya adının olması durumunda ...
    if(Length(GAktifDosya.CikisDosyaAdi) > 0) then
    begin

      Result := ProgramDosyasiOlustur(GAktifDosya);

    end else Result := HATA_PROJEYI_KAYDET;
  end else Result := IslevSonuc;
end;

procedure TfrmAnaSayfa.miKodCalistirClick(Sender: TObject);
var
  Process: TProcessUTF8;
begin

  if(pcDosyalar.PageCount = 0) then
  begin

    ShowMessage('Lütfen derlenecek kodları düzenleyicide açınız!');
    Exit;
  end;

  GAsm2.AtamaListesi.Temizle;
  GAsm2.Matematik.Temizle;

  GAktifDosya.Bicim := dbIkili;

  // kodlar daha önce derlenmiş veya program derleme aşamasında hata olmamış
  // olsa bile düzenleyicideki kodları MUTLAKA bir kez derle
  KodlariDerle(GAktifDuzenleyici);

  // program; exe olarak başarılı bir şekilde derlendiyse, çalıştır
  if(GAktifDosya.DerlemeBasarili) and (GAktifDosya.CikisDosyaUzanti = 'exe') then
  begin

    Process := TProcessUTF8.Create(nil);
    try

      Process.Executable := GAktifDosya.ProjeDizin + DirectorySeparator +
        GAktifDosya.CikisDosyaAdi + '.' + GAktifDosya.CikisDosyaUzanti;
      Process.Options := Process.Options + [poWaitOnExit];
      Process.Execute;
    except

      ShowMessage('Hata: program çalıştırılamıyor!');
    end;
    FreeAndNil(Process);

  end else ShowMessage('Lütfen öncelikle programı derleyiniz!');
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

procedure TfrmAnaSayfa.DosyayiDuzenleyiciyeYukle(Duzenleyici: TSynEdit; Dosya: TDosya;
  CP1254KarakterSetiniKullan: Boolean);
var
  YaziDosya: TextFile;
  Veri, s: string;
begin

  Duzenleyici.Clear;

  if(Length(Dosya.ProjeDosyaUzanti) > 0) then
    s := Dosya.ProjeDosyaAdi + '.' + Dosya.ProjeDosyaUzanti
  else s := Dosya.ProjeDosyaAdi;

  AssignFile(YaziDosya, Dosya.ProjeDizin + DirectorySeparator + s);
  {$I-} Reset(YaziDosya); {$I+}

  if(IOResult = 0) then
  begin

    while not EOF(YaziDosya) do
    begin

      ReadLn(YaziDosya, Veri);

      if(CP1254KarakterSetiniKullan) then
        Duzenleyici.Lines.Add(CP1254ToUTF8(Veri))
      else Duzenleyici.Lines.Add(Veri);

      Application.ProcessMessages;
    end;

    CloseFile(YaziDosya);
  end;
end;

// düzenleyicide açık olan dosyanın kimliğinden dosyanın düzenleyicinin hangi
// sırasında olduğunu bulur
function TfrmAnaSayfa.DosyaDuzenleyiciSiraNumarasiAl(DosyaKimlik: Integer): Integer;
var
  i: Integer;
begin

  Result := -1;

  if(pcDosyalar.PageCount = 0) then Exit;

  for i := 0 to pcDosyalar.PageCount - 1 do
  begin

    if(pcDosyalar.Pages[i].Tag = DosyaKimlik) then
    begin

      Result := i;
      Exit;
    end;
  end;
end;

end.
