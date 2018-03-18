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

unit rxdbgrid;

interface

uses
  Classes, SysUtils, LResources, LCLType, LCLIntf, Forms, Controls, Buttons,
  Graphics, Dialogs, Grids, rxdbutils, DBGrids, DB, PropertyStorage, rxlclutils,
  LMessages, types, StdCtrls, Menus, rxspin, LCLVersion;

const
  CBadQuickSearchSymbols = [VK_UNKNOWN..VK_HELP] + [VK_LWIN..VK_SLEEP] +
    [VK_NUMLOCK..VK_SCROLL] + [VK_LSHIFT..VK_OEM_102] + [VK_PROCESSKEY] +
    [VK_ATTN..VK_UNDEFINED];
  CCancelQuickSearchKeys = [VK_ESCAPE, VK_CANCEL, VK_DELETE, VK_INSERT,
    VK_DOWN, VK_UP, VK_NEXT, VK_PRIOR, VK_TAB, VK_RETURN, VK_HOME,
    VK_END, VK_SPACE, VK_MULTIPLY];

type
  //forward declarations
  TRxDBGrid = class;
  TRxColumn = class;
  TRxDBGridAbstractTools = class;
  TRxDbGridColumnsEnumerator = class;
  TRxColumnFooterItemsEnumerator = class;


  TRxQuickSearchNotifyEvent = procedure(Sender: TObject; Field: TField;
    var AValue: string) of object;

  TSortMarker = (smNone, smDown, smUp);

  TGetBtnParamsEvent = procedure(Sender: TObject; Field: TField;
    AFont: TFont; var Background: TColor; var SortMarker: TSortMarker;
    IsDown: boolean) of object;

  TGetCellPropsEvent = procedure(Sender: TObject; Field: TField;
    AFont: TFont; var Background: TColor) of object;

  TRxDBGridDataHintShowEvent = procedure(Sender: TObject; CursorPos: TPoint;
      Cell: TGridCoord; Column: TRxColumn; var HintStr: string;
      var Processed: boolean) of object;

  TRxDBGridCalcRowHeight = procedure(Sender: TRxDBGrid;  var ARowHegth:integer) of object;
  TRxDBGridMergeCellsEvent = procedure (Sender: TObject; ACol : Integer;
    var ALeft, ARight : Integer; var ADisplayColumn: TRxColumn) of object;

  //Freeman35 added
  TOnRxCalcFooterValues = procedure(Sender: TObject; Column: TRxColumn; var AValue : Variant) of object;
  TOnRxColumnFooterDraw = procedure(Sender: TObject; ABrush: TBrush; AFont : TFont;
    const Rect: TRect; Column: TRxColumn; var AText :String) of object;

  TRxColumnOption = (coCustomizeVisible, coCustomizeWidth, coFixDecimalSeparator, coDisableDialogFind);
  TRxColumnOptions = set of TRxColumnOption;

  TRxColumnEditButtonStyle = (ebsDropDownRx, ebsEllipsisRx, ebsGlyphRx, ebsUpDownRx,
    ebsPlusRx, ebsMinusRx);

  TFooterValueType = (fvtNon, fvtSum, fvtAvg, fvtCount, fvtFieldValue,
    fvtStaticText, fvtMax, fvtMin, fvtRecNo);

  TOptionRx = (rdgAllowColumnsForm,
    rdgAllowDialogFind,
    rdgHighlightFocusCol,          //TODO:
    rdgHighlightFocusRow,          //TODO:
    rdgDblClickOptimizeColWidth,
    rdgFooterRows,
    rdgXORColSizing,
    rdgFilter,
    rdgMultiTitleLines,
    rdgMrOkOnDblClik,
    rdgAllowQuickSearch,
    rdgAllowQuickFilter,
    rdgAllowFilterForm,
    rdgAllowSortForm,
    rdgAllowToolMenu,
    rdgCaseInsensitiveSort,
    rdgWordWrap,
    rdgDisableWordWrapTitles,
    rdgColSpanning
    );

  TOptionsRx = set of TOptionRx;

  TCreateLookup = TNotifyEvent;
  TDisplayLookup = TNotifyEvent;

  TRxDBGridCommand = (rxgcNone, rxgcShowFindDlg, rxgcShowColumnsDlg,
    rxgcShowFilterDlg, rxgcShowSortDlg, rxgcShowQuickFilter,
    rxgcHideQuickFilter, rxgcSelectAll, rxgcDeSelectAll, rxgcInvertSelection,
    rxgcOptimizeColumnsWidth, rxgcCopyCellValue

    );

  TRxFilterOpCode = (fopEQ, fopNotEQ, fopStartFrom, fopEndTo, fopLike, fopNotLike);

  { TRxDBGridKeyStroke }

  TRxDBGridKeyStroke = class(TCollectionItem)
  private
    FCommand: TRxDBGridCommand;
    FEnabled: boolean;
    FShortCut: TShortCut;
    FKey: word;          // Virtual keycode, i.e. VK_xxx
    FShift: TShiftState;
    procedure SetCommand(const AValue: TRxDBGridCommand);
    procedure SetShortCut(const AValue: TShortCut);
  protected
    function GetDisplayName: string; override;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Command: TRxDBGridCommand read FCommand write SetCommand;
    property ShortCut: TShortCut read FShortCut write SetShortCut;
    property Enabled: boolean read FEnabled write FEnabled;
  end;

  { TRxDBGridKeyStrokes }

  TRxDBGridKeyStrokes = class(TOwnedCollection)
  private
    function GetItem(Index: integer): TRxDBGridKeyStroke;
    procedure SetItem(Index: integer; const AValue: TRxDBGridKeyStroke);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    procedure Assign(Source: TPersistent); override;
    function Add: TRxDBGridKeyStroke;
    function AddE(ACommand: TRxDBGridCommand; AShortCut: TShortCut): TRxDBGridKeyStroke;
    procedure ResetDefaults;
    function FindRxCommand(AKey: word; AShift: TShiftState): TRxDBGridCommand;
    function FindRxKeyStrokes(ACommand: TRxDBGridCommand): TRxDBGridKeyStroke;
  public
    property Items[Index: integer]: TRxDBGridKeyStroke read GetItem write SetItem; default;
  end;

  { TRxDBGridSearchOptions }

  TRxDBGridSearchOptions = class(TPersistent)
  private
    FFromStart: boolean;
    FOwner:TRxDBGrid;
    FQuickSearchOptions: TLocateOptions;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TRxDBGrid);
  published
    property QuickSearchOptions:TLocateOptions read FQuickSearchOptions write FQuickSearchOptions;
    property FromStart:boolean read FFromStart write FFromStart;
  end;

  { TRxDBGridCollumnConstraint }

  TRxDBGridCollumnConstraints = class(TPersistent)
  private
    FMaxWidth: integer;
    FMinWidth: integer;
    FOwner: TPersistent;
    procedure SetMaxWidth(AValue: integer);
    procedure SetMinWidth(AValue: integer);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TPersistent);
  published
    property MinWidth:integer read FMinWidth write SetMinWidth default 0;
    property MaxWidth:integer read FMaxWidth write SetMaxWidth default 0;
  end;

  { TRxDBGridFooterOptions }

  TRxDBGridFooterOptions = class(TPersistent)
  private
    FActive: boolean;
    FColor: TColor;
    FDrawFullLine: boolean;
    FOwner: TRxDBGrid;
    FRowCount: integer;
    FStyle: TTitleStyle;
    procedure SetActive(AValue: boolean);
    procedure SetColor(AValue: TColor);
    procedure SetDrawFullLine(AValue: boolean);
    procedure SetRowCount(AValue: integer);
    procedure SetStyle(AValue: TTitleStyle);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(Owner: TRxDBGrid);
    destructor Destroy; override;
  published
    property Active: boolean read FActive write SetActive default false;
    property Color: TColor read FColor write SetColor default clWindow;
    property RowCount: integer read FRowCount write SetRowCount default 0;
    property Style: TTitleStyle read FStyle write SetStyle default tsLazarus;
    property DrawFullLine: boolean read FDrawFullLine write SetDrawFullLine;
  end;

  { TRxDBGridColumnDefValues }

  TRxDBGridColumnDefValues = class(TPersistent)
  private
    FBlobText: string;
    FOwner: TRxDBGrid;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TRxDBGrid);
    destructor Destroy; override;
  published
    property BlobText:string read FBlobText write FBlobText;
  end;

  { TRxDBGridSortEngine }
  TRxSortEngineOption = (seoCaseInsensitiveSort);
  TRxSortEngineOptions = set of TRxSortEngineOption;

  TRxDBGridSortEngine = class
  protected
    FGrid:TRxDBGrid;
  public
    procedure Sort(FieldName: string; ADataSet: TDataSet; Asc: boolean; SortOptions: TRxSortEngineOptions); virtual; abstract;
    procedure SortList(ListField: string; ADataSet: TDataSet; Asc: array of boolean; SortOptions: TRxSortEngineOptions); virtual;
  end;

  TRxDBGridSortEngineClass = class of TRxDBGridSortEngine;

  TMLCaptionItem = class
    Caption: string;
    Width: integer;
    Height: integer;
    Next: TMLCaptionItem;
    Prior: TMLCaptionItem;
    FInvalidDraw:integer;
    Col: TGridColumn;
  end;

  { TRxColumnTitle }
  TRxColumnTitle = class(TColumnTitle)
  private
    FHint: string;
    FOrientation: TTextOrientation;
    FShowHint: boolean;
    FCaptionLines: TFPList;
    function GetCaptionLinesCount: integer;
    procedure SetOrientation(const AValue: TTextOrientation);
    procedure ClearCaptionML;
  protected
    procedure SetCaption(const AValue: TCaption); override;
  public
    constructor Create(TheColumn: TGridColumn); override;
    destructor Destroy; override;
    property CaptionLinesCount: integer read GetCaptionLinesCount;
    function CaptionLine(ALine: integer): TMLCaptionItem;
  published
    property Orientation: TTextOrientation read FOrientation write SetOrientation;
    property Hint: string read FHint write FHint;
    property ShowHint: boolean read FShowHint write FShowHint default False;
  end;

  { TRxColumnFooterItem }
  TRxColumnFooterItem = class(TCollectionItem)
  private
    FColor: TColor;
    FIsDefaultFont: boolean;
    FLayout: TTextLayout;
    FOwner: TRxColumn;
    FAlignment: TAlignment;
    FDisplayFormat: string;
    FFieldName: string;
    FField:TField;
    FFont: TFont;
    FValue: string;
    FValueType: TFooterValueType;
    FTestValue: double;
    FCountRec:integer;
    procedure FontChanged(Sender: TObject);
    function GetFont: TFont;
    function IsFontStored: Boolean;
    procedure SetAlignment(AValue: TAlignment);
    procedure SetColor(AValue: TColor);
    procedure SetDisplayFormat(AValue: string);
    procedure SetFieldName(AValue: string);
    procedure SetFont(AValue: TFont);
    procedure SetLayout(AValue: TTextLayout);
    procedure SetValue(AValue: string);
    procedure SetValueType(AValue: TFooterValueType);

    function GetFieldValue: string;
    function GetRecordsCount: string;
    function GetRecNo: string;
    function GetStatTotal: string;
    procedure ResetTestValue;
    procedure UpdateTestValue;

    function DeleteTestValue: boolean;
    function PostTestValue: boolean;
    function ErrorTestValue: boolean;
  protected
    procedure UpdateTestValueFromVar(AValue:Variant);
    property  IsDefaultFont: boolean read FIsDefaultFont;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    function DisplayText: string;
    procedure FillDefaultFont;

    property Owner: TRxColumn read FOwner;
    property NumericValue: double read FTestValue;
    property CountRec:integer read FCountRec;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Layout: TTextLayout read FLayout write SetLayout default tlCenter;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property FieldName: string read FFieldName write SetFieldName;
    property Value: string read FValue write SetValue;
    property ValueType: TFooterValueType read FValueType write SetValueType default fvtNon;
    property Font: TFont read GetFont write SetFont stored IsFontStored;
    property Color : TColor read FColor write SetColor stored IsFontStored default clNone;
  end;

  { TRxColumnFooterItems }

  TRxColumnFooterItems = class(TOwnedCollection)
  private
    function GetItem(Index: integer): TRxColumnFooterItem;
    procedure SetItem(Index: integer; const AValue: TRxColumnFooterItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function GetEnumerator: TRxColumnFooterItemsEnumerator;
  public
    property Items[Index: integer]: TRxColumnFooterItem read GetItem write SetItem; default;
  end;

  { TRxColumnFooterItemsEnumerator }

  TRxColumnFooterItemsEnumerator = class
  private
    FList: TRxColumnFooterItems;
    FPosition: Integer;
  public
    constructor Create(AList: TRxColumnFooterItems);
    function GetCurrent: TRxColumnFooterItem;
    function MoveNext: Boolean;
    property Current: TRxColumnFooterItem read GetCurrent;
  end;


  { TRxColumnFilter }

  TRxFilterState = (rxfsAll, rxfsEmpty, rxfsNonEmpty, rxfsFilter{, rxfsTopXXXX});
  TRxFilterStyle = (rxfstSimple, rxfstDialog, rxfstManualEdit, rxfstBoth);

  TRxColumnFilter = class(TPersistent)
  private
    FIsFontStored:Boolean;
    FIsEmptyFontStored:Boolean;
    FAllValue: string;
    FCurrentValues: TStringList;
    FEnabled: boolean;
    FManulEditValue: string;
    FNotEmptyValue: string;
    FOwner: TRxColumn;
    FState: TRxFilterState;
    FStyle: TRxFilterStyle;
    FValueList: TStringList;
    FEmptyValue: string;
    FEmptyFont: TFont;
    FFont: TFont;
    FAlignment: TAlignment;
    FDropDownRows: integer;
    FColor: TColor;
    function GetDisplayFilterValue: string;
    function GetItemIndex: integer;
    function IsEmptyFontStored: Boolean;
    function IsFontStored: Boolean;
    procedure FontChanged(Sender: TObject);
    procedure SetColor(const AValue: TColor);
    procedure SetEmptyFont(AValue: TFont);
    procedure SetFont(const AValue: TFont);
    procedure SetItemIndex(const AValue: integer);
  public
    constructor Create(Owner: TRxColumn); virtual;
    destructor Destroy; override;
    procedure ClearFilter;

    property State:TRxFilterState read FState write FState;
    property CurrentValues : TStringList read FCurrentValues;
    property ManulEditValue : string read FManulEditValue write FManulEditValue;
    property DisplayFilterValue:string read GetDisplayFilterValue;
  published
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property Alignment: TAlignment read FAlignment write FAlignment default
      taLeftJustify;
    property DropDownRows: integer read FDropDownRows write FDropDownRows;
    property Color: TColor read FColor write SetColor default clWhite;
    property ValueList: TStringList read FValueList;
    property EmptyValue: string read FEmptyValue write FEmptyValue;
    property NotEmptyValue: string read FNotEmptyValue write FNotEmptyValue;
    property AllValue: string read FAllValue write FAllValue;
    property EmptyFont: TFont read FEmptyFont write SetEmptyFont stored IsEmptyFontStored;
    property ItemIndex: integer read GetItemIndex write SetItemIndex;
    property Enabled:boolean read FEnabled write FEnabled default true;
    property Style : TRxFilterStyle read FStyle write FStyle default rxfstSimple;
  end;

  { TRxColumnEditButton }

  TRxColumnEditButton = class(TCollectionItem)
  private
    FEnabled: Boolean;
    FShortCut: TShortCut;
    FStyle: TRxColumnEditButtonStyle;
    FButton:TSpeedButton;
    FVisible: Boolean;
    //
    FSpinBtn:TRxSpinButton;
    function GetGlyph: TBitmap;
    function GetHint: String;
    function GetNumGlyphs: Integer;
    function GetOnButtonClick: TNotifyEvent;
    function GetWidth: Integer;
    procedure SetGlyph(AValue: TBitmap);
    procedure SetHint(AValue: String);
    procedure SetNumGlyphs(AValue: Integer);
    procedure SetOnButtonClick(AValue: TNotifyEvent);
    procedure SetStyle(AValue: TRxColumnEditButtonStyle);
    procedure SetVisible(AValue: Boolean);
    procedure SetWidth(AValue: Integer);

    procedure DoBottomClick(Sender: TObject);
    procedure DoTopClick(Sender: TObject);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
  published
    property Enabled: Boolean read FEnabled write FEnabled default true;
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property Hint: String read GetHint write SetHint;
    property NumGlyphs: Integer read GetNumGlyphs write SetNumGlyphs default 1;
    property ShortCut: TShortCut read FShortCut write FShortCut default scNone;
    property Style: TRxColumnEditButtonStyle read FStyle write SetStyle default ebsDropDownRx;
    property Visible: Boolean read FVisible write SetVisible default true;
    property Width: Integer read GetWidth write SetWidth default 15;
    property OnClick: TNotifyEvent read GetOnButtonClick write SetOnButtonClick;
  end;

  TRxColumnEditButtons = class(TCollection)
  private
    FOwner: TPersistent;
    function GetItem(Index: integer): TRxColumnEditButton;
    procedure SetItem(Index: integer; AValue: TRxColumnEditButton);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TRxColumnEditButton;
  public
    property Items[Index: integer]: TRxColumnEditButton read GetItem write SetItem; default;
  end;

  TColumnGroupItemValue = class
    FieldName:string;
    GroupValue:Double;
  end;

  { TColumnGroupItem }

  TColumnGroupItem = class
  private
    FValues:TFPList;
    RecBookMark:TBookMark;
    FieldValue:string;
    RecordCount:integer;
    RecordNo:integer;
    function GetItems(FieldName: string): TColumnGroupItemValue;
    procedure ClearValues;
    function AddItem(AFieldName:string):TColumnGroupItemValue;
  public
    constructor Create;
    destructor Destroy; override;
    property Items[FieldName:string]:TColumnGroupItemValue read GetItems;
  end;

  { TColumnGroupItems }

  TColumnGroupItems = class
  private
    FColor: TColor;
    //for calc
    FGroupField:TField;
    FCurItem:TColumnGroupItem;
    FCurrentValue:String;
    //params
    FActive: boolean;
    FGroupFieldName: string;
    FList:TFPList;
    FRxDBGrid:TRxDBGrid;
    procedure SetActive(AValue: boolean);
    procedure SetColor(AValue: TColor);
  protected
    function AddGroupItem:TColumnGroupItem;
    procedure InitGroup;
    procedure DoneGroup;
  public
    constructor Create(ARxDBGrid:TRxDBGrid);
    destructor Destroy; override;
    procedure Clear;
    procedure UpdateValues;
    function FindGroupItem(ARecBookMark: TBookMark): TColumnGroupItem;
    property GroupFieldName:string read FGroupFieldName write FGroupFieldName;
  published
    property Active:boolean read FActive write SetActive;
    property Color:TColor read FColor write SetColor;
  end;



  { TRxColumnGroupParam }

  TRxColumnGroupParam = class
  private
    FAlignment: TAlignment;
    FColor: TColor;
    FDisplayFormat: string;
    FLayout: TTextLayout;
    FStaticText: string;
    FValueType: TFooterValueType;
    FColumn:TRxColumn;
    FIsDefaultFont: boolean;
    FFont: TFont;
    procedure FontChanged(Sender: TObject);
    function GetDisplayText: string;
    function GetFont: TFont;
    function IsFontStored: Boolean;
    procedure SetAlignment(AValue: TAlignment);
    procedure SetColor(AValue: TColor);
    procedure SetDisplayFormat(AValue: string);
    procedure SetFont(AValue: TFont);
    procedure SetLayout(AValue: TTextLayout);
    procedure SetStaticText(AValue: string);
  protected
    function GetGroupItems:TColumnGroupItem;
    function GetGroupItem:TColumnGroupItemValue;
    function GetRecordsCount: string;
    function GetGroupTotal: string;
    function GetGroupValue: string;
    function GetRecNo: string;
  public
    constructor Create(AColumn:TRxColumn);
    destructor Destroy; override;
    procedure FillDefaultFont;
    procedure UpdateValues;
    property DisplayText:string read GetDisplayText;
  published
    property ValueType:TFooterValueType read FValueType write FValueType default fvtNon;
    property Alignment:TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Layout: TTextLayout read FLayout write SetLayout default tlCenter;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property StaticText: string read FStaticText write SetStaticText;
    property Font: TFont read GetFont write SetFont stored IsFontStored;
    property Color : TColor read FColor write SetColor stored IsFontStored default clNone;
  end;



  { TRxColumn }

  TRxColumn = class(TColumn)
  private
    FDirectInput: boolean;
    FEditButtons: TRxColumnEditButtons;
    FFooter: TRxColumnFooterItem;
    FConstraints:TRxDBGridCollumnConstraints;
    FFilter: TRxColumnFilter;
    FGroupParam: TRxColumnGroupParam;
    FImageList: TImageList;
    FKeyList: TStrings;
    FNotInKeyListIndex: integer;
    FOnDrawColumnCell: TDrawColumnCellEvent;
    FOptions: TRxColumnOptions;
    FSortFields: string;
    FSortOrder: TSortMarker;
    FSortPosition: integer;
    FWordWrap: boolean;
    FFooters: TRxColumnFooterItems;
    function GetConstraints: TRxDBGridCollumnConstraints;
    function GetFooter: TRxColumnFooterItem;
    function GetFooters: TRxColumnFooterItems;
    function GetKeyList: TStrings;
    function GetSortFields:string;
    procedure SetConstraints(AValue: TRxDBGridCollumnConstraints);
    procedure SetEditButtons(AValue: TRxColumnEditButtons);
    procedure SetFilter(const AValue: TRxColumnFilter);
    procedure SetFooter(const AValue: TRxColumnFooterItem);
    procedure SetFooters(AValue: TRxColumnFooterItems);
    procedure SetImageList(const AValue: TImageList);
    procedure SetKeyList(const AValue: TStrings);
    procedure SetNotInKeyListIndex(const AValue: integer);
    procedure SetWordWrap(AValue: boolean);
  protected
    function CreateTitle: TGridColumnTitle; override;
    procedure ColumnChanged; override;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure OptimizeWidth;
    property SortOrder: TSortMarker read FSortOrder write FSortOrder;
    property SortPosition: integer read FSortPosition;
    property GroupParam:TRxColumnGroupParam read FGroupParam;
  published
    property Constraints:TRxDBGridCollumnConstraints read GetConstraints write SetConstraints;
    property DirectInput : boolean read FDirectInput write FDirectInput default true;
    property EditButtons:TRxColumnEditButtons read FEditButtons write SetEditButtons;
    property Filter: TRxColumnFilter read FFilter write SetFilter;
    property Footer: TRxColumnFooterItem read GetFooter write SetFooter;
    property Footers: TRxColumnFooterItems read GetFooters write SetFooters;
    property ImageList: TImageList read FImageList write SetImageList;
    property KeyList: TStrings read GetKeyList write SetKeyList;
    property NotInKeyListIndex: integer read FNotInKeyListIndex write SetNotInKeyListIndex default -1;
    property Options:TRxColumnOptions read FOptions write FOptions default [coCustomizeVisible, coCustomizeWidth];
    property SortFields: string read FSortFields write FSortFields;
    property WordWrap:boolean read FWordWrap write SetWordWrap default false;
    property OnDrawColumnCell: TDrawColumnCellEvent read FOnDrawColumnCell write FOnDrawColumnCell;
  end;

  { TRxDbGridColumns }
  TRxDbGridColumns = class(TDbGridColumns)
  private
    function GetColumn(Index: Integer): TRxColumn;
    procedure SetColumn(Index: Integer; AValue: TRxColumn);
  protected
    procedure Notify(Item: TCollectionItem;Action: TCollectionNotification); override;
  public
    function Add: TRxColumn;
    function GetEnumerator: TRxDbGridColumnsEnumerator;
    property Items[Index: Integer]: TRxColumn read GetColumn write SetColumn; default;
  end;

  { TRxDbGridColumnsEnumerator }

  TRxDbGridColumnsEnumerator = class
  private
    FList: TRxDbGridColumns;
    FPosition: Integer;
  public
    constructor Create(AList: TRxDbGridColumns);
    function GetCurrent: TRxColumn;
    function MoveNext: Boolean;
    property Current: TRxColumn read GetCurrent;
  end;

  { TRxDbGridColumnsSortList }

  TRxDbGridColumnsSortList = class(TFPList)
  private
    function GetCollumn(Index: Integer): TRxColumn;
  public
    property Collumn[Index: Integer]: TRxColumn read GetCollumn; default;
  end;

  { TFilterListCellEditor }

  TFilterListCellEditor = class(TComboBox)
  private
    FGrid: TCustomGrid;
    FCol: integer;
    FMouseFlag: boolean;
  protected
    procedure WndProc(var TheMessage: TLMessage); override;
    procedure KeyDown(var Key: word; Shift: TShiftState); override;
  public
    procedure Show(Grid: TCustomGrid; Col: integer);
    property Grid: TCustomGrid read FGrid;
    property Col: integer read FCol;
    property MouseFlag: boolean read FMouseFlag write FMouseFlag;
  end;

  { TFilterColDlgButton }

  TFilterColDlgButton = class(TSpeedButton)
  private
    FGrid: TRxDBGrid;
    FCol: integer;
  public
    procedure Show(AGrid: TRxDBGrid; Col: integer);
    property Col: integer read FCol;
  end;

  { TFilterSimpleEdit }

  TFilterSimpleEdit = class(TEdit)
  private
    FGrid: TCustomGrid;
    FCol: integer;
    FMouseFlag: boolean;
  protected
    procedure WndProc(var TheMessage: TLMessage); override;
    procedure KeyDown(var Key: word; Shift: TShiftState); override;
  public
    procedure Show(Grid: TCustomGrid; Col: integer);
    property Grid: TCustomGrid read FGrid;
    property Col: integer read FCol;
    property MouseFlag: boolean read FMouseFlag write FMouseFlag;
  end;


  { TRxDBGrid }
  TRxDBGrid = class(TCustomDBGrid)
  private
    FColumnDefValues: TRxDBGridColumnDefValues;
    FIsSelectedDefaultFont:boolean;

    FFooterOptions: TRxDBGridFooterOptions;
    FOnCalcRowHeight: TRxDBGridCalcRowHeight;
    FSearchOptions: TRxDBGridSearchOptions;
    FSelectedFont: TFont;
    FSortColumns: TRxDbGridColumnsSortList;
    FSortingNow:Boolean;
    FInProcessCalc: integer;

    FOnMergeCells: TRxDBGridMergeCellsEvent;
    FMergeLock: Integer;
    //
    FKeyStrokes: TRxDBGridKeyStrokes;
    FOnGetCellProps: TGetCellPropsEvent;
    FOptionsRx: TOptionsRx;

    FOnGetBtnParams: TGetBtnParamsEvent;
    FOnFiltred: TNotifyEvent;
    FOnRxCalcFooterValues :TOnRxCalcFooterValues;
    FOnRxColumnFooterDraw :TOnRxColumnFooterDraw;
    //auto sort support

    FAutoSort   : boolean;
    FSortEngine : TRxDBGridSortEngine;
    FPressedCol : TRxColumn;
    //
    FPressed: boolean;
    FSwapButtons: boolean;
    FTracking: boolean;

    F_Clicked: boolean;
    F_PopupMenu: TPopupMenu;
    F_MenuBMP: TBitmap;

    F_EventOnFilterRec: TFilterRecordEvent;
    F_EventOnBeforeDelete: TDataSetNotifyEvent;
    F_EventOnBeforePost: TDataSetNotifyEvent;
    F_EventOnDeleteError: TDataSetErrorEvent;
    F_EventOnPostError: TDataSetErrorEvent;
    F_LastFilter: TStringList;
    F_CreateLookup: TCreateLookup;
    F_DisplayLookup: TDisplayLookup;

    //storage
    //Column resize
    FColumnResizing: boolean;

    FFilterListEditor: TFilterListCellEditor;
    FFilterColDlgButton: TFilterColDlgButton;
    FFilterSimpleEdit:TFilterSimpleEdit;

//    FOldPosition: Integer;
    FVersion: integer;
    FPropertyStorageLink: TPropertyStorageLink;

    FAfterQuickSearch: TRxQuickSearchNotifyEvent;
    FBeforeQuickSearch: TRxQuickSearchNotifyEvent;
    FQuickUTF8Search: string;
    FOldDataSetState:TDataSetState;
    FToolsList:TFPList;

    FOnSortChanged: TNotifyEvent;
    FOnDataHintShow:TRxDBGridDataHintShowEvent;

    FSaveOnDataSetScrolled: TDataSetScrolledEvent;
    //Group data suppert
    FGroupItems:TColumnGroupItems;

    procedure DoCreateJMenu;
    function GetColumns: TRxDbGridColumns;
    function GetFooterColor: TColor;
    function GetFooterRowCount: integer;
    function GetPropertyStorage: TCustomPropertyStorage;
    function GetSortField: string;
    function GetSortOrder: TSortMarker;
    function GetTitleButtons: boolean;
    function IsColumnsStored: boolean;

    procedure SelectedFontChanged(Sender: TObject);
    function IsSelectedFontStored: Boolean;
    procedure SetAutoSort(const AValue: boolean);
    procedure SetColumnDefValues(AValue: TRxDBGridColumnDefValues);
    procedure SetColumns(const AValue: TRxDbGridColumns);
    procedure SetFooterColor(const AValue: TColor);
    procedure SetFooterOptions(AValue: TRxDBGridFooterOptions);
    procedure SetFooterRowCount(const AValue: integer);
    procedure SetKeyStrokes(const AValue: TRxDBGridKeyStrokes);
    procedure SetOptionsRx(const AValue: TOptionsRx);
    procedure SetPropertyStorage(const AValue: TCustomPropertyStorage);
    procedure SetSearchOptions(AValue: TRxDBGridSearchOptions);
    procedure SetSelectedFont(AValue: TFont);
    procedure SetTitleButtons(const AValue: boolean);
    procedure TrackButton(X, Y: integer);
    function GetDrawFullLine: boolean;
    procedure SetDrawFullLine(Value: boolean);
    procedure StopTracking;
    procedure CalcTitle;
    procedure ClearMLCaptionPointers;
    procedure FillDefaultFonts;
    function getFilterRect(bRect: TRect): TRect;
    function getTitleRect(bRect: TRect): TRect;
    procedure OutCaptionCellText(aCol, aRow: integer; const aRect: TRect;
      aState: TGridDrawState; const ACaption: string);
    procedure OutCaptionCellText90(aCol, aRow: integer; const aRect: TRect;
      aState: TGridDrawState; const ACaption: string;
      const TextOrient: TTextOrientation);
    procedure OutCaptionSortMarker(const aRect: TRect; ASortMarker: TSortMarker; ASortPosition:integer);
    procedure OutCaptionMLCellText(aCol, aRow: integer; aRect: TRect;
      aState: TGridDrawState; MLI: TMLCaptionItem);
    procedure UpdateJMenuStates;
    procedure UpdateJMenuKeys;
    function SortEngineOptions: TRxSortEngineOptions;
    procedure GetScrollbarParams(out aRange, aPage, aPos: Integer);
    procedure RestoreEditor;
    //storage
    procedure OnIniSave(Sender: TObject);
    procedure OnIniLoad(Sender: TObject);

    procedure CleanDSEvent;


    function UpdateRowsHeight:integer;
    procedure ResetRowHeght;

    procedure DoClearInvalidTitle;
    procedure DoDrawInvalidTitle;
    procedure DoSetColEdtBtn;
    procedure AddTools(ATools:TRxDBGridAbstractTools);
    procedure RemoveTools(ATools:TRxDBGridAbstractTools);
    procedure UpdateToolsState(ATools:TRxDBGridAbstractTools);

    procedure OnDataSetScrolled(aDataSet:TDataSet; Distance: Integer);
    procedure FillFilterData;
  protected
    FRxDbGridLookupComboEditor: TCustomControl;
    FRxDbGridDateEditor: TWinControl;
    FGroupItemDrawCur:TColumnGroupItem;

    procedure CollumnSortListUpdate;
    procedure CollumnSortListClear;
    procedure CollumnSortListApply;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function DatalinkActive: boolean;
    procedure AdjustEditorBounds(NewCol,NewRow:Integer); override;
    procedure LinkActive(Value: Boolean); override;

    function GetFieldDisplayText(AField:TField; ACollumn:TRxColumn):string;
    procedure DefaultDrawCellA(aCol, aRow: integer; aRect: TRect;
      aState: TGridDrawState);
    procedure DefaultDrawTitle(aCol, aRow: integer; aRect: TRect;
      aState: TGridDrawState);
    procedure DefaultDrawFilter(aCol, aRow: integer; aRect: TRect;
      aState: TGridDrawState);
    procedure DefaultDrawCellData(aCol, aRow: integer; aRect: TRect;
      aState: TGridDrawState);
    procedure DrawCell(aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
      override;
    procedure SetDBHandlers(Value: boolean);virtual;

    procedure DrawRow(ARow: Integer); override;
    procedure DrawFocusRect(aCol,aRow:Integer; ARect:TRect); override;
    procedure DrawFooterRows; virtual;
    procedure DrawCellBitmap(RxColumn: TRxColumn; aRect: TRect;
      aState: TGridDrawState; AImageIndex: integer); virtual;

    procedure DoTitleClick(ACol: longint; ACollumn: TRxColumn; Shift: TShiftState); virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;
    procedure KeyDown(var Key: word; Shift: TShiftState); override;
    procedure KeyPress(var Key: char); override;
    procedure UTF8KeyPress(var UTF8Key: TUTF8Char); override;
    function CreateColumns: TGridColumns; override;
    procedure SetEditText(ACol, ARow: longint; const Value: string); override;

    procedure ColRowMoved(IsColumn: boolean; FromIndex, ToIndex: integer); override;
    procedure Paint; override;
    procedure MoveSelection; override;
    function  GetBufferCount: integer; override;
    procedure CMHintShow(var Message: TLMessage); message CM_HINTSHOW;
    procedure FFilterListEditorOnChange(Sender: TObject);
    procedure FFilterListEditorOnCloseUp(Sender: TObject);
    procedure FFilterColDlgButtonOnClick(Sender: TObject);
    procedure FFilterSimpleEditOnChange(Sender: TObject);

    procedure InternalOptimizeColumnsWidth(AColList: TList);
    procedure VisualChange; override;
    procedure EditorWidthChanged(aCol,aWidth: Integer); override;

    procedure SetQuickUTF8Search(AValue: string);
    procedure BeforeDel(DataSet: TDataSet);
    procedure BeforePo(DataSet: TDataSet);
    procedure ErrorDel(DataSet: TDataSet; E: EDatabaseError; var DataAction: TDataAction);
    procedure ErrorPo(DataSet: TDataSet; E: EDatabaseError; var DataAction: TDataAction);
    procedure OnFind(Sender: TObject);
    procedure OnFilterBy(Sender: TObject);
    procedure OnFilter(Sender: TObject);
    procedure OnFilterClose(Sender: TObject);
    procedure OnSortBy(Sender: TObject);
    procedure OnChooseVisibleFields(Sender: TObject);
    procedure OnSelectAllRows(Sender: TObject);
    procedure OnCopyCellValue(Sender: TObject);
    procedure OnOptimizeColWidth(Sender: TObject);
    procedure Loaded; override;
    procedure UpdateFooterRowOnUpdateActive;

    procedure DoEditorHide; override;
    procedure DoEditorShow; override;
    procedure CheckNewCachedSizes(var AGCache:TGridDataCache); override;

    function  GetEditMask(aCol, aRow: Longint): string; override;
    function  GetEditText(aCol, aRow: Longint): string; override;
    function  GetDefaultEditor(Column: Integer): TWinControl; override;

    procedure PrepareCanvas(aCol, aRow: Integer; AState: TGridDrawState); override;
{$IFDEF DEVELOPER_RX}
    procedure InternalAdjustRowCount(var RecCount:integer); override;
{$ENDIF}
    property Editor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure EraseBackground(DC: HDC); override;
    procedure FilterRec(DataSet: TDataSet; var Accept: boolean);
    function EditorByStyle(Style: TColumnButtonStyle): TWinControl; override;
    procedure LayoutChanged; override;
    procedure SetFocus; override;
    procedure ShowFindDialog;
    procedure ShowColumnsDialog;
    procedure ShowSortDialog;
    procedure ShowFilterDialog;
    function ColumnByFieldName(AFieldName: string): TRxColumn;
    function ColumnByCaption(ACaption: string): TRxColumn;
    procedure CalcStatTotals;
    procedure OptimizeColumnsWidth(AColList: string);
    procedure OptimizeColumnsWidthAll;
    procedure UpdateTitleHight;
    procedure GetOnCreateLookup;
    procedure GetOnDisplayLookup;
    procedure SelectAllRows;
    procedure DeSelectAllRows;
    procedure InvertSelection;
    procedure CopyCellValue;
    function CreateToolMenuItem(ShortCut: char; const ACaption: string; MenuAction: TNotifyEvent):TMenuItem;
    procedure RemoveToolMenuItem(MenuAction: TNotifyEvent);

    procedure CalcCellExtent(ACol, ARow: Integer; var ARect: TRect);
    function IsMerged(ACol : Integer): Boolean; overload;
    function IsMerged(ACol : Integer; out ALeft, ARight: Integer; out AColumn: TRxColumn): Boolean; overload;

    procedure SetSort(AFields: array of String; ASortMarkers: array of TSortMarker; PreformSort: Boolean = False);

    property Canvas;
    property DefaultTextStyle;
    property EditorBorderStyle;
    property EditorMode;
    property ExtendedColSizing;
    property FastEditing;
    property FocusRectVisible;
    property SelectedRows;
    property QuickUTF8Search: string read FQuickUTF8Search write SetQuickUTF8Search;

    property SortField:string read GetSortField;
    property SortOrder:TSortMarker read GetSortOrder;

    property SortColumns:TRxDbGridColumnsSortList read FSortColumns;
    property GroupItems:TColumnGroupItems read FGroupItems;
  published
    property AfterQuickSearch: TRxQuickSearchNotifyEvent read FAfterQuickSearch write FAfterQuickSearch;
    property ColumnDefValues:TRxDBGridColumnDefValues read FColumnDefValues write SetColumnDefValues;
    property BeforeQuickSearch: TRxQuickSearchNotifyEvent read FBeforeQuickSearch write FBeforeQuickSearch;
    property OnGetBtnParams: TGetBtnParamsEvent read FOnGetBtnParams write FOnGetBtnParams;
    property TitleButtons: boolean read GetTitleButtons write SetTitleButtons;
    property AutoSort: boolean read FAutoSort write SetAutoSort;
    property OnGetCellProps: TGetCellPropsEvent read FOnGetCellProps write FOnGetCellProps;
    property Columns: TRxDbGridColumns read GetColumns write SetColumns stored IsColumnsStored;
    property KeyStrokes: TRxDBGridKeyStrokes read FKeyStrokes write SetKeyStrokes;
    property FooterOptions:TRxDBGridFooterOptions read FFooterOptions write SetFooterOptions;
    property SearchOptions:TRxDBGridSearchOptions read FSearchOptions write SetSearchOptions;
    property OnCalcRowHeight:TRxDBGridCalcRowHeight read FOnCalcRowHeight write FOnCalcRowHeight;
    property SelectedFont:TFont read FSelectedFont write SetSelectedFont stored IsSelectedFontStored;

    //storage
    property PropertyStorage: TCustomPropertyStorage read GetPropertyStorage write SetPropertyStorage;
    property Version: integer read FVersion write FVersion default 0;
    property OptionsRx: TOptionsRx read FOptionsRx write SetOptionsRx;
    property FooterColor: TColor read GetFooterColor write SetFooterColor default clWindow; deprecated;
    property FooterRowCount: integer read GetFooterRowCount write SetFooterRowCount default 0; deprecated;

    property OnFiltred: TNotifyEvent read FOnFiltred write FOnFiltred;
    property OnSortChanged: TNotifyEvent read FOnSortChanged write FOnSortChanged;
    property OnDataHintShow: TRxDBGridDataHintShowEvent read FOnDataHintShow write FOnDataHintShow;

    //from DBGrid
    property Align;
    property AlternateColor;
    property Anchors;
    property AutoAdvance default aaRightDown;
    property AutoFillColumns;
    property AutoEdit;
    property BiDiMode;
    property BorderSpacing;
    property BorderStyle;
    property Color;
    property CellHintPriority;
    property BorderColor;
    property DrawFullLine: boolean read GetDrawFullLine write SetDrawFullLine; deprecated;
    property FocusColor;
    property FixedHotColor;

    property SelectedColor;
    property GridLineColor;
    property GridLineStyle;

    property Constraints;
    property DataSource;
    property DefaultDrawing;
    property DefaultRowHeight;

    property DefaultColWidth;

    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FixedColor;
    property FixedCols;
    property Flat;
    property Font;
    property HeaderHotZones;
    property HeaderPushZones;
    //property ImeMode;
    //property ImeName;
    property Options;
    property OptionsExtra;
    property ParentBiDiMode;
    property ParentColor default false;
    //property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property Scrollbars default ssBoth;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TabAdvance;
    property TitleFont;
    property TitleImageList;
    property TitleStyle;
    property UseXORFeatures;
    property Visible;

    property OnCellClick;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnColumnSized;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawColumnCell;
    property OnDblClick;
    property OnEditButtonClick;
    property OnEditingDone;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnFieldEditMask;
    property OnGetCellHint;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnPrepareCanvas;
    property OnSelectEditor;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;
    property OnRxCalcFooterValues: TOnRxCalcFooterValues read FOnRxCalcFooterValues write FOnRxCalcFooterValues;
    property OnRxColumnFooterDraw: TOnRxColumnFooterDraw read FOnRxColumnFooterDraw write FOnRxColumnFooterDraw;
    property OnUserCheckboxBitmap;
    property OnUserCheckboxState;
    property OnUTF8KeyPress;


    property OnCreateLookup: TCreateLookup read F_CreateLookup write F_CreateLookup;
    property OnDisplayLookup: TDisplayLookup read F_DisplayLookup write F_DisplayLookup;
    property OnMergeCells:TRxDBGridMergeCellsEvent read FOnMergeCells write FOnMergeCells;
  end;

  { TRxDBGridAbstractTools }
  TRxDBGridToolsEvent = (rxteMouseDown, rxteMouseUp, rxteMouseMove, rxteKeyDown, rxteKeyUp);
  TRxDBGridToolsEvents = set of TRxDBGridToolsEvent;

  TRxDBGridAbstractTools = class(TComponent)
  private
    FEnabled: boolean;
    FOnAfterExecute: TNotifyEvent;
    FOnBeforeExecute: TNotifyEvent;
    FShowSetupForm: boolean;
    procedure ExecTools(Sender:TObject);
    procedure SetEnabled(AValue: boolean);
  protected
    FRxDBGrid: TRxDBGrid;
    FCaption:string;
    FToolsEvents:TRxDBGridToolsEvents;
    procedure SetRxDBGrid(AValue: TRxDBGrid);
    function DoExecTools:boolean; virtual;
    function DoSetupTools:boolean; virtual;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer):boolean; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute:boolean;
  published
    property RxDBGrid:TRxDBGrid read FRxDBGrid write SetRxDBGrid;
    property Caption:string read FCaption write FCaption;
    property ShowSetupForm:boolean read FShowSetupForm write FShowSetupForm default false;
    property OnBeforeExecute:TNotifyEvent read FOnBeforeExecute write FOnBeforeExecute;
    property OnAfterExecute:TNotifyEvent read FOnAfterExecute write FOnAfterExecute;
    property Enabled:boolean read FEnabled write SetEnabled default true;
  end;

procedure RegisterRxDBGridSortEngine(RxDBGridSortEngineClass: TRxDBGridSortEngineClass;
  DataSetClassName: string);

implementation

uses Math, rxdconst, rxstrutils, rxutils, strutils, rxdbgrid_findunit, Themes,
  rxdbgrid_columsunit, RxDBGrid_PopUpFilterUnit, rxlookup, rxtooledit, LCLProc,
  Clipbrd, rxfilterby, rxsortby, variants, LazUTF8;

{$R rxdbgrid.res}

const
  EditorCommandStrs: array[rxgcNone .. High(TRxDBGridCommand)] of TIdentMapEntry =
    (
    (Value: Ord(rxgcNone); Name: 'rxcgNone'),
    (Value: Ord(rxgcShowFindDlg); Name: 'rxgcShowFindDlg'),
    (Value: Ord(rxgcShowColumnsDlg); Name: 'rxgcShowColumnsDlg'),
    (Value: Ord(rxgcShowFilterDlg); Name: 'rxgcShowFilterDlg'),
    (Value: Ord(rxgcShowSortDlg); Name: 'rxgcShowSortDlg'),
    (Value: Ord(rxgcShowQuickFilter); Name: 'rxgcShowQuickFilter'),
    (Value: Ord(rxgcHideQuickFilter); Name: 'rxgcHideQuickFilter'),
    (Value: Ord(rxgcSelectAll); Name: 'rxgcSelectAll'),
    (Value: Ord(rxgcDeSelectAll); Name: 'rxgcDeSelectAll'),
    (Value: Ord(rxgcInvertSelection); Name: 'rxgcInvertSelection'),
    (Value: Ord(rxgcOptimizeColumnsWidth); Name: 'rxgcOptimizeColumnsWidth'),
    (Value: Ord(rxgcCopyCellValue); Name: 'rxgcCopyCellValue')
    );

var
  RxDBGridSortEngineList: TStringList;

  FMarkerUp   : TBitmap = nil;
  FMarkerDown : TBitmap = nil;
  FEllipsisRxBMP: TBitmap = nil;
  FGlyphRxBMP: TBitmap = nil;
  FUpDownRxBMP: TBitmap = nil;
  FPlusRxBMP: TBitmap = nil;
  FMinusRxBMP: TBitmap = nil;


procedure RegisterRxDBGridSortEngine(
  RxDBGridSortEngineClass: TRxDBGridSortEngineClass; DataSetClassName: string);
var
  Pos: integer;
  RxDBGridSortEngine: TRxDBGridSortEngine;
begin
  if not RxDBGridSortEngineList.Find(DataSetClassName, Pos) then
  begin
    RxDBGridSortEngine := RxDBGridSortEngineClass.Create;
    RxDBGridSortEngineList.AddObject(DataSetClassName, RxDBGridSortEngine);
  end;
end;

procedure GridInvalidateRow(Grid: TRxDBGrid; Row: longint);
var
  I: longint;
begin
  for I := 0 to Grid.ColCount - 1 do
    Grid.InvalidateCell(I, Row);
end;

type
  THackDataSet = class(TDataSet);


type

  { TRxDBGridLookupComboEditor }

  TRxDBGridLookupComboEditor = class(TRxCustomDBLookupCombo)
  private
    FGrid: TRxDBGrid;
    FCol, FRow: integer;
    FLDS: TDataSource;
  protected
    procedure WndProc(var TheMessage: TLMessage); override;
    procedure KeyDown(var Key: word; Shift: TShiftState); override;
    procedure msg_SetGrid(var Msg: TGridMessage); message GM_SETGRID;
    procedure msg_SetValue(var Msg: TGridMessage); message GM_SETVALUE;
    procedure msg_GetValue(var Msg: TGridMessage); message GM_GETVALUE;
    procedure OnInternalClosePopup(AResult:boolean);override;
    procedure ShowList; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  { TRxDBGridDateEditor }
  TRxDBGridDateEditor = class(TCustomRxDateEdit)
  private
    FGrid: TRxDBGrid;
    FCol, FRow: integer;
  protected
    procedure EditChange; override;
    procedure KeyDown(var Key: word; Shift: TShiftState); override;

    procedure WndProc(var TheMessage: TLMessage); override;
    procedure msg_SetGrid(var Msg: TGridMessage); message GM_SETGRID;
    procedure msg_SetValue(var Msg: TGridMessage); message GM_SETVALUE;
    procedure msg_GetValue(var Msg: TGridMessage); message GM_GETVALUE;
    procedure msg_SelectAll(var Msg: TGridMessage); message GM_SELECTALL;

  public
    constructor Create(Aowner : TComponent); override;
    procedure EditingDone; override;
  end;

{ TFilterSimpleEdit }

procedure TFilterSimpleEdit.WndProc(var TheMessage: TLMessage);
begin
  if TheMessage.msg = LM_KILLFOCUS then
  begin
    Change;
    Hide;
    if HWND(TheMessage.WParam) = HWND(Handle) then
    begin
      // lost the focus but it returns to ourselves
      // eat the message.
      TheMessage.Result := 0;
      exit;
    end;
  end;
  inherited WndProc(TheMessage);
end;

procedure TFilterSimpleEdit.KeyDown(var Key: word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_RETURN:
    begin
      Change;
      Hide;
    end;
  end;
end;

procedure TFilterSimpleEdit.Show(Grid: TCustomGrid; Col: integer);
begin
  FGrid := Grid;
  FCol := Col;
  Visible := True;
  SetFocus;
end;

{ TRxColumnGroupParam }

procedure TRxColumnGroupParam.FontChanged(Sender: TObject);
begin
  FisDefaultFont := FFont.IsDefault;
  FColumn.ColumnChanged;
end;

function TRxColumnGroupParam.GetDisplayText: string;
begin
  case FValueType of
    fvtCount : Result := GetRecordsCount;
    fvtSum,
    fvtAvg,
    fvtMax,
    fvtMin : Result := GetGroupTotal;
    fvtRecNo : Result := GetRecNo;
    fvtStaticText:Result := FStaticText;
    fvtFieldValue:Result := GetGroupValue;
  else
    //fvtNon,
    Result:='';
  end;
end;

function TRxColumnGroupParam.GetFont: TFont;
begin
  Result := FFont;
end;

function TRxColumnGroupParam.IsFontStored: Boolean;
begin
  Result := not FisDefaultFont;
end;

procedure TRxColumnGroupParam.SetAlignment(AValue: TAlignment);
begin
  if FAlignment=AValue then Exit;
  FAlignment:=AValue;
end;

procedure TRxColumnGroupParam.SetColor(AValue: TColor);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
end;

procedure TRxColumnGroupParam.SetDisplayFormat(AValue: string);
begin
  if FDisplayFormat=AValue then Exit;
  FDisplayFormat:=AValue;
end;

procedure TRxColumnGroupParam.SetFont(AValue: TFont);
begin
  if not FFont.IsEqual(AValue) then
    FFont.Assign(AValue);
end;

procedure TRxColumnGroupParam.SetLayout(AValue: TTextLayout);
begin
  if FLayout=AValue then Exit;
  FLayout:=AValue;
end;

procedure TRxColumnGroupParam.SetStaticText(AValue: string);
begin
  if FStaticText=AValue then Exit;
  FStaticText:=AValue;
end;

function TRxColumnGroupParam.GetGroupItems: TColumnGroupItem;
begin
  Result:=nil;
  if TRxDBGrid(FColumn.Grid).DatalinkActive then
    Result:=TRxDBGrid(FColumn.Grid).FGroupItemDrawCur;
end;

function TRxColumnGroupParam.GetGroupItem: TColumnGroupItemValue;
var
  FCGDI: TColumnGroupItem;
begin
  Result:=nil;
  if TRxDBGrid(FColumn.Grid).DatalinkActive then
  begin
    FCGDI:=TRxDBGrid(FColumn.Grid).FGroupItemDrawCur;
    if Assigned(FCGDI) then
      Result:=FCGDI.GetItems(FColumn.FieldName);
  end
end;

function TRxColumnGroupParam.GetRecordsCount: string;
var
  V: TColumnGroupItem;
begin
  V:=GetGroupItems;
  if Assigned(V) then
  begin
    if DisplayFormat <> '' then
      Result := Format(DisplayFormat, [V.RecordCount])
    else
      Result := IntToStr(V.RecordCount);
  end
  else
    Result := '';
end;

function TRxColumnGroupParam.GetGroupTotal: string;
var
  V: TColumnGroupItemValue;
  F: TField;
begin
  V:=GetGroupItem;
  if Assigned(V) then
  begin
    F := TRxDBGrid(FColumn.Grid).DataSource.DataSet.FieldByName(FColumn.FieldName);
    if Assigned(F) then
    begin
      if F.DataType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency,
        ftDate, ftTime, ftDateTime, ftTimeStamp, ftLargeint, ftBCD] then
      begin
        if F.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
        begin
          if FValueType in [fvtSum, fvtAvg] then
            Result := ''
          else
          if V.GroupValue = 0 then
            Result := ''
          else
          if FDisplayFormat = '' then
            Result := DateToStr(V.GroupValue)
          else
            Result := FormatDateTime(FDisplayFormat, V.GroupValue);
        end
        else
        if F.DataType in [ftSmallint, ftInteger, ftWord, ftLargeint] then
        begin
          if FDisplayFormat = '' then
            Result := IntToStr(Round(V.GroupValue))
          else
            Result := FormatFloat(FDisplayFormat, V.GroupValue);
        end
        else
        begin
          if FDisplayFormat <> '' then
            Result := FormatFloat(FDisplayFormat, V.GroupValue)
          else
          if F.DataType = ftCurrency then
            Result := FloatToStrF(V.GroupValue, ffCurrency, 12, 2)
          else
            Result := FloatToStr(V.GroupValue);
        end;
      end
      else
        Result := '';
    end
    else
      Result := '';
  end
  else
    Result := '';
end;

function TRxColumnGroupParam.GetGroupValue: string;
var
  V: TColumnGroupItem;
begin
  V:=GetGroupItems;
  if Assigned(V) then
    Result := V.FieldValue
  else
    Result := '';
end;

function TRxColumnGroupParam.GetRecNo: string;
var
  V: TColumnGroupItem;
begin
  V:=GetGroupItems;
  if Assigned(V) then
  begin
    if DisplayFormat <> '' then
      Result := Format(DisplayFormat, [V.RecordNo])
    else
      Result := IntToStr(V.RecordNo);
  end
  else
    Result := '';
end;

constructor TRxColumnGroupParam.Create(AColumn: TRxColumn);
begin
  inherited Create;
  FColumn:=AColumn;
  FValueType:=fvtNon;
  FAlignment:=taLeftJustify;
  FLayout := tlCenter;
  FColor:=clNone;

  FFont := TFont.Create;
  FillDefaultFont;
  FFont.OnChange := @FontChanged;
end;

destructor TRxColumnGroupParam.Destroy;
begin
  FreeAndNil(FFont);
  inherited Destroy;
end;

procedure TRxColumnGroupParam.FillDefaultFont;
var
  AGrid: TCustomGrid;
begin
  if not Assigned(FColumn) then exit;
  AGrid := FColumn.Grid;
  if (AGrid<>nil) then
  begin
    FFont.Assign(AGrid.Font);
    FIsDefaultFont := True;
  end;
end;

procedure TRxColumnGroupParam.UpdateValues;
var
  F: TField;
  V: TColumnGroupItemValue;
begin
  if (ValueType in [fvtSum, fvtAvg, fvtMax, fvtMin]) and (FColumn.FieldName <> '') then
  begin
    F := TRxDBGrid(FColumn.Grid).DataSource.DataSet.FindField(FColumn.FieldName);
    V:=TRxDBGrid(FColumn.Grid).FGroupItems.FCurItem.Items[FColumn.FieldName];
    if not Assigned(V) then
      V:=TRxDBGrid(FColumn.Grid).FGroupItems.FCurItem.AddItem(FColumn.FieldName);
    if Assigned(F) and Assigned(V) then
    begin
      if F.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
      begin
        case FValueType of
          fvtMax: V.GroupValue := Max(V.GroupValue, F.AsDateTime);
          fvtMin: V.GroupValue := Min(V.GroupValue, F.AsDateTime);
        end;
      end
      else
      begin
        case FValueType of
          fvtAvg,
          fvtSum: V.GroupValue := V.GroupValue + F.AsFloat;
          fvtMax: V.GroupValue := Max(V.GroupValue, F.AsFloat);
          fvtMin: V.GroupValue := Min(V.GroupValue, F.AsFloat);
        end;
      end;
    end;
  end;
end;

{ TRxColumnFooterItemsEnumerator }

constructor TRxColumnFooterItemsEnumerator.Create(AList: TRxColumnFooterItems);
begin
  FList := AList;
  FPosition := -1;
end;

function TRxColumnFooterItemsEnumerator.GetCurrent: TRxColumnFooterItem;
begin
  Result := FList[FPosition];
end;

function TRxColumnFooterItemsEnumerator.MoveNext: Boolean;
begin
  Inc(FPosition);
  Result := FPosition < FList.Count;
end;

{ TColumnGroupItems }

procedure TColumnGroupItems.SetActive(AValue: boolean);
begin
  if FActive=AValue then Exit;
  FActive:=AValue;
  if FActive then
  begin
    FRxDBGrid.CalcStatTotals;
  end
  else
    FRxDBGrid.UpdateRowsHeight;
  FRxDBGrid.VisualChange;
end;

procedure TColumnGroupItems.SetColor(AValue: TColor);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
  FRxDBGrid.Invalidate;
end;

constructor TColumnGroupItems.Create(ARxDBGrid: TRxDBGrid);
begin
  inherited Create;
  FActive:=false;
  FList:=TFPList.Create;
  FRxDBGrid:=ARxDBGrid;
end;

destructor TColumnGroupItems.Destroy;
begin
  Clear;
  FreeAndNil(FList);
  inherited Destroy;
end;

function TColumnGroupItems.FindGroupItem(ARecBookMark: TBookMark
  ): TColumnGroupItem;
var
  S, E, i: Integer;
begin
  Result:=nil;
  if FList.Count = 0 then exit;
  S:=0;
  E:=FList.Count - 1;
{
  while (S<=E) do
  begin
    i:=(E+S) div 2;
    if (TColumnGroupItem(FList[i]).RecordNo = ARecordNo) then
    begin
      Result:=TColumnGroupItem(FList[i]);
      Exit;
    end
    else
    if (TColumnGroupItem(FList[i]).RecordNo > ARecordNo) then E:=i-1
    else S:=i+1;
  end; }

  for i:=0 to FList.Count-1 do
    if FRxDBGrid.DataSource.DataSet.CompareBookmarks(TColumnGroupItem(FList[i]).RecBookMark, ARecBookMark) = 0 then
      exit(TColumnGroupItem(FList[i]))
end;

procedure TColumnGroupItems.Clear;
var
  i: Integer;
begin
  for i:=0 to FList.Count-1 do
    TColumnGroupItem(FList[i]).Free;
  FList.Clear;
end;

procedure TColumnGroupItems.UpdateValues;
begin
  if not Assigned(FGroupField) then Exit;
  if (FCurrentValue <> FGroupField.DisplayText) or (not Assigned(FCurItem)) then
  begin
    DoneGroup;
    FCurItem:=AddGroupItem;
    FCurrentValue:=FGroupField.DisplayText;
    FCurItem.RecordCount:=1;
    FCurItem.RecordNo:=FRxDBGrid.DataSource.DataSet.RecNo;
    FCurItem.RecBookMark:=FRxDBGrid.DataSource.DataSet.Bookmark;
    FCurItem.FieldValue:=FCurrentValue;
  end
  else
  begin
    Inc(FCurItem.RecordCount);
    FCurItem.RecordNo:=FRxDBGrid.DataSource.DataSet.RecNo;
    FCurItem.RecBookMark:=FRxDBGrid.DataSource.DataSet.Bookmark;
  end;
end;

function TColumnGroupItems.AddGroupItem: TColumnGroupItem;
begin
  Result:=TColumnGroupItem.Create;
  FList.Add(Result);
end;

procedure TColumnGroupItems.InitGroup;
begin
  if (FRxDBGrid.DataSource.DataSet.RecordCount > 0) and (FGroupFieldName <> '') then
  begin
    FGroupField:=FRxDBGrid.DataSource.DataSet.FieldByName(FGroupFieldName);
    FCurrentValue:=FGroupField.DisplayText;
  end;
end;

procedure TColumnGroupItems.DoneGroup;
begin
  { TODO : Необходимо список закладок отсортировать }
  if Assigned(FCurItem) then
  begin
    //FCurItem.RecordNo:=FRxDBGrid.DataSource.DataSet.RecNo;
    //FCurItem.RecordNo:=PtrInt(FRxDBGrid.DataSource.DataSet.ActiveBuffer);
    //FList.Sort(@DoListSortCompare);
    //FCurItem.RecordNo:=FRxDBGrid.DataSource.DataSet.Bookmark;
  end;
  FCurItem:=nil;
end;

{ TColumnGroupItem }

function TColumnGroupItem.GetItems(FieldName: string): TColumnGroupItemValue;
var
  i: Integer;
begin
  Result:=nil;
  for i:=0 to FValues.Count-1 do
    if TColumnGroupItemValue(FValues[i]).FieldName = FieldName then
      Exit(TColumnGroupItemValue(FValues[i]));
end;

procedure TColumnGroupItem.ClearValues;
var
  i: Integer;
begin
  for i:=0 to FValues.Count-1 do
    TColumnGroupItemValue(FValues[i]).Free;
  FValues.Clear;
end;

function TColumnGroupItem.AddItem(AFieldName: string): TColumnGroupItemValue;
begin
  Result:=TColumnGroupItemValue.Create;
  FValues.Add(Result);
  Result.FieldName:=AFieldName;
end;

constructor TColumnGroupItem.Create;
begin
  inherited Create;
  FValues:=TFPList.Create;
end;

destructor TColumnGroupItem.Destroy;
begin
  ClearValues;
  FreeAndNil(FValues);
  inherited Destroy;
end;

{ TRxDbGridColumnsEnumerator }

constructor TRxDbGridColumnsEnumerator.Create(AList: TRxDbGridColumns);
begin
  FList := AList;
  FPosition := -1;
end;

function TRxDbGridColumnsEnumerator.GetCurrent: TRxColumn;
begin
  Result := FList[FPosition];
end;

function TRxDbGridColumnsEnumerator.MoveNext: Boolean;
begin
  Inc(FPosition);
  Result := FPosition < FList.Count;
end;

{ TFilterColDlgButton }

procedure TFilterColDlgButton.Show(AGrid: TRxDBGrid; Col: integer);
begin
  FGrid := AGrid;
  FCol := Col;
  Visible := True;
end;

{ TRxDBGridSearchOptions }

procedure TRxDBGridSearchOptions.AssignTo(Dest: TPersistent);
begin
  if Dest is TRxDBGridSearchOptions then
  begin
    TRxDBGridSearchOptions(Dest).FQuickSearchOptions:=FQuickSearchOptions;
    TRxDBGridSearchOptions(Dest).FFromStart:=FFromStart;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TRxDBGridSearchOptions.Create(AOwner: TRxDBGrid);
begin
  inherited Create;
  FOwner:=AOwner;
  FQuickSearchOptions:=[loPartialKey, loCaseInsensitive];
  FFromStart:=false;
end;

{ TRxDBGridColumnDefValues }

procedure TRxDBGridColumnDefValues.AssignTo(Dest: TPersistent);
begin
  if Dest is TRxDBGridColumnDefValues then
  begin
    TRxDBGridColumnDefValues(Dest).FBlobText:=FBlobText;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TRxDBGridColumnDefValues.Create(AOwner: TRxDBGrid);
begin
  inherited Create;
  FOwner:=AOwner;
  FBlobText:=sBlobText;
end;

destructor TRxDBGridColumnDefValues.Destroy;
begin
  inherited Destroy;
end;

{ TRxColumnFooterItem }

procedure TRxColumnFooterItem.FontChanged(Sender: TObject);
begin
  FisDefaultFont := Font.IsDefault;
  FOwner.ColumnChanged;
end;

function TRxColumnFooterItem.GetFont: TFont;
begin
  Result := FFont;
end;

function TRxColumnFooterItem.IsFontStored: Boolean;
begin
  Result := not FisDefaultFont;
end;

procedure TRxColumnFooterItem.SetAlignment(AValue: TAlignment);
begin
  if FAlignment = AValue then exit;
  FAlignment := AValue;
  FOwner.ColumnChanged;
end;

procedure TRxColumnFooterItem.SetColor(AValue: TColor);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
  FOwner.ColumnChanged;
end;

procedure TRxColumnFooterItem.SetDisplayFormat(AValue: string);
begin
  if FDisplayFormat=AValue then Exit;
  FDisplayFormat:=AValue;
  FOwner.ColumnChanged;
end;

procedure TRxColumnFooterItem.SetFieldName(AValue: string);
begin
  if FFieldName=AValue then Exit;
  FFieldName:=AValue;
  FOwner.ColumnChanged;
end;

procedure TRxColumnFooterItem.SetFont(AValue: TFont);
begin
  if not FFont.IsEqual(AValue) then
    FFont.Assign(AValue);
end;

procedure TRxColumnFooterItem.SetLayout(AValue: TTextLayout);
begin
  if FLayout=AValue then Exit;
  FLayout:=AValue;
  FOwner.ColumnChanged;
end;

procedure TRxColumnFooterItem.SetValue(AValue: string);
begin
  if FValue=AValue then Exit;
  FValue:=AValue;
  FOwner.ColumnChanged;
end;

procedure TRxColumnFooterItem.SetValueType(AValue: TFooterValueType);
begin
  if FValueType=AValue then Exit;
  FValueType:=AValue;
  FOwner.ColumnChanged;
end;

function TRxColumnFooterItem.GetFieldValue: string;
begin
  if (FFieldName <> '') and TRxDBGrid(FOwner.Grid).DatalinkActive then
    Result := TRxDBGrid(FOwner.Grid).DataSource.DataSet.FieldByName(FFieldName).AsString
  else
    Result := '';
end;

function TRxColumnFooterItem.GetRecordsCount: string;
begin
  if TRxDBGrid(FOwner.Grid).DatalinkActive then
  begin
    if DisplayFormat <> '' then
      Result := Format(DisplayFormat, [FCountRec])
    else
      Result := IntToStr(FCountRec);
  end
  else
    Result := '';
end;

function TRxColumnFooterItem.GetRecNo: string;
begin
  if TRxDBGrid(FOwner.Grid).DatalinkActive then
  begin
    if DisplayFormat <> '' then
      Result := Format(DisplayFormat, [TRxDBGrid(FOwner.Grid).DataSource.DataSet.RecNo])
    else
      Result := IntToStr(TRxDBGrid(FOwner.Grid).DataSource.DataSet.RecNo);
  end
  else
    Result := '';
end;

function TRxColumnFooterItem.GetStatTotal: string;
var
  F: TField;
begin
  if (FFieldName <> '') and TRxDBGrid(FOwner.Grid).DatalinkActive and
    (TRxDBGrid(FOwner.Grid).DataSource.DataSet.RecordCount <> 0) then
  begin
    F := TRxDBGrid(FOwner.Grid).DataSource.DataSet.FieldByName(FFieldName);
    if Assigned(F) then
    begin
      if F.DataType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency,
        ftDate, ftTime, ftDateTime, ftTimeStamp, ftLargeint, ftBCD] then
      begin
        if F.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
        begin
          if FValueType in [fvtSum, fvtAvg] then
            Result := ''
          else
          if FTestValue = 0 then
            Result := ''
          else
          if FDisplayFormat = '' then
            Result := DateToStr(FTestValue)
          else
            Result := FormatDateTime(FDisplayFormat, FTestValue);
        end
        else
        if F.DataType in [ftSmallint, ftInteger, ftWord, ftLargeint] then
        begin
          if FDisplayFormat = '' then
            Result := IntToStr(Round(FTestValue))
          else
            Result := FormatFloat(FDisplayFormat, FTestValue);
        end
        else
        begin
          if FDisplayFormat <> '' then
            Result := FormatFloat(FDisplayFormat, FTestValue)
          else
          if F.DataType = ftCurrency then
            Result := FloatToStrF(FTestValue, ffCurrency, 12, 2)
          else
            Result := FloatToStr(FTestValue);
        end;
      end
      else
        Result := '';
    end
    else
      Result := '';
  end
  else
    Result := '';
