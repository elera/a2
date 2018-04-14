{-------------------------------------------------------------------------------

  Dosya: ayarlarform.pas

  İşlev: grafiksel ortamda program ayarlarını saklama / yönetme işlevlerini içerir

  Güncelleme Tarihi: 06/04/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit ayarlarform;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons;

type

  { TfrmAyarlar }

  TfrmAyarlar = class(TForm)
    btnKaydet: TBitBtn;
    btnIptal: TBitBtn;
    cbSonKullanilanDosyayiAc: TCheckBox;
    pnlAlt: TPanel;
    Shape1: TShape;
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

  cbSonKullanilanDosyayiAc.Checked := GProgramAyarlari.SonKullanilanDosyayiAc;
end;

procedure TfrmAyarlar.btnKaydetClick(Sender: TObject);
begin

  GProgramAyarlari.SonKullanilanDosyayiAc := cbSonKullanilanDosyayiAc.Checked;
end;

end.
