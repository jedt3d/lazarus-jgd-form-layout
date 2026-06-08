program SimpleApp;

{$mode objfpc}{$H+}
{$APPTYPE GUI}

uses
  Interfaces,
  Forms,
  uSimpleForm;

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TSimpleForm, SimpleForm);
  Application.Run;
end.
