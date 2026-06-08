program AddressApp;

{$mode objfpc}{$H+}
{$APPTYPE GUI}

uses
  Interfaces,
  Forms,
  uAddressForm;

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TAddressForm, AddressForm);
  Application.Run;
end.
