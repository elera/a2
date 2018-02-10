{-------------------------------------------------------------------------------

  Dosya: etiketform.pas

  İşlev: derleyici tarafından etiketlere atanan bellek adres eşleşmesini görüntüler

  Güncelleme Tarihi: 09/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit etiketform;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ValEdit,
  ComCtrls;

type
  TfrmEtiketForm = class(TForm)
    sbDurum: TStatusBar;
    vleEtiketler: TValueListEditor;
    procedure FormShow(Sender: TObject);
    procedure vleEtiketlerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
  public
  end;

var
  frmEtiketForm: TfrmEtiketForm;

implementation

{$R *.lfm}

uses genel, etiket, LCLType;

procedure TfrmEtiketForm.FormShow(Sender: TObject);
var
  EtiketU, i: Integer;
  Etiket: TEtiket;
begin

  // mevcut eski verileri sil
  vleEtiketler.Clear;

  // etiketleri listele
  EtiketU := GAsm2.Etiketler.Toplam;
  for i := 0 to EtiketU - 1 do
  begin

    Etiket := GAsm2.Etiketler.Eleman[i];
    vleEtiketler.InsertRow(Etiket.Adi, IntToStr(Etiket.BellekAdresi), True);
  end;

  sbDurum.SimpleText := 'Toplam Etiket Sayısı: ' + IntToStr(EtiketU);
end;

procedure TfrmEtiketForm.vleEtiketlerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if(Key = VK_ESCAPE) then Close;
end;

end.
