{-------------------------------------------------------------------------------

  Dosya: atamalarform.pas

  İşlev: derleyici tarafından atanan etiket ve tanım değerlerini görüntüler

  Güncelleme Tarihi: 21/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit atamalarform;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
    ExtCtrls, StdCtrls;

type
  TfrmAtamalar = class(TForm)
    ilGenel: TImageList;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label3: TLabel;
    lblToplamNesne: TLabel;
    lvEtiketler: TListView;
    pnlBilgi: TPanel;
    procedure FormShow(Sender: TObject);
    procedure lvEtiketlerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
  public
  end;

var
  frmAtamalar: TfrmAtamalar;

implementation

{$R *.lfm}

uses genel, atamalar, LCLType;

procedure TfrmAtamalar.FormShow(Sender: TObject);
var
  EtiketU, i: Integer;
  Atama: TAtama;
  li: TListItem;
begin

  // mevcut eski verileri sil
  lvEtiketler.Clear;

  EtiketU := GAsm2.AtamaListesi.Toplam;

  // etiketleri listele
  for i := 0 to EtiketU - 1 do
  begin

    Atama := GAsm2.AtamaListesi.Eleman[i];

    li := lvEtiketler.Items.Add;
    if(Atama.Tip = atEtiket) then
      li.ImageIndex := 0
    else li.ImageIndex := 1;
    li.Caption := '';
    li.SubItems.Add(Atama.DosyaAdi);
    li.SubItems.Add(IntToStr(Atama.SatirNo + 1));
    li.SubItems.Add(Atama.Adi);
    li.SubItems.Add(IntToStr(Ord(Atama.Tip)));

    // bellek adresi SADECE etiketlere özgüdür
    if(Atama.Tip = atEtiket) then
    begin

      if(Atama.BellekAdresi = 0) then
        li.SubItems.Add('0h')
      else li.SubItems.Add(IntToHex(Atama.BellekAdresi, -1) + 'h');
      li.SubItems.Add('-');
      li.SubItems.Add('-');
      li.SubItems.Add('-');
    end
    else
    begin

      li.SubItems.Add('-');
      li.SubItems.Add(IntToStr(Ord(Atama.VeriTipi)));
      li.SubItems.Add(IntToStr(Atama.VeriUzunluk ));
      if(Atama.iDeger = 0) then
        li.SubItems.Add('0h')
      else li.SubItems.Add(IntToHex(Atama.iDeger, -1) + 'h');
    end;
  end;

  lblToplamNesne.Caption := 'Toplam Eleman Sayısı: ' + IntToStr(EtiketU);
end;

procedure TfrmAtamalar.lvEtiketlerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if(Key = VK_ESCAPE) then Close;
end;

end.
