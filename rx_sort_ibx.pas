{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit rx_sort_ibx;

{$warn 5023 off : no warning about unused units}
interface

uses
  RxSortIBX, exsortibx, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('RxSortIBX', @RxSortIBX.Register);
end;

initialization
  RegisterPackage('rx_sort_ibx', @Register);
end.
