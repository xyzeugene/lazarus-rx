unit exsortibx;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, RxDBGrid;

type

  { TZeosDataSetSortEngine }

  { TIBXDataSetSortEngine }

  TIBXDataSetSortEngine = class(TRxDBGridSortEngine)
  protected
  public
    procedure Sort(FieldName: string; ADataSet:TDataSet; Asc:boolean; SortOptions:TRxSortEngineOptions);override;
    procedure SortList(ListField: string; ADataSet: TDataSet; Asc: array of boolean; SortOptions: TRxSortEngineOptions); override;
  end;

implementation
uses IBCustomDataSet;

function FixFieldName(S:string):string;inline;
begin
  if not IsValidIdent(S) then
    Result:='"'+S+'"'
  else
    Result:=S;
end;

{ TIBXDataSetSortEngine }

procedure TIBXDataSetSortEngine.Sort(FieldName: string; ADataSet: TDataSet;
  Asc: boolean; SortOptions: TRxSortEngineOptions);
begin
  if not Assigned(ADataSet) then exit;

  if ADataSet is TIBCustomDataSet then
  begin
    if Asc then
      FieldName := FixFieldName(FieldName) + ' Asc'
    else
      FieldName := FixFieldName(FieldName) + ' Desc';
    TIBCustomDataSet(ADataSet).OrderFields:=FieldName;
  end;
end;

procedure TIBXDataSetSortEngine.SortList(ListField: string; ADataSet: TDataSet;
  Asc: array of boolean; SortOptions: TRxSortEngineOptions);
var
  S: String;
  C: SizeInt;
  i: Integer;
begin
  if not Assigned(ADataSet) then exit;

  S:='';
  C:=Pos(';', ListField);
  i:=0;
  while C>0 do
  begin
    if S<>'' then S:=S+';';
    S:=S + FixFieldName(Copy(ListField, 1, C-1));
    Delete(ListField, 1, C);

    if (i<=High(Asc)) and (not Asc[i]) then
      S:=S + ' DESC';
    C:=Pos(';', ListField);
    inc(i);
  end;

  if ListField<>'' then
  begin
    if S<>'' then S:=S+';';
    S:=S + FixFieldName(ListField);
    if (i<=High(Asc)) and (not Asc[i]) then
      S:=S + ' DESC';
  end;

  (ADataSet as TIBCustomDataSet).OrderFields:=S;
end;

initialization
  RegisterRxDBGridSortEngine(TIBXDataSetSortEngine, 'TIBQuery');
  RegisterRxDBGridSortEngine(TIBXDataSetSortEngine, 'TIBDataSet');
end.

