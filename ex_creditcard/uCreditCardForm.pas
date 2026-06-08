unit uCreditCardForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Types, ujgdformslayout;

type
  TCreditCardForm = class(TForm)
    pnlTitleBar: TPanel;
    lblTitle: TLabel;
    lblClose: TLabel;
    { pnlFields layout: Columns = fill:pref:grow; Rows = pref, 10dlu, pref, 10dlu, pref, 10dlu, pref }
    pnlFields: TJgdFormLayout;
    paintCards: TPaintBox;
    edtName: TEdit;
    pnlCardInput: TPanel;
    paintBrandLogo: TPaintBox;
    edtCardNumber: TEdit;
    { pnlBottomLayout layout: Columns = pref, fill:0:grow, 60dlu, 8dlu, 40dlu; Rows = pref }
    pnlBottomLayout: TJgdFormLayout;
    btnSubmit: TButton;
    edtExpiry: TEdit;
    edtCVC: TEdit;

    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure lblCloseClick(Sender: TObject);
    procedure lblCloseMouseEnter(Sender: TObject);
    procedure lblCloseMouseLeave(Sender: TObject);
    procedure paintCardsPaint(Sender: TObject);
    procedure paintBrandLogoPaint(Sender: TObject);
    procedure edtCardNumberChange(Sender: TObject);
    procedure edtCardNumberKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtExpiryChange(Sender: TObject);
    procedure edtExpiryKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtCVCChange(Sender: TObject);
    procedure edtNameChange(Sender: TObject);
    procedure btnSubmitClick(Sender: TObject);
    
    // Draggable window events
    procedure pnlTitleBarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnlTitleBarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pnlTitleBarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FDragging: Boolean;
    FDragStart: TPoint;
    
    function GetCardBrand: string;
    procedure GetCardParts(out ANumber, AExpiry, ACvc: string);
    procedure DrawBrandLogo(ACanvas: TCanvas; ARect: TRect; const ABrand: string; AOnCard: Boolean);
  public
  end;

var
  CreditCardForm: TCreditCardForm;

implementation

{$R *.lfm}

{ Helper functions }

function IsLuhnValid(const ACardNumber: string): Boolean;
var
  I, Digit, Sum, Addend: Integer;
  Odd: Boolean;
begin
  Sum := 0;
  Odd := False;
  for I := Length(ACardNumber) downTo 1 do
  begin
    if ACardNumber[I] in ['0'..'9'] then
    begin
      Digit := Ord(ACardNumber[I]) - Ord('0');
      if Odd then
      begin
        Addend := Digit * 2;
        if Addend > 9 then
          Dec(Addend, 9);
      end
      else
        Addend := Digit;
      Sum := Sum + Addend;
      Odd := not Odd;
    end;
  end;
  Result := (Sum > 0) and (Sum mod 10 = 0);
end;

{ TCreditCardForm }

procedure TCreditCardForm.FormCreate(Sender: TObject);
begin
  FDragging := False;
  Self.DoubleBuffered := True;
  
  // Set default values matching mockup
  edtName.Text := 'LUKE WALKER';
  edtCardNumber.Text := '5324 1801 2345 6789';
  edtExpiry.Text := '09/30';
  edtCVC.Text := '324';
end;

procedure TCreditCardForm.FormPaint(Sender: TObject);
begin
  Canvas.Pen.Color := TColor($A07040); // Steel blue border in BGR
  Canvas.Pen.Width := 1;
  Canvas.Brush.Style := bsClear;
  Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);
end;

procedure TCreditCardForm.lblCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TCreditCardForm.lblCloseMouseEnter(Sender: TObject);
begin
  lblClose.Font.Color := clRed;
end;

procedure TCreditCardForm.lblCloseMouseLeave(Sender: TObject);
begin
  lblClose.Font.Color := TColor($333333);
end;

function TCreditCardForm.GetCardBrand: string;
var
  S: string;
  I: Integer;
  Digits: string;
begin
  S := edtCardNumber.Text;
  Digits := '';
  for I := 1 to Length(S) do
    if S[I] in ['0'..'9'] then
      Digits := Digits + S[I];

  if Length(Digits) > 0 then
  begin
    if Digits[1] = '4' then
      Exit('VISA')
    else if Digits[1] = '5' then
      Exit('MASTERCARD');
  end;
  Result := 'UNKNOWN';
