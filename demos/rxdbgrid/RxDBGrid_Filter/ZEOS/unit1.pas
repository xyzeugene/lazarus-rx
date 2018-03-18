unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, rxdbgrid, RxSortZeos, ZConnection, ZDataset,
  Forms, Controls, Graphics, Dialogs, db;

type

  { TForm1 }

  TForm1 = class(TForm)
    DataSource1: TDataSource;
    RxDBGrid1: TRxDBGrid;
    RxSortZeos1: TRxSortZeos;
    ZConnection1: TZConnection;
    ZReadOnlyQuery1: TZReadOnlyQuery;
    ZReadOnlyQuery1DEPARTMENT: TStringField;
    ZReadOnlyQuery1DEPT_NO: TStringField;
    ZReadOnlyQuery1LOCATION: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure ZReadOnlyQuery1FilterRecord(DataSet: TDataSet; var Accept: Boolean
      );
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  ZConnection1.Connected:=true;
  ZReadOnlyQuery1.Open;
end;

procedure TForm1.ZReadOnlyQuery1FilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
  //
end;

end.

