{ rxapputils unit

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

unit RxRangeSel;

{$I rx.inc}

interface

uses
  Classes, SysUtils, Types, Controls, LMessages, Graphics, ComCtrls;

type
  TRxRangeSelectorState =
      (rssNormal, rssDisabled,
       rssThumbTopHover, rssThumbTopDown,
       rssThumbBottomHover, rssThumbBottomDown,
       rssBlockHover, rssBlockDown);

  TRxRangeSelectorStyle = (rxrsSimple, rxrsLazarus, rxrsNative);

  { TRxCustomRangeSelector }

  TRxCustomRangeSelector = class(TCustomControl)
  private
    FBackgroudGlyph: TBitmap;
    FMax: Double;
    FMin: Double;
    FOnChange: TNotifyEvent;
    FOrientation: TTrackBarOrientation;
    FSelectedEnd: Double;
    FSelectedGlyph: TBitmap;
    FSelectedStart: Double;
    FState: TRxRangeSelectorState;
    FStyle: TRxRangeSelectorStyle;
    FThumbTopGlyph:TBitmap;
    FThumbBottomGlyph:TBitmap;
    //
    FThumbPosTop : TRect;
    FThumbPosBottom : TRect;
    FTracerPos : TRect;
    FSelectedPos : TRect;
    FThumbSize : TSize;

    FDblClicked : Boolean;
    FDown : boolean;
    FPrevX : integer;
    FPrevY : integer;
    procedure DoChange;
    function GetSelectedLength: Double;
    function GetThumbBottomGlyph: TBitmap;
    function GetThumbTopGlyph: TBitmap;
    function IsThumbBottomGlyphStored: Boolean;
    function IsThumbTopGlyphStored: Boolean;
    procedure SetBackgroudGlyph(AValue: TBitmap);
    procedure SetMax(AValue: Double);
    procedure SetMin(AValue: Double);
    procedure SetOrientation(AValue: TTrackBarOrientation);
    procedure SetSelectedEnd(AValue: Double);
    procedure SetSelectedGlyph(AValue: TBitmap);
    procedure SetSelectedStart(AValue: Double);
    procedure SetStyle(AValue: TRxRangeSelectorStyle);
    procedure SetThumbBottomGlyph(AValue: TBitmap);
    procedure SetThumbTopGlyph(AValue: TBitmap);
    procedure InitSizes;
    procedure UpdateData;
    function LogicalToScreen(const LogicalPos: double): double;
    function BarWidth: integer;
    procedure SetState(AValue: TRxRangeSelectorState);
    function DeduceState(const AX, AY: integer; const ADown: boolean): TRxRangeSelectorState;
    procedure InitImages(AOrient:TTrackBarOrientation);
  protected
    procedure Paint; override;
    class function GetControlClassDefaultSize: TSize; override;
    procedure Loaded; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseLeave; override ;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property SelectedGlyph: TBitmap read FSelectedGlyph write SetSelectedGlyph;
    property BackgroudGlyph: TBitmap read FBackgroudGlyph write SetBackgroudGlyph;

    procedure SetBounds(aLeft, aTop, aWidth, aHeight: integer); override;
    property Min:Double read FMin write SetMin;
    property Max:Double read FMax write SetMax;
    property SelectedStart : Double read FSelectedStart write SetSelectedStart;
    property SelectedEnd : Double read FSelectedEnd write SetSelectedEnd;
    property SelectedLength : Double read GetSelectedLength;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Style:TRxRangeSelectorStyle read FStyle write SetStyle;
    property ThumbTopGlyph: TBitmap read GetThumbTopGlyph write SetThumbTopGlyph stored IsThumbTopGlyphStored;
    property ThumbBottomGlyph: TBitmap read GetThumbBottomGlyph write SetThumbBottomGlyph stored IsThumbBottomGlyphStored;
    property State:TRxRangeSelectorState read FState;
    property Orientation:TTrackBarOrientation read FOrientation write SetOrientation default trHorizontal;
  end;

  { TRxRangeSelector }

  TRxRangeSelector = class(TRxCustomRangeSelector)
  published
    property Anchors;
    property Enabled;
    property Visible;
    property Color ;

    property Min;
    property Max;
    property SelectedStart;
    property SelectedEnd;
    property Style;
    property OnChange;
    property ThumbTopGlyph;
    property ThumbBottomGlyph;
    property SelectedGlyph;
    property Orientation;
  end;

implementation
uses rxlclutils, LCLType, LCLIntf, Themes;

const
  sRX_RANGE_H_BACK = 'RX_RANGE_H_BACK';
  sRX_RANGE_H_SEL = 'RX_RANGE_H_SEL';
  sRX_SLADER_BOTTOM = 'RX_SLADER_BOTTOM';
  sRX_SLADER_TOP = 'RX_SLADER_TOP';

  sRX_RANGE_V_BACK = 'RX_RANGE_V_BACK';
  sRX_RANGE_V_SEL = 'RX_RANGE_V_SEL';
  sRX_SLADER_LEFT = 'RX_SLADER_LEFT';
  sRX_SLADER_RIGHT = 'RX_SLADER_RIGHT';

function IsIntInInterval(x, xmin, xmax: integer): boolean; inline;
begin
  IsIntInInterval := (xmin <= x) and (x <= xmax);
end;

function PointInRect(const X, Y: integer; const Rect: TRect): boolean; inline;
begin
  PointInRect := IsIntInInterval(X, Rect.Left, Rect.Right) and
                 IsIntInInterval(Y, Rect.Top, Rect.Bottom);
end;

function IsRealInInterval(x, xmin, xmax: extended): boolean; inline;
begin
  IsRealInInterval := (xmin <= x) and (x <= xmax);
end;

{ TRxCustomRangeSelector }

procedure TRxCustomRangeSelector.SetMax(AValue: Double);
begin
  if FMax=AValue then Exit;
  FMax:=AValue;

  if FSelectedEnd > FMax then
    FSelectedEnd:=FMax;

  UpdateData;
  Invalidate;
  DoChange;
end;

procedure TRxCustomRangeSelector.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TRxCustomRangeSelector.GetSelectedLength: Double;
begin
  Result:=FSelectedEnd - FSelectedStart;
end;

function TRxCustomRangeSelector.GetThumbBottomGlyph: TBitmap;
begin
  Result:=FThumbBottomGlyph;
end;

function TRxCustomRangeSelector.GetThumbTopGlyph: TBitmap;
begin
  Result:=FThumbTopGlyph;
end;

function TRxCustomRangeSelector.IsThumbBottomGlyphStored: Boolean;
begin

end;

function TRxCustomRangeSelector.IsThumbTopGlyphStored: Boolean;
begin

end;

procedure TRxCustomRangeSelector.SetBackgroudGlyph(AValue: TBitmap);
begin
  InitSizes;
  FBackgroudGlyph.Assign(AValue);
end;

procedure TRxCustomRangeSelector.SetMin(AValue: Double);
begin
  if FMin=AValue then Exit;
  FMin:=AValue;

  if FSelectedStart < FMin then
    FSelectedStart:=FMin;

  UpdateData;
  Invalidate;
  DoChange;
end;

procedure TRxCustomRangeSelector.SetOrientation(AValue: TTrackBarOrientation);
begin
  if FOrientation=AValue then Exit;
  FOrientation:=AValue;

  InitImages(FOrientation);

  UpdateData;
  Invalidate;
end;

procedure TRxCustomRangeSelector.SetSelectedEnd(AValue: Double);
begin
  if FSelectedEnd=AValue then Exit;
  FSelectedEnd:=AValue;

  if FSelectedEnd > FMax then
    FSelectedEnd:=FMax
  else
  if FSelectedEnd < FSelectedStart then
    FSelectedEnd:=FSelectedStart;

  UpdateData;
  Invalidate;
  DoChange;
end;

procedure TRxCustomRangeSelector.SetSelectedGlyph(AValue: TBitmap);
begin
  InitSizes;
  FSelectedGlyph.Assign(AValue);
end;

procedure TRxCustomRangeSelector.SetSelectedStart(AValue: Double);
begin
  if FSelectedStart=AValue then Exit;
  FSelectedStart:=AValue;

  if FSelectedStart < FMin then
    FSelectedStart:=FMin
  else
  if FSelectedStart > FSelectedEnd then
    FSelectedStart:=FSelectedEnd;

  UpdateData;
  Invalidate;
  DoChange;
end;

procedure TRxCustomRangeSelector.SetStyle(AValue: TRxRangeSelectorStyle);
begin
  if FStyle=AValue then Exit;
  FStyle:=AValue;
  InitSizes;
  UpdateData;
  Invalidate;
end;

procedure TRxCustomRangeSelector.SetThumbBottomGlyph(AValue: TBitmap);
begin
  FThumbBottomGlyph.Assign(AValue);
  InitSizes;
  UpdateData;
  Invalidate;
end;

procedure TRxCustomRangeSelector.SetThumbTopGlyph(AValue: TBitmap);
begin
  FThumbTopGlyph.Assign(AValue);
  InitSizes;
  UpdateData;
  Invalidate;
end;

procedure TRxCustomRangeSelector.InitSizes;
var
  TD: TThemedElementDetails;
begin
  {$IFDEF WINDOWS}
  if (FStyle = rxrsNative) and ThemeServices.ThemesEnabled then
  begin
    if FOrientation = trHorizontal then
      TD:=ThemeServices.GetElementDetails(ttbThumbBottomPressed)
    else
      TD:=ThemeServices.GetElementDetails(ttbThumbRightPressed);
    FThumbSize:=ThemeServices.GetDetailSize(TD);
  end
  else
  {$ENDIF WINDOWS}
  if Assigned(FThumbTopGlyph) and (FThumbTopGlyph.Width > 0) then
  begin
    FThumbSize.CX:=FThumbTopGlyph.Width;
    FThumbSize.CY:=FThumbTopGlyph.Height;
  end
  else
  if Assigned(FThumbBottomGlyph) and (FThumbBottomGlyph.Width > 0) then
  begin
    FThumbSize.CX:=FThumbBottomGlyph.Width;
    FThumbSize.CY:=FThumbBottomGlyph.Height;
  end
  else
  begin
    FThumbSize.CX:=6;
    FThumbSize.CY:=10;
  end;
end;

procedure TRxCustomRangeSelector.UpdateData;
begin
  if FOrientation = trHorizontal then
  begin
    FTracerPos.Left := FThumbSize.CX div 2;
    FTracerPos.Right :=Width - FThumbSize.CX div 2;
    FTracerPos.Top:=FThumbSize.CY + 1;
    FTracerPos.Bottom:=FThumbPosBottom.Top - 1;

    FSelectedPos.Left := round(LogicalToScreen(FSelectedStart)) - FThumbSize.CX div 2;
    FSelectedPos.Top := FTracerPos.Top;
    FSelectedPos.Right := round(LogicalToScreen(FSelectedEnd)) + FThumbSize.CX div 2;
    FSelectedPos.Bottom := FTracerPos.Bottom;


    FThumbPosTop.Top:=0;
    FThumbPosTop.Left:=FSelectedPos.Left - FThumbSize.CX div 2;
    FThumbPosTop.Bottom:=FThumbTopGlyph.Height;
    FThumbPosTop.Right:=FThumbPosTop.Left + FThumbSize.CX;

    FThumbPosBottom.Bottom:=Height;
    FThumbPosBottom.Right:=FSelectedPos.Right + FThumbSize.CX div 2;
    FThumbPosBottom.Top:=Height - FThumbBottomGlyph.Height;
    FThumbPosBottom.Left:=FThumbPosBottom.Right - FThumbSize.CX;
  end
  else
  begin
    FTracerPos.Top:= FThumbSize.CY div 2;
    FTracerPos.Bottom:=Height - FThumbSize.CY div 2;
    FTracerPos.Left := FThumbSize.CX + 1;
    FTracerPos.Right :=Width - FThumbSize.CX - 1;

    FSelectedPos.Left := FTracerPos.Left;
    FSelectedPos.Top := round(LogicalToScreen(FSelectedStart)) - FThumbSize.CY div 2;
    FSelectedPos.Right := FTracerPos.Right;
    FSelectedPos.Bottom := round(LogicalToScreen(FSelectedEnd)) + FThumbSize.CY div 2;

    FThumbPosTop.Left:=0;
    FThumbPosTop.Right:=FThumbTopGlyph.Width;
    FThumbPosTop.Top:=FSelectedPos.Top - FThumbSize.CY div 2;
    FThumbPosTop.Bottom:=FThumbPosTop.Top + FThumbSize.CY;

    FThumbPosBottom.Right:=Width;
    FThumbPosBottom.Left:=Width - FThumbSize.CX - 1;
    FThumbPosBottom.Top:=FSelectedPos.Bottom - FThumbSize.CY div 2;
    FThumbPosBottom.Bottom:=FThumbPosBottom.Top + FThumbSize.CY;
  end;
end;

function TRxCustomRangeSelector.LogicalToScreen(const LogicalPos: double
  ): double;
begin
  if FOrientation = trHorizontal then
    Result := FThumbSize.CX
  else
    Result := FThumbSize.CY;

  if (FMax - FMin) > 0 then
    Result := Result + BarWidth * (LogicalPos - FMin) / (FMax - FMin)
end;

function TRxCustomRangeSelector.BarWidth: integer;
begin
  if FOrientation = trHorizontal then
    result := Width - 2 * FThumbSize.CX
  else
    result := Height - 2 * FThumbSize.CY;
end;

procedure TRxCustomRangeSelector.SetState(AValue: TRxRangeSelectorState);
begin
  if AValue <> FState then
  begin
    FState := AValue;
    Invalidate;
  end;
end;

function TRxCustomRangeSelector.DeduceState(const AX, AY: integer;
  const ADown: boolean): TRxRangeSelectorState;
begin
  Result := rssNormal;

  if not Enabled then
    Result := rssDisabled
  else
  begin
    if PointInRect(AX, AY, FThumbPosTop) then
    begin
      if ADown then
        Result := rssThumbTopDown
      else
        Result := rssThumbTopHover;
    end
    else
    if PointInRect(AX, AY, FThumbPosBottom) then
    begin
      if ADown then
        Result := rssThumbBottomDown
      else
        Result := rssThumbBottomHover;
    end
    else
    if PointInRect(AX, AY, FSelectedPos) then
    begin
      if ADown then
        Result := rssBlockDown
      else
        Result := rssBlockHover;
    end;
  end;
end;

procedure TRxCustomRangeSelector.InitImages(AOrient: TTrackBarOrientation);
begin
  if AOrient = trHorizontal then
  begin
    FSelectedGlyph := CreateResBitmap(sRX_RANGE_H_SEL);
    FBackgroudGlyph := CreateResBitmap(sRX_RANGE_H_BACK);

    FThumbTopGlyph:=CreateResBitmap(sRX_SLADER_TOP);
    FThumbBottomGlyph:=CreateResBitmap(sRX_SLADER_BOTTOM);
  end
  else
  begin
    FSelectedGlyph := CreateResBitmap(sRX_RANGE_V_SEL);
    FBackgroudGlyph := CreateResBitmap(sRX_RANGE_V_BACK);

    FThumbTopGlyph:=CreateResBitmap(sRX_SLADER_LEFT);
    FThumbBottomGlyph:=CreateResBitmap(sRX_SLADER_RIGHT);
  end;
end;

procedure TRxCustomRangeSelector.Paint;
var
  DE: TThemedElementDetails;
begin
  inherited Paint;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(ClientRect);

  {$IFDEF WINDOWS}
  if (FStyle = rxrsNative) and ThemeServices.ThemesEnabled then
  begin
    if FOrientation = trHorizontal then
      DE:=ThemeServices.GetElementDetails(ttbThumbBottomPressed)
    else
      DE:=ThemeServices.GetElementDetails(ttbThumbRightPressed);

    ThemeServices.DrawElement( Canvas.Handle, DE, FThumbPosTop);

    if FOrientation = trHorizontal then
      DE:=ThemeServices.GetElementDetails(ttbThumbTopPressed)
    else
      DE:=ThemeServices.GetElementDetails(ttbThumbLeftPressed);
    ThemeServices.DrawElement( Canvas.Handle, DE, FThumbPosBottom);

    if FOrientation = trHorizontal then
      DE:=ThemeServices.GetElementDetails(ttbTrack)
    else
      DE:=ThemeServices.GetElementDetails(ttbTrackVert);
    ThemeServices.DrawElement( Canvas.Handle, DE, FTracerPos);

    if FOrientation = trHorizontal then
      DE:=ThemeServices.GetElementDetails(ttbThumbNormal)
    else
      DE:=ThemeServices.GetElementDetails(ttbThumbVertNormal);
    ThemeServices.DrawElement( Canvas.Handle, DE, FSelectedPos);
  end
  else
  {$ENDIF WINDOWS}
  if FStyle = rxrsSimple then
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ClientRect);

    DrawEdge(Canvas.Handle, FTracerPos, EDGE_SUNKEN, BF_RECT);

    Canvas.Brush.Color := clHighlight;
    Canvas.FillRect(FSelectedPos);

    case FState of
        rssDisabled:
          DrawEdge(Canvas.Handle, FSelectedPos, EDGE_BUMP, BF_RECT or BF_MONO);
        rssBlockHover:
          DrawEdge(Canvas.Handle, FSelectedPos, EDGE_RAISED, BF_RECT);
        rssBlockDown:
          DrawEdge(Canvas.Handle, FSelectedPos, EDGE_SUNKEN, BF_RECT);
    else
        DrawEdge(Canvas.Handle, FSelectedPos, EDGE_ETCHED, BF_RECT);
    end;

    case FState of
        rssDisabled:
          DrawEdge(Canvas.Handle, FThumbPosTop, EDGE_BUMP, BF_RECT or BF_MONO);
        rssThumbTopHover:
          DrawEdge(Canvas.Handle, FThumbPosTop, EDGE_RAISED, BF_RECT);
        rssThumbTopDown:
          DrawEdge(Canvas.Handle, FThumbPosTop, EDGE_SUNKEN, BF_RECT);
    else
        DrawEdge(Canvas.Handle, FThumbPosTop, EDGE_ETCHED, BF_RECT);
    end;

    case FState of
        rssDisabled:
          DrawEdge(Canvas.Handle, FThumbPosBottom, EDGE_BUMP, BF_RECT or BF_MONO);
        rssThumbBottomHover:
          DrawEdge(Canvas.Handle, FThumbPosBottom, EDGE_RAISED, BF_RECT);
        rssThumbBottomDown:
          DrawEdge(Canvas.Handle, FThumbPosBottom, EDGE_SUNKEN, BF_RECT);
    else
        DrawEdge(Canvas.Handle, FThumbPosBottom, EDGE_ETCHED, BF_RECT);
    end;
  end
  else
  begin
    Canvas.Draw(FThumbPosTop.Left, FThumbPosTop.Top, FThumbTopGlyph);
    Canvas.Draw(FThumbPosBottom.Left, FThumbPosBottom.Top, FThumbBottomGlyph);

    if (FBackgroudGlyph.Width > 0) and (FBackgroudGlyph.Height>0) then
    begin
      Canvas.StretchDraw(FTracerPos, FBackgroudGlyph)
    end;

    if (FSelectedGlyph.Width > 0) and (FSelectedGlyph.Height > 0) then
      Canvas.StretchDraw(FSelectedPos, FSelectedGlyph)
    else
    begin
      Canvas.Brush.Color := clBlue;
      Canvas.FillRect(FSelectedPos);
    end;
  end