end;

procedure TCreditCardForm.GetCardParts(out ANumber, AExpiry, ACvc: string);
var
  NumDigits: string;
  I: Integer;
begin
  NumDigits := '';
  for I := 1 to Length(edtCardNumber.Text) do
    if edtCardNumber.Text[I] in ['0'..'9'] then
      NumDigits := NumDigits + edtCardNumber.Text[I];
      
  ANumber := NumDigits;
  while Length(ANumber) < 16 do
    ANumber := ANumber + 'x';
    
  ANumber := Copy(ANumber, 1, 4) + ' ' + Copy(ANumber, 5, 4) + ' ' + Copy(ANumber, 9, 4) + ' ' + Copy(ANumber, 13, 4);

  // Expiry
  AExpiry := edtExpiry.Text;
  if AExpiry = '' then
    AExpiry := 'MM/YY';

  // Cvc
  ACvc := edtCVC.Text;
  if ACvc = '' then
    ACvc := 'XXX';
end;

procedure TCreditCardForm.DrawBrandLogo(ACanvas: TCanvas; ARect: TRect; const ABrand: string; AOnCard: Boolean);
var
  Radius, CX, CY: Integer;
begin
  ACanvas.Pen.Style := psClear;
  ACanvas.Brush.Style := bsSolid;
  
  if ABrand = 'VISA' then
  begin
    ACanvas.Font.Name := 'Segoe UI';
    ACanvas.Font.Style := [fsBold, fsItalic];
    ACanvas.Font.Size := 9;
    if AOnCard then
      ACanvas.Font.Color := clWhite
    else
      ACanvas.Font.Color := TColor($8A3B1A);
      
    ACanvas.TextOut(ARect.Left + (ARect.Width - ACanvas.TextWidth('VISA')) div 2, 
                    ARect.Top + (ARect.Height - ACanvas.TextHeight('VISA')) div 2, 
                    'VISA');
  end
  else if ABrand = 'MASTERCARD' then
  begin
    Radius := (ARect.Height * 7) div 20;
    CY := ARect.Top + ARect.Height div 2;
    
    ACanvas.Brush.Color := TColor($2A2AEB);
    CX := ARect.Left + (ARect.Width * 4) div 10;
    ACanvas.Ellipse(CX - Radius, CY - Radius, CX + Radius, CY + Radius);
    
    ACanvas.Brush.Color := TColor($10A5F9);
    CX := ARect.Left + (ARect.Width * 6) div 10;
    ACanvas.Ellipse(CX - Radius, CY - Radius, CX + Radius, CY + Radius);
  end
  else
  begin
    ACanvas.Brush.Color := TColor($E0E0E0);
    if AOnCard then
      ACanvas.Brush.Color := TColor($90A0B0);
      
    ACanvas.RoundRect(ARect.Left + 2, ARect.Top + 2, ARect.Right - 2, ARect.Bottom - 2, 4, 4);
    
    ACanvas.Brush.Color := TColor($B0B0B0);
    if AOnCard then
      ACanvas.Brush.Color := TColor($A8B8C8);
      
    ACanvas.FillRect(ARect.Left + 6, ARect.Top + 6, ARect.Left + 12, ARect.Top + 10);
  end;
end;

procedure TCreditCardForm.paintCardsPaint(Sender: TObject);
var
  LCanvas: TCanvas;
  CardNum, Expiry, Cvc: string;
  Brand: string;
