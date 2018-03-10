{-------------------------------------------------------------------------------

  Dosya: derlemebilgisi.pas

  İşlev: derleme sonrası bilgi verme işlemi

  Güncelleme Tarihi: 22/02/2018

-------------------------------------------------------------------------------}
{$mode objfpc}{$H+}
unit derlemebilgisiform;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls;

type

  { TfrmDerlemeBilgisi }

  TfrmDerlemeBilgisi = class(TForm)
    btnTamam: TBitBtn;
    lblDerlenenDosya: TLabel;
    lblIkiliUzunluk: TLabel;
    lblDerlemeCevrimSayisi: TLabel;
    lblDerlemeCevrimSayisiC: TLabel;
    lblProjeDosyasiB1: TLabel;
    lblIkiliDosyaB: TLabel;
    lblIkiliUzunlukB: TLabel;
    lblSatirSayisiB: TLabel;
    lblDosyaSayisiB: TLabel;
    lblSatirSayisi: TLabel;
    lblDosyaSayisi: TLabel;
    lblProjeDosyasiB: TLabel;
    lblProjeDosyasi: TLabel;
    shpCizgi: TShape;
    shpCizgi1: TShape;
    shpCizgi2: TShape;
    procedure FormShow(Sender: TObject);
  private
  public
    DerlenenSatirSayisi,
    IkiliDosyaUzunluk,
    DerlemeCevrimSayisi: Integer;
    DerlenenDosya: string;
  end;

var
  frmDerlemeBilgisi: TfrmDerlemeBilgisi;

implementation

{$R *.lfm}

procedure TfrmDerlemeBilgisi.FormShow(Sender: TObject);
begin

  lblDerlenenDosya.Caption := DerlenenDosya;
  lblSatirSayisi.Caption := IntToStr(DerlenenSatirSayisi);
  lblDerlemeCevrimSayisi.Caption := IntToStr(DerlemeCevrimSayisi);
  lblIkiliUzunluk.Caption := IntToStr(IkiliDosyaUzunluk);
end;

end.
