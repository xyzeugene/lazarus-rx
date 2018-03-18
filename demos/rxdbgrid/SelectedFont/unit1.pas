unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, db,
  DBGrids, ColorBox, EditBtn, Spin, rxmemds, rxdbgrid, rxtooledit;

type

  { TForm1 }

  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    ColorBox1: TColorBox;
    ColorBox2: TColorBox;
    dsData: TDataSource;
    EditButton1: TEditButton;
    FontDialog1: TFontDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel1: TPanel;
    rxData: TRxMemoryData;
    rxDataCaption: TStringField;
    rxDataEditDate: TDateTimeField;
    rxDataID: TLongintField;
    RxDBGrid1: TRxDBGrid;
    SpinEdit1: TSpinEdit;
    procedure CheckBox1Change(Sender: TObject);
    procedure EditButton1ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
   procedure LoadFontParams;
  public

  end;

var
  Form1: TForm1;

implementation
uses math;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  rxData.Open;
  for i:=1 to 12 do
    rxData.AppendRecord([i, 'Line '+IntToStr(i) + ' ('+DefaultFormatSettings.LongMonthNames[i] +')', RandomRange(1, 100000) + Random]);
  rxData.First;

  LoadFontParams;
end;

procedure TForm1.LoadFontParams;
begin
  SpinEdit1.OnChange:=nil;
  CheckBox2.OnChange:=nil;
  CheckBox3.OnChange:=nil;
  CheckBox4.OnChange:=nil;
  CheckBox5.OnChange:=nil;
  ColorBox1.OnChange:=nil;
  ColorBox2.OnChange:=nil;

  EditButton1.Text:=RxDBGrid1.SelectedFont.Name;
  SpinEdit1.Value:=RxDBGrid1.SelectedFont.Size;
  CheckBox2.Checked:=fsBold in RxDBGrid1.SelectedFont.Style;
  CheckBox3.Checked:=fsItalic in RxDBGrid1.SelectedFont.Style;
  CheckBox4.Checked:=fsUnderline in RxDBGrid1.SelectedFont.Style;
  CheckBox5.Checked:=fsStrikeOut in RxDBGrid1.SelectedFont.Style;
  ColorBox2.Selected:=RxDBGrid1.SelectedFont.Color;
  ColorBox1.Selected:=RxDBGrid1.SelectedColor;

  SpinEdit1.OnChange:=@CheckBox1Change;
  CheckBox2.OnChange:=@CheckBox1Change;
  CheckBox3.OnChange:=@CheckBox1Change;
  CheckBox4.OnChange:=@CheckBox1Change;
  CheckBox5.OnChange:=@CheckBox1Change;
  ColorBox1.OnChange:=@CheckBox1Change;
  ColorBox2.OnChange:=@CheckBox1Change;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked then
    RxDBGrid1.Options:=RxDBGrid1.Options + [dgRowSelect]
  else
    RxDBGrid1.Options:=RxDBGrid1.Options - [dgRowSelect];

  RxDBGrid1.SelectedColor:=ColorBox1.Selected;

  if CheckBox2.Checked then
    RxDBGrid1.SelectedFont.Style:=RxDBGrid1.SelectedFont.Style + [fsBold]
  else
    RxDBGrid1.SelectedFont.Style:=RxDBGrid1.SelectedFont.Style - [fsBold];

  if CheckBox3.Checked then
    RxDBGrid1.SelectedFont.Style:=RxDBGrid1.SelectedFont.Style + [fsItalic]
  else
    RxDBGrid1.SelectedFont.Style:=RxDBGrid1.SelectedFont.Style - [fsItalic];

  if CheckBox4.Checked then
    RxDBGrid1.SelectedFont.Style:=RxDBGrid1.SelectedFont.Style + [fsUnderline]
  else
    RxDBGrid1.SelectedFont.Style:=RxDBGrid1.SelectedFont.Style - [fsUnderline];

  if CheckBox5.Checked then
    RxDBGrid1.SelectedFont.Style:=RxDBGrid1.SelectedFont.Style + [fsStrikeOut]
  else
    RxDBGrid1.SelectedFont.Style:=RxDBGrid1.SelectedFont.Style - [fsStrikeOut];

  RxDBGrid1.SelectedFont.Color:=ColorBox2.Selected;
  RxDBGrid1.SelectedFont.Size:=SpinEdit1.Value;


  LoadFontParams;
end;

procedure TForm1.EditButton1ButtonClick(Sender: TObject);
begin
  FontDialog1.Font:=RxDBGrid1.SelectedFont;
  if FontDialog1.Execute then
  begin
    RxDBGrid1.SelectedFont:=FontDialog1.Font;
    LoadFontParams;
  end;
end;

end.