end;

class function TRxCustomRangeSelector.GetControlClassDefaultSize: TSize;
begin
  Result.CX := 100;
  Result.CY := 60;
end;

procedure TRxCustomRangeSelector.Loaded;
begin
  inherited Loaded;
  UpdateData;
end;

procedure TRxCustomRangeSelector.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X: Integer; Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);

  if FDblClicked then
  begin
    FDblClicked := false;
    Exit;
  end;

  FDown := Button = mbLeft;
  SetState(DeduceState(X, Y, FDown));
end;

procedure TRxCustomRangeSelector.MouseMove(Shift: TShiftState; X: Integer;
  Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);

  if FState = rssThumbTopDown then
  begin
    if FOrientation = trHorizontal then
      SetSelectedStart(FSelectedStart + (X - FPrevX) * (FMax - FMin) / BarWidth)
    else
      SetSelectedStart(FSelectedStart + (Y - FPrevY) * (FMax - FMin) / BarWidth)
  end
  else
  if FState = rssThumbBottomDown then
  begin
    if FOrientation = trHorizontal then
      SetSelectedEnd(FSelectedEnd + (X - FPrevX) * (FMax - FMin) / BarWidth)
    else
      SetSelectedEnd(FSelectedEnd + (Y - FPrevY) * (FMax - FMin) / BarWidth)
  end
  else
  if FState = rssBlockDown then
  begin
    if FOrientation = trHorizontal then
    begin
      if IsRealInInterval(FSelectedStart + (X - FPrevX) * (FMax - FMin) / BarWidth, FMin, FMax) and
         IsRealInInterval(FSelectedEnd + (X - FPrevX) * (FMax - FMin) / BarWidth, FMin, FMax) then
      begin
        SetSelectedStart(FSelectedStart + (X - FPrevX) * (FMax - FMin) / BarWidth);
        SetSelectedEnd(FSelectedEnd + (X - FPrevX) * (FMax - FMin) / BarWidth);
      end;
    end
    else
    begin
      if IsRealInInterval(FSelectedStart + (Y - FPrevY) * (FMax - FMin) / BarWidth, FMin, FMax) and
         IsRealInInterval(FSelectedEnd + (Y - FPrevY) * (FMax - FMin) / BarWidth, FMin, FMax) then
      begin
        SetSelectedStart(FSelectedStart + (Y - FPrevY) * (FMax - FMin) / BarWidth);
        SetSelectedEnd(FSelectedEnd + (Y - FPrevY) * (FMax - FMin) / BarWidth);
      end;
    end
  end
  else
    SetState(DeduceState(X, Y, FDown));

  FPrevX := X;
  FPrevY := Y;
