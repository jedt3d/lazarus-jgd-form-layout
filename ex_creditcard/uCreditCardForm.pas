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
    pnlFields: TJgdFormLayout;
    paintCards: TPaintBox;
    edtName: TEdit;
    pnlCardInput: TPanel;
    paintBrandLogo: TPaintBox;
    edtCardDetails: TEdit;
    btnSubmit: TPanel;

    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure lblCloseClick(Sender: TObject);
    procedure lblCloseMouseEnter(Sender: TObject);
    procedure lblCloseMouseLeave(Sender: TObject);
    procedure paintCardsPaint(Sender: TObject);
    procedure paintBrandLogoPaint(Sender: TObject);
    procedure edtCardDetailsChange(Sender: TObject);
    procedure edtCardDetailsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtNameChange(Sender: TObject);
    procedure btnSubmitClick(Sender: TObject);
    procedure btnSubmitMouseEnter(Sender: TObject);
    procedure btnSubmitMouseLeave(Sender: TObject);
    
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
  
  // Set default placeholder/hint values matching the mockup
  edtName.Text := 'LUKE WALKER';
  edtCardDetails.Text := '5324 1801 2345 6789 09/30 324';
end;

procedure TCreditCardForm.FormPaint(Sender: TObject);
begin
  // Draw the custom 1px steel blue border around the borderless window
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
  S := edtCardDetails.Text;
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
  S: string;
  Digits: string;
  I: Integer;
begin
  S := edtCardDetails.Text;
  Digits := '';
  for I := 1 to Length(S) do
    if S[I] in ['0'..'9'] then
      Digits := Digits + S[I];

  // Card Number (up to 16 digits)
  ANumber := Copy(Digits, 1, 16);
  while Length(ANumber) < 16 do
    ANumber := ANumber + 'x';
    
  // Format Card Number with spaces
  ANumber := Copy(ANumber, 1, 4) + ' ' + Copy(ANumber, 5, 4) + ' ' + Copy(ANumber, 9, 4) + ' ' + Copy(ANumber, 13, 4);

  // Expiry (digits 17 to 20)
  AExpiry := Copy(Digits, 17, 4);
  if Length(AExpiry) > 0 then
  begin
    if Length(AExpiry) < 4 then
      AExpiry := AExpiry + StringOfChar('x', 4 - Length(AExpiry));
    AExpiry := Copy(AExpiry, 1, 2) + '/' + Copy(AExpiry, 3, 2);
  end
  else
    AExpiry := 'MM/YY';

  // Cvc (digits 21+)
  if Length(Digits) >= 21 then
    ACvc := Copy(Digits, 21, 4)
  else
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
    // Draw Visa text
    ACanvas.Font.Name := 'Segoe UI';
    ACanvas.Font.Style := [fsBold, fsItalic];
    ACanvas.Font.Size := 9;
    if AOnCard then
      ACanvas.Font.Color := clWhite
    else
      ACanvas.Font.Color := TColor($8A3B1A); // Dark blue in BGR
      
    ACanvas.TextOut(ARect.Left + (ARect.Width - ACanvas.TextWidth('VISA')) div 2, 
                    ARect.Top + (ARect.Height - ACanvas.TextHeight('VISA')) div 2, 
                    'VISA');
  end
  else if ABrand = 'MASTERCARD' then
  begin
    // Two overlapping circles
    Radius := (ARect.Height * 7) div 20;
    CY := ARect.Top + ARect.Height div 2;
    
    // Left circle: Red
    ACanvas.Brush.Color := TColor($2A2AEB);
    CX := ARect.Left + (ARect.Width * 4) div 10;
    ACanvas.Ellipse(CX - Radius, CY - Radius, CX + Radius, CY + Radius);
    
    // Right circle: Yellow/Orange
    ACanvas.Brush.Color := TColor($10A5F9);
    CX := ARect.Left + (ARect.Width * 6) div 10;
    ACanvas.Ellipse(CX - Radius, CY - Radius, CX + Radius, CY + Radius);
  end
  else
  begin
    // Generic Card Outline
    ACanvas.Brush.Color := TColor($E0E0E0);
    if AOnCard then
      ACanvas.Brush.Color := TColor($90A0B0);
      
    ACanvas.RoundRect(ARect.Left + 2, ARect.Top + 2, ARect.Right - 2, ARect.Bottom - 2, 4, 4);
    
    // Draw a small decorative stripe/chip inside generic icon
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

  // Clear background
  LCanvas.Brush.Color := Self.Color;
  LCanvas.FillRect(paintCards.ClientRect);

  LCanvas.Pen.Style := psClear;
  LCanvas.Brush.Style := bsSolid;

  // 1. Draw Back Card (Behind)
  // Position: X=110, Y=30, W=220, H=130
  LCanvas.Brush.Color := TColor($D29864); // Medium steel blue BGR
  LCanvas.RoundRect(110, 30, 330, 160, 10, 10);

  // Black magnetic stripe
  LCanvas.Brush.Color := clBlack;
  LCanvas.FillRect(110, 45, 330, 68);

  // White CVC box
  LCanvas.Brush.Color := clWhite;
  LCanvas.FillRect(250, 80, 310, 102);

  // CVC digits
  LCanvas.Font.Name := 'Segoe UI';
  LCanvas.Font.Size := 9;
  LCanvas.Font.Color := clBlack;
  LCanvas.Font.Style := [];
  LCanvas.TextOut(255, 82, Cvc);

  // CVC code label below
  LCanvas.Font.Size := 7;
  LCanvas.Font.Color := clWhite;
  LCanvas.TextOut(255, 105, 'CVC code');

  // 2. Draw Front Card (On top)
  // Position: X=20, Y=10, W=220, H=130
  LCanvas.Brush.Color := TColor($C57B3B); // Nice blue BGR
  LCanvas.RoundRect(20, 10, 240, 140, 10, 10);

  // BANK text
  LCanvas.Font.Name := 'Segoe UI';
  LCanvas.Font.Size := 9;
  LCanvas.Font.Color := clWhite;
  LCanvas.Font.Style := [fsBold];
  LCanvas.TextOut(190, 20, 'BANK');

  // Card Number (Consolas / Courier for standard card feel)
  LCanvas.Font.Name := 'Consolas';
  LCanvas.Font.Size := 11;
  LCanvas.Font.Color := clWhite;
  LCanvas.Font.Style := [fsBold];
  LCanvas.TextOut(32, 58, CardNum);

  // Cardholder Name
  LCanvas.Font.Name := 'Segoe UI';
  LCanvas.Font.Size := 9;
  LCanvas.Font.Color := clWhite;
  LCanvas.Font.Style := [];
  LCanvas.TextOut(35, 92, UpperCase(edtName.Text));

  // Expiry Date
  LCanvas.Font.Size := 8;
  LCanvas.TextOut(35, 110, Expiry);

  // Brand Logo on front card
  DrawBrandLogo(LCanvas, Rect(190, 95, 225, 118), Brand, True);
