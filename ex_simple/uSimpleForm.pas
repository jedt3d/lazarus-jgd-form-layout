unit uSimpleForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ujgdformslayout;

type
  TSimpleForm = class(TForm)
    pnlMain: TJgdFormLayout;
    lblMessage: TLabel;
    lblMessageRight: TLabel;
    pnlBottom: TJgdFormLayout;
    btnDontSave: TButton;
    btnCancel: TButton;
    btnSave: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnDontSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
  public
  end;

var
  SimpleForm: TSimpleForm;

implementation

{$R *.lfm}

procedure TSimpleForm.FormCreate(Sender: TObject);
begin
  lblMessage.Caption := 'Hello from Left side!';
  lblMessageRight.Caption := 'Hello from Right side!';
end;

procedure TSimpleForm.btnDontSaveClick(Sender: TObject);
begin
  ShowMessage('Don''t Save clicked!');
end;

procedure TSimpleForm.btnCancelClick(Sender: TObject);
begin
  ShowMessage('Cancel clicked!');
end;

procedure TSimpleForm.btnSaveClick(Sender: TObject);
begin
  ShowMessage('Save clicked!');
end;

end.
