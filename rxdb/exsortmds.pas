{ exsortmds unit

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

unit exsortmds;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, RxDBGrid;

type

  { TMemDataSetSortEngine }

  TMemDataSetSortEngine = class(TRxDBGridSortEngine)
  public
    procedure Sort(FieldName: string; ADataSet:TDataSet; Asc:boolean; SortOptions:TRxSortEngineOptions);override;
  end;

implementation
uses memds;

type
  THackMDS = class(TMemDataSet)
  end;
  
procedure TMemDataSetSortEngine.Sort(FieldName: string; ADataSet: TDataSet;
  Asc: boolean; SortOptions: TRxSortEngineOptions);
var
  MS:TMemoryStream;
  V, FRecSize, FRecCount, I, J:integer;
  BufOrign, BufTest:PChar;
  PI, PJ:PInteger;
  S1:string;
  R1:Double;
  I1:integer;
  B1:boolean;
  D1:TDateTime;
  Field:TField;


function DoExch:boolean;
begin
  Result:=false;
  ADataSet.RecNo:=J+1;
  if Asc then
  begin
    case Field.DataType of
      ftFixedChar,
      ftWideString,
      ftString:Result:=S1 > Field.AsString;

      ftBoolean:Result:=B1 > Field.AsBoolean;

      ftInteger,
      ftWord,
      ftSmallint,
      ftAutoInc,
      ftLargeint:
        begin
          Result:=I1 > Field.AsInteger;
//          writeln('I1=', I1, '    I2=',Field.AsInteger,'  Result=', Result, '   i=',i, '   j=',j);
        end;

      ftFloat,
      ftCurrency,
      ftBCD:Result:=R1 > Field.AsFloat;

      ftDate,
      ftTime,
      ftDateTime,
      ftTimeStamp:Result:=D1 > Field.AsFloat;
    else
      exit;
    end;
  end
  else
  begin
    case Field.DataType of
      ftFixedChar,
      ftWideString,
      ftString:Result:=S1 < Field.AsString;

      ftBoolean:Result:=B1 < Field.AsBoolean;

      ftInteger,
      ftWord,
      ftSmallint,
      ftAutoInc,
      ftLargeint:Result:=I1 < Field.AsInteger;

      ftFloat,
      ftCurrency,
      ftBCD:Result:=R1 < Field.AsFloat;

      ftDate,
      ftTime,
      ftDateTime,
      ftTimeStamp:Result:=D1 < Field.AsFloat;
    else
      exit;
    end;
  end;
{  if not Asc then
    Result:=not Result;
  Result:=true;}
end;

begin
  if Assigned(ADataSet) then
  begin
    Field:=ADataSet.FieldByName(FieldName);
    ADataSet.DisableControls;
    MS:=TMemoryStream.Create;
    BufOrign:=THackMDS(ADataSet).AllocRecordBuffer;
    BufTest:=THackMDS(ADataSet).AllocRecordBuffer;
    PI:=@I;
    PJ:=@J;
    try
      THackMDS(ADataSet).SaveDataToStream(MS, true);
      MS.Seek(0, soFromBeginning);
      MS.Read(V, SizeOf(V)); // Marker
      MS.Read(V, SizeOf(V)); // Size
      FRecSize:=THackMDS(ADataSet).GetRecordSize;
      FRecCount:=V div FRecSize;
      for i:=0 to FRecCount-2 do
      begin
        MS.Seek(FRecSize*I + SizeOf(V)*2, soFromBeginning);
        MS.Read(BufOrign^, FRecSize);
        if i=0 then       //fix error
          ADataSet.First
        else
          ADataSet.RecNo:=I+1;

        case Field.DataType of
          ftFixedChar,
          ftWideString,
          ftString:S1:=Field.AsString;

          ftBoolean:B1:=Field.AsBoolean;

          ftInteger,
          ftWord,
          ftSmallint,
          ftAutoInc,
          ftLargeint:I1:=Field.AsInteger;

          ftFloat,
          ftCurrency,
          ftBCD:R1:=Field.AsFloat;

          ftDate,
          ftTime,
          ftDateTime,
          ftTimeStamp:D1:=Field.AsFloat;
{        else
          exit;}
        end;

        for j:=i+1 to FRecCount-1 do
        begin
          MS.Seek(FRecSize*j + SizeOf(V)*2, soFromBeginning);
          MS.Read(BufTest^, FRecSize);
          if DoExch then
          begin
            MS.Seek(FRecSize*j + SizeOf(V)*2, soFromBeginning);
            MS.Write(BufOrign^, FRecSize);
            Move(BufTest^, BufOrign^, FRecSize);
          end;
        end;
        THackMDS(ADataSet).SetBookmarkData(BufOrign, @PI);
        MS.Seek(FRecSize*I + SizeOf(V)*2, soFromBeginning);
        MS.Write(BufOrign^, FRecSize);
        MS.Seek(0, soFromBeginning);
       THackMDS(ADataSet).LoadDataFromStream(MS);
      end;
//    (ADataSet as TFBDataSet).SortOnField(Field.FieldName, Asc);}
      MS.Seek(0, soFromBeginning);
      THackMDS(ADataSet).LoadDataFromStream(MS);
    finally
      THackMDS(ADataSet).FreeRecordBuffer(BufOrign);
      THackMDS(ADataSet).FreeRecordBuffer(BufTest);
      MS.Free;
      ADataSet.EnableControls;
    end;
    THackMDS(ADataSet).First;
  end;
end;

initialization
  RegisterRxDBGridSortEngine(TMemDataSetSortEngine, 'TMemDataset');
end.