end;

procedure TRxCustomRangeSelector.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X: Integer; Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FDown := false;
  SetState(DeduceState(X, Y, FDown));
end;

procedure TRxCustomRangeSelector.MouseLeave;
begin
  inherited MouseLeave;
  if Enabled then
    SetState(rssNormal)
  else
    SetState(rssDisabled);
end;

procedure TRxCustomRangeSelector.SetBounds(aLeft, aTop, aWidth, aHeight: integer
  );
begin
  inherited SetBounds(aLeft, aTop, aWidth, aHeight);
  InitSizes;
  UpdateData;
  Invalidate;
end;

constructor TRxCustomRangeSelector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

//  FThumbTopGlyph:=TBitmap.Create;
//  FThumbBottomGlyph:=TBitmap.Create;

//  FSelectedGlyph:=TBitmap.Create;
//  FBackgroudGlyph:=TBitmap.Create;
  InitImages(trHorizontal);

  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, CX, CY);

  FSelectedEnd:=50;
  FMax:=100;
  FOrientation:=trHorizontal;
end;

destructor TRxCustomRangeSelector.Destroy;
begin
  FreeAndNil(FThumbTopGlyph);
  FreeAndNil(FThumbBottomGlyph);
  FreeAndNil(FSelectedGlyph);
  FreeAndNil(FBackgroudGlyph);
  inherited Destroy;
end;

end.

