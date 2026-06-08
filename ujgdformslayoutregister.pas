unit ujgdformslayoutregister;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLIntf, LResources, ujgdformslayout;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('JGoodies', [TJgdFormLayout]);
end;

end.
