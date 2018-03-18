{ RXHistory unit

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

unit RXHistory;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  rxtoolbar;

type
  TToolbarButtonStyleCntrl = (tbrcNotChange, tbrcDropDown, tbrcDropDownExtra);

  PNavigateRec = ^TNavigateRec;
  TNavigateRec = packed record
    Name:string;
    Cond:string;
    Next:PNavigateRec;
  end;

  TOnNavigateEvent = procedure(Sender:TObject; const EventName, EventMacro:string) of object;
  { TRXHistory }

  TRXHistory = class(TComponent)
  private
    FButtonNext: string;
    FButtonPrior: string;
    FButtonStyle: TToolbarButtonStyleCntrl;
    FNextButton: TToolbarItem;
    FNextButtonName: string;
    FOnNavigateEvent: TOnNavigateEvent;
    FPriorButton: TToolbarItem;
    FPriorButtonName: string;
    FToolPanel: TToolPanel;
    function GetNextButtonName: string;
    function GetPriorButtonName: string;
    procedure SetButtonStyle(const AValue: TToolbarButtonStyleCntrl);
    procedure SetNextButtonName(const AValue: string);
    procedure SetPriorButtonName(const AValue: string);
    procedure SetToolPanel(const AValue: TToolPanel);
    function SetBtn(const ABtnName: string;var Button:TToolbarItem):boolean;
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    property PriorButton:TToolbarItem read FPriorButton;
    property NextButton:TToolbarItem read FNextButton;
  published
    property ToolPanel:TToolPanel read FToolPanel write SetToolPanel;
    property PriorButtonName:string read GetPriorButtonName write SetPriorButtonName;
    property NextButtonName:string read GetNextButtonName write SetNextButtonName;
    property ButtonStyle:TToolbarButtonStyleCntrl read FButtonStyle write SetButtonStyle default tbrcNotChange;
    property OnNavigateEvent:TOnNavigateEvent read FOnNavigateEvent write FOnNavigateEvent;
  end;

procedure Register;

implementation
uses PropEdits, Componenteditors, TypInfo;

type

  { TTRXHistoryBtnNameProperty }

  TTRXHistoryBtnNameProperty = class(TStringPropertyEditor)
  public
    function  GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

{ TTRXHistoryBtnNameProperty }

function TTRXHistoryBtnNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result:=inherited GetAttributes;
  Result:=Result + [paValueList, paSortList, paMultiSelect];
end;

procedure TTRXHistoryBtnNameProperty.GetValues(Proc: TGetStrProc);
var
  ToolPanel:TToolPanel;
  i:integer;
begin
  ToolPanel := GetObjectProp(GetComponent(0), 'ToolPanel') as TToolPanel;
  if Assigned(ToolPanel) then
    for I := 0 to ToolPanel.Items.Count - 1 do
    begin
      if Assigned(ToolPanel.Items[i].Action) then
       Proc(ToolPanel.Items[i].Action.Name);
    end;
end;

procedure Register;
begin
  RegisterComponents('RX',[TRXHistory]);

  RegisterPropertyEditor(TypeInfo(string), TRXHistory, 'PriorButtonName', TTRXHistoryBtnNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TRXHistory, 'NextButtonName', TTRXHistoryBtnNameProperty);
end;

{ TRXHistory }

procedure TRXHistory.SetToolPanel(const AValue: TToolPanel);
begin
  if FToolPanel=AValue then exit;
  FToolPanel:=AValue;
end;

function TRXHistory.SetBtn(const ABtnName: string;var Button:TToolbarItem):boolean;
var
  i:integer;
begin
  Result:=false;
  if not Assigned(FToolPanel) then exit;
  Button:=FToolPanel.Items.ByActionName[ABtnName];
  Result:=Assigned(Button);
  if Result then
  begin
    case FButtonStyle of
      tbrcDropDown:Button.ButtonStyle:=tbrDropDown;
      tbrcDropDownExtra:Button.ButtonStyle:=tbrDropDownExtra;
    end;
  end;
end;

procedure TRXHistory.Loaded;
begin
  inherited Loaded;
  if not SetBtn(FNextButtonName, FNextButton) then
    FNextButtonName:='';
  if not SetBtn(FPriorButtonName, FPriorButton) then
    FPriorButtonName:='';
end;

constructor TRXHistory.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButtonStyle:=tbrcNotChange;
end;

procedure TRXHistory.SetNextButtonName(const AValue: string);
begin
  if FNextButtonName=AValue then exit;
  if csLoading in ComponentState then
    FNextButtonName:=AValue
  else
  begin
    if SetBtn(AValue, FNextButton) then
      FNextButtonName:=AValue
    else
      FNextButtonName:='';
  end;
end;

procedure TRXHistory.SetButtonStyle(const AValue: TToolbarButtonStyleCntrl);
begin
  if FButtonStyle=AValue then exit;
  FButtonStyle:=AValue;
end;

function TRXHistory.GetNextButtonName: string;
begin
  if Assigned(NextButton) and Assigned(NextButton.Action) then
    Result:=NextButton.Action.Name
  else
    Result:='';
end;

function TRXHistory.GetPriorButtonName: string;
begin
  if Assigned(PriorButton) and Assigned(PriorButton.Action) then
    Result:=PriorButton.Action.Name
  else
    Result:='';
end;

procedure TRXHistory.SetPriorButtonName(const AValue: string);
begin
  if FPriorButtonName=AValue then exit;
  if csLoading in ComponentState then
    FPriorButtonName:=AValue
  else
  begin
    if SetBtn(AValue, FPriorButton) then
      FPriorButtonName:=AValue
    else
      FPriorButtonName:='';
  end;
end;

end.
