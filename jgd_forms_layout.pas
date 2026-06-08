{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit jgd_forms_layout;

{$warn 5023 off : no warning about unused units}
interface

uses
  ujgdformslayout, ujgdformslayoutregister, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ujgdformslayoutregister', @ujgdformslayoutregister.Register);
end;

initialization
  RegisterPackage('jgd_forms_layout', @Register);
end.
