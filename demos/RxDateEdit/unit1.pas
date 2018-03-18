unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, DividerBevel, LResources, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ComCtrls, rxmemds, rxdbdateedit, rxcurredit,
  rxtooledit, rxDateRangeEditUnit;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CurrencyEdit1: TCurrencyEdit;
    dsData: TDatasource;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    PageControl1: TPageControl;
    rxData: TRxMemoryData;
    rxDataDOC_DATE: TDateField;
    RxDateEdit1: TRxDateEdit;
    RxDateRangeEdit1: TRxDateRangeEdit;
    RxDBDateEdit1: TRxDBDateEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RxDateRangeEdit1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  rxData.Open;
  rxData.Append;
  rxDataDOC_DATE.AsDateTime:=Now;
  CurrencyEdit1.Value:=1214.55;

  CheckBox1Change(nil);
end;

procedure TForm1.RxDateRangeEdit1Change(Sender: TObject);
begin
  Edit1.Text:=DateToStr(RxDateRangeEdit1.Period);
  Edit2.Text:=DateToStr(RxDateRangeEdit1.PeriodEnd);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  CurrencyEdit1.Invalidate;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
var
  R: TRxDateRangeEditOptions;
begin
  R:=[];
  if CheckBox1.Checked then
    R:=R + [reoMonth];
  if CheckBox2.Checked then
    R:=R + [reoQuarter];
  if CheckBox3.Checked then
    R:=R + [reoHalfYear];
  RxDateRangeEdit1.Options:=R;
end;

end.

