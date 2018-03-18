{ RxStrUtils unit

  Copyright (C) 2005-2017 Lagunov Aleksey alexs@yandex.ru and Lazarus team
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

unit rxutils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure SwapValues (var X, Y : Byte); inline; overload;
procedure SwapValues (var X, Y : Word); inline; overload;
procedure SwapValues (var X, Y : Integer); inline; overload;
//procedure SwapValues (var X, Y : Longint); inline; overload;
procedure SwapValues (var X, Y : Cardinal); inline; overload;
procedure SwapValues (var X, Y : QWord); inline; overload;
procedure SwapValues (var X, Y : Int64); inline; overload;
{procedure Swap (X : Integer) : Integer;{$ifdef SYSTEMINLINE}inline;{$endif}[internconst:fpc_in_const_swap_word];
function swap (X : Longint) : Longint;{$ifdef SYSTEMINLINE}inline;{$endif}[internconst:fpc_in_const_swap_long];
function Swap (X : Cardinal) : Cardinal;{$ifdef SYSTEMINLINE}inline;{$endif}[internconst:fpc_in_const_swap_long];
function Swap (X : QWord) : QWord;{$ifdef SYSTEMINLINE}inline;{$endif}[internconst:fpc_in_const_swap_qword];
function swap (X : Int64) : Int64;{$ifdef SYSTEMINLINE}inline;{$endif}[internconst:fpc_in_const_swap_qword];
}
implementation

procedure SwapValues(var X, Y: Byte);
var
  T: Byte;
begin
  T:=X;
  X:=Y;
  Y:=T;
end;

procedure SwapValues(var X, Y: Word);
var
  T: Word;
begin
  T:=X;
  X:=Y;
  Y:=T;
end;

procedure SwapValues(var X, Y: Integer);
var
  T: Integer;
begin
  T:=X;
  X:=Y;
  Y:=T;
end;
{
procedure SwapValues(var X, Y: Longint);
var
  T: LongInt;
begin
  T:=X;
  X:=Y;
  Y:=T;
end;
}
procedure SwapValues(var X, Y: Cardinal);
var
  T: Cardinal;
begin
  T:=X;
  X:=Y;
  Y:=T;
end;

procedure SwapValues(var X, Y: QWord);
var
  T: QWord;
begin
  T:=X;
  X:=Y;
  Y:=T;
end;

procedure SwapValues(var X, Y: Int64);
var
  T: Int64;
begin
  T:=X;
  X:=Y;
  Y:=T;
end;

end.

