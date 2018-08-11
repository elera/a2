{-------------------------------------------------------------------------------

  Dosya: ayarlarform.pas

  İşlev: grafiksel ortamda program ayarlarını saklama / yönetme işlevlerini içerir

  Güncelleme Tarihi: 09/08/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit ayarlarform;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, ComCtrls;

type
  TfrmAyarlar = class(TForm)
    btnKaydet: TBitBtn;
    btnIptal: TBitBtn;
    cbAcikDosyalariTabAlanindaAc: TCheckBox;
    edtYaziBoyutu: TEdit;
    lblYaziBoyutu: TLabel;
    pnlAlt: TPanel;
    shpAyirac: TShape;
    udYaziBoyutu: TUpDown;
    procedure btnKaydetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmAyarlar: TfrmAyarlar;

implementation

{$R *.lfm}

uses genel;

procedure TfrmAyarlar.FormShow(Sender: TObject);
begin

  edtYaziBoyutu.Text := IntToStr(GProgramAyarlari.DuzenleyiciYaziBoyut);
  cbAcikDosyalariTabAlanindaAc.Checked := GProgramAyarlari.AcikDosyalariTabAlanindaAc;
end;

procedure TfrmAyarlar.btnKaydetClick(Sender: TObject);
begin

  try
    GProgramAyarlari.DuzenleyiciYaziBoyut := StrToInt(edtYaziBoyutu.Text);
  except
  end;

  GProgramAyarlari.AcikDosyalariTabAlanindaAc := cbAcikDosyalariTabAlanindaAc.Checked;
end;

end.
