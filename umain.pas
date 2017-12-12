unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    gbAsmLines: TGroupBox;
    gbAsmLinesOutput: TGroupBox;
    mmAsmLines: TMemo;
    mmAsmLinesOutput: TMemo;
    spMain: TSplitter;
    sbMain: TStatusBar;
    tbMain: TToolBar;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

uses profunc;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  CurrentLineCount, TotalLineCount: Integer;
  CodeData, Data: string;
begin

  mmAsmLinesOutput.Clear;

  TotalLineCount := mmAsmLines.Lines.Count;
  CurrentLineCount := 0;

  while CurrentLineCount < TotalLineCount do
  begin

    Data := mmAsmLines.Lines[CurrentLineCount];
    CodeData := Trim(Data);
    if(Length(CodeData) > 0) then
    begin

      if(CodeData[1] = ';') then

        mmAsmLinesOutput.Lines.Add('Açıklama: ' + Data)

      else
      begin

        Data := GetOpcode(CodeData);
        mmAsmLinesOutput.Lines.Add('Kod: ' + Data);
      end;
    end;

    Inc(CurrentLineCount);
  end;
end;

end.
