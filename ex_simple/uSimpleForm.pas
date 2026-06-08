unit uSimpleForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ujgdformslayout;

type
  TSimpleForm = class(TForm)
    pnlMain: TJgdFormLayout;
    lblMessage: TLabel;
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  SimpleForm: TSimpleForm;

implementation

{$R *.lfm}

procedure TSimpleForm.FormCreate(Sender: TObject);
begin
  lblMessage.Caption := 'Hello from Simple standard application!';
end;

end.