end;

procedure TRxColumnFooterItem.ResetTestValue;
var
  F: TField;
begin
  FTestValue := 0;
  FCountRec:=0;

  if (ValueType in [fvtMin, fvtMax]) and (TRxDBGrid(
    FOwner.Grid).DataSource.DataSet.RecordCount <> 0) and (FFieldName<>'') then
  begin
    F := TRxDBGrid(FOwner.Grid).DataSource.DataSet.FieldByName(FFieldName);
    if (Assigned(F)) and not (F.IsNull) then
      if F.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
        FTestValue := F.AsDateTime
      else
        FTestValue := F.AsFloat;
  end;
end;

procedure TRxColumnFooterItem.UpdateTestValue;
var
  F: TField;
begin
  if (ValueType in [fvtSum, fvtAvg, fvtMax, fvtMin]) and (FFieldName<>'') then
  begin
    F := TRxDBGrid(FOwner.Grid).DataSource.DataSet.FindField(FFieldName);
    if Assigned(F) then
    begin
      if F.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
      begin
        case FValueType of
          fvtMax: FTestValue := Max(FTestValue, F.AsDateTime);
          fvtMin: FTestValue := Min(FTestValue, F.AsDateTime);
        end;
      end
      else
      begin
        case FValueType of
          fvtSum: FTestValue := FTestValue + F.AsFloat;
          //        fvtAvg:
          fvtMax: FTestValue := Max(FTestValue, F.AsFloat);
          fvtMin: FTestValue := Min(FTestValue, F.AsFloat);
        end;
      end;
    end;
  end;
