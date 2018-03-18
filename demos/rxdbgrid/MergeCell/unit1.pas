unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, rxdbgrid, rxmemds, RxDBGridExportSpreadSheet,
  RxDBGridPrintGrid, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, db,
  Grids, DBGrids;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    dsData: TDataSource;
    Panel1: TPanel;
    rxDataCODE: TLongintField;
    rxDataDATE: TDateTimeField;
    rxDataNAME: TStringField;
    RxDBGrid1: TRxDBGrid;
    rxData: TRxMemoryData;
    RxDBGridExportSpreadSheet1: TRxDBGridExportSpreadSheet;
    RxDBGridPrint1: TRxDBGridPrint;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RxDBGrid1Columns0DrawColumnCell(Sender: TObject;
      const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);
    procedure RxDBGrid1MergeCells(Sender: TObject; ACol: Integer; var ALeft,
      ARight: Integer; var ADisplayColumn: TRxColumn);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  rxData.Open;
  rxData.DisableControls;
  for i:=1 to 30 do
    rxData.AppendRecord([i, Date - i, 'Line '+IntToStr(i)]);
  rxData.First;
  rxData.EnableControls;
end;

procedure TForm1.RxDBGrid1Columns0DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  S: String;
  FAl: TAlignment;
begin
  S:=rxDataCODE.DisplayText;
  if CheckBox1.Checked and (rxDataCODE.AsInteger mod 10 = 1) then
    FAl:=taCenter
  else
    FAl:=taRightJustify;
  WriteTextHeader(RxDBGrid1.Canvas, Rect, S, FAl)
end;

procedure TForm1.RxDBGrid1MergeCells(Sender: TObject; ACol: Integer; var ALeft,
  ARight: Integer; var ADisplayColumn: TRxColumn);
begin
  if rxDataCODE.AsInteger mod 10 = 1 then
  begin
    ALeft:=1;
    ARight:=3;
{    if rxDataCODE.AsInteger > 10 then
      ADisplayColumn:=RxDBGrid1.ColumnByFieldName('DATE');}
  end;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked then
    RxDBGrid1.OptionsRx:=RxDBGrid1.OptionsRx + [rdgColSpanning]
  else
    RxDBGrid1.OptionsRx:=RxDBGrid1.OptionsRx - [rdgColSpanning];
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  RxDBGridExportSpreadSheet1.Execute;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  RxDBGridPrint1.Execute;
end;

end.

