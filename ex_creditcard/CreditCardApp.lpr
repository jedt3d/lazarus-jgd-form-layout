program CreditCardApp;

{$mode objfpc}{$H+}
{$APPTYPE GUI}

uses
  Interfaces,
  Forms,
  uCreditCardForm;

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TCreditCardForm, CreditCardForm);
  Application.Run;
end.
