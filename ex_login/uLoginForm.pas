unit uLoginForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ujgdformslayout;

type
  TLoginForm = class(TForm)
    FLayout: TJgdFormLayout;
    FTitleLabel: TLabel;
    FSubTitleLabel: TLabel;
    FEmailLabel: TLabel;
    FEmailEdit: TEdit;
    FPassLabel: TLabel;
    FPassEdit: TEdit;
    FRememberPanel: TPanel;
    FRememberCheckBox: TCheckBox;
    FForgotLabel: TLabel;
    FBtnSignIn: TPanel;
    FBtnGoogle: TPanel;
    FGoogleContentPanel: TPanel;
    FGoogleLogo: TPaintBox;
    FGoogleSpacer: TPanel;
    FGoogleText: TLabel;
    FFooterPanel: TPanel;
    FNoAccountLabel: TLabel;
    FSignUpLabel: TLabel;
    procedure GoogleLogoPaint(Sender: TObject);
    procedure BtnSignInClick(Sender: TObject);
    procedure BtnSignInMouseEnter(Sender: TObject);
    procedure BtnSignInMouseLeave(Sender: TObject);
    procedure BtnGoogleClick(Sender: TObject);
    procedure BtnGoogleMouseEnter(Sender: TObject);
    procedure BtnGoogleMouseLeave(Sender: TObject);
    procedure ForgotPasswordClick(Sender: TObject);
    procedure SignUpClick(Sender: TObject);
  private
  public
  end;

var
  LoginForm: TLoginForm;

implementation

{$R *.lfm}

procedure TLoginForm.GoogleLogoPaint(Sender: TObject);
var
  LCanvas: TCanvas;
  R: TRect;
begin
  LCanvas := TPaintBox(Sender).Canvas;
  R := TPaintBox(Sender).ClientRect;
  
  // Clear background matching parent button state
  LCanvas.Brush.Color := FGoogleContentPanel.Color;
  LCanvas.FillRect(R);
  
  LCanvas.Pen.Style := psClear;
  
  // Google Red arc (Top)
  LCanvas.Brush.Color := $282BEA; // #EA4335
  LCanvas.Pie(R.Left, R.Top, R.Right, R.Bottom, R.Right, R.Top, R.Left, R.Top);
  
  // Google Yellow arc (Left)
  LCanvas.Brush.Color := $10C6FF; // #FBBC05
  LCanvas.Pie(R.Left, R.Top, R.Right, R.Bottom, R.Left, R.Top, R.Left, R.Bottom);
  
  // Google Green arc (Bottom)
  LCanvas.Brush.Color := $41A935; // #34A853
  LCanvas.Pie(R.Left, R.Top, R.Right, R.Bottom, R.Left, R.Bottom, R.Right, R.Bottom);
  
  // Google Blue arc (Right)
  LCanvas.Brush.Color := $E08B00; // #4285F4
  LCanvas.Pie(R.Left, R.Top, R.Right, R.Bottom, R.Right, R.Bottom, R.Right, R.Top);
  
  // Center hole cutout (turns sectors into G-ring)
  LCanvas.Brush.Color := FGoogleContentPanel.Color;
  LCanvas.Ellipse(R.Left + 4, R.Top + 4, R.Right - 4, R.Bottom - 4);
  
  // Blue horizontal crossbar
  LCanvas.Brush.Color := $E08B00; // #4285F4
  LCanvas.FillRect(R.Left + R.Width div 2, R.Top + R.Height div 2 - 2, R.Right, R.Top + R.Height div 2 + 2);
  
  // Cutout sector gap above crossbar
  LCanvas.Brush.Color := FGoogleContentPanel.Color;
  LCanvas.Pie(R.Left + 3, R.Top + 3, R.Right - 3, R.Bottom - 3, R.Right, R.Top + R.Height div 2 - 2, R.Right, R.Top + 1);
end;

procedure TLoginForm.BtnSignInClick(Sender: TObject);
begin
  if (FEmailEdit.Text = '') or (FPassEdit.Text = '') then
    ShowMessage('Please fill in both Email and Password!')
  else
    ShowMessage('Signing in with: ' + FEmailEdit.Text);
end;

procedure TLoginForm.BtnSignInMouseEnter(Sender: TObject);
begin
  FBtnSignIn.Color := $C64169; // Darker Purple (#6941C6)
end;

procedure TLoginForm.BtnSignInMouseLeave(Sender: TObject);
begin
  FBtnSignIn.Color := $D9567F; // Original Purple (#7F56D9)
end;

procedure TLoginForm.BtnGoogleClick(Sender: TObject);
begin
  ShowMessage('Connecting to Google accounts...');
end;

procedure TLoginForm.BtnGoogleMouseEnter(Sender: TObject);
begin
  FBtnGoogle.Color := $F9F9F9; // Soft hover grey
  FGoogleContentPanel.Color := $F9F9F9;
  FGoogleSpacer.Color := $F9F9F9;
  FGoogleLogo.Invalidate;
end;

procedure TLoginForm.BtnGoogleMouseLeave(Sender: TObject);
begin
  FBtnGoogle.Color := clWhite;
  FGoogleContentPanel.Color := clWhite;
  FGoogleSpacer.Color := clWhite;
  FGoogleLogo.Invalidate;
end;

procedure TLoginForm.ForgotPasswordClick(Sender: TObject);
begin
  ShowMessage('Redirecting to reset password...');
end;

procedure TLoginForm.SignUpClick(Sender: TObject);
begin
  ShowMessage('Redirecting to sign up page...');
end;

end.
