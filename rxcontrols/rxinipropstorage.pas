{ RxIniPropStorage unit

  Copyright (C) 2005-2018 Lagunov Aleksey alexs75@yandex.ru and Lazarus team
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

unit RxIniPropStorage;

{$I rx.inc}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, IniPropStorage;

type

  { TRxIniPropStorage }

  TRxIniPropStorage = class(TIniPropStorage)
  private
    FSeparateFiles: boolean;
  protected
    function GetIniFileName: string; override;
  public
    procedure StorageNeeded(ReadOnly: Boolean); override;
    { Public declarations }
  published
    property SeparateFiles:boolean read FSeparateFiles write FSeparateFiles;
  end;

implementation
uses rxapputils, LazUTF8, FileUtil, LazFileUtils, IniFiles;

{ TRxIniPropStorage }

function TRxIniPropStorage.GetIniFileName: string;
var
  S:string;
begin
  if ExtractFileDir(IniFileName) <> '' then
    Result:=IniFileName
  else
  begin
    S:=GetDefaultIniName;
    if IniFileName <> '' then
      Result:=AppendPathDelim(ExtractFileDir(S)) + IniFileName
    else
    begin
      if FSeparateFiles then
        Result:=AppendPathDelim(ExtractFileDir(S)) + RootSection + '.cfg'
      else
        Result:=S;
    end;
  end;
  Result:=UTF8ToSys(Result);
end;

procedure TRxIniPropStorage.StorageNeeded(ReadOnly: Boolean);
var
  F: Boolean;
begin
  F:=Assigned(IniFile);
  inherited StorageNeeded(ReadOnly);
  if Assigned(IniFile) and (not F) then
    if IniFile is TIniFile then
      TIniFile(IniFile).CacheUpdates:=true;
end;

end.
