unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, StdCtrls, DBGrids, ExtCtrls, rxlookup, rxmemds;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    DBGrid1: TDBGrid;
    dsData1: TDatasource;
    dsLookUpData: TDatasource;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    rxData1ID: TLongintField;
    RxDBLookupCombo1: TRxDBLookupCombo;
    rxData1: TRxMemoryData;
    rxLookUpData: TRxMemoryData;
    rxLookUpDataCaption: TStringField;
    rxLookUpDataID: TLongintField;
    rxLookUpDataPrice: TCurrencyField;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

procedure TForm1.Button1Click(Sender: TObject);
begin
  Label2.Caption:=RxDBLookupCombo1.Text;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  RxDBLookupCombo1.Text:=Edit1.Text;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  RxDBLookupCombo1.Flat:=CheckBox1.Checked;

  case RadioGroup1.ItemIndex of
    0:RxDBLookupCombo1.BorderStyle:=bsNone;
    1:RxDBLookupCombo1.BorderStyle:=bsSingle;
  end;

  case RadioGroup2.ItemIndex of
    0:RxDBLookupCombo1.Style:=rxcsDropDown;
    1:RxDBLookupCombo1.Style:=rxcsDropDownList;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  rxData1.Open;
  rxData1.Append;
  rxLookUpData.Open;
  rxLookUpData.AppendRecord([1, 'Lazarus', 0]);
  rxLookUpData.AppendRecord([2, 'Delphi', 1000]);
  rxLookUpData.AppendRecord([3, 'MS Office', 400]);
  rxLookUpData.AppendRecord([4, 'MS Windows XP', 150]);
  rxLookUpData.AppendRecord([5, 'MS Windows Vista', 100]);
  rxLookUpData.AppendRecord([6, 'MS Windows 7', 200]);
  rxLookUpData.AppendRecord([7, 'Fedora Linux 11 - 27', 0]);
  Label2.Caption:='';
end;

end.