end;

function TRxColumnFooterItem.DeleteTestValue: boolean;
var
  F: TField;
begin
  Result := True;
  if (ValueType in [fvtSum, fvtAvg, fvtMax, fvtMin]) and (FFieldName<>'') then
  begin
    F := TRxDBGrid(FOwner.Grid).DataSource.DataSet.FieldByName(FFieldName);
    if (Assigned(F)) and not (F.IsNull) then
      if F.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
        Result := not ((FValueType in [fvtMax, fvtMin]) and (FTestValue = F.AsDateTime))
      else
      if FValueType in [fvtMax, fvtMin] then
        Result := (FTestValue <> F.AsFloat)
      else
        FTestValue := FTestValue - F.AsFloat;
  end;
end;

function TRxColumnFooterItem.PostTestValue: boolean;
var
  F: TField;
begin
  Result := True;
  if (ValueType in [fvtSum, fvtAvg, fvtMax, fvtMin]) and (FFieldName<>'') then
  begin
    F := TRxDBGrid(FOwner.Grid).DataSource.DataSet.FieldByName(FFieldName);
    if Assigned(F) then
      if F.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
      begin
        if FValueType in [fvtMax, fvtMin] then
          if F.DataSet.State = dsinsert then
          begin
            if not (F.IsNull) then
              case FValueType of
                fvtMax: FTestValue := Max(FTestValue, F.AsDateTime);
                fvtMin: FTestValue := Min(FTestValue, F.AsDateTime);
              end;
          end
          else
          if (F.OldValue <> null) and (FTestValue = TDateTime(F.OldValue)) then
            Result := False
          else
          if not F.IsNull then
            case FValueType of
              fvtMax: FTestValue := Max(FTestValue, F.AsDateTime);
              fvtMin: FTestValue := Min(FTestValue, F.AsDateTime);
            end;
      end
      else
      if F.DataSet.State = dsinsert then
      begin
        if not F.IsNull then
          case FValueType of
            fvtSum: FTestValue := FTestValue + F.AsFloat;
            fvtMax: FTestValue := Max(FTestValue, F.AsFloat);
            fvtMin: FTestValue := Min(FTestValue, F.AsFloat);
          end;
      end
      else
      if (FValueType in [fvtMax, fvtMin]) and (F.OldValue <> null) and
        (FTestValue = Float(F.OldValue)) then
        Result := False
      else
        case FValueType of
          fvtSum:
          begin
            if not F.IsNull then
            begin
              if F.OldValue <> null then
                FTestValue := FTestValue - Float(F.OldValue);
              FTestValue := FTestValue + F.AsFloat;
            end;
          end;
          fvtMax: if not F.IsNull then
              FTestValue := Max(FTestValue, F.AsFloat);
          fvtMin: if not F.IsNull then
              FTestValue := Min(FTestValue, F.AsFloat);
        end;
  end;
end;

function TRxColumnFooterItem.ErrorTestValue: boolean;
var
  F: TField;
begin
  Result := True;
  if (ValueType in [fvtSum, fvtAvg, fvtMax, fvtMin]) and (FFieldName<>'') then
  begin
    F := TRxDBGrid(FOwner.Grid).DataSource.DataSet.FieldByName(FFieldName);
    if Assigned(F) then
    begin
      if F.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
      begin
        if (FValueType in [fvtMax, fvtMin]) and not (F.IsNull) then
        begin
          if not (F.IsNull) and (FTestValue = F.AsDateTime) then
            Result := False
          else
          if (F.DataSet.RecordCount <> 0) and (F.OldValue <> null) then
          begin
            case FValueType of
              fvtMax: FTestValue := Max(FTestValue, TDateTime(F.OldValue));
              fvtMin: FTestValue := Min(FTestValue, TDateTime(F.OldValue));
            end;
          end;
        end;
      end
      else
      if (FValueType in [fvtMax, fvtMin]) and not (F.IsNull) and (FTestValue = F.AsFloat) then
        Result := False
      else
      begin
        case FValueType of
          fvtSum:
            if F.DataSet.RecordCount = 0 then
            begin
{              if not F.IsNull then
                FTestValue := FTestValue - F.AsFloat;}
              { TODO -oalexs : need rewrite this code - where difficult! }
            end
            else
            begin
              if F.OldValue <> null then
                FTestValue := FTestValue + Float(F.OldValue);
              if not F.IsNull then
                FTestValue := FTestValue - F.AsFloat;
            end;
          fvtMax:
            if (F.DataSet.RecordCount <> 0) and (F.OldValue <> null) then
              FTestValue := Max(FTestValue, Float(F.OldValue));
          fvtMin:
            if (F.DataSet.RecordCount <> 0) and (F.OldValue <> null) then
              FTestValue := Min(FTestValue, Float(F.OldValue));
        end;
      end;
    end;
  end;
end;

procedure TRxColumnFooterItem.UpdateTestValueFromVar(AValue: Variant);
begin
  if FValueType in [fvtSum, fvtAvg, fvtMax, fvtMin] then
  begin
    if (not VarIsEmpty(AValue)) and (AValue <> null) and Assigned(FField) then
    begin
      if FField.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
      begin
        case FValueType of
          fvtMax: FTestValue := Max(FTestValue, AValue);
          fvtMin: FTestValue := Min(FTestValue, AValue);
        end;
      end
      else
      begin
        case FValueType of
          fvtSum,
          fvtAvg: FTestValue := FTestValue + AValue;
          fvtMax: FTestValue := Max(FTestValue, AValue);
          fvtMin: FTestValue := Min(FTestValue, AValue);
        end;
      end;
    end;
  end;
end;

constructor TRxColumnFooterItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  if Assigned(ACollection) then
    FOwner := TRxColumn(TRxColumnFooterItems(ACollection).Owner);

  FTestValue := 0;
  FLayout := tlCenter;
  FColor:=clNone;

  FFont := TFont.Create;
  FillDefaultFont;
  FFont.OnChange := @FontChanged;
end;

destructor TRxColumnFooterItem.Destroy;
begin
  FreeAndNil(FFont);
  inherited Destroy;
end;

function TRxColumnFooterItem.DisplayText: string;
begin
  case FValueType of
    fvtSum,
    fvtAvg,
    fvtMax,
    fvtMin: Result := GetStatTotal;
    fvtCount: Result := GetRecordsCount;
    fvtFieldValue: Result := GetFieldValue;
    fvtStaticText: Result := FValue;
    fvtRecNo: Result := GetRecNo;
    else
      Result := '';
  end;
end;

procedure TRxColumnFooterItem.FillDefaultFont;
var
  AGrid: TCustomGrid;
begin
  if not Assigned(FOwner) then exit;
  AGrid := FOwner.Grid;
  if (AGrid<>nil) then
  begin
    FFont.Assign(AGrid.Font);
    FIsDefaultFont := True;
  end;
end;

{ TRxColumnFooterItems }

function TRxColumnFooterItems.GetItem(Index: integer): TRxColumnFooterItem;
begin
  Result := TRxColumnFooterItem(inherited GetItem(Index));
end;

procedure TRxColumnFooterItems.SetItem(Index: integer;
  const AValue: TRxColumnFooterItem);
begin
  inherited SetItem(Index, AValue);
end;

procedure TRxColumnFooterItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
end;

constructor TRxColumnFooterItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TRxColumnFooterItem);
end;

function TRxColumnFooterItems.GetEnumerator: TRxColumnFooterItemsEnumerator;
begin
  Result:=TRxColumnFooterItemsEnumerator.Create(Self);
end;

{ TRxDBGridAbstractTools }

procedure TRxDBGridAbstractTools.SetRxDBGrid(AValue: TRxDBGrid);
begin
  if FRxDBGrid=AValue then Exit;
  if Assigned(FRxDBGrid) then
    FRxDBGrid.RemoveTools(Self);
  FRxDBGrid:=AValue;
  if Assigned(FRxDBGrid) then
    FRxDBGrid.AddTools(Self);
end;

function TRxDBGridAbstractTools.DoExecTools: boolean;
begin
  Result:=false;
end;

function TRxDBGridAbstractTools.DoSetupTools: boolean;
begin
  Result:=true;
end;

function TRxDBGridAbstractTools.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: integer): boolean;
begin
  Result:=false;
end;

procedure TRxDBGridAbstractTools.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = FRxDBGrid) and (Operation = opRemove) then
    FRxDBGrid := nil;
end;

procedure TRxDBGridAbstractTools.ExecTools(Sender: TObject);
begin
  Execute;
end;

procedure TRxDBGridAbstractTools.SetEnabled(AValue: boolean);
begin
  if FEnabled=AValue then Exit;
  FEnabled:=AValue;
  FRxDBGrid.UpdateToolsState(Self);
end;

constructor TRxDBGridAbstractTools.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FToolsEvents:=[];
  FCaption:=Name;
  FShowSetupForm:=false;
  FEnabled:=true;
end;

destructor TRxDBGridAbstractTools.Destroy;
begin
  SetRxDBGrid(nil);
  inherited Destroy;
end;

function TRxDBGridAbstractTools.Execute: boolean;
begin
  Result:=true;
  if Assigned(FOnBeforeExecute) then
    FOnBeforeExecute(Self);

  if FShowSetupForm then
    Result:=DoSetupTools;

  if Result then
    Result:=DoExecTools;

  if Assigned(FOnAfterExecute) then
    FOnAfterExecute(Self);
end;


{ TRxDBGridCollumnConstraint }

procedure TRxDBGridCollumnConstraints.SetMaxWidth(AValue: integer);
begin
  if FMaxWidth=AValue then Exit;
  if (FMinWidth<>0) and (AValue<>0) and (AValue < FMinWidth) then exit;
  FMaxWidth:=AValue;
end;

procedure TRxDBGridCollumnConstraints.SetMinWidth(AValue: integer);
begin
  if FMinWidth=AValue then Exit;
  if (FMaxWidth<>0) and (AValue<>0) and (AValue > FMaxWidth) then exit;
  FMinWidth:=AValue;
end;

procedure TRxDBGridCollumnConstraints.AssignTo(Dest: TPersistent);
begin
  if Dest is TRxDBGridCollumnConstraints then
  begin
    TRxDBGridCollumnConstraints(Dest).FMinWidth:=FMinWidth;
    TRxDBGridCollumnConstraints(Dest).FMaxWidth:=FMaxWidth;
  end
  else
  inherited AssignTo(Dest);
end;

constructor TRxDBGridCollumnConstraints.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner:=AOwner;
end;

{ TRxDbGridColumnsSortList }

function TRxDbGridColumnsSortList.GetCollumn(Index: Integer): TRxColumn;
begin
  Result:=TRxColumn(Items[Index]);
end;

{ TRxColumnEditButton }

function TRxColumnEditButton.GetGlyph: TBitmap;
begin
  Result:=FButton.Glyph;
end;

function TRxColumnEditButton.GetHint: String;
begin
  Result:=FButton.Hint;
end;

function TRxColumnEditButton.GetNumGlyphs: Integer;
begin
  Result:=FButton.NumGlyphs;
end;

function TRxColumnEditButton.GetOnButtonClick: TNotifyEvent;
begin
  Result:=FButton.OnClick;
end;

function TRxColumnEditButton.GetWidth: Integer;
begin
  Result:=FButton.Width;
end;

procedure TRxColumnEditButton.SetGlyph(AValue: TBitmap);
begin
  FButton.Glyph.Assign(AValue);
  if not (csLoading in TRxDBGrid(TRxColumnEditButtons(Collection).Owner).ComponentState) then
    FStyle:=ebsGlyphRx;
end;

procedure TRxColumnEditButton.SetHint(AValue: String);
begin
  FButton.Hint:=AValue;
  FSpinBtn.Hint:=AValue;
end;

procedure TRxColumnEditButton.SetNumGlyphs(AValue: Integer);
begin
  FButton.NumGlyphs:=AValue;
end;

procedure TRxColumnEditButton.SetOnButtonClick(AValue: TNotifyEvent);
begin
  FButton.OnClick:=AValue;
end;

procedure TRxColumnEditButton.SetStyle(AValue: TRxColumnEditButtonStyle);
begin
  if FStyle=AValue then Exit;
  FStyle:=AValue;
  case FStyle of
    ebsDropDownRx:FButton.Glyph.Assign(FMarkerDown);
    ebsEllipsisRx:FButton.Glyph.Assign(FEllipsisRxBMP);
    ebsGlyphRx:FButton.Glyph.Assign(FGlyphRxBMP);
    ebsUpDownRx:FButton.Glyph.Assign(FUpDownRxBMP);
    ebsPlusRx:FButton.Glyph.Assign(FPlusRxBMP);
    ebsMinusRx:FButton.Glyph.Assign(FMinusRxBMP);
  else
    FButton.Glyph.Assign(nil);
  end;
end;

procedure TRxColumnEditButton.SetVisible(AValue: Boolean);
begin
  FVisible:=AValue;
  if AValue then
  begin
    if Style = ebsUpDownRx then
    begin
      FSpinBtn.Visible:=AValue;
      FButton.Visible:=false;
    end
    else
    begin
      FButton.Visible:=AValue;
      FSpinBtn.Visible:=false;
    end;
  end
  else
  begin
    FButton.Visible:=AValue;
    FSpinBtn.Visible:=AValue;
  end;
end;

procedure TRxColumnEditButton.SetWidth(AValue: Integer);
begin
  FButton.Width:=AValue;
  FSpinBtn.Width:=AValue;
end;

procedure TRxColumnEditButton.DoBottomClick(Sender: TObject);
var
  F:TField;
  Col:TRxColumn;

  msg: TGridMessage;
begin
  Col:=TRxColumnEditButtons(Collection).FOwner as TRxColumn;
  F:=Col.Field;

  if Assigned(F) and (F.DataType in NumericDataTypes) then
  begin
    if not (F.DataSet.State in dsEditModes) then
      F.DataSet.Edit;

    if F.IsNull then
      F.Value:=0;

    F.Value:=F.Value - 1;

    Msg.LclMsg.msg:=GM_SETVALUE;
    Msg.Grid:=Col.Grid;
    Msg.Value:=F.DisplayText;
    TRxDBGrid(Col.Grid).Editor.Dispatch(Msg);

  end;
end;

procedure TRxColumnEditButton.DoTopClick(Sender: TObject);
var
  F:TField;
  Col:TRxColumn;

  msg: TGridMessage;
begin
  Col:=TRxColumnEditButtons(Collection).FOwner as TRxColumn;
  F:=Col.Field;

  if Assigned(F) and (F.DataType in NumericDataTypes) then
  begin
    if not (F.DataSet.State in dsEditModes) then
      F.DataSet.Edit;

    if F.IsNull then
      F.Value:=0;
    F.Value:=F.Value + 1;

    Msg.LclMsg.msg:=GM_SETVALUE;
    Msg.Grid:=Col.Grid;
    Msg.Value:=F.DisplayText;
    TRxDBGrid(Col.Grid).Editor.Dispatch(Msg);
  end;
end;

function TRxColumnEditButton.GetDisplayName: string;
begin
  if Hint<>'' then
    Result:=Hint
  else
    Result:='TRxColumnEditButton';
end;

constructor TRxColumnEditButton.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FButton:=TSpeedButton.Create(nil);

  FSpinBtn:=TRxSpinButton.Create(nil);
  FSpinBtn.OnBottomClick:=@DoBottomClick;
  FSpinBtn.OnTopClick:=@DoTopClick;

  FVisible:=true;
  FEnabled:=true;
  Width:=15;
end;

destructor TRxColumnEditButton.Destroy;
begin
  FreeAndNil(FButton);
  FreeAndNil(FSpinBtn);
  inherited Destroy;
end;

{ TRxColumnEditButtons }

function TRxColumnEditButtons.GetItem(Index: integer): TRxColumnEditButton;
begin
  Result:= TRxColumnEditButton(inherited Items[Index]);
end;

procedure TRxColumnEditButtons.SetItem(Index: integer;
  AValue: TRxColumnEditButton);
begin
  inherited SetItem(Index, AValue);
end;

procedure TRxColumnEditButtons.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
end;

constructor TRxColumnEditButtons.Create(AOwner: TPersistent);
begin
  inherited Create(TRxColumnEditButton);
  FOwner:=AOwner;
end;

function TRxColumnEditButtons.Add: TRxColumnEditButton;
begin
  Result := TRxColumnEditButton(inherited Add);
end;

{ TRxDBGridFooterOptions }

procedure TRxDBGridFooterOptions.SetActive(AValue: boolean);
begin
  if FActive=AValue then Exit;
  FActive:=AValue;

  { TODO : Устаревший код - в следующей версии необходимо убрать }
  if FActive then
    FOwner.FOptionsRx:=FOwner.FOptionsRx + [rdgFooterRows]
  else
    FOwner.FOptionsRx:=FOwner.FOptionsRx - [rdgFooterRows];

  if FActive then
    FOwner.CalcStatTotals;
  FOwner.VisualChange;
end;

procedure TRxDBGridFooterOptions.SetColor(AValue: TColor);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
  FOwner.Invalidate;
end;

procedure TRxDBGridFooterOptions.SetDrawFullLine(AValue: boolean);
begin
  if FDrawFullLine=AValue then Exit;
  FDrawFullLine:=AValue;
  FOwner.VisualChange;
end;

procedure TRxDBGridFooterOptions.SetRowCount(AValue: integer);
begin
  if FRowCount=AValue then Exit;
  FRowCount:=AValue;
  FOwner.VisualChange;
end;

procedure TRxDBGridFooterOptions.SetStyle(AValue: TTitleStyle);
begin
  if FStyle=AValue then Exit;
  FStyle:=AValue;
end;

procedure TRxDBGridFooterOptions.AssignTo(Dest: TPersistent);
var
  FO:TRxDBGridFooterOptions absolute Dest;
begin
  if Dest is TRxDBGridFooterOptions then
  begin
    FO.Active:=Active;
    FO.Color:=Color;
    FO.RowCount:=RowCount;
    FO.Style:=Style;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TRxDBGridFooterOptions.Create(Owner: TRxDBGrid);
begin
  inherited Create;
  FOwner:=Owner;

  FColor := clWindow;
  FRowCount := 0;
  FStyle := tsLazarus;
end;

destructor TRxDBGridFooterOptions.Destroy;
begin
  inherited Destroy;
end;


{ TRxDBGridDateEditor }

procedure TRxDBGridDateEditor.EditChange;
var
  D:TDateTime;
begin
  inherited EditChange;
  if Assigned(FGrid) and FGrid.DatalinkActive and not FGrid.EditorIsReadOnly then
  begin
    if not (FGrid.DataSource.DataSet.State in dsEditModes) then
      FGrid.DataSource.Edit;
    if Self.Text <> '' then
      FGrid.SelectedField.AsDateTime := Self.Date
    else
      FGrid.SelectedField.Clear;

    if FGrid <> nil then
    begin
      if TryStrToDate(Text, D) then
        FGrid.SetEditText(FCol, FRow, Text)
      else
        FGrid.SetEditText(FCol, FRow, '');
    end;
  end;
end;

procedure TRxDBGridDateEditor.KeyDown(var Key: word; Shift: TShiftState);

  function AllSelected: boolean;
  begin
    Result := (SelLength > 0) and (SelLength = UTF8Length(Text));
  end;

  function AtStart: boolean;
  begin
    Result := (SelStart = 0);
  end;

  function AtEnd: boolean;
  begin
    Result := ((SelStart + 1) > UTF8Length(Text)) or AllSelected;
  end;

  procedure doEditorKeyDown;
  begin
    if FGrid <> nil then
      FGrid.EditorkeyDown(Self, key, shift);
  end;

  procedure doGridKeyDown;
  begin
    if FGrid <> nil then
      FGrid.KeyDown(Key, shift);
  end;

  function GetFastEntry: boolean;
  begin
    if FGrid <> nil then
      Result := FGrid.FastEditing
    else
      Result := False;
  end;

  procedure CheckEditingKey;
  begin
    if (FGrid = nil) or FGrid.EditorIsReadOnly then
      Key := 0;
  end;

var
  IntSel: boolean;
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_F2:
      if AllSelected then
      begin
        SelLength := 0;
        SelStart := Length(Text);
      end;
    VK_DELETE:
      CheckEditingKey;
    VK_UP, VK_DOWN:
      doGridKeyDown;
    VK_LEFT, VK_RIGHT:
      if GetFastEntry then
      begin
        IntSel :=
          ((Key = VK_LEFT) and not AtStart) or ((Key = VK_RIGHT) and not AtEnd);
        if not IntSel then
        begin
          doGridKeyDown;
        end;
      end;
    VK_END, VK_HOME:
      ;
    else
      doEditorKeyDown;
  end;
end;

procedure TRxDBGridDateEditor.WndProc(var TheMessage: TLMessage);
begin
  if FGrid<>nil then
    case TheMessage.Msg of
      LM_CLEAR,
      LM_CUT,
      LM_PASTE:
        begin
          if FGrid.EditorIsReadOnly then
            exit;
        end;
    end;

  if TheMessage.msg = LM_KILLFOCUS then
  begin
    if HWND(TheMessage.WParam) = HWND(Handle) then
    begin
      // lost the focus but it returns to ourselves
      // eat the message.
      TheMessage.Result := 0;
      exit;
    end;
  end;
  inherited WndProc(TheMessage);
end;

procedure TRxDBGridDateEditor.msg_SetGrid(var Msg: TGridMessage);
begin
  FGrid := Msg.Grid as TRxDBGrid;
  Msg.Options := EO_AUTOSIZE or EO_SELECTALL
  {or EO_HOOKEXIT or EO_HOOKKEYPRESS or EO_HOOKKEYUP};
end;

procedure TRxDBGridDateEditor.msg_SetValue(var Msg: TGridMessage);
var
  D: TDateTime;
begin
  if FGrid.SelectedField.DataType in [ftDate, ftDateTime] then
    Self.Date := FGrid.SelectedField.AsDateTime
  else
  if TryStrToDateTime(FGrid.SelectedField.AsString, D) then
    Self.Date := D
  else
    Self.Clear;
end;

procedure TRxDBGridDateEditor.msg_GetValue(var Msg: TGridMessage);
var
  sText: string;
begin
  sText := Text;
  Msg.Value := sText;
end;

procedure TRxDBGridDateEditor.msg_SelectAll(var Msg: TGridMessage);
begin
  SelectAll;
end;

constructor TRxDBGridDateEditor.Create(Aowner: TComponent);
begin
  inherited Create(Aowner);
  AutoSize := false;
  Spacing:=0;
  UpdateMask;
end;

procedure TRxDBGridDateEditor.EditingDone;
begin
  inherited EditingDone;
  if FGrid <> nil then
    FGrid.EditingDone;
end;


{ TRxDBGridLookupComboEditor }

