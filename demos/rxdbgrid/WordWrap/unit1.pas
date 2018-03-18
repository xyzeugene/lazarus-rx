unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, rxdbgrid, rxmemds, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, db;

type

  { TForm1 }

  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    DataSource1: TDataSource;
    Panel1: TPanel;
    RxDBGrid1: TRxDBGrid;
    RxMemoryData1: TRxMemoryData;
    RxMemoryData1CODE: TLongintField;
    RxMemoryData1ID: TLongintField;
    RxMemoryData1NAME: TStringField;
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RxDBGrid1CalcRowHeight(Sender: TRxDBGrid; var ARowHegth: integer);
  private
    procedure FillTestDatabase;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  CheckBox1.OnChange := nil;
  CheckBox2.OnChange := nil;

  CheckBox1.Checked := rdgWordWrap in RxDBGrid1.OptionsRx;
  CheckBox2.Checked := RxDBGrid1.FooterOptions.Active;

  CheckBox1.OnChange := @CheckBox1Change;
  CheckBox2.OnChange := @CheckBox1Change;

  RxMemoryData1.Open;
  FillTestDatabase;
end;

procedure TForm1.RxDBGrid1CalcRowHeight(Sender: TRxDBGrid;
  var ARowHegth: integer);
begin
  if RxMemoryData1ID.AsInteger mod 10 = 0 then
    ARowHegth:=ARowHegth + 1;
end;

procedure TForm1.FillTestDatabase;
var
  F:TextFile;
  S:string;
  I:integer;
begin
  AssignFile(F, 'unit1.pas');
  Reset(F);
  I:=0;
  while not Eof(F) do
  begin
    Readln(F, S);
    if Trim(S)<>'' then
    begin
      RxMemoryData1.AppendRecord([i, S, i]);
      Inc(i);
    end;
  end;
  CloseFile(F);
  RxMemoryData1.First;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked then
    RxDBGrid1.OptionsRx := RxDBGrid1.OptionsRx + [rdgWordWrap]
  else
    RxDBGrid1.OptionsRx := RxDBGrid1.OptionsRx - [rdgWordWrap];

  RxDBGrid1.FooterOptions.Active := CheckBox2.Checked;

  RxMemoryData1.First;
end;

end.

