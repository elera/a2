unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls;

type
  TfrmMain = class(TForm)
    gbAsmLines: TGroupBox;
    gbAsmLinesOutput: TGroupBox;
    mmAsmLines: TMemo;
    mmAsmLinesOutput: TMemo;
    spMain: TSplitter;
    sbMain: TStatusBar;
    tbMain: TToolBar;
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

end.