begin
  LCanvas := paintCards.Canvas;
  GetCardParts(CardNum, Expiry, Cvc);
  Brand := GetCardBrand;

  LCanvas.Brush.Color := Self.Color;
  LCanvas.FillRect(paintCards.ClientRect);

  LCanvas.Pen.Style := psClear;
  LCanvas.Brush.Style := bsSolid;

  // 1. Draw Back Card
  LCanvas.Brush.Color := TColor($D29864);
  LCanvas.RoundRect(110, 30, 330, 160, 10, 10);

  LCanvas.Brush.Color := clBlack;
  LCanvas.FillRect(110, 45, 330, 68);

  LCanvas.Brush.Color := clWhite;
  LCanvas.FillRect(250, 80, 310, 102);

  LCanvas.Font.Name := 'Segoe UI';
  LCanvas.Font.Size := 9;
  LCanvas.Font.Color := clBlack;
  LCanvas.Font.Style := [];
  LCanvas.TextOut(255, 82, Cvc);

  LCanvas.Font.Size := 7;
  LCanvas.Font.Color := clWhite;
  LCanvas.TextOut(255, 105, 'CVC code');

  // 2. Draw Front Card
  LCanvas.Brush.Color := TColor($C57B3B);
  LCanvas.RoundRect(20, 10, 240, 140, 10, 10);

  LCanvas.Font.Name := 'Segoe UI';
  LCanvas.Font.Size := 9;
  LCanvas.Font.Color := clWhite;
  LCanvas.Font.Style := [fsBold];
  LCanvas.TextOut(190, 20, 'BANK');

  LCanvas.Font.Name := 'Consolas';
  LCanvas.Font.Size := 11;
  LCanvas.Font.Color := clWhite;
  LCanvas.Font.Style := [fsBold];
  LCanvas.TextOut(32, 58, CardNum);

  LCanvas.Font.Name := 'Segoe UI';
  LCanvas.Font.Size := 9;
  LCanvas.Font.Color := clWhite;
  LCanvas.Font.Style := [];
  LCanvas.TextOut(35, 92, UpperCase(edtName.Text));

  LCanvas.Font.Size := 8;
  LCanvas.TextOut(35, 110, Expiry);

  DrawBrandLogo(LCanvas, Rect(190, 95, 225, 118), Brand, True);
end;

procedure TCreditCardForm.paintBrandLogoPaint(Sender: TObject);
begin
  DrawBrandLogo(paintBrandLogo.Canvas, paintBrandLogo.ClientRect, GetCardBrand, False);
end;

procedure TCreditCardForm.edtCardNumberChange(Sender: TObject);
var
  S, Digits, Formatted: string;
  I, DigitCount, OrigSelStart, TargetSelStart, DigitIndexAtCursor: Integer;
begin
  S := edtCardNumber.Text;
  OrigSelStart := edtCardNumber.SelStart;
  
  DigitIndexAtCursor := 0;
  for I := 1 to OrigSelStart do
    if S[I] in ['0'..'9'] then
      Inc(DigitIndexAtCursor);
      
  Digits := '';
  for I := 1 to Length(S) do
    if S[I] in ['0'..'9'] then
      Digits := Digits + S[I];
      
  if Length(Digits) > 16 then
    Digits := Copy(Digits, 1, 16);
    
  Formatted := '';
  DigitCount := Length(Digits);
  for I := 1 to DigitCount do
  begin
    Formatted := Formatted + Digits[I];
    if (I mod 4 = 0) and (I < 16) and (I < DigitCount) then
      Formatted := Formatted + ' ';
  end;
  
  if edtCardNumber.Text <> Formatted then
  begin
    edtCardNumber.Text := Formatted;
    
    TargetSelStart := 0;
    I := 0;
    while (I < Length(Formatted)) and (DigitIndexAtCursor > 0) do
    begin
      Inc(I);
      Inc(TargetSelStart);
      if Formatted[I] in ['0'..'9'] then
        Dec(DigitIndexAtCursor);
    end;
    
    if (TargetSelStart < Length(Formatted)) and (Formatted[TargetSelStart + 1] = ' ') then
      Inc(TargetSelStart);
      
    edtCardNumber.SelStart := TargetSelStart;
  end;
  
  paintCards.Invalidate;
  paintBrandLogo.Invalidate;
end;

procedure TCreditCardForm.edtCardNumberKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  SelStartVal: Integer;
  S: string;
begin
  if Key = 8 then
  begin
    SelStartVal := edtCardNumber.SelStart;
    S := edtCardNumber.Text;
    if (SelStartVal > 0) and (SelStartVal <= Length(S)) then
    begin
      if S[SelStartVal] = ' ' then
      begin
        Delete(S, SelStartVal - 1, 2);
        edtCardNumber.Text := S;
        edtCardNumber.SelStart := SelStartVal - 2;
        Key := 0;
      end;
    end;
  end;
