unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, rxdbgrid,
  Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBGrids, Menus, ExtCtrls, DbCtrls, db, rxdbverticalgrid, rxmemds;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    dsData: TDataSource;
    ImageList1: TImageList;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    PopupMenu3: TPopupMenu;
    RadioGroup1: TRadioGroup;
    rxDataCREATE_USER_DATE: TDateTimeField;
    rxDataCREATE_USER_NAME: TStringField;
    rxDataTB_CLEINT_CODE: TLongintField;
    rxDataTB_CLEINT_MEMO: TMemoField;
    rxDataTB_CLEINT_TYPE: TLongintField;
    rxDataTB_CLIENT_EMAIL: TStringField;
    rxDataTB_CLIENT_ID: TAutoIncField;
    rxDataTB_CLIENT_IMAGE: TBlobField;
    rxDataTB_CLIENT_INN: TStringField;
    rxDataTB_CLIENT_NAME: TStringField;
    rxDataTB_CLIENT_PHONE: TStringField;
    rxDataVIP: TBooleanField;
    RxDBGrid1: TRxDBGrid;
    RxDBVerticalGrid1: TRxDBVerticalGrid;
    rxData: TRxMemoryData;
    Splitter1: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure FillDataBase;
  public

  end;

var
  Form1: TForm1;

implementation
uses LazUTF8, LazFileUtils;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  FillDataBase;
  CheckBox1.Checked:=rxvgColumnTitle in RxDBVerticalGrid1.Options;
  CheckBox2.Checked:=RxDBVerticalGrid1.Rows[11].ShowBlobImagesAndMemo;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  RxDBVerticalGrid1.DataSource:=nil;
  RxDBGrid1.DataSource:=nil;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  RxDBVerticalGrid1.DataSource:=dsData;
  RxDBGrid1.DataSource:=dsData;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked then
    RxDBVerticalGrid1.Options:=RxDBVerticalGrid1.Options + [rxvgColumnTitle]
  else
    RxDBVerticalGrid1.Options:=RxDBVerticalGrid1.Options - [rxvgColumnTitle]
    ;

  case RadioGroup1.ItemIndex of
    0:RxDBVerticalGrid1.Rows[11].Alignment:=taLeftJustify;
    1:RxDBVerticalGrid1.Rows[11].Alignment:=taRightJustify;
    2:RxDBVerticalGrid1.Rows[11].Alignment:=taCenter;
  end;
  RxDBVerticalGrid1.Rows[11].ShowBlobImagesAndMemo:=CheckBox2.Checked;
  RxDBVerticalGrid1.Rows[12].ShowBlobImagesAndMemo:=CheckBox2.Checked;

end;

procedure TForm1.FillDataBase;

procedure AppendRecord(AType, ACode:Integer; AINN, AName, ADesc, AEmail, APhone, AUser:string; AVip:boolean; AImageName:string);
var
  S: String;
begin
  rxData.Append;
  rxDataTB_CLEINT_TYPE.AsInteger:=AType;
  rxDataTB_CLEINT_CODE.AsInteger:=ACode;
  rxDataTB_CLIENT_INN.AsString:=AINN;
  rxDataTB_CLIENT_NAME.AsString:=AName;
  rxDataTB_CLEINT_MEMO.AsString:=ADesc;
  rxDataTB_CLIENT_EMAIL.AsString:=AEmail;
  rxDataTB_CLIENT_PHONE.AsString:=APhone;
  rxDataVIP.AsBoolean:=AVip;

  if AImageName <> '' then
  begin
    S:=AppendPathDelim(ExpandFileName(AppendPathDelim(ExtractFileDir(ParamStr(0))) + '..'+DirectorySeparator + '..'+DirectorySeparator + '..' + DirectorySeparator + '..')) + 'images' + DirectorySeparator;
    //ForceDirectories()
    // /usr/local/share/lazarus/components/rxnew/demos/RxDBVerticalGrid
    // /usr/local/share/lazarus/images
    if FileExistsUTF8(S + AImageName) then
      rxDataTB_CLIENT_IMAGE.LoadFromFile(S + AImageName);
  end;

  rxDataCREATE_USER_NAME.AsString:=AUser;
  rxDataCREATE_USER_DATE.AsDateTime:=Now + (200-Random * 100);
  rxData.Post;
end;

begin
  rxData.Open;
  AppendRecord(1, 1, '01000100101', 'JSC "BOOT"', 'Описание'#13'Строка 2'#13'Строка 3', 'test1@email.com', '5(555)-557-88-77', 'alexs', true, 'splash_logo.png');
  AppendRecord(2, 2, '02000100101', 'Wikimedia Foundation, Inc.', 'Описание', 'test2@email.com', '5(555)-557-88-77', 'boss', false, 'splash_logo.xpm');
  AppendRecord(3, 3, '03000100101', 'LLC Pilot ', 'Описание', 'test3@email.com', '5(555)-557-88-77', 'master', false, 'powered_by.png');
  AppendRecord(4, 4, '04000100101', 'Pilot, OOO', 'Описание', 'test4@email.com', '5(555)-557-88-77', 'onegin', false, 'folder.png');
  AppendRecord(5, 5, '05000100101', 'JSC "MS"', 'Описание', 'test5@email.com', '5(555)-557-88-77', 'alfred', false, 'splash_source'+DirectorySeparator + 'cheetah.jpg');
  AppendRecord(6, 11, '06000100101', 'JSC "AA"', 'Описание', 'test6@email.com', '5(555)-557-88-77', 'anna', false, 'mimetypes'+DirectorySeparator + 'text-lazarus-project-information.png');
  AppendRecord(7, 12, '07000100101', 'JSC "BBBB"', 'Описание', 'test7@email.com', '5(555)-557-88-77', 'tux', false, 'splash_source'+DirectorySeparator + 'paw.png');
  AppendRecord(8, 13, '08000100101', 'JSC "CCCC"', 'Описание', 'test8@email.com', '5(555)-557-88-77', 'x-man', false, '');
  AppendRecord(9, 14, '09000100101', 'JSC "DDD"', 'Описание', 'test9@email.com', '5(555)-557-88-77', 'arny', false, '');
  AppendRecord(10, 15, '101000200101', 'JSC "EEEE"', 'Описание', 'test10@email.com', '5(555)-557-88-77', 'andy', false, '');
  rxData.First;
end;

end.

