unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, db,
  IBQuery, IBDatabase, IBCustomDataSet, rxdbgrid, RxSortIBX;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    IBDatabase1: TIBDatabase;
    IBDataSet1: TIBDataSet;
    IBQuery1: TIBQuery;
    IBTransaction1: TIBTransaction;
    PageControl1: TPageControl;
    RxDBGrid1: TRxDBGrid;
    RxDBGrid2: TRxDBGrid;
    RxSortIBX1: TRxSortIBX;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure FormCreate(Sender: TObject);
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
  IBDatabase1.Connected:=true;
  IBTransaction1.StartTransaction;
  IBQuery1.Open;
  IBDataSet1.Open;
end;

end.