end;

procedure TCreditCardForm.paintBrandLogoPaint(Sender: TObject);
begin
  DrawBrandLogo(paintBrandLogo.Canvas, paintBrandLogo.ClientRect, GetCardBrand, False);
end;

procedure TCreditCardForm.edtCardDetailsChange(Sender: TObject);
var
  S, Digits, Formatted: string;
  I, DigitCount, OrigSelStart, TargetSelStart, DigitIndexAtCursor: Integer;
begin
  S := edtCardDetails.Text;
  OrigSelStart := edtCardDetails.SelStart;
  
  // Count digits before cursor
  DigitIndexAtCursor := 0;
  for I := 1 to OrigSelStart do
    if S[I] in ['0'..'9'] then
      Inc(DigitIndexAtCursor);
  
  // Extract all digits
  Digits := '';
  for I := 1 to Length(S) do
    if S[I] in ['0'..'9'] then
      Digits := Digits + S[I];
      
  // Limit digits to max 24 (16 card + 4 expiry + 4 CVC)
  if Length(Digits) > 24 then
    Digits := Copy(Digits, 1, 24);
    
  // Format digits
  Formatted := '';
  DigitCount := Length(Digits);
  for I := 1 to DigitCount do
  begin
    Formatted := Formatted + Digits[I];
    
    // Add separators
    if I = 4 then
    begin
      if DigitCount > 4 then Formatted := Formatted + ' ';
    end
    else if I = 8 then
    begin
      if DigitCount > 8 then Formatted := Formatted + ' ';
    end
    else if I = 12 then
    begin
      if DigitCount > 12 then Formatted := Formatted + ' ';
    end
    else if I = 16 then
    begin
      if DigitCount > 16 then Formatted := Formatted + ' ';
    end
    else if I = 18 then
    begin
      if DigitCount > 18 then Formatted := Formatted + '/';
    end
    else if I = 20 then
    begin
      if DigitCount > 20 then Formatted := Formatted + ' ';
    end;
  end;
  
  // Update text if changed to avoid recursion
  if edtCardDetails.Text <> Formatted then
  begin
    edtCardDetails.Text := Formatted;
    
    // Map digit index back to cursor position in formatted string
    TargetSelStart := 0;
    I := 0;
    while (I < Length(Formatted)) and (DigitIndexAtCursor > 0) do
    begin
      Inc(I);
      Inc(TargetSelStart);
      if Formatted[I] in ['0'..'9'] then
        Dec(DigitIndexAtCursor);
    end;
    
    // Adjust for trailing spaces/slashes if user typed right before it
    if (TargetSelStart < Length(Formatted)) and not (Formatted[TargetSelStart + 1] in ['0'..'9']) then
      Inc(TargetSelStart);
      
    edtCardDetails.SelStart := TargetSelStart;
  end;

  // Redraw card preview & brand logo
  paintCards.Invalidate;
  paintBrandLogo.Invalidate;
end;

procedure TCreditCardForm.edtCardDetailsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  SelStartVal: Integer;
  S: string;
begin
  if Key = 8 then // Backspace
  begin
    SelStartVal := edtCardDetails.SelStart;
    S := edtCardDetails.Text;
    if (SelStartVal > 0) and (SelStartVal <= Length(S)) then
    begin
      // If the character to the left of the cursor is a space or slash, delete the digit before it too
      if (S[SelStartVal] in [' ', '/']) then
      begin
        Delete(S, SelStartVal - 1, 2);
        edtCardDetails.Text := S;
        edtCardDetails.SelStart := SelStartVal - 2;
        Key := 0; // Handled
      end;
    end;
  end;
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
  S := edtCardDetails.Text;
  Digits := '';
  for I := 1 to Length(S) do
    if S[I] in ['0'..'9'] then
      Digits := Digits + S[I];

  CardNum := Copy(Digits, 1, 16);
  
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

procedure TCreditCardForm.btnSubmitMouseEnter(Sender: TObject);
begin
  btnSubmit.Color := TColor($EAEAEA);
end;

procedure TCreditCardForm.btnSubmitMouseLeave(Sender: TObject);
begin
  btnSubmit.Color := TColor($E0E0E0);
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
