{-------------------------------------------------------------------------------

  Dosya: aramaform.pas

  İşlev: düzenleyici içerisinde kelime arama işlevlerini yönetir

  Güncelleme Tarihi: 06/11/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit aramaform;

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type
  TfrmAra = class(TForm)
    btnAra: TButton;
    edtAra: TEdit;
    lblAramaHatasi: TLabel;
    lblAra: TLabel;
    procedure btnAraClick(Sender: TObject);
    procedure edtAraClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
  private
    SonBulunanKonum: Integer;
  public
  end;

var
  frmAra: TfrmAra;

implementation

{$R *.lfm}

uses genel, strutils;

procedure TfrmAra.FormShow(Sender: TObject);
begin

  KeyPreview := True;
  SonBulunanKonum := 0;
end;

procedure TfrmAra.btnAraClick(Sender: TObject);
var
  Aranan: string;
  UAranan, YeniBulunanKonum: Integer;
begin

  Aranan := edtAra.Text;
  UAranan := Length(Aranan);
  if(UAranan > 0) then
  begin

    YeniBulunanKonum := PosEx(Aranan, GAktifDuzenleyici.Text, SonBulunanKonum + 1);
    if(YeniBulunanKonum > 0) then
    begin

      lblAramaHatasi.Visible := False;
      GAktifDuzenleyici.SelStart := YeniBulunanKonum;
      GAktifDuzenleyici.SelEnd:= YeniBulunanKonum + UAranan;
      GAktifDuzenleyici.SetFocus;
      SonBulunanKonum := YeniBulunanKonum;
    end
    else
    begin

      lblAramaHatasi.Visible := True;
      SonBulunanKonum := 0;
    end;
  end;
end;

procedure TfrmAra.edtAraClick(Sender: TObject);
begin

  edtAra.SelectAll;
end;

procedure TfrmAra.FormKeyPress(Sender: TObject; var Key: char);
begin

  if(Key = #27) then
  begin

    Key := #0;
    Close;
  end;
end;

end.