end;

procedure TCreditCardForm.edtExpiryChange(Sender: TObject);
var
  S, Digits, Formatted: string;
  I, DigitCount, OrigSelStart, TargetSelStart, DigitIndexAtCursor: Integer;
begin
  S := edtExpiry.Text;
  OrigSelStart := edtExpiry.SelStart;
  
  DigitIndexAtCursor := 0;
  for I := 1 to OrigSelStart do
    if S[I] in ['0'..'9'] then
      Inc(DigitIndexAtCursor);
      
  Digits := '';
  for I := 1 to Length(S) do
    if S[I] in ['0'..'9'] then
      Digits := Digits + S[I];
      
  if Length(Digits) > 4 then
    Digits := Copy(Digits, 1, 4);
    
  Formatted := '';
  DigitCount := Length(Digits);
  for I := 1 to DigitCount do
  begin
    Formatted := Formatted + Digits[I];
    if (I = 2) and (DigitCount > 2) then
      Formatted := Formatted + '/';
  end;
  
  if edtExpiry.Text <> Formatted then
  begin
    edtExpiry.Text := Formatted;
    
    TargetSelStart := 0;
    I := 0;
    while (I < Length(Formatted)) and (DigitIndexAtCursor > 0) do
    begin
      Inc(I);
      Inc(TargetSelStart);
      if Formatted[I] in ['0'..'9'] then
        Dec(DigitIndexAtCursor);
    end;
    
    if (TargetSelStart < Length(Formatted)) and (Formatted[TargetSelStart + 1] = '/') then
      Inc(TargetSelStart);
      
    edtExpiry.SelStart := TargetSelStart;
  end;
  
  paintCards.Invalidate;
end;

procedure TCreditCardForm.edtExpiryKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  SelStartVal: Integer;
  S: string;
begin
  if Key = 8 then
  begin
    SelStartVal := edtExpiry.SelStart;
    S := edtExpiry.Text;
    if (SelStartVal > 0) and (SelStartVal <= Length(S)) then
    begin
      if S[SelStartVal] = '/' then
      begin
        Delete(S, SelStartVal - 1, 2);
        edtExpiry.Text := S;
        edtExpiry.SelStart := SelStartVal - 2;
        Key := 0;
      end;
    end;
  end;
end;

procedure TCreditCardForm.edtCVCChange(Sender: TObject);
var
  S, Digits: string;
  I: Integer;
begin
  S := edtCVC.Text;
  Digits := '';
  for I := 1 to Length(S) do
    if S[I] in ['0'..'9'] then
      Digits := Digits + S[I];
      
  if Length(Digits) > 4 then
    Digits := Copy(Digits, 1, 4);
    
  if edtCVC.Text <> Digits then
    edtCVC.Text := Digits;
    
  paintCards.Invalidate;
end;

procedure TCreditCardForm.edtNameChange(Sender: TObject);
begin
  paintCards.Invalidate;
end;

procedure TCreditCardForm.btnSubmitClick(Sender: TObject);
var
  S, Digits, CardNum: string;
  I: Integer;
begin
  S := edtCardNumber.Text;
  Digits := '';
  for I := 1 to Length(S) do
    if S[I] in ['0'..'9'] then
      Digits := Digits + S[I];

  CardNum := Digits;
  
  if Length(CardNum) < 13 then
  begin
    ShowMessage('Card validation failed: Card number is too short.');
  end
  else if IsLuhnValid(CardNum) then
  begin
    ShowMessage('Success: Credit Card details are valid! (Luhn algorithm passed)');
  end
  else
  begin
    ShowMessage('Error: Invalid Credit Card number! (Luhn check failed)');
  end;
end;

procedure TCreditCardForm.pnlTitleBarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDragging := True;
    FDragStart := Point(X, Y);
  end;
end;

procedure TCreditCardForm.pnlTitleBarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  if FDragging then
  begin
    P := ClientToScreen(Point(X, Y));
    Left := P.X - FDragStart.X;
    Top := P.Y - FDragStart.Y;
  end;
end;

procedure TCreditCardForm.pnlTitleBarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
end;

end.