procedure TRxDBGridLookupComboEditor.WndProc(var TheMessage: TLMessage);
begin
  if TheMessage.msg = LM_KILLFOCUS then
  begin
    if HWND(TheMessage.WParam) = HWND(Handle) then
    begin
      // lost the focus but it returns to ourselves
      // eat the message.
      TheMessage.Result := 0;
      exit;
    end;
  end;
  inherited WndProc(TheMessage);
end;

procedure TRxDBGridLookupComboEditor.KeyDown(var Key: word; Shift: TShiftState);

  procedure doGridKeyDown;
  begin
    if Assigned(FGrid) then
      FGrid.KeyDown(Key, shift);
  end;

  procedure doEditorKeyDown;
  begin
    if FGrid <> nil then
      FGrid.EditorkeyDown(Self, key, shift);
  end;

  function GetFastEntry: boolean;
  begin
    if FGrid <> nil then
      Result := FGrid.FastEditing
    else
      Result := False;
  end;
  procedure CheckEditingKey;
  begin
    if (FGrid=nil) or FGrid.EditorIsReadOnly then
      Key := 0;
  end;

begin
  CheckEditingKey;
  case Key of
    VK_UP,
    VK_DOWN:
      if (not PopupVisible) and (not (ssAlt in Shift)) then
      begin
        doGridKeyDown;
        Key:=0;
        exit;
      end;
    VK_LEFT, VK_RIGHT:
      if GetFastEntry then
      begin
        doGridKeyDown;
        exit;
      end;
    else
    begin
      inherited KeyDown(Key, Shift);
      doEditorKeyDown;
      exit;
    end;
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TRxDBGridLookupComboEditor.msg_SetGrid(var Msg: TGridMessage);
begin
  FGrid := Msg.Grid as TRxDBGrid;
  Msg.Options := EO_AUTOSIZE;
end;

procedure TRxDBGridLookupComboEditor.msg_SetValue(var Msg: TGridMessage);
var
  F: TField;
begin
  FCol := Msg.Col;
  FRow := Msg.Row;
  F := FGrid.SelectedField;
  DataSource := FGrid.DataSource;
  if Assigned(F) then
  begin
    DataField := F.KeyFields;
    LookupDisplay := F.LookupResultField;
    LookupField := F.LookupKeyFields;
    FLDS.DataSet := F.LookupDataSet;
    FGrid.GetOnCreateLookup;
  end;
end;

procedure TRxDBGridLookupComboEditor.msg_GetValue(var Msg: TGridMessage);
var
  sText: string;
  F:TField;
begin
  if Assigned(FGrid.SelectedField) and Assigned(FLDS.DataSet) then
  begin
    F:=FLDS.DataSet.FieldByName(LookupDisplay);
    if Assigned(F) then
    begin
      sText := F.DisplayText;
      Msg.Value := sText;
    end;
  end;
end;

procedure TRxDBGridLookupComboEditor.ShowList;
begin
  FGrid.GetOnDisplayLookup;
  inherited ShowList;
end;

procedure TRxDBGridLookupComboEditor.OnInternalClosePopup(AResult: boolean);
  procedure CheckEditingKey;
  begin
    if (FGrid=nil) or FGrid.EditorIsReadOnly then
//      Key := 0;
  end;
var
  F:TField;
begin
  inherited OnInternalClosePopup(AResult);
  CheckEditingKey;
  if (AResult) and Assigned(FGrid.SelectedField) and Assigned(FLDS.DataSet) then
  begin
    F:=FLDS.DataSet.FieldByName(LookupDisplay);
    if Assigned(F) then
    begin
      if (FGrid<>nil) and Visible then begin
        FGrid.SetEditText(FCol, FRow, F.DisplayText);
      end;
    end;
  end;
end;

constructor TRxDBGridLookupComboEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLDS := TDataSource.Create(nil);
  LookupSource := FLDS;
  AutoSize := false;
  Style:=rxcsDropDownList;
end;

destructor TRxDBGridLookupComboEditor.Destroy;
begin
  FreeAndNil(FLDS);
  inherited Destroy;
end;

{ TRxDBGrid }

procedure TRxDBGrid.SetTitleButtons(const AValue: boolean);
begin
  if AValue then
    Options := Options + [dgHeaderPushedLook]
  else
    Options := Options - [dgHeaderPushedLook];
end;

procedure TRxDBGrid.GetScrollbarParams(out aRange, aPage, aPos: Integer);
begin
  if (DataSource.DataSet<>nil) and DataSource.DataSet.Active then begin
    if DataSource.DataSet.IsSequenced then begin
      aRange := DataSource.DataSet.RecordCount + VisibleRowCount - 1;
      aPage := VisibleRowCount;
      if aPage<1 then aPage := 1;
      if DataSource.DataSet.BOF then aPos := 0 else
      if DataSource.DataSet.EOF then aPos := aRange
      else
        aPos := DataSource.DataSet.RecNo - 1; // RecNo is 1 based
      if aPos<0 then aPos:=0;
    end else begin
      aRange := 6;
      aPage := 2;
      if DataSource.DataSet.EOF then aPos := 4 else
      if DataSource.DataSet.BOF then aPos := 0
      else aPos := 2;
    end;
  end else begin
    aRange := 0;
    aPage := 0;
    aPos := 0;
  end;
end;

procedure TRxDBGrid.RestoreEditor;
begin
  if EditorMode then
  begin
    EditorMode := False;
    EditorMode := True;
  end;
end;

procedure TRxDBGrid.SetAutoSort(const AValue: boolean);
var
  S: string;
  Pos: integer;
begin
  if FAutoSort = AValue then
    exit;
  FAutoSort := AValue;
  if Assigned(DataSource) and Assigned(DataSource.DataSet) and
    DataSource.DataSet.Active then
  begin
    S := DataSource.DataSet.ClassName;
    if RxDBGridSortEngineList.Find(S, Pos) then
      FSortEngine := RxDBGridSortEngineList.Objects[Pos] as TRxDBGridSortEngine
    else
      FSortEngine := nil;
    FSortColumns.Clear;
  end;
end;

procedure TRxDBGrid.SetColumnDefValues(AValue: TRxDBGridColumnDefValues);
begin
  FColumnDefValues.AssignTo(AValue);
end;

function TRxDBGrid.GetColumns: TRxDbGridColumns;
begin
  Result := TRxDbGridColumns(inherited Columns);
end;

function TRxDBGrid.GetFooterColor: TColor;
begin
  Result:=FFooterOptions.FColor;
end;

function TRxDBGrid.GetFooterRowCount: integer;
begin
  Result:=FFooterOptions.RowCount;
end;

function TRxDBGrid.GetDrawFullLine: boolean;
begin
  Result := FFooterOptions.FDrawFullLine;
end;

procedure TRxDBGrid.SetDrawFullLine(Value: boolean);
begin
  FFooterOptions.DrawFullLine := Value;
end;

function TRxDBGrid.CreateToolMenuItem(ShortCut: char; const ACaption: string;
  MenuAction: TNotifyEvent): TMenuItem;
begin
  Result := TMenuItem.Create(F_PopupMenu);
  F_PopupMenu.Items.Add(Result);
  Result.Caption := ACaption;
  if ShortCut <> #0 then
    Result.ShortCut := KeyToShortCut(Ord(ShortCut), [ssCtrl]);
  Result.OnClick := MenuAction;
end;

procedure TRxDBGrid.RemoveToolMenuItem(MenuAction: TNotifyEvent);
var
  R: TMenuItem;
  I: Integer;
begin
  if not Assigned(MenuAction) then Exit;
  for I:=F_PopupMenu.Items.Count-1 downto 0 do
  begin
    R:=F_PopupMenu.Items[I];
    if R.OnClick = MenuAction then
    begin
      F_PopupMenu.Items.Delete(i);
      R.Free;
    end;
  end;
end;

