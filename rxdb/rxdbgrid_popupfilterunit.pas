{ rxdbgrid unit

  Copyright (C) 2005-2017 Lagunov Aleksey alexs75@yandex.ru and Lazarus team
  original conception from rx library for Delphi (c)

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

{$I rx.inc}

unit RxDBGrid_PopUpFilterUnit;

interface

uses
  Classes, SysUtils, FileUtil, DividerBevel, ListFilterEdit, Forms, Controls,
  Graphics, Dialogs, Buttons, ComCtrls, CheckLst, ButtonPanel, StdCtrls, Menus,
  rxdbgrid;

type

  { TRxDBGrid_PopUpFilterForm }

  TRxDBGrid_PopUpFilterForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    CheckBox1: TCheckBox;
    CheckListBox1: TCheckListBox;
    DividerBevel1: TDividerBevel;
    DividerBevel2: TDividerBevel;
    DividerBevel3: TDividerBevel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PopupMenu1: TPopupMenu;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MenuItem1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
  private
    FRxDBGrid:TRxDBGrid;
    FRxColumn: TRxColumn;
    procedure UpdateChList;
    procedure Localize;
  public
    constructor CreatePopUpFilterForm(ARxColumn: TRxColumn);
  end;

implementation
uses LCLType, rxdconst;

{$R *.lfm}

{ TRxDBGrid_PopUpFilterForm }

procedure TRxDBGrid_PopUpFilterForm.SpeedButton1Click(Sender: TObject);
begin
  if TComponent(Sender).Tag > 0 then
    FRxColumn.SortOrder:=smUp
  else
  if TComponent(Sender).Tag < 0 then
    FRxColumn.SortOrder:=smDown
  else
    FRxColumn.SortOrder:=smNone;
  FRxDBGrid.SetSort([FRxColumn.FieldName], [FRxColumn.SortOrder], true);
  Close;
end;

procedure TRxDBGrid_PopUpFilterForm.SpeedButton3Click(Sender: TObject);
begin
  FRxColumn.Filter.State:=rxfsAll;
  FRxColumn.Filter.CurrentValues.Clear;
  FRxDBGrid.DataSource.DataSet.Filtered := True;
  FRxDBGrid.DataSource.DataSet.First;
  Close;
end;

procedure TRxDBGrid_PopUpFilterForm.SpeedButton4Click(Sender: TObject);
begin
  FRxColumn.Filter.State:=rxfsEmpty;
  FRxDBGrid.DataSource.DataSet.Filtered := True;
  FRxDBGrid.DataSource.DataSet.First;
  Close;
end;

procedure TRxDBGrid_PopUpFilterForm.SpeedButton5Click(Sender: TObject);
begin
  FRxColumn.Filter.State:=rxfsNonEmpty;
  FRxDBGrid.DataSource.DataSet.Filtered := True;
  FRxDBGrid.DataSource.DataSet.First;
  Close;
end;

procedure TRxDBGrid_PopUpFilterForm.SpeedButton6Click(Sender: TObject);
begin
  Hide;
  Close;
  FRxDBGrid.ShowFilterDialog;
end;

procedure TRxDBGrid_PopUpFilterForm.SpeedButton9Click(Sender: TObject);
var
  K, i: Integer;
begin
  K:=CheckListBox1.ItemIndex;
  if K < 0 then
    K:=0;

  for i:=0 to CheckListBox1.Items.Count-1 do
    if i = k then
      CheckListBox1.Checked[i]:=TComponent(Sender).Tag > 0
    else
      CheckListBox1.Checked[i]:=TComponent(Sender).Tag = 0;
  CheckListBox1ClickCheck(nil);
end;

procedure TRxDBGrid_PopUpFilterForm.UpdateChList;
var
  i, Cnt: Integer;
  S: String;
begin
  CheckListBox1.Items.BeginUpdate;
  CheckListBox1.Items.Clear;
  Cnt:=FRxColumn.Filter.ValueList.Count - 1;
{
  if FRxColumn.Filter.Style = rxfstBoth then
    Dec(Cnt);
}
  for i:=0 to Cnt do
  begin
    S:=FRxColumn.Filter.ValueList[i];
    if (S <> FRxColumn.Filter.AllValue) and (S <> FRxColumn.Filter.EmptyValue) then
      CheckListBox1.Checked[CheckListBox1.Items.Add(S)]:=FRxColumn.Filter.CurrentValues.IndexOf(S) >= 0;
  end;

  CheckListBox1ClickCheck(nil);

  CheckListBox1.Items.EndUpdate;
end;

procedure TRxDBGrid_PopUpFilterForm.Localize;
begin
  DividerBevel1.Caption:=sSorting;
  SpeedButton1.Caption:=sAscending;
  SpeedButton2.Caption:=sDescending;
  DividerBevel2.Caption:=sQuickFilter;
  SpeedButton3.Caption:=sClearFilter;
  SpeedButton4.Caption:=sEmptyValues;
  SpeedButton5.Caption:=sNotEmpty;
  SpeedButton6.Caption:=sStandartFilter;
  CheckBox1.Caption:=sAllValues;
  SpeedButton9.Hint:=sHintShowOnlyCurrentItem;
  SpeedButton8.Hint:=sHintHideOnlyCurrentItem;
end;

constructor TRxDBGrid_PopUpFilterForm.CreatePopUpFilterForm(ARxColumn: TRxColumn
  );
begin
  inherited Create(ARxColumn.Grid);
  BorderStyle:=bsNone;
  FRxColumn:=ARxColumn;
  FRxDBGrid:=FRxColumn.Grid as TRxDBGrid;
  Localize;
  UpdateChList;
end;

procedure TRxDBGrid_PopUpFilterForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    ModalResult:=mrCancel;
end;

procedure TRxDBGrid_PopUpFilterForm.MenuItem1Click(Sender: TObject);
begin
  CheckBox1.Checked:=TComponent(Sender).Tag = 1;
end;

procedure TRxDBGrid_PopUpFilterForm.CheckBox1Change(Sender: TObject);
var
  i: Integer;
begin
  CheckListBox1.OnClickCheck:=nil;
  for i:=0 to CheckListBox1.Items.Count - 1 do
    CheckListBox1.Checked[i]:=CheckBox1.Checked;
  CheckListBox1.OnClickCheck:=@CheckListBox1ClickCheck;
//  CheckListBox1ClickCheck(nil);
end;

procedure TRxDBGrid_PopUpFilterForm.CheckListBox1ClickCheck(Sender: TObject);
var
  AC, AU: Boolean;
  i: Integer;
begin
  AC:=true;
  AU:=true;
  for i:=0 to CheckListBox1.Items.Count-1 do
  begin
    if not CheckListBox1.Checked[i] then
      AC:=false;
    if CheckListBox1.Checked[i] then
      AU:=false;
  end;

  CheckBox1.OnChange:=nil;
  if AC then
    CheckBox1.Checked:=true
  else
  if AU then
    CheckBox1.Checked:=false
  else
    CheckBox1.State:=cbGrayed;
  CheckBox1.OnChange:=@CheckBox1Change;
end;

procedure TRxDBGrid_PopUpFilterForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var
  i: Integer;
begin
  if ModalResult = mrOk then
  begin
    FRxDBGrid.DataSource.DataSet.DisableControls;
    FRxDBGrid.DataSource.DataSet.Filtered := false;
    if CheckBox1.Checked then
    begin
      FRxColumn.Filter.State:=rxfsAll;
      FRxColumn.Filter.CurrentValues.Assign(CheckListBox1.Items);
    end
    else
    if CheckBox1.State = cbUnchecked then
    begin
      FRxColumn.Filter.State:=rxfsAll;
      FRxColumn.Filter.CurrentValues.Clear;
    end
    else
    begin
      FRxColumn.Filter.CurrentValues.BeginUpdate;
      FRxColumn.Filter.CurrentValues.Clear;
      for i:=0 to CheckListBox1.Items.Count-1 do
        if CheckListBox1.Checked[i] then
          FRxColumn.Filter.CurrentValues.Add(CheckListBox1.Items[i]);
      FRxColumn.Filter.CurrentValues.EndUpdate;
      if (FRxColumn.Filter.CurrentValues.Count > 0) then
        FRxColumn.Filter.State:=rxfsFilter
      else
        FRxColumn.Filter.State:=rxfsAll;
    end;
    FRxDBGrid.DataSource.DataSet.Filtered := True;
    FRxDBGrid.DataSource.DataSet.First;
    FRxDBGrid.DataSource.DataSet.EnableControls;
  end;
end;

end.



