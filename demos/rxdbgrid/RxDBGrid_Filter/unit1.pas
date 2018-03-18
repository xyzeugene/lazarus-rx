unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, rxdbgrid, rxmemds, Forms, Controls, Graphics,
  Dialogs, StdCtrls, db;

type

  { TForm1 }

  TForm1 = class(TForm)
    dsData: TDataSource;
    rxDataID_R: TLongintField;
    RxDBGrid1: TRxDBGrid;
    rxData: TRxMemoryData;
    rxDataCODE: TLongintField;
    rxDataID: TLongintField;
    rxDataNAME: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure rxDataAfterInsert(DataSet: TDataSet);
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
  for i:=1 to 20 do
  begin
    rxData.AppendRecord([i, i mod 4, Format('Line %d', [i])]);
    if i mod 5 = 0 then
      rxData.AppendRecord([null, null, 'Пустая строка']);
  end;
  rxData.First;
end;

procedure TForm1.rxDataAfterInsert(DataSet: TDataSet);
begin
  rxDataID_R.AsInteger:=rxData.RecordCount + 1;
end;

end.