procedure TRxDBGrid.DoCreateJMenu;
begin
  F_PopupMenu := TPopupMenu.Create(Self);
  F_PopupMenu.Name := 'OptionsMenu';
  CreateToolMenuItem('F', sRxDBGridFind, @OnFind);
  CreateToolMenuItem('T', sRxDBGridFilter, @OnFilterBy);
  CreateToolMenuItem('E', sRxDBGridFilterSimple, @OnFilter);
  CreateToolMenuItem('Q', sRxDBGridFilterClear, @OnFilterClose);
  CreateToolMenuItem(#0, '-', nil);
  CreateToolMenuItem('C', sRxDBGridSortByColumns, @OnSortBy);
  CreateToolMenuItem('W', sRxDBGridSelectColumns, @OnChooseVisibleFields);
  CreateToolMenuItem('A', sRxDBGridSelectAllRows, @OnSelectAllRows);
  CreateToolMenuItem(#0, sRxDBGridCopyCellValue, @OnCopyCellValue);
  CreateToolMenuItem(#0, sRxDBGridOptimizeColWidth, @OnOptimizeColWidth);
end;

function TRxDBGrid.GetPropertyStorage: TCustomPropertyStorage;
begin
  Result := FPropertyStorageLink.Storage;
end;

function TRxDBGrid.GetSortField: string;
begin
  if FSortColumns.Count > 0 then
    Result:=FSortColumns[0].GetSortFields
  else
    Result:='';
end;

function TRxDBGrid.GetSortOrder: TSortMarker;
begin
  if FSortColumns.Count > 0 then
    Result:=FSortColumns[0].SortOrder
  else
    Result:=smNone;
end;

function TRxDBGrid.GetTitleButtons: boolean;
begin
  Result := dgHeaderPushedLook in Options;
end;

function TRxDBGrid.IsColumnsStored: boolean;
begin
  Result := TRxDbGridColumns(TCustomDrawGrid(Self).Columns).Enabled;
end;

procedure TRxDBGrid.SelectedFontChanged(Sender: TObject);
begin
  FIsSelectedDefaultFont:=FSelectedFont.IsDefault;
  VisualChange;
end;

function TRxDBGrid.IsSelectedFontStored: Boolean;
begin
  Result:=not FIsSelectedDefaultFont
end;

procedure TRxDBGrid.SetColumns(const AValue: TRxDbGridColumns);
begin
  inherited Columns := TDBGridColumns(AValue);
end;

procedure TRxDBGrid.SetFooterColor(const AValue: TColor);
begin
  FFooterOptions.Color := AValue;
end;

procedure TRxDBGrid.SetFooterOptions(AValue: TRxDBGridFooterOptions);
begin
  FFooterOptions.AssignTo(AValue);
end;

procedure TRxDBGrid.SetFooterRowCount(const AValue: integer);
begin
  FFooterOptions.RowCount:=AValue;
end;

procedure TRxDBGrid.SetKeyStrokes(const AValue: TRxDBGridKeyStrokes);
begin
  if Assigned(AValue) then
    FKeyStrokes.Assign(AValue)
  else
    FKeyStrokes.Clear;

  UpdateJMenuKeys;
end;

procedure TRxDBGrid.SetOptionsRx(const AValue: TOptionsRx);
var
  OldOpt: TOptionsRx;
begin
  if FOptionsRx = AValue then
    exit;
  BeginUpdate;
  OldOpt := FOptionsRx;
  FOptionsRx := AValue;
  UseXORFeatures := rdgXORColSizing in AValue;
  if (rdgFilter in AValue) and not (rdgFilter in OldOpt) then
  begin
    FillFilterData;
    LayoutChanged;
  end
  else
  if rdgFilter in OldOpt then
  begin
    FFilterListEditor.Hide;
    FFilterColDlgButton.Hide;
    FFilterSimpleEdit.Hide;
    LayoutChanged;
  end;

  FFooterOptions.FActive:=rdgFooterRows in FOptionsRx;

  if (rdgWordWrap in OldOpt) and not (rdgWordWrap in FOptionsRx) then
    ResetRowHeght;

  EndUpdate;
end;

procedure TRxDBGrid.SetPropertyStorage(const AValue: TCustomPropertyStorage);
begin
  FPropertyStorageLink.Storage := AValue;
end;

procedure TRxDBGrid.SetSearchOptions(AValue: TRxDBGridSearchOptions);
begin
  FSearchOptions.Assign(AValue);
end;

procedure TRxDBGrid.SetSelectedFont(AValue: TFont);
begin
  if not FSelectedFont.IsEqual(AValue) then
    FSelectedFont.Assign(AValue);
end;

function TRxDBGrid.DatalinkActive: boolean;
begin
  Result := Assigned(DataSource) and Assigned(DataSource.DataSet) and
    DataSource.DataSet.Active;
end;

procedure TRxDBGrid.AdjustEditorBounds(NewCol, NewRow: Integer);
begin
  inherited AdjustEditorBounds(NewCol, NewRow);
  if EditorMode then
  begin
    DoSetColEdtBtn;
  end;
end;

procedure TRxDBGrid.TrackButton(X, Y: integer);
var
  Cell: TGridCoord;
  NewPressed: boolean;
  I, Offset: integer;
begin
  Cell := MouseCoord(X, Y);
  Offset := RowCount;
  NewPressed := PtInRect(Rect(0, 0, ClientWidth, ClientHeight), Point(X, Y)) and
    (FPressedCol = TColumn(ColumnFromGridColumn(Cell.X))) and (Cell.Y < Offset);
  if FPressed <> NewPressed then
  begin
    FPressed := NewPressed;
    for I := 0 to Offset - 1 do
      GridInvalidateRow(Self, I);
  end;
end;

procedure TRxDBGrid.StopTracking;
begin
  if FTracking then
  begin
    TrackButton(-1, -1);
    FTracking := False;
    MouseCapture := False;
  end;
end;

procedure TRxDBGrid.CalcTitle;
var
  i, j: integer;
  H, H1, W, W1, FDefRowH: integer;
  rxCol, rxColNext: TRxColumn;
  rxTit, rxTitleNext: TRxColumnTitle;
  MLRec1, P: TMLCaptionItem;
  MLRec2: TMLCaptionItem;
  tmpCanvas: TCanvas;
  FWC: SizeInt;
begin
 FDefRowH:=GetDefaultRowHeight;

  { TODO -oalexs : need rewrite code - split to 2 step:
1. make links between column
2. calc title width for all linked column series }
  if RowCount = 0 then
    exit;
  tmpCanvas := GetWorkingCanvas(Canvas);
  try
    ClearMLCaptionPointers;
    for i := 0 to Columns.Count - 1 do
    begin
      rxCol := TRxColumn(Columns[i]);
      if Assigned(rxCol) and rxCol.Visible then
      begin
        rxTit := TRxColumnTitle(rxCol.Title);
        if Assigned(rxTit) then
        begin
          if rxTit.Orientation in [toVertical270, toVertical90] then
//            H := Max((tmpCanvas.TextWidth(Columns[i].Title.Caption) + tmpCanvas.TextWidth('W')*2) div DefaultRowHeight, H)
          else
          begin
            rxColNext := nil;
            rxTitleNext := nil;
            if i < Columns.Count - 1 then
            begin
              rxColNext := TRxColumn(Columns[i + 1]);
              rxTitleNext := TRxColumnTitle(rxColNext.Title);
            end;

//            W := Max(rxCol.Width - 6, 1);
            if rxTit.CaptionLinesCount > 0 then
            begin
//              H2 := 0;
//              H1 := 0;
              for j := 0 to rxTit.CaptionLinesCount - 1 do
              begin
                MLRec1 := rxTit.CaptionLine(j);

                if Assigned(rxTitleNext) and (rxTitleNext.CaptionLinesCount > j) then
                begin
                  //make links to next column - and in the next column set link to prior-current
                  MLRec2 := rxTitleNext.CaptionLine(j);
                  if MLRec1.Caption = MLRec2.Caption then
                  begin
                    MLRec1.Next := MLRec2;
                    MLRec2.Prior := MLRec1;
                  end
                  else
                    break;
                end;

                MLRec1.Width := tmpCanvas.TextWidth(MLRec1.Caption) + 2;

{                if W > MLRec1.Width then
                  H2 := 1
                else
                  H2 := MLRec1.Width div W + 1;

                if H2 > WordCount(MLRec1.Caption, [' ']) then
                  H2 := WordCount(MLRec1.Caption, [' ']);

                H1 := H1 + H2;}
              end;
            end
{            else
            begin
              H1 := Max((tmpCanvas.TextWidth(rxTit.Caption) + 2) div W + 1, H);
              if H1 > WordCount(rxTit.Caption, [' ']) then
                H1 := WordCount(rxTit.Caption, [' ']);
            end;
            H := Max(H1, H); }
          end;

          for j := 0 to rxTit.CaptionLinesCount - 1 do
          begin
            MLRec1 := rxTit.CaptionLine(j);
            if MLRec1.Width < rxTit.Column.Width then
              MLRec1.Width := rxTit.Column.Width;
          end;

        end;
      end;
    end;

    //Тут расчёт высоты заголовка каждой колонки - надо обработать слитые заголовки

    H := 1;
    for i := 0 to Columns.Count - 1 do
    begin
      rxCol := TRxColumn(Columns[i]);
      rxTit := TRxColumnTitle(rxCol.Title);
      H1 := 0;
      W := Max(rxCol.Width - 6, 1);
      //Не забудем про вертикальную ориентацию
      if Assigned(rxCol) and rxCol.Visible and Assigned(rxTit) then
      begin
        if rxTit.Orientation in [toVertical270, toVertical90] then
          H1 := Max((tmpCanvas.TextWidth(Columns[i].Title.Caption) +
            tmpCanvas.TextWidth('W')) div FDefRowH, H)
        else
        begin
          if rxTit.CaptionLinesCount = 0 then
          begin
            H1 := Max((tmpCanvas.TextWidth(rxTit.Caption) + 2) div W + 1, H);
            FWC:=WordCount(rxTit.Caption, [' ']);
            if H1 > FWC then H1 := FWC;
          end
          else
          begin
            if rxTit.CaptionLinesCount > H then
              H := rxTit.CaptionLinesCount;
            for j := 0 to rxTit.CaptionLinesCount - 1 do
            begin
              MLRec1 := rxTit.CaptionLine(j);
              //S := MLRec1.Caption;
              if not Assigned(MLRec1.Prior) then
              begin
                W := rxCol.Width;
                P := MLRec1.Next;
                while Assigned(P) do
                begin
                  Inc(W, P.Col.Width);
                  P := P.Next;
                end;
                W1 := tmpCanvas.TextWidth(MLRec1.Caption) + 2;
                if W1 > W then
                  MLRec1.Height := Min(W1 div Max(W, 1) + 1, UTF8Length(MLRec1.Caption))
                else
                  MLRec1.Height := 1;

                P := MLRec1.Next;
                while Assigned(P) do
                begin
                  P.Height := MLRec1.Height;
                  P := P.Next;
                end;
              end;
              H1 := H1 + MLRec1.Height;
            end;

          end;
        end;
      end;
      if H1 > H then
        H := H1;
    end;

    if not (rdgDisableWordWrapTitles in OptionsRx) then
      RowHeights[0] := FDefRowH * H
    else
      RowHeights[0] := FDefRowH;

    if rdgFilter in OptionsRx then
    begin
      H:=FDefRowH;
      if  Assigned(FFilterListEditor) then
        H:=Max(H, FFilterListEditor.Height);

      if Assigned(FFilterSimpleEdit) then
        H:=Max(H, FFilterSimpleEdit.Height);

      RowHeights[0] := RowHeights[0] + H;
    end;

  finally
    if TmpCanvas <> Canvas then
      FreeWorkingCanvas(tmpCanvas);
  end;
end;

procedure TRxDBGrid.ClearMLCaptionPointers;
var
  i, j: integer;
  rxCol: TRxColumn;
  rxTit: TRxColumnTitle;
begin
  for i := 0 to Columns.Count - 1 do
  begin
    rxCol := TRxColumn(Columns[i]);
    if Assigned(rxCol) then
    begin
      rxTit := TRxColumnTitle(rxCol.Title);
      if Assigned(rxTit) then
      begin
        for j := 0 to rxTit.CaptionLinesCount - 1 do
        begin
          rxTit.CaptionLine(j).Next := nil;
          rxTit.CaptionLine(j).Prior := nil;
        end;
      end;
    end;
  end;
end;

procedure TRxDBGrid.FillDefaultFonts;
begin
  FSelectedFont.Assign(Font);
  //FSelectedFont.Color:=clHighlightText;
  FIsSelectedDefaultFont := True;
end;

function TRxDBGrid.getFilterRect(bRect: TRect): TRect;
begin
  Result := bRect;
  if Assigned(FFilterListEditor) then
    Result.Top := bRect.Bottom - FFilterListEditor.Height
  else
    Result.Top := bRect.Bottom - GetDefaultRowHeight;
end;

function TRxDBGrid.getTitleRect(bRect: TRect): TRect;
begin
  Result := bRect;
  if Assigned(FFilterListEditor) then
    Result.Bottom := bRect.Bottom - FFilterListEditor.Height
  else
    Result.Bottom := bRect.Bottom - GetDefaultRowHeight;
end;

procedure TRxDBGrid.OutCaptionCellText(aCol, aRow: integer; const aRect: TRect;
  aState: TGridDrawState; const ACaption: string);
begin
  if (TitleStyle = tsNative) then
    DrawThemedCell(aCol, aRow, aRect, aState)
  else
  begin
    Canvas.FillRect(aRect);
    DrawCellGrid(aCol, aRow, aRect, aState);
  end;

  if ACaption <> '' then
  begin
    if not (rdgDisableWordWrapTitles in OptionsRx) then
      WriteTextHeader(Canvas, aRect, ACaption, GetColumnAlignment(aCol, True))
    else
      DrawCellText(aCol, aRow, aRect, aState, ACaption);
  end;
end;

procedure TRxDBGrid.OutCaptionCellText90(aCol, aRow: integer;
  const aRect: TRect; aState: TGridDrawState; const ACaption: string;
  const TextOrient: TTextOrientation);
var
  dW, dY: integer;
begin
  if (TitleStyle = tsNative) then
    DrawThemedCell(aCol, aRow, aRect, aState)
  else
  begin
    Canvas.FillRect(aRect);
    DrawCellGrid(aCol, aRow, aRect, aState);
  end;


  if TextOrient in [toVertical90, toVertical270] then
  begin
    dW := ((aRect.Bottom - aRect.Top) - Canvas.TextWidth(ACaption)) div 2;
    dY := ((aRect.Right - aRect.Left) - Canvas.TextHeight(ACaption)) div 2;
  end
  else
  begin
    dW := 0;
    dY := 0;
  end;
  OutTextXY90(Canvas, aRect.Left + dY, aRect.Top + dw, ACaption, TextOrient);
end;

procedure TRxDBGrid.OutCaptionSortMarker(const aRect: TRect;
  ASortMarker: TSortMarker; ASortPosition: integer);
var
  X, Y, W: integer;
  S:string;
  F:TFont;
begin
  if (dgHeaderPushedLook in Options) then
  begin
    if (ASortMarker <> smNone) and (ASortPosition>0) then
    begin
      F:=TFont.Create;
      F.Assign(Font);

      if Font.Size = 0 then
        Font.Size:=7
      else
        Font.Size:=Font.Size-2;
      S:='('+IntToStr(ASortPosition)+')';
      W:=Canvas.TextWidth(S) + 10;
    end
    else
    begin
      W:=6;
      F:=nil;
    end;

    if ASortMarker = smDown then
    begin
      X := aRect.Right - FMarkerDown.Width - W;
      Y := Trunc((aRect.Top + aRect.Bottom - FMarkerDown.Height) / 2);
      Canvas.Draw(X, Y, FMarkerDown);
    end
    else
    if ASortMarker = smUp then
    begin
      X := aRect.Right - FMarkerUp.Width - W;
      Y := Trunc((aRect.Top + aRect.Bottom - FMarkerUp.Height) / 2);
      Canvas.Draw(X, Y, FMarkerUp);
    end;

    if Assigned(F) then
    begin
      Canvas.TextOut( X + FMarkerDown.Width, Y,  S);
      Font.Assign(F);
      FreeAndNil(F);
    end;

  end;
end;

procedure TRxDBGrid.OutCaptionMLCellText(aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState; MLI: TMLCaptionItem);
var
  MLINext: TMLCaptionItem;
  Rgn: HRGN;
begin
  MLINext := MLI.Next;
  while Assigned(MLINext) do
  begin
    aRect.Right := aRect.Right + MLINext.Col.Width;
    MLINext := MLINext.Next;
  end;

  Rgn := CreateRectRgn(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);
  SelectClipRgn(Canvas.Handle, Rgn);
  OutCaptionCellText(aCol, aRow, aRect, aState, MLI.Caption);
  SelectClipRgn(Canvas.Handle, 0);
  DeleteObject(Rgn);
end;

procedure TRxDBGrid.UpdateJMenuStates;
begin
  F_PopupMenu.Items[0].Visible := rdgAllowDialogFind in FOptionsRx;
  F_PopupMenu.Items[1].Visible := rdgAllowFilterForm in FOptionsRx;
  F_PopupMenu.Items[2].Visible := rdgAllowQuickFilter in FOptionsRx;
  F_PopupMenu.Items[3].Visible :=
    (rdgFilter in FOptionsRx) or (rdgAllowFilterForm in FOptionsRx);
  F_PopupMenu.Items[5].Visible := rdgAllowSortForm in FOptionsRx;
  F_PopupMenu.Items[6].Visible := rdgAllowColumnsForm in FOptionsRx;
  F_PopupMenu.Items[7].Visible := dgMultiselect in Options;
end;

procedure TRxDBGrid.UpdateJMenuKeys;

  function DoShortCut(Cmd: TRxDBGridCommand): TShortCut;
  var
    K: TRxDBGridKeyStroke;
  begin
    K := FKeyStrokes.FindRxKeyStrokes(Cmd);
    if Assigned(K) and K.Enabled then
      Result := K.ShortCut
    else
      Result := 0;
  end;

begin
  F_PopupMenu.Items[0].ShortCut := DoShortCut(rxgcShowFindDlg);
  F_PopupMenu.Items[1].ShortCut := DoShortCut(rxgcShowFilterDlg);
  F_PopupMenu.Items[2].ShortCut := DoShortCut(rxgcShowQuickFilter);
  F_PopupMenu.Items[3].ShortCut := DoShortCut(rxgcHideQuickFilter);
  F_PopupMenu.Items[5].ShortCut := DoShortCut(rxgcShowSortDlg);
  F_PopupMenu.Items[6].ShortCut := DoShortCut(rxgcShowColumnsDlg);
  F_PopupMenu.Items[7].ShortCut := DoShortCut(rxgcSelectAll);
end;

function TRxDBGrid.SortEngineOptions: TRxSortEngineOptions;
begin
  Result := [];
  if rdgCaseInsensitiveSort in FOptionsRx then
    Include(Result, seoCaseInsensitiveSort);
end;

procedure TRxDBGrid.OnIniSave(Sender: TObject);
var
  i: integer;
  S, S1: string;
  C: TRxColumn;
begin
  S := Owner.Name + '.' + Name;
  FPropertyStorageLink.Storage.WriteInteger(S + sVersion, FVersion);
  FPropertyStorageLink.Storage.WriteInteger(S + sCount, Columns.Count);
  S := S + sItem;
  for i := 0 to Columns.Count - 1 do
  begin
    S1 := S + IntToStr(i);
    C := TRxColumn(Columns[i]);
    FPropertyStorageLink.Storage.WriteString(S1 + sCaption,
      StrToHexText(C.Title.Caption));
    FPropertyStorageLink.Storage.WriteInteger(S1 + sWidth, C.Width);
    FPropertyStorageLink.Storage.WriteInteger(S1 + sIndex, C.Index);
    FPropertyStorageLink.Storage.WriteInteger(S1 + sVisible, Ord(C.Visible));
  end;

  { TODO : Необходимо подключить сохранение списка колонок сортировки }
{
  FSortColumns;
  if Assigned(FSortField) then
  begin
    FPropertyStorageLink.Storage.WriteInteger(S1 + sSortMarker, Ord(FSortOrder));
    FPropertyStorageLink.Storage.WriteString(S1 + sSortField, FSortField.FieldName);
  end
  else
    FPropertyStorageLink.Storage.WriteInteger(S1 + sSortMarker, Ord(smNone));
}
end;

procedure TRxDBGrid.OnIniLoad(Sender: TObject);
var
  i, ACount: integer;
  S, S1, ColumName: string;
  C: TRxColumn;

begin
  S := Owner.Name + '.' + Name;
  ACount := FPropertyStorageLink.Storage.ReadInteger(S + sVersion, FVersion);
  //Check cfg version
  if ACount = FVersion then
  begin
    ACount := FPropertyStorageLink.Storage.ReadInteger(S + sCount, 0);
    S := S + sItem;
    for i := 0 to ACount - 1 do
    begin
      S1 := S + IntToStr(i);
      ColumName := HexTextToStr(FPropertyStorageLink.Storage.ReadString(S1 +
        sCaption, ''));
      if ColumName <> '' then
      begin
        C := ColumnByCaption(ColumName);
        if Assigned(C) then
        begin
          C.Width := FPropertyStorageLink.Storage.ReadInteger(S1 + sWidth, C.Width);
          C.Visible := FPropertyStorageLink.Storage.ReadInteger(S1 +
            sVisible, Ord(C.Visible)) = 1;
          C.Index := Min(FPropertyStorageLink.Storage.ReadInteger(S1 + sIndex, C.Index),
            Columns.Count - 1);
        end;
      end;
    end;

    { TODO : Необходимо подключить востановление списка колонок сортировки }
{    FSortOrder := TSortMarker(FPropertyStorageLink.Storage.ReadInteger(
      S1 + sSortMarker, Ord(smNone)));
    if Assigned(FSortEngine) and (FSortOrder <> smNone) and DatalinkActive then
    begin
      ColumName := FPropertyStorageLink.Storage.ReadString(S1 + sSortField, '');
      if ColumName <> '' then
      begin
        FSortField := DataSource.DataSet.FindField(ColumName);
        if Assigned(FSortField) then
          FSortEngine.Sort(FSortField, DataSource.DataSet, FSortOrder = smUp,
            SortEngineOptions);
      end;
    end;}
  end;
end;

procedure TRxDBGrid.CleanDSEvent;
begin
  if Assigned(DataSource) and Assigned(DataSource.DataSet) then
  begin
    if DataSource.DataSet.OnPostError = @ErrorPo then
      DataSource.DataSet.OnPostError := F_EventOnPostError;

    if DataSource.DataSet.OnFilterRecord = @FilterRec then
      DataSource.DataSet.OnFilterRecord := F_EventOnFilterRec;

    if DataSource.DataSet.BeforeDelete = @BeforeDel then
      DataSource.DataSet.BeforeDelete := F_EventOnBeforeDelete;

    if DataSource.DataSet.BeforePost = @BeforePo then
      DataSource.DataSet.BeforePost:=F_EventOnBeforePost;

    if DataSource.DataSet.OnDeleteError = @ErrorDel then
      DataSource.DataSet.OnDeleteError:=F_EventOnDeleteError;

    if DataSource.DataSet.OnPostError = @ErrorPo then
      DataSource.DataSet.OnPostError:=F_EventOnPostError;

    F_EventOnPostError:=nil;
    F_EventOnFilterRec:=nil;
    F_EventOnBeforeDelete:=nil;
    F_EventOnBeforePost:=nil;
    F_EventOnDeleteError:=nil;
    F_EventOnPostError:=nil;
  end;
end;

procedure TRxDBGrid.CollumnSortListUpdate;
var
  i, J:integer;
  C:TRxColumn;
begin
  FSortColumns.Clear;
  for i:=0 to Columns.Count - 1 do
  begin
    C:=TRxColumn(Columns[i]);
    if C.SortOrder <> smNone then
    begin
      if FSortColumns.Count <> 0 then
      begin
        for j:=0 to FSortColumns.Count-1 do
          if FSortColumns[j].FSortPosition > C.FSortPosition then
          begin
            FSortColumns.Insert(j, C);
            C:=nil;
            Break;
          end;
      end;
      if C<>nil then
        FSortColumns.Add(C);
    end;
  end;

  for i:=0 to FSortColumns.Count - 1 do
    FSortColumns[i].FSortPosition:=i;
end;

procedure TRxDBGrid.CollumnSortListClear;
var
  i:integer;
begin
  FSortColumns.Clear;
  for i:=0 to Columns.Count - 1 do
  begin
    TRxColumn(Columns[i]).FSortOrder:=smNone;
    TRxColumn(Columns[i]).FSortPosition:=0;
  end;
end;

procedure TRxDBGrid.CollumnSortListApply;
var
  i:integer;
  S:string;
  Asc:array of boolean;
begin
  if (FSortColumns.Count = 0) then exit;
  S:='';
  FSortingNow:=true;
  if (FSortColumns.Count>1) or (Pos(';', FSortColumns[0].GetSortFields)>0) then
  begin
    SetLength(Asc, FSortColumns.Count);
    for i := 0 to FSortColumns.Count - 1 do
    begin
      Asc[i]:=FSortColumns[i].FSortOrder = smUp;
      if S<>'' then
          S:=S+';';
      S:=S + FSortColumns[i].GetSortFields;
    end;
    { TODO : Необходимо добавить опцию регистронезависимого поиска }
    FSortEngine.SortList(S, DataSource.DataSet, Asc, SortEngineOptions);
  end
  else
    FSortEngine.Sort(FSortColumns[0].GetSortFields, DataSource.DataSet, FSortColumns[0].FSortOrder = smUp, SortEngineOptions);
  FSortingNow:=false;
end;

procedure TRxDBGrid.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Assigned(Datalink) and (AComponent = DataSource) and (Operation = opRemove) then
  begin
    ShowMessage('i');
  end
  else
  if (Operation = opRemove) and (AComponent is TRxDBGridAbstractTools) then
    RemoveTools(TRxDBGridAbstractTools(AComponent));
end;

function TRxDBGrid.UpdateRowsHeight: integer;
var
  i, J, H, H1, H2:integer;
  F:TField;
  S:string;
  CurActiveRecord: Integer;
  R:TRxColumn;
  P: PtrInt;

begin
  Result:=0;
  if (not (Assigned(DataLink) and DataLink.Active)) or ((GCache.VisibleGrid.Top=0) and (GCache.VisibleGrid.Bottom=0)) then
    exit;

  CurActiveRecord:=DataLink.ActiveRecord;
  H2:=0;

  for i:=GCache.VisibleGrid.Top to GCache.VisibleGrid.Bottom do
  begin
    DataLink.ActiveRecord:=i - FixedRows;
    P:=PtrInt(DataSource.DataSet.ActiveBuffer);
    H:=1;
    for j:=0 to Columns.Count-1 do
    begin
      R:=Columns[j] as TRxColumn;;
      if R.WordWrap then
      begin
        F:=R.Field;
        if Assigned(F) then
          S:=F.DisplayText
        else
          S:='';

        H1 := Max((Canvas.TextWidth(S) + 2) div R.Width + 1, H);
        if H1 > WordCount(S, [' ']) then
          H1 := WordCount(S, [' ']);
      end
      else
        H1:=1;
      H:=Max(H, H1);
    end;

    if FGroupItems.Active and DatalinkActive then
      if Assigned(FGroupItems.FindGroupItem(DataSource.DataSet.Bookmark)) then
        Inc(H);


    if i<RowCount then
    begin
      if Assigned(FOnCalcRowHeight) then
        FOnCalcRowHeight(Self, H);
      RowHeights[i] := GetDefaultRowHeight * H;
      H2:=H2 + RowHeights[i];
      if H2<=ClientHeight  then
        Inc(Result);
    end;
  end;
  DataLink.ActiveRecord:=CurActiveRecord;
end;

procedure TRxDBGrid.ResetRowHeght;
var
  i:integer;
begin
  for i:=1 to RowCount-1 do
    RowHeights[i] := GetDefaultRowHeight;
end;

procedure TRxDBGrid.DoClearInvalidTitle;
var
  i, j:integer;
  FTitle:TRxColumnTitle;
begin
  for i:=0 to Columns.Count-1 do
  begin
    FTitle:=TRxColumnTitle(Columns[i].Title);
    for j:=0 to FTitle.CaptionLinesCount-1 do
      FTitle.CaptionLine(j).FInvalidDraw:=0;
  end;
end;

procedure TRxDBGrid.DoDrawInvalidTitle;
var
  i, j:integer;
  MLI:TMLCaptionItem;
  FTitle:TRxColumnTitle;
begin
  for i:=0 to Columns.Count-1 do
  begin
    FTitle:=TRxColumnTitle(Columns[i].Title);
    for j:=0 to FTitle.CaptionLinesCount - 1 do
    begin
      MLI:=FTitle.CaptionLine(j);
      if MLI.FInvalidDraw<0 then
      begin
        exit;
      end;
    end;
  end;
end;

procedure TRxDBGrid.DoSetColEdtBtn;
var
  R:TRxColumn;
  i, w:integer;
  SB:TGraphicControl;
begin
  R:=SelectedColumn as TRxColumn;

  if Assigned(Editor) and Assigned(R) then
  begin
    W:=0;
    for i:=0 to R.EditButtons.Count-1 do
    begin
      if R.EditButtons[i].Visible and R.EditButtons[i].Enabled then
        W:=W+R.EditButtons[i].Width;
    end;

    if W>0 then
    begin
      if Editor.Name = 'ButtonEditor' then
      begin
        Editor.Left:=Editor.Left - W;
        W:=Editor.Width + Editor.Left;
      end
      else
      begin
        Editor.Width:=Editor.Width - W;
        W:=Editor.Width + Editor.Left;
      end;

      for i:=0 to R.EditButtons.Count-1 do
      if R.EditButtons[i].Visible and R.EditButtons[i].Enabled then
      begin
        if R.EditButtons[i].Style = ebsUpDownRx then
        begin
          SB:=R.EditButtons[i].FSpinBtn;
          TRxSpinButton(SB).FocusControl:=Editor;
        end
        else
          SB:=R.EditButtons[i].FButton;

        SB.Parent:=Self;
        SB.Left:=W;
        SB.Top:=Editor.Top;
        SB.Height:=Editor.Height;
        SB.Visible:=true;

        W:=W+R.EditButtons[i].Width;
      end;
    end;
  end;
end;

procedure TRxDBGrid.AddTools(ATools: TRxDBGridAbstractTools);
var
  i:integer;
  R: TMenuItem;
begin
  if not Assigned(ATools) then Exit;

  for i:=8 to F_PopupMenu.Items.Count - 1 do
    if F_PopupMenu.Items[i].Tag = IntPtr(ATools) then
      exit;

  R := TMenuItem.Create(F_PopupMenu);
  F_PopupMenu.Items.Add(R);
  R.Caption := ATools.FCaption;
  R.OnClick := @(ATools.ExecTools);
  R.Tag:=IntPtr(ATools);
  R.Enabled:=ATools.Enabled;

  if Assigned(FToolsList) and (FToolsList.IndexOf(ATools)<0) then
    FToolsList.Add(ATools);
end;

procedure TRxDBGrid.RemoveTools(ATools: TRxDBGridAbstractTools);
var
  i:integer;
  R: TMenuItem;
begin
  for i:=8 to F_PopupMenu.Items.Count - 1 do
    if F_PopupMenu.Items[i].Tag = IntPtr(ATools) then
    begin
      R:=F_PopupMenu.Items[i];
      F_PopupMenu.Items.Delete(i);
      R.Free;
      exit;
    end;

  if Assigned(FToolsList) then
    FToolsList.Remove(ATools);
end;

procedure TRxDBGrid.UpdateToolsState(ATools: TRxDBGridAbstractTools);
var
  i: Integer;
begin
  if not Assigned(ATools) then Exit;
  for i:=8 to F_PopupMenu.Items.Count - 1 do
    if F_PopupMenu.Items[i].Tag = IntPtr(ATools) then
    begin
      F_PopupMenu.Items[i].Enabled:=ATools.Enabled;
      exit;
    end;
end;

procedure TRxDBGrid.OnDataSetScrolled(aDataSet: TDataSet; Distance: Integer);
begin
  if Assigned(FSaveOnDataSetScrolled) then
    FSaveOnDataSetScrolled(aDataSet, Distance);

  if (rdgWordWrap in FOptionsRx) or (FGroupItems.Active) then
    UpdateRowsHeight;
end;

function TRxDBGrid.GetFieldDisplayText(AField: TField; ACollumn: TRxColumn
  ): string;
var
  J: Integer;
begin
  Result:='';
  if Assigned(AField) then
  begin
    if AField.dataType <> ftBlob then
    begin
      {$IF lcl_fullversion >= 1090000}
      if CheckDisplayMemo(AField) then
        Result := AField.AsString
      else
      {$ENDIF}
        Result := AField.DisplayText;
      if Assigned(ACollumn) and (ACollumn.KeyList.Count > 0) and (ACollumn.PickList.Count > 0) then
      begin
        J := ACollumn.KeyList.IndexOf(Result);
        if (J >= 0) and (J < ACollumn.PickList.Count) then
          Result := ACollumn.PickList[j];
      end;
    end
    else
      Result := FColumnDefValues.FBlobText;
  end
end;

procedure TRxDBGrid.FillFilterData;
var
  i: Integer;
  C: TRxColumn;
  FBS, FAS: TDataSetNotifyEvent;
begin
  for i := 0 to Columns.Count - 1 do
  begin
    C := TRxColumn(Columns[i]);
    C.Filter.ValueList.Clear;
    C.Filter.CurrentValues.Clear;
    C.Filter.ManulEditValue:='';
    C.Filter.ItemIndex := -1;
    C.Filter.ValueList.Add(C.Filter.EmptyValue);
    C.Filter.ValueList.Add(C.Filter.AllValue);
  end;

  if DatalinkActive then
  begin
    DataSource.DataSet.DisableControls;
    DataSource.DataSet.Filtered := True;
    FBS:=DataSource.DataSet.BeforeScroll;
    FAS:=DataSource.DataSet.AfterScroll;
    DataSource.DataSet.BeforeScroll:=nil;
    DataSource.DataSet.AfterScroll:=nil;
    DataSource.DataSet.First;
    while not DataSource.DataSet.EOF do
    begin
      for i := 0 to Columns.Count - 1 do
      begin
        C := TRxColumn(Columns[i]);
        if C.Filter.Enabled and (C.Field <> nil) and (C.Filter.ValueList.IndexOf(C.Field.DisplayText) < 0) then
          C.Filter.ValueList.Add(C.Field.DisplayText);
      end;
      DataSource.DataSet.Next;
    end;
    DataSource.DataSet.First;
    DataSource.DataSet.BeforeScroll:=FBS;
    DataSource.DataSet.AfterScroll:=FAS;
    DataSource.DataSet.EnableControls;
  end;
end;

procedure TRxDBGrid.DefaultDrawCellA(aCol, aRow: integer; aRect: TRect;
  aState: TGridDrawState);
begin
  PrepareCanvas(aCol, aRow, aState);
  if rdgFilter in OptionsRx then
  begin
    DefaultDrawFilter(aCol, aRow, getFilterRect(aRect), aState);
    DefaultDrawTitle(aCol, aRow, getTitleRect(aRect), aState);
  end
  else
    DefaultDrawTitle(aCol, aRow, aRect, aState);
end;

procedure TRxDBGrid.DefaultDrawTitle(aCol, aRow: integer; aRect: TRect;
  aState: TGridDrawState);

procedure DoClearMLIInvalid(MLI1: TMLCaptionItem);
begin
  while Assigned(MLI1) do
  begin
    inc(MLI1.FInvalidDraw);
    MLI1:=MLI1.Next;
  end;
end;

var
  ASortMarker: TSortMarker;
  ASortPosition: integer;

  Background: TColor;
  i: integer;
  Down: boolean;
  aRect2: TRect;

  FTitle: TRxColumnTitle;
  GrdCol: TRxColumn;

  MLI : TMLCaptionItem;

begin
  if (dgIndicator in Options) and (aCol = 0) then
  begin
    Canvas.FillRect(aRect);
    if F_Clicked then
      aState := aState + [gdPushed];

    if (TitleStyle = tsNative) then
      DrawThemedCell(aCol, aRow, aRect, aState)
    else
      DrawCellGrid(aCol, aRow, aRect, aState);

    if DatalinkActive and (rdgAllowToolMenu in FOptionsRx) then
      Canvas.Draw((ARect.Left + ARect.Right - F_MenuBMP.Width) div 2,
        (ARect.Top + ARect.Bottom - F_MenuBMP.Height) div 2, F_MenuBMP);
    exit;
  end;

  GrdCol := TRxColumn(ColumnFromGridColumn(aCol));

  Down := FPressed and (dgHeaderPushedLook in Options) and
    (FPressedCol = GrdCol);

  if Assigned(GrdCol) then
  begin
    ASortMarker := GrdCol.FSortOrder;
    if FSortColumns.Count>1 then
      ASortPosition:=GrdCol.FSortPosition
    else
      ASortPosition:=-1;
  end
  else
    ASortMarker := smNone;

  if Assigned(FOnGetBtnParams) and Assigned(GetFieldFromGridColumn(aCol)) then
  begin
    Background := Canvas.Brush.Color;
    FOnGetBtnParams(Self, GetFieldFromGridColumn(aCol), Canvas.Font,
      Background, ASortMarker, Down);
    Canvas.Brush.Color := Background;
  end;

  if (gdFixed in aState) and (aRow = 0) and (ACol >= FixedCols) then
  begin

    //GrdCol := ColumnFromGridColumn(aCol);
    if Assigned(GrdCol) then
      FTitle := TRxColumnTitle(GrdCol.Title)
    else
      FTitle := nil;

    if Assigned(FTitle) then
    begin
      if FTitle.Orientation <> toHorizontal then
      begin
        OutCaptionCellText90(aCol, aRow, aRect, aState, FTitle.Caption,
          FTitle.Orientation);
        if Down then
          aState := aState + [gdPushed];
      end
      else
      if (FTitle.CaptionLinesCount > 0) then
      begin
        aRect2.Left := aRect.Left;
        aRect2.Right := aRect.Right;
        aRect2.Top := aRect.Top;
        for i := 0 to FTitle.CaptionLinesCount - 1 do
        begin
          MLI := FTitle.CaptionLine(i);
          aRect2.Right := aRect.Right;

          if i = FTitle.CaptionLinesCount - 1 then
          begin
            aRect2.Bottom := aRect.Bottom;
            aRect.Top := ARect2.Top;
            if Down then
              aState := aState + [gdPushed]
            else
              aState := aState - [gdPushed]
              ;
          end
          else
          begin
            aRect2.Bottom := aRect2.Top + MLI.Height * GetDefaultRowHeight;
            aState := aState - [gdPushed];
          end;


          if Assigned(MLI.Next) then
          begin
            if Assigned(MLI.Prior) then
            begin
              if aCol = LeftCol then
              begin
                OutCaptionMLCellText(aCol, aRow, aRect2, aState, MLI);
                DoClearMLIInvalid(MLI);
              end
              else
                Dec(MLI.FInvalidDraw);
            end
            else
            begin
              OutCaptionMLCellText(aCol, aRow, aRect2, aState, MLI);
              DoClearMLIInvalid(MLI);
            end;
          end
          else
          begin
            if not Assigned(MLI.Prior) then
            begin
              OutCaptionCellText(aCol, aRow, aRect2, aState, MLI.Caption);
              DoClearMLIInvalid(MLI);
            end
            else
            begin
              if aCol = LeftCol then
              begin
                OutCaptionMLCellText(aCol, aRow, aRect2, aState, MLI);
                DoClearMLIInvalid(MLI);
              end
              else
                Dec(MLI.FInvalidDraw);
            end;
          end;
          aRect2.Top := aRect2.Bottom;
        end;
      end
      else
      begin
        if Down then
          aState := aState + [gdPushed];
        OutCaptionCellText(aCol, aRow, aRect, aState, FTitle.Caption);
      end;
    end
    else
    begin
      OutCaptionCellText(aCol, aRow, aRect, aState, GetDefaultColumnTitle(aCol));
    end;

    OutCaptionSortMarker(aRect, ASortMarker, ASortPosition+1);
  end
  else
  begin
    if Down then
      aState := aState + [gdPushed];
    OutCaptionCellText(aCol, aRow, aRect, aState, '');
  end;
end;

procedure TRxDBGrid.DefaultDrawFilter(aCol, aRow: integer; aRect: TRect;
  aState: TGridDrawState);
var
  bg: TColor;
  al: TAlignment;
  ft: TFont;
  MyCol: integer;
  TxS: TTextStyle;
  S: String;

begin
  if (dgIndicator in Options) and (aCol = 0) then
  begin
    if (TitleStyle = tsNative) then
      DrawThemedCell(aCol, aRow, aRect, aState)
    else
    begin
      Canvas.FillRect(aRect);
      DrawCellGrid(aCol, aRow, aRect, aState);
    end;
    exit;
  end;

  if (TitleStyle = tsNative) then
    DrawThemedCell(aCol, aRow, aRect, aState)
  else
  begin
    Canvas.FillRect(aRect);
    DrawCellGrid(aCol, aRow, aRect, aState);
  end;

  Inc(aRect.Left, 1);
  Dec(aRect.Right, 1);
  Inc(aRect.Top, 1);
  Dec(aRect.Bottom, 1);

  if Columns.Count > (aCol - ord(dgIndicator in Options)) then
  begin
    bg := Canvas.Brush.Color;
    al := Canvas.TextStyle.Alignment;
//    ft := Canvas.Font;
    ft:=TFont.Create;
    ft.Assign(Canvas.Font);
    TxS := Canvas.TextStyle;

    MyCol := Columns.RealIndex(aCol - ord(dgIndicator in Options));
    with TRxColumn(Columns[MyCol]).Filter do
    begin
      if (TitleStyle <> tsNative) then
      begin
        Canvas.Brush.Color := Color;
        Canvas.FillRect(aRect);
      end;

      S:=DisplayFilterValue;
      if (aRect.Right - aRect.Left) >= Canvas.TextWidth(S) then
        TxS.Alignment := Alignment
      else
        TxS.Alignment := taLeftJustify;
      Canvas.TextStyle := TxS;

      if State in [rxfsEmpty, rxfsNonEmpty] then
        Canvas.Font := TRxColumn(Columns[MyCol]).Filter.EmptyFont;

      DrawCellText(aCol, aRow, aRect, aState, S);
(*
      if CurrentValues.Count > 0 then
      begin
        S:=CurrentValues[0];
        if CurrentValues.Count > 1 then
          S:=S + '(...)';
        Canvas.Font := Font;
        if (aRect.Right - aRect.Left) >= Canvas.TextWidth(S) then
          TxS.Alignment := Alignment
        else
          TxS.Alignment := taLeftJustify;
        Canvas.TextStyle := TxS;
        DrawCellText(aCol, aRow, aRect, aState, S);
      end
      else
      begin
        if (Style in (rxfstManualEdit, rxfstBoth)) and (ManulEditValue<>'') then
          S:=ManulEditValue
        else
        if State = rxfsEmpty then
          S:=Filter.EmptyValue
        else
        if State = rxfsNonEmpty then
          S:=Filter.NotEmptyValue
        else
        if State = rxfsAll then
          S:=Filter.AllValue
        else
          S:='';

        Canvas.Font := TRxColumn(Columns[MyCol]).Filter.EmptyFont;
        if (aRect.Right - aRect.Left) >= Canvas.TextWidth(S) then
          TxS.Alignment := Alignment
        else
          TxS.Alignment := taLeftJustify;

        Canvas.TextStyle := TxS;
        DrawCellText(aCol, aRow, aRect, aState, S)
      end; *)
    end;

//    Canvas.Font := ft;
    Canvas.Font.Assign(ft);
    ft.Free;
    Canvas.Brush.Color := bg;
    //    Canvas.TextStyle.Alignment := al;
    TxS.Alignment := al;
    Canvas.TextStyle := TxS;
  end
  else
  begin
    bg := Canvas.Brush.Color;
    Canvas.Brush.Color := Color;
    Canvas.FillRect(aRect);
    Canvas.Brush.Color := bg;
  end;
end;

procedure TRxDBGrid.DefaultDrawCellData(aCol, aRow: integer; aRect: TRect;
  aState: TGridDrawState);
var
  S: string;
  F: TField;
  C: TRxColumn;
  j, DataCol, L, R: integer;
  FIsMerged: Boolean;

function CheckBoxHeight(const aState: TCheckboxState):integer;
const
  arrtb:array[TCheckboxState] of TThemedButton = (tbCheckBoxUncheckedNormal, tbCheckBoxCheckedNormal, tbCheckBoxMixedNormal);
var
  Details: TThemedElementDetails;
  CSize: TSize;
  ChkBitmap: TBitmap;
begin
  if (TitleStyle=tsNative) and not assigned(OnUserCheckboxBitmap) then
  begin
    Details := ThemeServices.GetElementDetails(arrtb[AState]);
    CSize := ThemeServices.GetDetailSize(Details);
    //CSize.cx := MulDiv(CSize.cx, Font.PixelsPerInch, Screen.PixelsPerInch);
    Result := MulDiv(CSize.cy, Font.PixelsPerInch, Screen.PixelsPerInch);
  end
  else
  begin
    ChkBitmap := GetImageForCheckBox(aCol, aRow, AState);
    if ChkBitmap<>nil then
      Result:=ChkBitmap.Height
    else
      Result:=DefaultRowHeight;
  end;
end;

begin
  FIsMerged:=false;

  C:=nil;
  F:=nil;

  if rdgColSpanning in OptionsRx then
    if IsMerged(aCol, L, R, C) then
    begin
      aCol:=L;
      FIsMerged:=true;
    end;

  if Assigned(OnDrawColumnCell) and not (CsDesigning in ComponentState) then
  begin
    DataCol := ColumnIndexFromGridColumn(aCol);
    if not Assigned(C) then
      C:=TRxColumn(ColumnFromGridColumn(aCol));
    OnDrawColumnCell(Self, aRect, DataCol, C, aState)
  end
  else
  begin


    if not Assigned(C) then
      C := ColumnFromGridColumn(aCol) as TRxColumn;
    if Assigned(C) then
      F:=C.Field;

    if Assigned(C) and Assigned(C.FOnDrawColumnCell) then
      C.OnDrawColumnCell(Self, aRect, aCol, TColumn(ColumnFromGridColumn(aCol)), aState)
    else
    begin
      case ColumnEditorStyle(aCol, F) of
        cbsCheckBoxColumn:begin
          if C.Layout = tlTop then
            aRect.Bottom:=aRect.Top + CheckBoxHeight(cbChecked) + varCellPadding + 1
          else
          if C.Layout = tlBottom then
            aRect.Top:=aRect.Bottom - CheckBoxHeight(cbChecked) - varCellPadding - 1;
          DrawCheckBoxBitmaps(aCol, aRect, F);
        end
      else
        S:=GetFieldDisplayText(F, C);
        if ((rdgWordWrap in FOptionsRx) and Assigned(C) and (C.WordWrap)) or (FIsMerged) then
          WriteTextHeader(Canvas, aRect, S, C.Alignment)
        else
          DrawCellText(aCol, aRow, aRect, aState, S);
      end;
    end;
  end;
end;

procedure TRxDBGrid.DrawCell(aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
var
  RxColumn, C: TRxColumn;
  AImageIndex: integer;
  FBackground: TColor;
  gRect: TRect;
begin
  if (gdFixed in aState) and (aRow = 0) then
  begin
    DefaultDrawCellA(aCol, aRow, aRect, aState);
  end
  else
  if not ((gdFixed in aState) or ((aCol = 0) and (dgIndicator in Options)) or
    ((aRow = 0) and (dgTitles in Options))) then
  begin

    if rdgColSpanning in OptionsRx then
      CalcCellExtent(acol, arow, aRect);

    PrepareCanvas(aCol, aRow, aState);

    if FGroupItems.Active and  Assigned(FGroupItemDrawCur) then
    begin
      gRect:=aRect;
      aRect.Bottom:=aRect.Bottom - DefaultRowHeight - 1;
      gRect.Top:=aRect.Bottom;
      gRect.Bottom:=gRect.Bottom - 2;
    end;

    if Assigned(FOnGetCellProps) and not (gdSelected in aState) then
    begin
      FBackground := Canvas.Brush.Color;
      FOnGetCellProps(Self, GetFieldFromGridColumn(aCol), Canvas.Font, FBackground);
      Canvas.Brush.Color := FBackground;
    end;
    Canvas.FillRect(aRect);

    DrawCellGrid(aCol, aRow, aRect, aState);

    RxColumn := TRxColumn(ColumnFromGridColumn(aCol));
    if Assigned(RxColumn) and Assigned(RxColumn.Field) and
      Assigned(RxColumn.ImageList) then
    begin
      AImageIndex := StrToIntDef(RxColumn.KeyList.Values[RxColumn.Field.AsString],
        RxColumn.NotInKeyListIndex);
      if (AImageIndex > -1) and (AImageIndex < RxColumn.ImageList.Count) then
        DrawCellBitmap(RxColumn, aRect, aState, AImageIndex);
    end
    else
      DefaultDrawCellData(aCol, aRow, aRect, aState)
      ;

    if FGroupItems.Active and  Assigned(FGroupItemDrawCur) then
    begin
      C := ColumnFromGridColumn(aCol) as TRxColumn;

      if C.FGroupParam.Color <> clNone then
        Canvas.Brush.Color := C.FGroupParam.Color
      else
      if FGroupItems.Color <> clNone then
        Canvas.Brush.Color := FGroupItems.Color
      else
        Canvas.Brush.Color := Color;

      Canvas.Font.Color:=Font.Color;

      Canvas.FillRect(gRect);

      if C.FGroupParam.FValueType <> fvtNon then
        WriteTextHeader(Canvas, gRect, C.FGroupParam.DisplayText, C.FGroupParam.Alignment);
    end;

  end
  else
    inherited DrawCell(aCol, aRow, aRect, aState);
end;

procedure TRxDBGrid.LinkActive(Value: Boolean);
var
  S: string;
  Pos: integer;
begin
  if Value then
  begin
    S := DataSource.DataSet.ClassName;
    if RxDBGridSortEngineList.Find(S, Pos) then
      FSortEngine := RxDBGridSortEngineList.Objects[Pos] as TRxDBGridSortEngine
    else
      FSortEngine := nil;
  end;

  inherited LinkActive(Value);
  if not Value then
  begin
    FSortEngine := nil;
    if SelectedRows.Count > 0 then
      SelectedRows.Clear;
  end;

  if not FSortingNow then
    CollumnSortListClear;
  if not (csDesigning in ComponentState) then
    SetDBHandlers(Value);
end;

procedure TRxDBGrid.SetDBHandlers(Value: boolean);
begin
   if Value then
  begin
    if DataSource.DataSet.OnFilterRecord <> @FilterRec then
    begin
      F_EventOnFilterRec := DataSource.DataSet.OnFilterRecord;
      DataSource.DataSet.OnFilterRecord := @FilterRec;
    end;
    if DataSource.DataSet.BeforeDelete <> @BeforeDel then
    begin
      F_EventOnBeforeDelete := DataSource.DataSet.BeforeDelete;
      DataSource.DataSet.BeforeDelete := @BeforeDel;
    end;
    if DataSource.DataSet.BeforePost <> @BeforePo then
    begin
      F_EventOnBeforePost := DataSource.DataSet.BeforePost;
      DataSource.DataSet.BeforePost := @BeforePo;
    end;
    if DataSource.DataSet.OnDeleteError <> @ErrorDel then
    begin
      F_EventOnDeleteError := DataSource.DataSet.OnDeleteError;
      DataSource.DataSet.OnDeleteError := @ErrorDel;
    end;
    if DataSource.DataSet.OnPostError <> @ErrorPo then
    begin
      F_EventOnPostError := DataSource.DataSet.OnPostError;
      DataSource.DataSet.OnPostError := @ErrorPo;
    end;
    CalcStatTotals;
    if rdgFilter in OptionsRx then
    begin
      FillFilterData;
      //OnFilter(nil);
    end;
  end
  else
  begin
    if Assigned(DataSource) and Assigned(DataSource.DataSet) then
    begin
      DataSource.DataSet.OnFilterRecord := F_EventOnFilterRec;
      F_EventOnFilterRec := nil;
      DataSource.DataSet.BeforeDelete := F_EventOnBeforeDelete;
      F_EventOnBeforeDelete := nil;
      DataSource.DataSet.BeforePost := F_EventOnBeforePost;
      F_EventOnBeforePost := nil;
      DataSource.DataSet.OnDeleteError := F_EventOnDeleteError;
      F_EventOnDeleteError := nil;
      DataSource.DataSet.OnPostError := F_EventOnPostError;
      F_EventOnPostError := nil;
      if rdgFilter in OptionsRx then
      begin
        FillFilterData;
        //OnFilter(nil);
      end;
    end;
    F_LastFilter.Clear;
  end;
end;

procedure TRxDBGrid.DrawRow(ARow: Integer);
var
  P: TBookMark;
begin
  FGroupItemDrawCur:=nil;
  if FGroupItems.Active and DatalinkActive then
  begin
    if (ARow>=FixedRows) then
    begin
      DataLink.ActiveRecord:=ARow-FixedRows;
      P:=DataSource.DataSet.Bookmark;
      FGroupItemDrawCur:=FGroupItems.FindGroupItem(P);
    end;
  end;
  inherited DrawRow(ARow);
end;

procedure TRxDBGrid.DrawFocusRect(aCol, aRow: Integer; ARect: TRect);
begin
    CalcCellExtent(acol, arow, aRect);
    CalcCellExtent(ACol, ARow, ARect);

  if FGroupItems.Active and Assigned(FGroupItemDrawCur) then
    ARect.Bottom:=ARect.Bottom - DefaultRowHeight;
  inherited DrawFocusRect(aCol, aRow, ARect);
end;

procedure TRxDBGrid.DrawFooterRows;
var
  FooterRect: TRect;
  R: TRect;
  TotalYOffs: integer;
  TotalWidth: integer;
  i: integer;
  C: TRxColumn;
  Background: TColor;
  ClipArea: Trect;
  TxS: TTextStyle;
  j: Integer;
  FItem: TRxColumnFooterItem;
//FreeMan35 added
  AText: String;
  ABrush: TBrush;
begin
  TotalWidth := GCache.ClientWidth;
  //TotalYOffs := GCache.ClientHeight {- (GetDefaultRowHeight * FFooterOptions.RowCount)};
  TotalYOffs := GCache.ClientRect.Bottom {- (GetDefaultRowHeight * FFooterOptions.RowCount)};

  FooterRect := Rect(0, TotalYOffs, TotalWidth, TotalYOffs + GetDefaultRowHeight * FFooterOptions.RowCount);

  Background := Canvas.Brush.Color;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(FooterRect);

  R.Top := TotalYOffs;
  R.Bottom := TotalYOffs + GetDefaultRowHeight * FFooterOptions.RowCount;

  Canvas.Brush.Color := FFooterOptions.FColor;
  if (Columns.Count > 0) then
  begin
    TxS := Canvas.TextStyle;

    if FFooterOptions.FDrawFullLine then
    begin
      ColRowToOffset(True, True, 0, R.Left, R.Right);
      Canvas.Pen.Color := GridLineColor;
      Canvas.MoveTo(R.Right - 1, R.Top);
      Canvas.LineTo(R.Right - 1, RowHeights[0]);
    end;

    ABrush := nil;//initialize, no need create everytime.

    R.Top := TotalYOffs;
    R.Bottom := TotalYOffs + GetDefaultRowHeight;

    for j:=0 to FFooterOptions.RowCount-1 do
    begin

      for i := GCache.VisibleGrid.Left to GCache.VisibleGrid.Right do
      begin
        ColRowToOffset(True, True, i, R.Left, R.Right);

        if FFooterOptions.FDrawFullLine then
        begin
          Canvas.MoveTo(R.Right - 1, R.Top);
          Canvas.LineTo(R.Right - 1, RowHeights[0]);
        end;

        C := ColumnFromGridColumn(i) as TRxColumn;
        if Assigned(C) then
        begin
          FItem:=nil;
          if (J = 0) then
          begin
            if (C.Footers.Count = 0) then
              FItem:=C.Footer
            else
              FItem:=C.Footers[0];
          end
          else
          if J <= C.Footers.Count-1 then
            FItem:=C.Footers[j];

          if Assigned(FItem) then
          begin
            TxS.Alignment := FItem.Alignment;
            TxS.Layout := FItem.Layout;
            Canvas.TextStyle := TxS;
            if not FItem.IsDefaultFont then
              Canvas.Font:=FItem.Font
            else
              Canvas.Font:=Font;

            if FItem.Color <> clNone then
              Canvas.Brush.Color:=FItem.Color
            else
              Canvas.Brush.Color:=FFooterOptions.FColor;

            if not Assigned(OnRxColumnFooterDraw) then
            begin
              Canvas.FillRect(R);
              DrawCellGrid(i, 0, R, []);
              DrawCellText(i, 0, R, [], FItem.DisplayText);
            end
            else
            begin
              if not Assigned(ABrush)then
                ABrush := TBrush.Create;
              ABrush.Assign(Canvas.Brush);//Backup Brush info
              AText := FItem.DisplayText;
              OnRxColumnFooterDraw(Self, Canvas.Brush, Canvas.Font, R, C, AText);
              Canvas.FillRect(R);//need repaint cell
              DrawCellGrid(i, 0, R, []);//need reDraw cell
              DrawCellText(i, 0, R, [], AText);
              Canvas.Brush.Assign(ABrush);//Restore Brush info
            end;
          end
          else
          begin
            Canvas.FillRect(R);
            DrawCellGrid(i, 0, R, []);
          end;
        end
        else
        begin
          Canvas.FillRect(R);
          DrawCellGrid(i, 0, R, []);
        end;//Assigned(C)
      end;

      R.Top := R.Bottom;
      R.Bottom := R.Bottom + GetDefaultRowHeight;
    end;

    if assigned(ABrush)then FreeAndNil(ABrush);

    if FFooterOptions.FDrawFullLine then
    begin
      Canvas.MoveTo(FooterRect.Left, FooterRect.Top);
      Canvas.LineTo(R.Right, FooterRect.Top);
    end;

    ClipArea := Canvas.ClipRect;
    for i := 0 to FixedCols - 1 do
    begin
      ColRowToOffset(True, True, i, R.Left, R.Right);
      if FFooterOptions.FStyle = tsNative then
        DrawThemedCell(i, 0, R, [gdFixed])
      else
        DrawCellGrid(i, 0, R, [gdFixed]);

      if ((R.Left < ClipArea.Right) and (R.Right > ClipArea.Left)) then
        DefaultDrawTitle(i, 0, getTitleRect(R), [gdFixed]);
    end;
  end;
  Canvas.Brush.Color := Background;
end;

procedure TRxDBGrid.DoTitleClick(ACol: longint; ACollumn: TRxColumn;
  Shift: TShiftState);
begin
  if FAutoSort and (ACollumn.Field <> nil) then
  begin
    if ssCtrl in Shift then
    begin
      if ACollumn.FSortOrder <> smNone then
      begin
        if ACollumn.FSortOrder = smUp then
          ACollumn.FSortOrder := smDown
        else
        begin
          ACollumn.FSortOrder := smNone;
          ACollumn.FSortPosition:=0;
        end;
      end
      else
      begin
        ACollumn.FSortOrder := smUp;
        ACollumn.FSortPosition:=FSortColumns.Count;
      end;
    end
    else
    begin
      if (FSortColumns.Count>0) and (FSortColumns[0] = ACollumn) then
      begin
        if Assigned(FSortEngine) then
        begin
          if FSortColumns[0].FSortOrder = smUp then
            FSortColumns[0].FSortOrder := smDown
          else
            FSortColumns[0].FSortOrder := smUp;
        end
        else
        begin
          case ACollumn.FSortOrder of
            smNone: ACollumn.FSortOrder := smUp;
            smUp: ACollumn.FSortOrder := smDown;
            smDown: ACollumn.FSortOrder := smNone;
          end;
        end;
      end
      else
      begin
        CollumnSortListClear;
        ACollumn.FSortOrder := smUp;
      end;
    end;

    CollumnSortListUpdate;
    if Assigned(FSortEngine) then
      CollumnSortListApply;
    if Assigned(FOnSortChanged) then
    begin
      FSortingNow := True;
      FOnSortChanged(Self);
      FSortingNow := False;
    end;
  end
  else
    HeaderClick(True, ACol);
end;

procedure TRxDBGrid.MouseMove(Shift: TShiftState; X, Y: integer);
var
  Cell: TGridCoord;
  Rect: TRect;
begin
  if FTracking then
    TrackButton(X, Y);
  inherited MouseMove(Shift, X, Y);

  if (rdgFilter in OptionsRx) and (dgColumnResize in Options) and
    (Cursor = crHSplit) then
  begin
    Cell := MouseCoord(X, Y);
    Rect := getFilterRect(CellRect(Cell.x, Cell.y));
    if (Cell.Y = 0) and (Cell.X >= Ord(dgIndicator in Options)) and (Rect.Top < Y) then
    begin
      Cursor := crDefault;
    end;
  end;

  if FColumnResizing and (MouseToGridZone(X, Y) = gzFixedCols) then
  begin
    CalcTitle;
    if FFooterOptions.Active and (dgColumnResize in Options) and (FFooterOptions.RowCount > 0) then
      DrawFooterRows;
  end;
end;

procedure TRxDBGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  Cell: TGridCoord;
  Rect: TRect;
  C:TRxColumn;
  i: Integer;
begin
  QuickUTF8Search := '';

  Cell := MouseCoord(X, Y);

  if FFilterColDlgButton.Visible then
    FFilterColDlgButton.Hide;

  if (DatalinkActive) and (DataSource.DataSet.State = dsBrowse) and
    (Button = mbLeft) and (Cell.X = 0) and (Cell.Y = 0) and
    (dgIndicator in Options) and (rdgAllowToolMenu in FOptionsRx) then
  begin
    F_Clicked := True;
    InvalidateCell(0, 0);
  end
  else
  if (Cell.Y = 0) and (Cell.X >= Ord(dgIndicator in Options)) then
  begin
    if (rdgFilter in OptionsRx) and DatalinkActive then
    begin
      Cell := MouseCoord(X, Y);
      Rect := getFilterRect(CellRect(Cell.x, Cell.y));
      if (Cell.Y = 0) and (Cell.X >= Ord(dgIndicator in Options)) and (Rect.Top < Y) then
      begin
        C:=TRxColumn (Columns[Columns.RealIndex(Cell.x - ord(dgIndicator in Options))]);
        if (C.Filter.Enabled) and (C.Filter.ValueList.Count > 0)  then
        begin
          if C.Filter.Style = rxfstSimple then
          begin
            if FFilterSimpleEdit.Visible then
              FFilterSimpleEdit.Hide;
            if FFilterColDlgButton.Visible then
              FFilterColDlgButton.Hide;

            FFilterListEditor.Style := csDropDownList;
            if C.Filter.DropDownRows>0 then
              FFilterListEditor.DropDownCount := C.Filter.DropDownRows;

            FFilterListEditor.Parent := Self;
            FFilterListEditor.Width := Rect.Right - Rect.Left;
            FFilterListEditor.Height := Rect.Bottom - Rect.Top;
            FFilterListEditor.BoundsRect := Rect;

            FFilterListEditor.Items.Assign(C.Filter.ValueList);

            if C.Filter.CurrentValues.Count>0 then
              FFilterListEditor.Text := C.Filter.CurrentValues[0]
            else
              FFilterListEditor.Text := '';
            FFilterListEditor.Show(Self, Cell.x - ord(dgIndicator in Options));
          end
          else
          if C.Filter.Style = rxfstManualEdit then
          begin
            if FFilterListEditor.Visible then
              FFilterListEditor.Hide;

            if FFilterColDlgButton.Visible then
              FFilterColDlgButton.Hide;

            FFilterSimpleEdit.Parent := Self;
            FFilterSimpleEdit.Width := Rect.Right - Rect.Left;
            FFilterSimpleEdit.Height := Rect.Bottom - Rect.Top;
            FFilterSimpleEdit.BoundsRect := Rect;
            FFilterSimpleEdit.Show(Self, Cell.x - ord(dgIndicator in Options));
{            if C.Filter.CurrentValues.Count>0 then
              FFilterSimpleEdit.Text := C.Filter.CurrentValues[C.Filter.CurrentValues.Count - 1]
            else}
            FFilterSimpleEdit.Text := C.Filter.ManulEditValue;
          end
          else
          if C.Filter.Style = rxfstDialog then
          begin
            if FFilterListEditor.Visible then
              FFilterListEditor.Hide;

            if FFilterSimpleEdit.Visible then
              FFilterSimpleEdit.Hide;

            FFilterColDlgButton.Parent:=Self;
            FFilterColDlgButton.Width := 32;
            FFilterColDlgButton.Height := Rect.Bottom - Rect.Top;
            FFilterColDlgButton.Top := Rect.Top;
            FFilterColDlgButton.Left := Rect.Right - FFilterColDlgButton.Width;
            FFilterColDlgButton.Show(Self, Cell.x - ord(dgIndicator in Options));
          end
          else
          if C.Filter.Style = rxfstBoth then
          begin
            if FFilterListEditor.Visible then
              FFilterListEditor.Hide;

            FFilterColDlgButton.Parent:=Self;
            FFilterColDlgButton.Width := 32;
            FFilterColDlgButton.Height := Rect.Bottom - Rect.Top;
            FFilterColDlgButton.Top := Rect.Top;
            FFilterColDlgButton.Left := Rect.Right - FFilterColDlgButton.Width;
            FFilterColDlgButton.Show(Self, Cell.x - ord(dgIndicator in Options));

            FFilterSimpleEdit.Parent := Self;
            FFilterSimpleEdit.Width := Rect.Right - Rect.Left - FFilterColDlgButton.Width;
            FFilterSimpleEdit.Height := Rect.Bottom - Rect.Top;
            Rect.Width:=Rect.Width - FFilterColDlgButton.Width;
            FFilterSimpleEdit.BoundsRect := Rect;
            FFilterSimpleEdit.Show(Self, Cell.x - ord(dgIndicator in Options));
{            if C.Filter.CurrentValues.Count>0 then
              FFilterSimpleEdit.Text := C.Filter.CurrentValues[0]
            else}
            FFilterSimpleEdit.Text := C.Filter.ManulEditValue;
          end
        end;
        exit;
      end;
    end;

    if dgColumnResize in Options then
    begin
      FColumnResizing := True;
    end;

    if FAutoSort then
    begin
      Cell := MouseCoord(X, Y);
      if (Cell.Y = 0) and (Cell.X >= Ord(dgIndicator in Options)) then
      begin
        if (dgColumnResize in Options) and (Button = mbRight) then
        begin
          Shift := Shift + [ssLeft];
          inherited MouseDown(Button, Shift, X, Y);
        end
        else
        if Button = mbLeft then
        begin
          if (MouseToGridZone(X, Y) = gzFixedCols) and
            (dgColumnResize in Options) and (Cursor = crHSplit) then
          begin
            if (ssDouble in Shift) and (rdgDblClickOptimizeColWidth in FOptionsRx) then
            begin
              if Assigned(ColumnFromGridColumn(Cell.X)) then
                TRxColumn(ColumnFromGridColumn(Cell.X)).OptimizeWidth;
            end
            else
              inherited MouseDown(Button, Shift, X, Y);
          end
          else
          begin
            MouseCapture := True;
            FTracking := True;
            FPressedCol := TRxColumn(ColumnFromGridColumn(Cell.X));
            TrackButton(X, Y);
            inherited MouseDown(Button, Shift, X, Y);
          end;
        end;
      end
      else
      begin
        inherited MouseDown(Button, Shift, X, Y);
      end;
    end
    else
    begin
      inherited MouseDown(Button, Shift, X, Y);
    end;
  end
  else
  begin
    for i:=0 to FToolsList.Count-1 do
      if (rxteMouseDown in TRxDBGridAbstractTools(FToolsList[i]).FToolsEvents) then
        if TRxDBGridAbstractTools(FToolsList[i]).MouseDown(Button, Shift, X, Y) then
          exit;

    if rdgMrOkOnDblClik in FOptionsRx then
    begin
      if (Cell.Y > 0) and (Cell.X >= Ord(dgIndicator in Options)) and
        (ssDouble in Shift) then
      begin
        if Owner is TCustomForm then
          TCustomForm(Owner).ModalResult := mrOk;
      end;
    end;
    inherited MouseDown(Button, Shift, X, Y);
  end;
end;

procedure TRxDBGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  Cell: TGridCoord;
  ACol: longint;
  DoClick: boolean;

  ShowMenu: boolean;
  MPT: TPoint;
  Rct: TRect;
begin
  ShowMenu := False;

  FColumnResizing := False;

  if (dgHeaderPushedLook in Options) and FTracking and (FPressedCol <> nil) then
  begin
    Cell := MouseCoord(X, Y);
    DoClick := PtInRect(Rect(0, 0, ClientWidth, ClientHeight), Point(X, Y)) and
      (Cell.Y < RowHeights[0]) and (FPressedCol = TRxColumn(ColumnFromGridColumn(Cell.X)));
    StopTracking;
    if DoClick then
    begin
      ACol := Cell.X;
      if (dgIndicator in Options) then
        Dec(ACol);
      if DataLinkActive and (ACol >= 0) and (ACol < Columns.Count) then
      begin
        FPressedCol := TRxColumn(ColumnFromGridColumn(Cell.X));
        if Assigned(FPressedCol) then
          DoTitleClick(FPressedCol.Index, FPressedCol, Shift);
      end;
    end;
  end
  else
  if FSwapButtons then
  begin
    FSwapButtons := False;
    MouseCapture := False;
    if Button = mbRight then
      Button := mbLeft;
  end;

  if (DatalinkActive) and (DataSource.DataSet.State = dsBrowse) and
    (rdgAllowToolMenu in FOptionsRx) then
  begin
    Cell := MouseCoord(X, Y);
    if ((Button = mbLeft) and (Cell.X = 0) and (Cell.Y = 0) and
      (dgIndicator in Options)) or (F_Clicked) then
    begin
      F_Clicked := False;
      InvalidateCell(0, 0);
      ShowMenu := True;
      Button := mbRight;
    end;
  end;

  inherited MouseUp(Button, Shift, X, Y);

  if (DatalinkActive) and (DataSource.DataSet.State = dsBrowse) and (ShowMenu) then
  begin
    Rct := CellRect(0, 0);
    MPT.X := Rct.Left;
    if rdgFilter in FOptionsRx then
      MPT.Y := Rct.Bottom - GetDefaultRowHeight
    else
      MPT.Y := Rct.Bottom;
    MPT := ClientToScreen(MPT);

    UpdateJMenuStates;
    F_PopupMenu.Popup(MPT.X, MPT.Y);
  end;
end;

procedure TRxDBGrid.SetQuickUTF8Search(AValue: string);
var
  ClearSearchValue: boolean;
  OldSearchString: string;
begin
  if (rdgAllowQuickSearch in OptionsRx) then
  begin
    OldSearchString := Self.FQuickUTF8Search;
    if (OldSearchString <> AValue) and Assigned(Self.FBeforeQuickSearch) then
      Self.FBeforeQuickSearch(Self, SelectedField, AValue);
    if OldSearchString <> AValue then
    begin
      ClearSearchValue := True;
      if (Length(AValue) > 0) and (Self.DatalinkActive) then
      begin
        if (DataSource.DataSet.State = dsBrowse) and
          (not (DataSource.DataSet.EOF and DataSource.DataSet.BOF)) then
        begin
          //1.Вызываем процедурку поиска...
          if DataSetLocateThrough(Self.DataSource.DataSet,
            Self.SelectedField.FieldName, AValue, FSearchOptions.FQuickSearchOptions, rsdAll, FSearchOptions.FFromStart) then
            Self.FQuickUTF8Search := AValue;
          ClearSearchValue := False;
        end;
      end;
      if ClearSearchValue then
      begin
        Self.FQuickUTF8Search := '';
      end;
      if (OldSearchString <> Self.FQuickUTF8Search) and
        Assigned(Self.FAfterQuickSearch) then
        Self.FAfterQuickSearch(Self, SelectedField, OldSearchString);
    end;
  end;
  //TODO: сделать отображение ищущейся буквы/строки.
end;

procedure TRxDBGrid.UTF8KeyPress(var UTF8Key: TUTF8Char);
var
  CheckUp: boolean;
begin
  inherited UTF8KeyPress(UTF8Key);
  if ReadOnly then
  begin
    //0. Проверяем что это кнопка значащая, увеличиваем "строку поиска"
    if Length(UTF8Key) = 1 then
    begin
      //DebugLn('Ord Of Key:',IntToStr(Ord(UTF8Key[1])));
      CheckUp := not (Ord(UTF8Key[1]) in CBadQuickSearchSymbols);
    end
    else
      CheckUp := True;
    //  DebugLn('RxDBGrid.UTF8KeyPress check',IfThen(CheckUp,'True','False'),'INIT UTF8Key= ',UTF8Key,' Selected Field: ', Self.SelectedField.FieldName);
    if CheckUp then
      QuickUTF8Search := QuickUTF8Search + Trim(UTF8Key);
  end;
end;

procedure TRxDBGrid.KeyDown(var Key: word; Shift: TShiftState);

procedure DoShowFindDlg;
begin
  if not (rdgAllowDialogFind in OptionsRx) then
    exit;
  if Length(QuickUTF8Search) > 0 then
    QuickUTF8Search := '';
  ShowFindDialog;
end;

procedure DoShowColumnsDlg;
begin
  if not (rdgAllowColumnsForm in OptionsRx) then
    exit;
  if Length(QuickUTF8Search) > 0 then
    QuickUTF8Search := '';
  ShowColumnsDialog;
end;

procedure DoShowQuickFilter;
begin
  if not (rdgAllowQuickFilter in FOptionsRx) then
    exit;
  OnFilter(Self);
end;

begin
  if (Key in CCancelQuickSearchKeys) then
    if Length(QuickUTF8Search) > 0 then
      QuickUTF8Search := '';

  inherited KeyDown(Key, Shift);
  if Key <> 0 then
  begin
    case FKeyStrokes.FindRxCommand(Key, Shift) of
      rxgcShowFindDlg: DoShowFindDlg;
      rxgcShowColumnsDlg: DoShowColumnsDlg;
      rxgcShowFilterDlg: OnFilterBy(Self);
      rxgcShowQuickFilter: DoShowQuickFilter;
      rxgcHideQuickFilter: OnFilterClose(Self);
      rxgcShowSortDlg: OnSortBy(Self);
      rxgcSelectAll: SelectAllRows;
      rxgcDeSelectAll: DeSelectAllRows;
      rxgcInvertSelection:InvertSelection;
      rxgcOptimizeColumnsWidth:OptimizeColumnsWidthAll;
      rxgcCopyCellValue:OnCopyCellValue(Self);
    else
      exit;
    end;
    Key := 0;
  end;
end;

procedure TRxDBGrid.KeyPress(var Key: char);
begin
  inherited KeyPress(Key);
  if Assigned(SelectedColumn) and Assigned(SelectedColumn.Field) and (SelectedColumn.Field.DataType in [ftFloat, ftCurrency]) and
     (coFixDecimalSeparator in TRxColumn(SelectedColumn).Options) then
    if (Key in [',', '.']) then
      Key:=DefaultFormatSettings.DecimalSeparator
end;

function TRxDBGrid.CreateColumns: TGridColumns;
begin
  Result := TRxDbGridColumns.Create(Self, TRxColumn);
end;

procedure TRxDBGrid.DrawCellBitmap(RxColumn: TRxColumn; aRect: TRect;
  aState: TGridDrawState; AImageIndex: integer);
var
  ClientSize: TSize;
  H, W: integer;
begin
  InflateRect(aRect, -1, -1);

  H := RxColumn.ImageList.Height;
  W := RxColumn.ImageList.Width;

  ClientSize.cx := Min(aRect.Right - aRect.Left, W);
  ClientSize.cy := Min(aRect.Bottom - aRect.Top, H);

  if ClientSize.cx = W then
  begin
    aRect.Left := (aRect.Left + aRect.Right - W) div 2;
    aRect.Right := aRect.Left + W;
  end;

  if ClientSize.cy = H then
  begin
    aRect.Top := (aRect.Top + aRect.Bottom - H) div 2;
    aRect.Bottom := aRect.Top + H;
  end;
  RxColumn.ImageList.Draw(Canvas, aRect.Left, aRect.Top, AImageIndex);
end;

procedure TRxDBGrid.SetEditText(ACol, ARow: longint; const Value: string);
var
  C: TRxColumn;
  j, L, R: integer;
  S: string;
begin
  C:=nil;
  if (rdgColSpanning in OptionsRx) then
    if IsMerged(aCol, L, R, C) then
      aCol:=L;

  if not Assigned(C) then
    C := ColumnFromGridColumn(aCol) as TRxColumn;

  S := Value;
  if Assigned(C) and (C.KeyList.Count > 0) and (C.PickList.Count > 0) then
  begin
    J := C.PickList.IndexOf(S);
    if (J >= 0) and (J < C.KeyList.Count) then
      S := C.KeyList[j];
  end;
  inherited SetEditText(ACol, ARow, S);
end;


procedure TRxDBGrid.ColRowMoved(IsColumn: boolean; FromIndex, ToIndex: integer);
begin
  inherited ColRowMoved(IsColumn, FromIndex, ToIndex);
  if IsColumn then
    CalcTitle;
end;

procedure TRxDBGrid.Paint;
var
  P:TPoint;
begin
  Inc(FInProcessCalc);
  DoClearInvalidTitle;

  inherited Paint;

  DoDrawInvalidTitle;

  if FFooterOptions.Active and (FFooterOptions.RowCount > 0) then
    DrawFooterRows;

  Dec(FInProcessCalc);
end;

procedure TRxDBGrid.MoveSelection;
begin
  inherited MoveSelection;
(*  if Assigned(FFooterOptions) and FFooterOptions.Active and (FFooterOptions.RowCount > 0) then
    DrawFooterRows; *)
end;

function TRxDBGrid.GetBufferCount: integer;
var
  H, H1:integer;
  i: LongInt;
begin
  {      Result := ClientHeight div DefaultRowHeight;
        if dgTitles in Options then
          Dec(Result, 1);}

  if GetDefaultRowHeight > 0 then
  begin
    H:=ClientHeight;
    if FFooterOptions.Active then
      H:=H - GetDefaultRowHeight * FFooterOptions.RowCount;


    Result := H div GetDefaultRowHeight;

    if rdgFilter in OptionsRx then
      Dec(Result, 1);

    if dgTitles in Options then
      //Dec(Result, 1);
      Result:=Result - RowHeights[0] div GetDefaultRowHeight;
  end
  else
    Result := 1;
end;

procedure TRxDBGrid.CMHintShow(var Message: TLMessage);
var
  Cell: TGridCoord;
  tCol: TRxColumn;
  HintStr_: string;
  Processed: boolean;
  rec: integer;
  CellRect_: TRect;
begin
  if Assigned(TCMHintShow(Message).HintInfo) then
  begin
    with TCMHintShow(Message).HintInfo^ do
    begin
      Cell := MouseCoord(CursorPos.X, CursorPos.Y);
      tCol := TRxColumn(ColumnFromGridColumn(Cell.X));
      if (Cell.Y = 0) and (Cell.X >= Ord(dgIndicator in Options)) then
      begin
        if Assigned(tCol) and (TRxColumnTitle(tCol.Title).Hint <> '') and
          (TRxColumnTitle(tCol.Title).FShowHint) then
          HintStr := TRxColumnTitle(tCol.Title).Hint;
      end
      else
      if Cell.X >= Ord(dgIndicator in Options) then
      begin
        CellRect_ := CellRect(Cell.X, Cell.Y);
        if (CellRect_.Bottom > CursorPos.Y) and (CellRect_.Right > CursorPos.X) then
          if Assigned(FOnDataHintShow) then
          begin
            rec := DataLink.ActiveRecord;
            try
              DataLink.ActiveRecord := Cell.y - 1;
              HintStr_ := tCol.Field.DisplayText;
            finally
              DataLink.ActiveRecord := rec;
            end;
            Processed := False;
            FOnDataHintShow(Self, CursorPos, Cell, tCol, HintStr_, Processed);
            if Processed then
              HintStr := HintStr_;
          end;
      end;
    end;
  end;
  inherited CMHintShow(Message);
end;

procedure TRxDBGrid.FFilterListEditorOnChange(Sender: TObject);
begin
  FFilterListEditor.Hide;
  with TRxColumn(Columns[Columns.RealIndex(FFilterListEditor.Col)]).Filter do
  begin
    if (FFilterListEditor.Text = EmptyValue) then
    begin
      ClearFilter;
{      CurrentValues.Clear;
      State:=rxfsEmpty;}
    end
    else
    if (FFilterListEditor.Text = AllValue) {or (FFilterListEditor.Text = '')} then
    begin
      ClearFilter;
      State:=rxfsAll;
    end
    else
    begin
      ClearFilter;
      CurrentValues.Add(FFilterListEditor.Text);
      State:=rxfsFilter;
    end;
  end;

  DataSource.DataSet.DisableControls;
  DataSource.DataSet.Filtered:=false;
  DataSource.DataSet.Filtered:=true;
  CalcStatTotals;
  DataSource.DataSet.EnableControls;

  if Assigned(FOnFiltred) then
    FOnFiltred(Self);
end;

procedure TRxDBGrid.FFilterListEditorOnCloseUp(Sender: TObject);
begin
  FFilterListEditor.Hide;
  FFilterListEditor.Changed;
  SetFocus;
end;

procedure TRxDBGrid.FFilterColDlgButtonOnClick(Sender: TObject);
var
  RxDBGrid_PopUpFilterForm: TRxDBGrid_PopUpFilterForm;
  R, P: TPoint;
  FRxCol: TRxColumn;
  FRect: TRect;
begin
  FRxCol:=TRxColumn(Columns[Columns.RealIndex(FFilterColDlgButton.Col)]);

  RxDBGrid_PopUpFilterForm:=TRxDBGrid_PopUpFilterForm.CreatePopUpFilterForm(FRxCol);


  P:=Point(FFilterColDlgButton.Left, FFilterColDlgButton.Top + FFilterColDlgButton.Width);


  if RxDBGrid_PopUpFilterForm.Width < FRxCol.Width then
    P.X:=FFilterColDlgButton.Left + FFilterColDlgButton.Width - RxDBGrid_PopUpFilterForm.Width
  else
    P.X:=FFilterColDlgButton.Left + FFilterColDlgButton.Width - FRxCol.Width;

  R:=ClientToScreen(P);
  if R.X + RxDBGrid_PopUpFilterForm.Width > Screen.Width then
    R.X:=Screen.Width - RxDBGrid_PopUpFilterForm.Width;

  RxDBGrid_PopUpFilterForm.Left:=R.X;
  RxDBGrid_PopUpFilterForm.Top:=R.Y;
  RxDBGrid_PopUpFilterForm.ShowModal;
  RxDBGrid_PopUpFilterForm.Free;
end;

procedure TRxDBGrid.FFilterSimpleEditOnChange(Sender: TObject);
begin
  with TRxColumn(Columns[Columns.RealIndex(FFilterSimpleEdit.Col)]).Filter do
  begin
    if (FFilterSimpleEdit.Text = '') and (Style = rxfstManualEdit) then
    begin
      CurrentValues.Clear;
      State:=rxfsAll;
    end
    else
      State:=rxfsFilter;
    ManulEditValue:=FFilterSimpleEdit.Text;
  end;

  DataSource.DataSet.DisableControls;
  DataSource.DataSet.Filtered:=false;
  DataSource.DataSet.Filtered:=true;
  CalcStatTotals;
  DataSource.DataSet.EnableControls;

  if Assigned(FOnFiltred) then
    FOnFiltred(Self);
end;

procedure TRxDBGrid.InternalOptimizeColumnsWidth(AColList: TList);
var
  P: TBookmark;
  i, W, n: integer;
  WA: PIntegerArray;
  S: string;
begin
  GetMem(WA, SizeOf(integer) * AColList.Count);

  for I := 0 to AColList.Count - 1 do
  begin
    if TRxColumnTitle(TRxColumn(AColList[i]).Title).CaptionLinesCount > 1 then
      WA^[i] := Max(Canvas.TextWidth(
        TRxColumnTitle(TRxColumn(AColList[i]).Title).CaptionLine(
        TRxColumnTitle(TRxColumn(AColList[i]).Title).CaptionLinesCount -
        1).Caption) + 8, 20)
    else
      WA^[i] := Max(Canvas.TextWidth(TRxColumn(AColList[i]).Title.Caption) + 8, 20);
  end;

  with DataSource.DataSet do
  begin
    DisableControls;
    P := GetBookmark;
    First;
    try
      while not EOF do
      begin
        for I := 0 to AColList.Count - 1 do
        begin
(*
          if Assigned(TRxColumn(AColList[i]).Field) then
            S := TRxColumn(AColList[i]).Field.DisplayText
          else
            S:='';
          with TRxColumn(AColList[i]) do
            if (KeyList.Count > 0) and (PickList.Count > 0) then
            begin
              n := KeyList.IndexOf(S);
              if (n <> -1) and (n < PickList.Count) then
                S := PickList.Strings[n];
            end; *)
          S:=GetFieldDisplayText(TRxColumn(AColList[i]).Field, TRxColumn(AColList[i]));
          W := Canvas.TextWidth(S) + 6;
          if WA^[i] < W then
            WA^[i] := W;
        end;
        Next;
      end;
    finally
      GotoBookmark(p);
      FreeBookmark(p);
      EnableControls;
    end;
  end;

  for I := 0 to AColList.Count - 1 do
    if WA^[i] > 0 then
      TRxColumn(AColList[i]).Width := WA^[i];

  FreeMem(WA, SizeOf(integer) * AColList.Count);
end;

procedure TRxDBGrid.VisualChange;
var
  P: TPoint;
begin
  CalcTitle;

  if FFooterOptions.Active and (FFooterOptions.RowCount > 0) then
  begin
    P:=GCache.MaxClientXY;
    with GCache do
      MaxClientXY.Y:=MaxClientXY.Y - (GetDefaultRowHeight * FFooterOptions.RowCount + 2);
  end;

  if ((rdgWordWrap in FOptionsRx) or (Assigned(FGroupItems) and FGroupItems.Active)) and (HandleAllocated) then
    UpdateRowsHeight;

  inherited VisualChange;
end;

procedure TRxDBGrid.EditorWidthChanged(aCol, aWidth: Integer);
var
  R:TRect;
begin
  inherited EditorWidthChanged(aCol, aWidth);
  if FFilterListEditor.Visible then
  begin
    R:=CellRect(FFilterListEditor.Col+1,0);
    FFilterListEditor.Width:=Columns[FFilterListEditor.Col].Width;
    FFilterListEditor.Left:=R.Left;
  end
  else
  if FFilterSimpleEdit.Visible then
  begin
    R:=CellRect(FFilterSimpleEdit.Col+1,0);
    FFilterSimpleEdit.Width:=Columns[FFilterSimpleEdit.Col].Width;
    FFilterSimpleEdit.Left:=R.Left;
  end
  else
  if FFilterColDlgButton.Visible then
  begin
    R:=CellRect(FFilterColDlgButton.Col+1,0);
    FFilterColDlgButton.Left := R.Right - FFilterColDlgButton.Width;
  end;
end;

function TRxDBGrid.EditorByStyle(Style: TColumnButtonStyle): TWinControl;
var
  F: TField;
begin
  if Style = cbsAuto then
  begin
    F := SelectedField;
    if Assigned(F) then
    begin
      if Assigned(F.LookupDataSet) and (F.LookupKeyFields <> '') and
        (F.LookupResultField <> '') and (F.KeyFields <> '') then
      begin
        Result := FRxDbGridLookupComboEditor;
        exit;
      end
      else
      if F.DataType in [ftDate, ftDateTime] then
      begin
        Result := FRxDbGridDateEditor;
        exit;
      end;
    end;
  end;
  Result := inherited EditorByStyle(Style);

  if (Style = cbsPickList) and (Result is TCustomComboBox) then
  begin
    if TRxColumn(SelectedColumn).DirectInput then
      TCustomComboBox(Result).Style:=csDropDown
    else
      TCustomComboBox(Result).Style:=csDropDownList;
  end;

end;

procedure TRxDBGrid.CalcStatTotals;
var
  {$IFDEF NoAutomatedBookmark}
  P_26: TBookmark;
  {$ENDIF}
  P: TBookmark;
  i, cnt: integer;
  APresent: boolean;

  DHS:THackDataSet;

  SaveState:TDataSetState;
  SavePos:integer;
  SaveActiveRecord:integer;

  SaveAfterScroll:TDataSetNotifyEvent;
  SaveBeforeScroll:TDataSetNotifyEvent;
  C:TRxColumn;
  AValue:Variant;

  FCList, FCList2:TFPList;
  j: Integer;
  F: TRxColumnFooterItem;
  S: String;
begin
  if (not (DatalinkActive and (FGroupItems.Active or FFooterOptions.Active))) or (Columns.Count = 0) or (gsAddingAutoColumns in GridStatus) then
    Exit;

  if Assigned(OnRxCalcFooterValues)then
  begin
    Inc(FInProcessCalc);
    for C in Columns do
    begin
      C.Footer.ResetTestValue;
      AValue:=Null;
      OnRxCalcFooterValues(Self, C, AValue);
      if AValue<>null then C.Footer.FTestValue := AValue;
    end;
    Dec(FInProcessCalc);
    Exit;
  end;

  APresent := False;
  for C in Columns do
  begin
    APresent := (C.Footer.FValueType in [fvtSum, fvtAvg, fvtMax, fvtMin, fvtCount]) {or (C.FGroupItems.Active)};
    if not APresent then
    begin
      for F in C.Footers do
      begin
        APresent:=F.FValueType in [fvtSum, fvtAvg, fvtMax, fvtMin, fvtCount];
        if APresent then
          break;
      end;
    end
    else
      break;
  end;

  if (not APresent) and (not FGroupItems.Active) then Exit;


  Inc(FInProcessCalc);

  cnt:=0;

  if FGroupItems.Active then FGroupItems.Clear;

  for C in Columns do
  begin
    C.Footer.ResetTestValue;
    for F in C.Footers do F.ResetTestValue;
  end;

  if (DataSource.DataSet.RecordCount<=0) then
  begin
    Dec(FInProcessCalc);
    exit;
  end;

  DHS:=THackDataSet(DataSource.DataSet);

  {$IFDEF NoAutomatedBookmark}
  P:=DataSource.DataSet.GetBookmark;
  {$ELSE}
  P := DHS.Bookmark;
  {$ENDIF}

  SaveState:=DHS.SetTempState(dsBrowse);

  SaveAfterScroll:=DHS.AfterScroll;
  SaveBeforeScroll:=DHS.BeforeScroll;
  DHS.AfterScroll:=nil;
  DHS.BeforeScroll:=nil;

  SaveActiveRecord:=Datalink.ActiveRecord;
  Datalink.ActiveRecord:=0;
  SavePos:=DHS.RecNo;

  FCList:=TFPList.Create;
  FCList2:=TFPList.Create;

  for C in Columns do
  begin
    if (C.Footer.ValueType in [fvtSum, fvtAvg, fvtMax, fvtMin]) and C.Visible then
    begin
      FCList.Add(C);
      C.Footer.FField:=DHS.FieldByName(C.Footer.FieldName);
    end;

    for F in C.Footers do
    begin
      if (F.ValueType in [fvtSum, fvtAvg, fvtMax, fvtMin]) and C.Visible then
      begin
        if FCList.IndexOf(C) < 0 then
          FCList.Add(C);
        F.FField:=DHS.FieldByName(F.FieldName);
      end;
    end;

    if FGroupItems.Active then
      if C.FGroupParam.ValueType <> fvtNon then
        FCList2.Add(C);
  end;

  DHS.First;

  if FGroupItems.Active then
    FGroupItems.InitGroup;

  while not DHS.EOF do
  begin
    for i:=0 to FCList.Count-1 do
    begin
      C:=TRxColumn(FCList[i]);
      if (C.FFooter.FValueType in [fvtSum, fvtAvg, fvtMax, fvtMin]) and Assigned(C.FFooter.FField) then
        C.FFooter.UpdateTestValueFromVar(C.FFooter.FField.AsVariant);

      for F in C.FFooters do
      begin
        if (F.FValueType in [fvtSum, fvtAvg, fvtMax, fvtMin]) and Assigned(F.FField) then
          F.UpdateTestValueFromVar( F.FField.AsVariant)
      end;
    end;

    if FGroupItems.Active then
    begin
      FGroupItems.UpdateValues;
      for i:=0 to FCList2.Count-1 do
        TRxColumn(FCList2[i]).FGroupParam.UpdateValues;
    end;

    inc(cnt);
    DHS.Next;
  end;

  //calc agregate values
  for C in Columns do
  begin
    if C.Footer.ValueType = fvtCount then
        C.FFooter.FCountRec:=Cnt
    else
    if C.Footer.ValueType = fvtAvg then
      C.FFooter.FTestValue:=C.FFooter.FTestValue / Cnt;

    for F in C.Footers do
    begin
      if F.ValueType = fvtCount then
          F.FCountRec:=Cnt
      else
      if F.ValueType = fvtAvg then
        F.FTestValue:=F.FTestValue / Cnt;
    end;
  end;

  if FGroupItems.Active then
    FGroupItems.DoneGroup;

  FCList2.Free;
  FCList.Free;

  //Restore cursor position
  if Min(Datalink.RecordCount + SavePos - 1, DHS.RecNo) > 0 then
    DHS.RecNo := Min(Datalink.RecordCount + SavePos - 1, DHS.RecNo);

  while not DHS.BOF do
  begin
    if SavePos = DHS.RecNo then
      break;
    DHS.Prior;
  end;

  for i:=0 to Columns.Count-1 do
    TRxColumn(Columns[i]).Footer.FField:=nil;

  Datalink.ActiveRecord:=SaveActiveRecord;
  DHS.RestoreState(SaveState);

  DHS.AfterScroll  := SaveAfterScroll;
  DHS.BeforeScroll := SaveBeforeScroll;

  {$IFDEF NoAutomatedBookmark}
  P_26:=DHS.GetBookmark;
  if DHS.CompareBookmarks(P_26, P)<>0 then
    DHS.GotoBookmark(P); //workaround for fix navigation problem
  DHS.FreeBookmark(P);
  DHS.FreeBookmark(P_26);
  {$ELSE}
  if DHS.BookmarkValid(P) and (DHS.CompareBookmarks(DHS.Bookmark, P)<>0) then
    DHS.Bookmark:=P; //workaround for fix navigation problem
  {$ENDIF}


  Dec(FInProcessCalc);
  if FInProcessCalc < 0 then
    FInProcessCalc := 0;
end;

procedure TRxDBGrid.OptimizeColumnsWidth(AColList: string);
var
  ColList: TList;

  procedure DoFillColList;
  var
    L: integer;
  begin
    L := Pos(';', AColList);
    while L > 0 do
    begin
      if AColList <> '' then
        ColList.Add(ColumnByFieldName(Copy(AColList, 1, L - 1)));
      Delete(AColList, 1, L);
      L := Pos(';', AColList);
    end;
    if AColList <> '' then
      ColList.Add(ColumnByFieldName(AColList));
  end;

begin
  if (not DatalinkActive) or (Columns.Count = 0) then
    Exit;
  ColList := TList.Create;
  DoFillColList;
  InternalOptimizeColumnsWidth(ColList);
  ColList.Free;

  if Assigned(OnColumnSized) then
    OnColumnSized(Self);
end;

procedure TRxDBGrid.OptimizeColumnsWidthAll;
var
  ColList: TList;
  i: integer;
begin
  if (not DatalinkActive) or (Columns.Count = 0) then
    Exit;
  ColList := TList.Create;
  for i := 0 to Columns.Count - 1 do
    ColList.Add(Columns[i]);
  InternalOptimizeColumnsWidth(ColList);
  ColList.Free;
end;

procedure TRxDBGrid.UpdateTitleHight;
begin
  CalcTitle;
end;

procedure TRxDBGrid.FilterRec(DataSet: TDataSet; var Accept: boolean);
var
  i: integer;
  Filter: TRxColumnFilter;
  F: TField;
begin
  Accept := True;
  for i := 0 to Columns.Count - 1 do
  begin
    Filter:=TRxColumn(Columns[i]).Filter;
    F:=TRxColumn(Columns[i]).Field;
    if Filter.State = rxfsAll then
      Accept:=true
    else
    if Filter.State = rxfsEmpty then
      Accept:=F.IsNull
    else
    if Filter.State = rxfsNonEmpty then
      Accept:=not F.IsNull
    else
{      if Filter.State = rxfsTopXXXX then
      begin
        if DataSet.State = dsFilter then
          Accept:=true
        else
          Accept:=DataSet.RecNo <  Filter.TopRecord;
        if not Accept then
          Break;
      end
      else}
    begin
      if Filter.CurrentValues.Count > 0 then
        Accept := Filter.CurrentValues.IndexOf(F.DisplayText) >= 0;

      if Accept and (Filter.Style in [rxfstBoth, rxfstManualEdit]) and (Filter.ManulEditValue<>'') then
        Accept := UTF8Pos(UTF8UpperCase(Filter.ManulEditValue), UTF8UpperCase(F.DisplayText)) > 0;

      if not Accept then
        Break;
    end;
  end;
  if Assigned(F_EventOnFilterRec) then
    F_EventOnFilterRec(DataSet, Accept);
end;

procedure TRxDBGrid.BeforeDel(DataSet: TDataSet);
var
  i: integer;
begin
  if FFooterOptions.Active and (DatalinkActive) then
    for i := 0 to Columns.Count - 1 do
      if not TRxColumn(Columns[i]).Footer.DeleteTestValue then
      begin
        FInProcessCalc := -1;
        Break;
      end;
  if Assigned(F_EventOnBeforeDelete) then
    F_EventOnBeforeDelete(DataSet);
end;

procedure TRxDBGrid.BeforePo(DataSet: TDataSet);
var
  i: integer;
  C:TRxColumn;
begin
  if DatalinkActive then
  begin
    if FooterOptions.Active  then
    for i := 0 to Columns.Count - 1 do
    begin
      if not TRxColumn(Columns[i]).Footer.PostTestValue then
      begin
          FInProcessCalc := -1;
          Break;
      end;
    end;

    if rdgFilter in OptionsRx then
    for i := 0 to Columns.Count - 1 do
    begin
      C:=TRxColumn(Columns[i]);
      if Assigned(C.Field) and (C.Filter.ValueList.IndexOf(C.Field.DisplayText)<  0) then
        C.Filter.ValueList.Add(C.Field.DisplayText);
    end;
  end;

  if Assigned(F_EventOnBeforePost) then
    F_EventOnBeforePost(DataSet);
end;

procedure TRxDBGrid.ErrorDel(DataSet: TDataSet; E: EDatabaseError;
  var DataAction: TDataAction);
var
  i: integer;
begin
  if FFooterOptions.Active and (DatalinkActive) then
    for i := 0 to Columns.Count - 1 do
      if not TRxColumn(Columns[i]).Footer.ErrorTestValue then
      begin
        FInProcessCalc := -1;
        Break;
      end;
  if Assigned(F_EventOnDeleteError) then
    F_EventOnDeleteError(DataSet, E, DataAction);
end;

procedure TRxDBGrid.ErrorPo(DataSet: TDataSet; E: EDatabaseError;
  var DataAction: TDataAction);
var
  i: integer;
begin
  if FFooterOptions.Active and (DatalinkActive) then
    for i := 0 to Columns.Count - 1 do
      if not TRxColumn(Columns[i]).Footer.ErrorTestValue then
      begin
        FInProcessCalc := -1;
        Break;
      end;
  if Assigned(F_EventOnPostError) then
    F_EventOnPostError(DataSet, E, DataAction);
end;

procedure TRxDBGrid.OnFind(Sender: TObject);
begin
  if rdgAllowDialogFind in OptionsRx then
    ShowFindDialog;
end;

procedure TRxDBGrid.OnFilterBy(Sender: TObject);
var
  NewFilter: string;
begin
  if DataLinkActive then
  begin
    OptionsRx := OptionsRx - [rdgFilter];
    rxFilterByForm := TrxFilterByForm.Create(Application);
    NewFilter := DataSource.DataSet.Filter;
    if rxFilterByForm.Execute(Self, NewFilter, F_LastFilter) then
    begin
      if NewFilter <> '' then
      begin
        DataSource.DataSet.Filter := NewFilter;
        DataSource.DataSet.Filtered := True;
      end
      else
      begin
        DataSource.DataSet.Filtered := False;
      end;
      CalcStatTotals;
    end;
    FreeAndNil(rxFilterByForm);
  end;
end;

procedure TRxDBGrid.OnFilter(Sender: TObject);
var
  C: TRxColumn;
  i: integer;
  FBS, FAS:TDataSetNotifyEvent;
begin
  BeginUpdate;
  OptionsRx := OptionsRx + [rdgFilter];
{
  for i := 0 to Columns.Count - 1 do
  begin
    C := TRxColumn(Columns[i]);
    C.Filter.ValueList.Clear;
    C.Filter.CurrentValues.Clear;
    C.Filter.ManulEditValue:='';
    C.Filter.ItemIndex := -1;
    C.Filter.ValueList.Add(C.Filter.EmptyValue);
    C.Filter.ValueList.Add(C.Filter.AllValue);
  end;

  if DatalinkActive then
  begin
    DataSource.DataSet.DisableControls;
    DataSource.DataSet.Filtered := True;
    FBS:=DataSource.DataSet.BeforeScroll;
    FAS:=DataSource.DataSet.AfterScroll;
    DataSource.DataSet.BeforeScroll:=nil;
    DataSource.DataSet.AfterScroll:=nil;
    DataSource.DataSet.First;
    while not DataSource.DataSet.EOF do
    begin
      for i := 0 to Columns.Count - 1 do
      begin
        C := TRxColumn(Columns[i]);
        if C.Filter.Enabled and (C.Field <> nil) and (C.Filter.ValueList.IndexOf(C.Field.DisplayText) < 0) then
          C.Filter.ValueList.Add(C.Field.DisplayText);
      end;
      DataSource.DataSet.Next;
    end;
    DataSource.DataSet.First;
    DataSource.DataSet.BeforeScroll:=FBS;
    DataSource.DataSet.AfterScroll:=FAS;
    DataSource.DataSet.EnableControls;
  end;
}
  EndUpdate;
end;

procedure TRxDBGrid.OnFilterClose(Sender: TObject);
begin
  OptionsRx := OptionsRx - [rdgFilter];
  DataSource.DataSet.Filtered := False;
  CalcStatTotals;
end;

procedure TRxDBGrid.OnSortBy(Sender: TObject);
var
  i: integer;
  S1: string;
  FSortListField:TStringList;
  FColumn:TRxColumn;
begin
  if DatalinkActive then
  begin
    FSortListField:=TStringList.Create;
    try
      rxSortByForm := TrxSortByForm.Create(Application);
      rxSortByForm.CheckBox1.Checked := rdgCaseInsensitiveSort in FOptionsRx;
      if rxSortByForm.Execute(Self, FSortListField) then
      begin
        for i := 0 to FSortListField.Count - 1 do
        begin
          S1:=FSortListField.Strings[i];
          FColumn:=TRxColumn(ColumnByFieldName(Copy(S1, 2, Length(S1))));
          if S1[1] = '1' then
            FColumn.FSortOrder := smUp
          else
            FColumn.FSortOrder := smDown;

          FColumn.FSortPosition:=i;
        end;

        CollumnSortListUpdate;

        if rxSortByForm.CheckBox1.Checked then
          Include(FOptionsRx, rdgCaseInsensitiveSort)
        else
          Exclude(FOptionsRx, rdgCaseInsensitiveSort);

        CollumnSortListApply;
        if Assigned(FOnSortChanged) then
        begin
          FSortingNow := True;
          FOnSortChanged(Self);
          FSortingNow := False;
        end;
      end;

    finally
      FreeAndNil(rxSortByForm);
      FreeAndNil(FSortListField);
    end;
    Invalidate;
  end;
end;

procedure TRxDBGrid.OnChooseVisibleFields(Sender: TObject);
begin
  if rdgAllowColumnsForm in OptionsRx then
    ShowColumnsDialog;
end;

procedure TRxDBGrid.OnSelectAllRows(Sender: TObject);
begin
  SelectAllRows;
end;

procedure TRxDBGrid.OnCopyCellValue(Sender: TObject);
var
  P:TBookMark;
  S:string;
  i, k, j:integer;
begin
  if DatalinkActive then
  begin
    if (dgMultiselect in Options) and (SelectedRows.Count>1) then
    begin
      S:='';
      DataSource.DataSet.DisableControls;
      {$IFDEF NoAutomatedBookmark}
      P:=DataSource.DataSet.GetBookmark;
      {$ELSE}
      P:=DataSource.DataSet.Bookmark;
      {$ENDIF}
      try
        for j:=0 to SelectedRows.Count-1 do
        begin
          DataSource.DataSet.Bookmark:=SelectedRows[j];
          if S<>'' then
            S:=S+LineEnding;
          K:=0;
          for i:=0 to Columns.Count-1 do
          begin
            if Assigned(Columns[i].Field) then
            begin
              if K<>0 then
                S:=S+#9;

              {$IF lcl_fullversion >= 1090000}
              if CheckDisplayMemo(Columns[i].Field) then
                S :=S + Columns[i].Field.AsString
              else
              {$ENDIF}
                S:=S+Columns[i].Field.DisplayText;
              inc(K);
            end;
          end;
        end;
      finally
      {$IFDEF NoAutomatedBookmark}
        DataSource.DataSet.GotoBookmark(P);
        DataSource.DataSet.FreeBookmark(P);
      {$ELSE}
        DataSource.DataSet.Bookmark:=P;
      {$ENDIF}
        DataSource.DataSet.EnableControls;
      end;
      Invalidate;
      if S<>'' then
      begin
        try
          Clipboard.Open;
          Clipboard.AsText:=S;
        finally
          Clipboard.Close;
        end;
      end;
    end
(*    else
    if (dgMultiselect in Options) and (SelectedRows.Count>1) then
    begin
      S:='';
      DataSource.DataSet.DisableControls;
      {$IFDEF NoAutomatedBookmark}
      P:=DataSource.DataSet.GetBookmark;
      {$ELSE}
      P:=DataSource.DataSet.Bookmark;
      {$ENDIF}
      try
        DataSource.DataSet.First;
        while not DataSource.DataSet.EOF do
        begin
          if S<>'' then
            S:=S+LineEnding;
          K:=0;
          for i:=0 to Columns.Count-1 do
          begin
            if Assigned(Columns[i].Field) then
            begin
              if K<>0 then
                S:=S+#9;
              S:=S+Columns[i].Field.DisplayText;
              inc(K);
            end;
          end;
          DataSource.DataSet.Next;
        end;
      finally
      {$IFDEF NoAutomatedBookmark}
        DataSource.DataSet.GotoBookmark(P);
        DataSource.DataSet.FreeBookmark(P);
      {$ELSE}
        DataSource.DataSet.Bookmark:=P;
      {$ENDIF}
        DataSource.DataSet.EnableControls;
      end;
      Invalidate;
      if S<>'' then
      begin
        try
          Clipboard.Open;
          Clipboard.AsText:=S;
        finally
          Clipboard.Close;
        end;
      end;
    end   *)
    else
    if Assigned(SelectedField) then
    try
      Clipboard.Open;

      {$IF lcl_fullversion >= 1090000}
      if CheckDisplayMemo(SelectedField) then
        Clipboard.AsText:=SelectedField.AsString
      else
      {$ENDIF}
        Clipboard.AsText:=SelectedField.DisplayText;
    finally
      Clipboard.Close;
    end;
  end;
end;

procedure TRxDBGrid.OnOptimizeColWidth(Sender: TObject);
begin
  OptimizeColumnsWidthAll;
end;

procedure TRxDBGrid.Loaded;
begin
  inherited Loaded;
  UpdateJMenuKeys;
end;

procedure TRxDBGrid.UpdateFooterRowOnUpdateActive;
begin
  if Assigned(DataSource) then
  begin
    if DataSource.State <> FOldDataSetState then
    begin
      if (FOldDataSetState in dsEditModes) and (DataSource.State = dsBrowse) then
        CalcStatTotals;
      FOldDataSetState:=DataSource.State;
    end;
  end
  else
    FOldDataSetState:=dsInactive;
end;

procedure TRxDBGrid.DoEditorHide;
var
  R:TRxColumn;
  i:integer;
begin
  inherited DoEditorHide;
  R:=SelectedColumn as TRxColumn;

  if Assigned(Editor) and Assigned(R) then
  for i:=0 to R.EditButtons.Count-1 do
  begin
    if R.EditButtons[i].Style = ebsUpDownRx then
      R.EditButtons[i].FSpinBtn.Visible:=false
    else
      R.EditButtons[i].FButton.Visible:=false;
  end;
end;

procedure TRxDBGrid.DoEditorShow;
var
  R, R1: TRect;
  FSaveRow: Integer;
  P: TBookMark;
  FG: TColumnGroupItem;
begin
  inherited DoEditorShow;

{  if FGroupItems.Active then
  begin
    if (Row>=FixedRows) then
    begin
      FSaveRow:=DataLink.ActiveRecord;
      DataLink.ActiveRecord:=Row-FixedRows;
      P:=DataSource.DataSet.Bookmark;
      DataLink.ActiveRecord:=FSaveRow;
      FG:=FGroupItems.FindGroupItem(P);
      if Assigned(FG) then
      begin
        R:=CellRect(Col, Row);
        Editor.SetBounds(R.Left, R.Top, R.Right - R.Left - 1, R.Bottom - R.Top - DefaultRowHeight - 1);
        R1:=Editor.BoundsRect;
      end;
    end;
  end;    }

  if rdgColSpanning in OptionsRx then
  begin
    if IsMerged(Col) then
    begin
      CalcCellExtent(Col, Row, R);
      Editor.SetBounds(R.Left, R.Top, R.Right-R.Left-1, R.Bottom-R.Top-1);
    end;
  end;

  DoSetColEdtBtn;
end;

procedure TRxDBGrid.CheckNewCachedSizes(var AGCache: TGridDataCache);
begin
  inherited CheckNewCachedSizes(AGCache);

  if FFooterOptions.Active then
  begin
//    AGCache.ClientHeight:=AGCache.ClientHeight - DefaultRowHeight * FFooterOptions.RowCount;
    AGCache.ScrollHeight:=AGCache.ScrollHeight - DefaultRowHeight * FFooterOptions.RowCount;
    AGCache.ClientRect.Bottom:=AGCache.ClientRect.Bottom - DefaultRowHeight * FFooterOptions.RowCount;
  end;

end;

procedure TRxDBGrid.CalcCellExtent(ACol, ARow: Integer; var ARect: TRect);
var
  L, T, R, B: Integer;
  C: TRxColumn;
begin
  if IsMerged(ACol, L, R, C) then
  begin
    ARect.TopLeft := CellRect(L, ARow).TopLeft;
    ARect.BottomRight := CellRect(R, ARow).BottomRight;
  end;
end;

function TRxDBGrid.IsMerged(ACol: Integer): Boolean;
var
  L, R: Integer;
  C: TRxColumn;
begin
  Result := IsMerged(ACol, L, R, C);
end;

function TRxDBGrid.IsMerged(ACol: Integer; out ALeft, ARight: Integer; out
  AColumn: TRxColumn): Boolean;
begin
  Result := false;
  AColumn:=nil;
  ALeft := ACol;
  ARight := ACol;

  if (rdgColSpanning in OptionsRx) and Assigned(FOnMergeCells) then
  begin
    inc(FMergeLock);
    FOnMergeCells(Self, ACol, ALeft, ARight, AColumn);
    if ALeft > ARight then
      SwapValues(ALeft, ARight);
    Result := (ALeft <> ARight);
    dec(FMergeLock);
  end;
end;

function TRxDBGrid.GetEditMask(aCol, aRow: Longint): string;
var
  L, R: Integer;
  C: TRxColumn;
begin
  if (rdgColSpanning in OptionsRx) then
    if IsMerged(aCol, L, R, C) then
    begin
      if Assigned(C) then
        aCol:=C.Index
      else
        aCol:=L;
    end;
  Result:=inherited GetEditMask(aCol, aRow);
end;

function TRxDBGrid.GetEditText(aCol, aRow: Longint): string;
var
  R, L: Integer;
  C: TRxColumn;
begin
  if (rdgColSpanning in OptionsRx) then
    if IsMerged(aCol, L, R, C) then
    begin
      if Assigned(C) then
        aCol:=C.Index
      else
        aCol:=L;
    end;
  Result:=inherited GetEditText(aCol, aRow);
end;

function TRxDBGrid.GetDefaultEditor(Column: Integer): TWinControl;
var
  L, R: Integer;
  C: TRxColumn;
begin
  if (rdgColSpanning in OptionsRx) then
    if IsMerged(Column, L, R, C) then
    begin
      if Assigned(C) then
        Column:=C.Index
      else
        Column:=L;
    end;
  Result:=inherited GetDefaultEditor(Column);
end;

procedure TRxDBGrid.PrepareCanvas(aCol, aRow: Integer; AState: TGridDrawState);
function  IsCellButtonColumn(ACell: TPoint): boolean;
var
  Column: TGridColumn;
begin
  Column := ColumnFromGridColumn(ACell.X);
  result := (Column<>nil) and (Column.ButtonStyle=cbsButtonColumn) and
            (ACell.y>=FixedRows);
end;

var
  L, R, RR: Integer;
  C: TRxColumn;
begin
  if (rdgColSpanning in OptionsRx) then
    if not ((gdFixed in aState) and (aRow = 0)) then
      if ((Row - FixedRows) = Datalink.ActiveRecord) and IsMerged(ACol, L, R, C) then
        if (aCol >= L) and (aCol <= R) then
          AState := AState + [gdSelected, gdFocused];
  inherited PrepareCanvas(aCol, aRow, AState);


  if (gdSelected in AState) then
  begin
    if not IsCellButtonColumn(point(aCol,aRow)) then
      if not FIsSelectedDefaultFont then
      begin
        Canvas.Font:=FSelectedFont;
        if FSelectedFont.Color = clDefault then
          Canvas.Font.Color := clHighlightText;
      end;
  end;
end;

{$IFDEF DEVELOPER_RX}
type
  THackDataLink = class(TDataLink)

  end;

procedure TRxDBGrid.InternalAdjustRowCount(var RecCount: integer);
var
  CurActiveRecord, j, H1, FRec, H, H2: Integer;
  i: LongInt;
  R: TRxColumn;
  F: TField;
  S: String;
begin
  inherited InternalAdjustRowCount(RecCount);

  if (not (Assigned(DataLink) and DataLink.Active)) or ((GCache.VisibleGrid.Top=0) and (GCache.VisibleGrid.Bottom=0)) then
    exit;

  CurActiveRecord:=DataLink.ActiveRecord;

  if dgTitles in Options then
  begin
    FRec:=1;
    H2:=1;
  end
  else
  begin
    FRec:=0;
    H2:=0;
  end;

  for i:=GCache.VisibleGrid.Top to GCache.VisibleGrid.Bottom do
  begin
    DataLink.ActiveRecord:=i - FixedRows;
//    P:=PtrInt(DataSource.DataSet.ActiveBuffer);
    H:=1;
    for j:=0 to Columns.Count-1 do
    begin
      R:=Columns[j] as TRxColumn;
      if R.WordWrap then
      begin
        F:=R.Field;
        if Assigned(F) then
          S:=F.DisplayText
        else
          S:='';

        H1 := Max((Canvas.TextWidth(S) + 2) div R.Width + 1, H);
        if H1 > WordCount(S, [' ']) then
          H1 := WordCount(S, [' ']);
      end
      else
        H1:=1;
      H:=Max(H, H1);
    end;


{

    if FGroupItems.Active and DatalinkActive then
      if Assigned(FGroupItems.FindGroupItem(DataSource.DataSet.Bookmark)) then
        Inc(H);


    if i<RowCount then
    begin
      if Assigned(FOnCalcRowHeight) then
        FOnCalcRowHeight(Self, H);
      RowHeights[i] := GetDefaultRowHeight * H;
      H2:=H2 + RowHeights[i];
      if H2<=ClientHeight  then
        Inc(Result);
    end;}

    if H2 + H > RecCount then
    begin
//      RecCount:=FRec;
      if (FRec < FixedRows + CurActiveRecord) {and (CurActiveRecord = DataLink.ActiveRecord)} then
      begin
        TopRow:=1;
//        THackDataLink(DataLink).FirstRecord:=THackDataLink(DataLink).FirstRecord + 1;
{        H:=CurActiveRecord - DataLink.ActiveRecord;
        THackDataLink(DataLink).FirstRecord:=THackDataLink(DataLink).FirstRecord + 1;
        THackDataSet(DataLink.DataSet).RecalcBufListSize;}
//        THackDataLink(DataLink).BufferCount:=FRec;
        H:=0;
      end;
//      DataLink.BufferCount:=FRec;
//      break;
    end
    else
    begin
      FRec:=FRec + 1;
      H2:=H2 + H;
    end;
  end;

  DataLink.ActiveRecord:=CurActiveRecord;

end;
{$ENDIF}

procedure TRxDBGrid.GetOnCreateLookup;
begin
  if Assigned(F_CreateLookup) then
    F_CreateLookup(FRxDbGridLookupComboEditor);
end;

procedure TRxDBGrid.GetOnDisplayLookup;
begin
  if Assigned(F_DisplayLookup) then
    F_DisplayLookup(FRxDbGridLookupComboEditor);
end;

procedure TRxDBGrid.SelectAllRows;
var
  P:TBookMark;
begin
  if DatalinkActive then
  begin
    DataSource.DataSet.DisableControls;
{$IFDEF NoAutomatedBookmark}
    P:=DataSource.DataSet.GetBookmark;
{$ELSE}
    P:=DataSource.DataSet.Bookmark;
{$ENDIF}
    try
      DataSource.DataSet.First;
      while not DataSource.DataSet.EOF do
      begin
        SelectedRows.CurrentRowSelected:=true;
        DataSource.DataSet.Next;
      end;
    finally
{$IFDEF NoAutomatedBookmark}
      DataSource.DataSet.GotoBookmark(P);
      DataSource.DataSet.FreeBookmark(P);
{$ELSE}
      DataSource.DataSet.Bookmark:=P;
{$ENDIF}
      DataSource.DataSet.EnableControls;
    end;
    Invalidate;
  end;
end;

procedure TRxDBGrid.DeSelectAllRows;
var
  P:TBookMark;
begin
  if DatalinkActive then
  begin
    DataSource.DataSet.DisableControls;
{$IFDEF NoAutomatedBookmark}
    P:=DataSource.DataSet.GetBookmark;
{$ELSE}
    P:=DataSource.DataSet.Bookmark;
{$ENDIF}
    try
      DataSource.DataSet.First;
      while not DataSource.DataSet.EOF do
      begin
        SelectedRows.CurrentRowSelected:=false;
        DataSource.DataSet.Next;
      end;
    finally
{$IFDEF NoAutomatedBookmark}
      DataSource.DataSet.GotoBookmark(P);
      DataSource.DataSet.FreeBookmark(P);
{$ELSE}
      DataSource.DataSet.Bookmark:=P;
{$ENDIF}
      DataSource.DataSet.EnableControls;
    end;
    Invalidate;
  end;
end;

procedure TRxDBGrid.InvertSelection;
var
  P:TBookMark;
begin
  if DatalinkActive then
  begin
    DataSource.DataSet.DisableControls;
    {$IFDEF NoAutomatedBookmark}
    P:=DataSource.DataSet.GetBookmark;
    {$ELSE}
    P:=DataSource.DataSet.Bookmark;
    {$ENDIF}
    try
      DataSource.DataSet.First;
      while not DataSource.DataSet.EOF do
      begin
        SelectedRows.CurrentRowSelected:=not SelectedRows.CurrentRowSelected;
        DataSource.DataSet.Next;
      end;
    finally
      {$IFDEF NoAutomatedBookmark}
      DataSource.DataSet.GotoBookmark(P);
      DataSource.DataSet.FreeBookmark(P);
      {$ELSE}
      DataSource.DataSet.Bookmark:=P;
      {$ENDIF}
      DataSource.DataSet.EnableControls;
    end;
    Invalidate;
  end;
end;

procedure TRxDBGrid.CopyCellValue;
begin
  OnCopyCellValue(Self);
end;

procedure TRxDBGrid.SetSort(AFields: array of String;
  ASortMarkers: array of TSortMarker; PreformSort: Boolean);
var
  I: Integer;
  C: TRxColumn;
begin
  CollumnSortListClear;
  if (Length(AFields) > 0) and (Length(AFields) = Length(ASortMarkers)) then
  begin
    for I := 0 to Length(AFields) - 1 do
    begin
      C := ColumnByFieldName(AFields[I]);
      if C <> nil then
      begin
        C.SortOrder := ASortMarkers[I];
        C.FSortPosition := I;
      end;
    end;
    CollumnSortListUpdate;
  end;
  if PreformSort then
  begin
    if Assigned(FSortEngine) then
      CollumnSortListApply;
    if Assigned(FOnSortChanged) then
    begin
      FSortingNow := True;
      FOnSortChanged(Self);
      FSortingNow := False;
    end;
  end;
end;


constructor TRxDBGrid.Create(AOwner: TComponent);
begin
  FFooterOptions:=TRxDBGridFooterOptions.Create(Self);
  inherited Create(AOwner);
{$IFDEF RXDBGRID_OPTIONS_WO_CANCEL_ON_EXIT}
  Options := Options - [dgCancelOnExit];
{$ENDIF}
  FSaveOnDataSetScrolled:=Datalink.OnDataSetScrolled;
  Datalink.OnDataSetScrolled:=@OnDataSetScrolled;

  FToolsList:=TFPList.Create;
  FColumnDefValues:=TRxDBGridColumnDefValues.Create(Self);
  FSearchOptions:=TRxDBGridSearchOptions.Create(Self);

  FSortColumns:=TRxDbGridColumnsSortList.Create;
  FGroupItems:=TColumnGroupItems.Create(Self);

  F_MenuBMP := CreateResBitmap('rx_menu_grid');

  Options := Options - [dgTabs];

//  TDrawGrid(Self).Options:=TDrawGrid(Self).Options + [goColSpanning];

  OptionsRx := OptionsRx + [rdgAllowColumnsForm, rdgAllowDialogFind, rdgAllowQuickFilter];

  FAutoSort := True;

  F_Clicked := False;

  DoCreateJMenu;

  FKeyStrokes := TRxDBGridKeyStrokes.Create(Self);
  FKeyStrokes.ResetDefaults;

  F_LastFilter := TStringList.Create;

  FPropertyStorageLink := TPropertyStorageLink.Create;
  FPropertyStorageLink.OnSave := @OnIniSave;
  FPropertyStorageLink.OnLoad := @OnIniLoad;

  FFilterListEditor := TFilterListCellEditor.Create(nil);
  with FFilterListEditor do
  begin
    Name := 'FilterListEditor';
    Visible := False;
    Items.Append('');
    ReadOnly := True;
    AutoComplete := True;
    OnChange := @FFilterListEditorOnChange;
    OnCloseUp := @FFilterListEditorOnCloseUp;
  end;

  FFilterColDlgButton:=TFilterColDlgButton.Create(nil);
  FFilterColDlgButton.Name := 'FilterColDlgButton';
  FFilterColDlgButton.Visible := False;
  FFilterColDlgButton.OnClick := @FFilterColDlgButtonOnClick;
  FFilterColDlgButton.Glyph.Assign(FEllipsisRxBMP);


  FFilterSimpleEdit:=TFilterSimpleEdit.Create(nil);
  FFilterSimpleEdit.Name := 'FFilterSimpleEdit';
  FFilterSimpleEdit.Visible := False;
  FFilterSimpleEdit.OnChange := @FFilterSimpleEditOnChange;

  FColumnResizing := False;

  FRxDbGridLookupComboEditor := TRxDBGridLookupComboEditor.Create(nil);
  FRxDbGridLookupComboEditor.Name := 'RxDBGridLookupComboEditor';
  FRxDbGridLookupComboEditor.Visible := False;

  FRxDbGridDateEditor := TRxDBGridDateEditor.Create(nil);
  FRxDbGridDateEditor.Name := 'RxDbGridDateEditor';
  FRxDbGridDateEditor.Visible := False;

  FSelectedFont:=TFont.Create;
  FSelectedFont.OnChange:=@SelectedFontChanged;
  FillDefaultFonts;
  UpdateJMenuKeys;

end;

destructor TRxDBGrid.Destroy;
begin
  CleanDSEvent;
  FreeAndNil(FSelectedFont);
  FreeAndNil(FFilterSimpleEdit);
  FreeAndNil(FFooterOptions);
  FreeAndNil(FRxDbGridLookupComboEditor);
  FreeAndNil(FRxDbGridDateEditor);
  FreeAndNil(FPropertyStorageLink);
  FreeAndNil(FFilterListEditor);
  FreeAndNil(FFilterColDlgButton);
  FreeAndNil(F_PopupMenu);
  FreeAndNil(F_MenuBMP);
  FreeAndNil(F_LastFilter);
  FreeAndNil(FKeyStrokes);
  FreeAndNil(FToolsList);
  FreeAndNil(FColumnDefValues);
  FreeAndNil(FSearchOptions);
  FreeAndNil(FGroupItems);

  inherited Destroy;
  FreeAndNil(FSortColumns);
end;

procedure TRxDBGrid.LayoutChanged;
begin
  if csDestroying in ComponentState then
    exit;

  inherited LayoutChanged;
  if DatalinkActive and (FInProcessCalc = 0) and (Datalink.DataSet.State = dsBrowse) then
    CalcStatTotals;
end;

procedure TRxDBGrid.SetFocus;
begin
  inherited SetFocus;
  if FFilterListEditor.Visible then
    FFilterListEditor.Hide;

  if FFilterColDlgButton.Visible then
    FFilterColDlgButton.Hide;
end;

procedure TRxDBGrid.ShowFindDialog;
begin
  ShowRxDBGridFindForm(Self);
end;

procedure TRxDBGrid.ShowColumnsDialog;
begin
  ShowRxDBGridColumsForm(Self);
end;

procedure TRxDBGrid.ShowSortDialog;
begin
  OnSortBy(nil);
end;

procedure TRxDBGrid.ShowFilterDialog;
begin
  OnFilterBy(nil);
end;

function TRxDBGrid.ColumnByFieldName(AFieldName: string): TRxColumn;
var
  i: integer;
begin
  Result := nil;
  AFieldName := UpperCase(AFieldName);
  for i := 0 to Columns.Count - 1 do
  begin
    if UpperCase(Columns[i].FieldName) = AFieldName then
    begin
      Result := Columns[i] as TRxColumn;
      exit;
    end;
  end;
end;

function TRxDBGrid.ColumnByCaption(ACaption: string): TRxColumn;
var
  i: integer;
begin
  Result := nil;
  ACaption := UpperCase(ACaption);
  for i := 0 to Columns.Count - 1 do
    if ACaption = UpperCase(Columns[i].Title.Caption) then
    begin
      Result := TRxColumn(Columns[i]);
      exit;
    end;
end;

procedure TRxDBGrid.EraseBackground(DC: HDC);
begin
  // The correct implementation is doing nothing
end;

function TRxDbGridColumns.GetColumn(Index: Integer): TRxColumn;
begin
  Result:=TRxColumn( inherited Items[Index] );
end;

procedure TRxDbGridColumns.SetColumn(Index: Integer; AValue: TRxColumn);
begin
  Items[Index].Assign( AValue );
end;

procedure TRxDbGridColumns.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
begin
  inherited Notify(Item, Action);
  TRxDBGrid(Grid).CollumnSortListUpdate;
end;

{ TRxDbGridColumns }
function TRxDbGridColumns.Add: TRxColumn;
begin
  Result := TRxColumn(inherited Add);
end;

function TRxDbGridColumns.GetEnumerator: TRxDbGridColumnsEnumerator;
begin
  Result:=TRxDbGridColumnsEnumerator.Create(Self);
end;

{ TRxColumn }

function TRxColumn.GetKeyList: TStrings;
begin
  if FKeyList = nil then
    FKeyList := TStringList.Create;
  Result := FKeyList;
end;

function TRxColumn.GetSortFields: string;
begin
  if FSortFields = '' then
    Result:=FieldName
  else
    Result:=FSortFields;
end;

procedure TRxColumn.SetConstraints(AValue: TRxDBGridCollumnConstraints);
begin
  FConstraints.Assign(AValue);
end;

procedure TRxColumn.SetEditButtons(AValue: TRxColumnEditButtons);
begin
  FEditButtons.Assign(AValue);
end;

procedure TRxColumn.SetFilter(const AValue: TRxColumnFilter);
begin
  FFilter.Assign(AValue);
end;

function TRxColumn.GetFooter: TRxColumnFooterItem;
begin
  Result := FFooter;
end;

function TRxColumn.GetFooters: TRxColumnFooterItems;
begin
  Result:=FFooters;
end;

function TRxColumn.GetConstraints: TRxDBGridCollumnConstraints;
begin
  Result:=FConstraints;
end;

procedure TRxColumn.SetFooter(const AValue: TRxColumnFooterItem);
begin
  FFooter.Assign(AValue);
end;

procedure TRxColumn.SetFooters(AValue: TRxColumnFooterItems);
begin
  FFooters.Assign(AValue);
end;

procedure TRxColumn.SetImageList(const AValue: TImageList);
begin
  if FImageList = AValue then
    exit;
  FImageList := AValue;
  if Grid <> nil then
    Grid.Invalidate;
end;

procedure TRxColumn.SetKeyList(const AValue: TStrings);
begin
  if AValue = nil then
  begin
    if FKeyList <> nil then
      FKeyList.Clear;
  end
  else
    KeyList.Assign(AValue);
end;

procedure TRxColumn.SetNotInKeyListIndex(const AValue: integer);
begin
  if FNotInKeyListIndex = AValue then
    exit;
  FNotInKeyListIndex := AValue;
  if Grid <> nil then
    Grid.Invalidate;
end;

procedure TRxColumn.SetWordWrap(AValue: boolean);
begin
  if FWordWrap=AValue then Exit;
  FWordWrap:=AValue;
end;

function TRxColumn.CreateTitle: TGridColumnTitle;
begin
  Result := TRxColumnTitle.Create(Self);
end;

procedure TRxColumn.ColumnChanged;
begin
  inherited ColumnChanged;
  if Assigned(FConstraints) and (FConstraints.MinWidth <> 0) and (FConstraints.MinWidth > Width) then
    Width:=FConstraints.MinWidth;

  if Assigned(FConstraints) and (FConstraints.MaxWidth <> 0) and (FConstraints.MaxWidth < Width) then
    Width:=FConstraints.MaxWidth;
end;

constructor TRxColumn.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNotInKeyListIndex := -1;
  FConstraints:=TRxDBGridCollumnConstraints.Create(Self);
  FFooter := TRxColumnFooterItem.Create(nil);
  FFooter.FOwner:=Self;
  FFooter.FillDefaultFont;

  FFilter := TRxColumnFilter.Create(Self);
  FDirectInput := true;
  FEditButtons:=TRxColumnEditButtons.Create(Self);
  FOptions:=[coCustomizeVisible, coCustomizeWidth];
  FFooters:=TRxColumnFooterItems.Create(Self);
  FGroupParam:=TRxColumnGroupParam.Create(Self);
end;

destructor TRxColumn.Destroy;
begin
  FreeAndNil(FGroupParam);
  FreeAndNil(FFooters);
  FreeAndNil(FEditButtons);
  if FKeyList <> nil then
  begin
    FKeyList.Free;
    FKeyList := nil;
  end;
  FreeAndNil(FFooter);
  FreeAndNil(FFilter);
  FreeAndNil(FConstraints);
  inherited Destroy;
end;

procedure TRxColumn.OptimizeWidth;
begin
  if Grid <> nil then
    TRxDBGrid(Grid).OptimizeColumnsWidth(FieldName);
end;

{ TRxColumnTitle }
procedure TRxColumnTitle.SetOrientation(const AValue: TTextOrientation);
begin
  if FOrientation = AValue then
    exit;
  FOrientation := AValue;
  TRxDBGrid(TRxColumn(Column).Grid).CalcTitle;
  TRxColumn(Column).ColumnChanged;
end;

function TRxColumnTitle.GetCaptionLinesCount: integer;
begin
  if Assigned(FCaptionLines) then
    Result := FCaptionLines.Count
  else
    Result := 0;
end;

function TRxColumnTitle.CaptionLine(ALine: integer): TMLCaptionItem;
begin
  if Assigned(FCaptionLines) and (FCaptionLines.Count > 0) and
    (ALine >= 0) and (FCaptionLines.Count > ALine) then
    Result := TMLCaptionItem(FCaptionLines[ALine])
  else
    Result := nil;
end;

procedure TRxColumnTitle.ClearCaptionML;
var
  i: integer;
  R: TMLCaptionItem;
begin
  for i := 0 to FCaptionLines.Count - 1 do
  begin
    R := TMLCaptionItem(FCaptionLines[i]);
    R.Free;
  end;
  FCaptionLines.Clear;
end;

procedure TRxColumnTitle.SetCaption(const AValue: TCaption);
var
  c: integer;
  s: string;

  procedure AddMLStr(AStr: string);
  var
    R: TMLCaptionItem;
  begin
    R := TMLCaptionItem.Create;
    R.Caption := AStr;
    R.Col := Column;
    FCaptionLines.Add(R);
  end;

begin
  inherited SetCaption(AValue);
  ClearCaptionML;
  c := Pos('|', AValue);
  if C > 0 then
  begin
    S := AValue;
    while C > 0 do
    begin
      AddMLStr(Copy(S, 1, C - 1));
      System.Delete(S, 1, C);
      c := Pos('|', S);
    end;
    if S <> '' then
      AddMLStr(S);
  end;
  if not (csLoading in Column.Grid.ComponentState) and Column.Grid.HandleAllocated then
    TRxDBGrid(Column.Grid).CalcTitle;
end;

constructor TRxColumnTitle.Create(TheColumn: TGridColumn);
begin
  inherited Create(TheColumn);
{$IFDEF NEW_STYLE_TITLE_ALIGNMENT_RXDBGRID}
  Alignment := taCenter;
{$ENDIF}
  FCaptionLines := TFPList.Create;
end;

destructor TRxColumnTitle.Destroy;
begin
  ClearCaptionML;
  FreeAndNil(FCaptionLines);
  inherited Destroy;
end;

{ TFilterListCellEditor }

procedure TFilterListCellEditor.WndProc(var TheMessage: TLMessage);
begin
  if TheMessage.msg = LM_KILLFOCUS then
  begin
    Change;
    Hide;
    if HWND(TheMessage.WParam) = HWND(Handle) then
    begin
      // lost the focus but it returns to ourselves
      // eat the message.
      TheMessage.Result := 0;
      exit;
    end;
  end;
  inherited WndProc(TheMessage);
end;

procedure TFilterListCellEditor.KeyDown(var Key: word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_RETURN:
    begin
      DroppedDown := False;
      Change;
      Hide;
    end;
  end;
end;

procedure TFilterListCellEditor.Show(Grid: TCustomGrid; Col: integer);
begin
  FGrid := Grid;
  FCol := Col;
  Visible := True;
  SetFocus;
end;


{ TRxColumnFilter }

function TRxColumnFilter.GetItemIndex: integer;
begin
  if CurrentValues.Count > 0 then
    Result := FValueList.IndexOf(CurrentValues[0])
  else
    Result := -1;
end;

function TRxColumnFilter.IsEmptyFontStored: Boolean;
begin
  Result:=FIsEmptyFontStored;
end;

function TRxColumnFilter.IsFontStored: Boolean;
begin
  Result:=FIsFontStored;
end;

procedure TRxColumnFilter.FontChanged(Sender: TObject);
begin
  if Sender = FFont then
    FIsFontStored:=not FFont.IsDefault
  else
    FIsEmptyFontStored:=not FEmptyFont.IsDefault;
  FOwner.ColumnChanged;
end;

function TRxColumnFilter.GetDisplayFilterValue: string;
begin
  Result:='';
  if CurrentValues.Count > 0 then
  begin
    Result:=CurrentValues[0];
    if CurrentValues.Count > 1 then
      Result:=Result + '(...)';
  end
  else
  if (Style in [rxfstManualEdit, rxfstBoth]) and (ManulEditValue<>'') then
    Result:=ManulEditValue
  else
  if State = rxfsEmpty then
    Result:=EmptyValue
  else
  if State = rxfsNonEmpty then
    Result:=NotEmptyValue
  else
  if State = rxfsAll then
    Result:=AllValue;
end;

procedure TRxColumnFilter.SetColor(const AValue: TColor);
begin
  if FColor = AValue then
    exit;
  FColor := AValue;
  FOwner.ColumnChanged;
end;

procedure TRxColumnFilter.SetEmptyFont(AValue: TFont);
begin
  if not FEmptyFont.IsEqual(AValue) then
    FEmptyFont.Assign(AValue);
end;

procedure TRxColumnFilter.SetFont(const AValue: TFont);
begin
  if not FFont.IsEqual(AValue) then
    FFont.Assign(AValue);
end;

procedure TRxColumnFilter.SetItemIndex(const AValue: integer);
begin
  if (AValue >= -1) and (AValue < FValueList.Count) then
  begin
    CurrentValues.Clear;
    if AValue > -1 then
      CurrentValues.Add(FValueList[AValue]);

    FOwner.ColumnChanged;
  end;
end;

constructor TRxColumnFilter.Create(Owner: TRxColumn);
begin
  inherited Create;
  FOwner := Owner;

  FFont := TFont.Create;
  FFont.OnChange:=@FontChanged;
  FEmptyFont := TFont.Create;
  FEmptyFont.OnChange:=@FontChanged;

  FValueList := TStringList.Create;
  FValueList.Sorted := True;
  FCurrentValues:=TStringList.Create;
  FCurrentValues.Sorted:=true;

  FColor := clWhite;
  State:=rxfsAll;
  Style:=rxfstSimple;

  FEmptyFont.Style := [fsItalic];
  FEmptyValue := sRxDBGridEmptyFilter;
  FAllValue := sRxDBGridAllFilter;
  FNotEmptyValue:=sRxDBGridNotEmptyFilter;
  FEnabled:=true;
end;

destructor TRxColumnFilter.Destroy;
begin
  FreeAndNil(FFont);
  FreeAndNil(FEmptyFont);
  FreeAndNil(FValueList);
  FreeAndNil(FCurrentValues);
  inherited Destroy;
end;

procedure TRxColumnFilter.ClearFilter;
begin
  CurrentValues.Clear;
  FManulEditValue:='';
  FState:=rxfsEmpty;
end;

{ TExDBGridSortEngine }

procedure TRxDBGridSortEngine.SortList(ListField: string; ADataSet: TDataSet;
  Asc: array of boolean; SortOptions: TRxSortEngineOptions);
begin

end;

{ TRxDBGridKeyStroke }

procedure TRxDBGridKeyStroke.SetCommand(const AValue: TRxDBGridCommand);
begin
  if FCommand = AValue then
    exit;
  FCommand := AValue;
  Changed(False);
end;

procedure TRxDBGridKeyStroke.SetShortCut(const AValue: TShortCut);
begin
  if FShortCut = AValue then
    exit;
  FShortCut := AValue;
  Menus.ShortCutToKey(FShortCut, FKey, FShift);
  Changed(False);
end;

function TRxDBGridKeyStroke.GetDisplayName: string;
begin
  IntToIdent(Ord(FCommand), Result, EditorCommandStrs);
  Result := Result + ' - ' + ShortCutToText(FShortCut);
end;

procedure TRxDBGridKeyStroke.Assign(Source: TPersistent);
begin
  if Source is TRxDBGridKeyStroke then
  begin
    Command := TRxDBGridKeyStroke(Source).Command;
    ShortCut := TRxDBGridKeyStroke(Source).ShortCut;
    Enabled := TRxDBGridKeyStroke(Source).Enabled;
  end
  else
    inherited Assign(Source);
end;

{ TRxDBGridKeyStrokes }

function TRxDBGridKeyStrokes.GetItem(Index: integer): TRxDBGridKeyStroke;
begin
  Result := TRxDBGridKeyStroke(inherited GetItem(Index));
end;

procedure TRxDBGridKeyStrokes.SetItem(Index: integer; const AValue: TRxDBGridKeyStroke);
begin
  inherited SetItem(Index, AValue);
end;

procedure TRxDBGridKeyStrokes.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if (UpdateCount = 0) and Assigned(Owner) and Assigned(TRxDBGrid(Owner).FKeyStrokes) then
    TRxDBGrid(Owner).UpdateJMenuKeys;
end;


constructor TRxDBGridKeyStrokes.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TRxDBGridKeyStroke);
end;

procedure TRxDBGridKeyStrokes.Assign(Source: TPersistent);
var
  i: integer;
begin
  if Source is TRxDBGridKeyStrokes then
  begin
    Clear;
    for i := 0 to TRxDBGridKeyStrokes(Source).Count-1 do
    begin
      with Add do
        Assign(TRxDBGridKeyStrokes(Source)[i]);
    end;
  end
  else
    inherited Assign(Source);
end;

function TRxDBGridKeyStrokes.Add: TRxDBGridKeyStroke;
begin
  Result := TRxDBGridKeyStroke(inherited Add);
  Result.Enabled := True;
end;

function TRxDBGridKeyStrokes.AddE(ACommand: TRxDBGridCommand;
  AShortCut: TShortCut): TRxDBGridKeyStroke;
begin
  Result := nil;
  Result := Add;
  Result.FShortCut := AShortCut;
  Result.FCommand := ACommand;
end;

procedure TRxDBGridKeyStrokes.ResetDefaults;
begin
  Clear;
  AddE(rxgcShowFindDlg, Menus.ShortCut(Ord('F'), [ssCtrl]));
  AddE(rxgcShowColumnsDlg, Menus.ShortCut(Ord('W'), [ssCtrl]));
  AddE(rxgcShowFilterDlg, Menus.ShortCut(Ord('T'), [ssCtrl]));
  AddE(rxgcShowSortDlg, Menus.ShortCut(Ord('S'), [ssCtrl]));
  AddE(rxgcShowQuickFilter, Menus.ShortCut(Ord('Q'), [ssCtrl]));
  AddE(rxgcHideQuickFilter, Menus.ShortCut(Ord('H'), [ssCtrl]));
  AddE(rxgcSelectAll, Menus.ShortCut(Ord('A'), [ssCtrl]));
  AddE(rxgcDeSelectAll, Menus.ShortCut(Ord('-'), [ssCtrl]));
  AddE(rxgcInvertSelection, Menus.ShortCut(Ord('*'), [ssCtrl]));
  AddE(rxgcOptimizeColumnsWidth, Menus.ShortCut(Ord('+'), [ssCtrl]));
  AddE(rxgcCopyCellValue, Menus.ShortCut(Ord('C'), [ssCtrl]));
end;

function TRxDBGridKeyStrokes.FindRxCommand(AKey: word;
  AShift: TShiftState): TRxDBGridCommand;
var
  i: integer;
  K: TRxDBGridKeyStroke;
begin
  Result := rxgcNone;
  for i := 0 to Count - 1 do
  begin
    K := Items[i];
    if (K.FKey = AKey) and (K.FShift = AShift) and (K.FEnabled) then
    begin
      Result := K.FCommand;
      exit;
    end;
  end;
end;

function TRxDBGridKeyStrokes.FindRxKeyStrokes(ACommand: TRxDBGridCommand):
TRxDBGridKeyStroke;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if (Items[i].Command = ACommand) then
    begin
      Result := Items[i];
      exit;
    end;
  end;
end;

initialization
  RegisterPropertyToSkip( TRxDBGrid, 'AllowedOperations', 'This property duplicated standart DBGrid.Options', '');
  RegisterPropertyToSkip( TRxColumnFilter, 'IsNull', 'depricated property', '');
  RegisterPropertyToSkip( TRxColumnFilter, 'IsAll', 'depricated property', '');
  RegisterPropertyToSkip( TRxColumnFilter, 'Value', 'depricated property', '');

  RxDBGridSortEngineList := TStringList.Create;
  RxDBGridSortEngineList.Sorted := True;

  FMarkerUp := CreateResBitmap('rx_markerup');
  FMarkerDown := CreateResBitmap('rx_markerdown');
  FEllipsisRxBMP:=CreateResBitmap('rx_Ellipsis');
  FGlyphRxBMP:=CreateResBitmap('rx_Glyph');
  FUpDownRxBMP:=CreateResBitmap('rx_UpDown');
  FPlusRxBMP:=CreateResBitmap('rx_plus');
  FMinusRxBMP:=CreateResBitmap('rx_minus');

finalization

  while (RxDBGridSortEngineList.Count > 0) do
  begin
    RxDBGridSortEngineList.Objects[0].Free;
    RxDBGridSortEngineList.Delete(0);
  end;
  RxDBGridSortEngineList.Free;

  FreeAndNil(FMarkerUp);
  FreeAndNil(FMarkerDown);
  FreeAndNil(FEllipsisRxBMP);
  FreeAndNil(FGlyphRxBMP);
  FreeAndNil(FUpDownRxBMP);
  FreeAndNil(FPlusRxBMP);
  FreeAndNil(FMinusRxBMP);
end.

