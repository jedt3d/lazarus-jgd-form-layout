program EmployeeApp;

{$mode objfpc}{$H+}
{$APPTYPE GUI}

uses
  Interfaces,
  Forms,
  uEmployeeForm;

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TEmployeeForm, EmployeeForm);
  Application.Run;
end.
