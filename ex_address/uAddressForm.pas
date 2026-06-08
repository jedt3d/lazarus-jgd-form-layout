unit uAddressForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, Types, Menus, ujgdformslayout;

type
  TAddressForm = class(TForm)
    pnlTitleBar: TPanel;
    lblTitle: TLabel;
    lblClose: TLabel;
    
    pnlFields: TJgdFormLayout;
    
    pnlCountryDropdown: TPanel;
    paintFlag: TPaintBox;
    lblCountryText: TLabel;
    lblDownArrow: TLabel;
    
    edtAddress1: TEdit;
    edtAddress2: TEdit;
    
    pnlCityStateZip: TJgdFormLayout;
    edtCity: TEdit;
    edtState: TEdit;
    edtZipCode: TEdit;
    
    btnAccept: TPanel;
    popCountries: TPopupMenu;

    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure lblCloseClick(Sender: TObject);
    procedure lblCloseMouseEnter(Sender: TObject);
    procedure lblCloseMouseLeave(Sender: TObject);
    procedure paintFlagPaint(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);
    procedure btnAcceptMouseEnter(Sender: TObject);
    procedure btnAcceptMouseLeave(Sender: TObject);
    procedure pnlCountryDropdownClick(Sender: TObject);
    procedure CountryMenuItemClick(Sender: TObject);
    
    // Draggable window events
    procedure pnlTitleBarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnlTitleBarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pnlTitleBarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FDragging: Boolean;
    FDragStart: TPoint;
    FSelectedCountryCode: string;
    function CreateFlagBitmap(CountryCode: string): TBitmap;
  public
  end;

var
  AddressForm: TAddressForm;

implementation

{$R *.lfm}

{ TAddressForm }

function TAddressForm.CreateFlagBitmap(CountryCode: string): TBitmap;
var
  Bmp: TBitmap;
  W, H, Stripe: Integer;
begin
  Bmp := TBitmap.Create;
  Bmp.SetSize(18, 12);
  W := Bmp.Width;
  H := Bmp.Height;
  Bmp.Canvas.Pen.Style := psClear;
  Bmp.Canvas.Brush.Style := bsSolid;
  
  if CountryCode = 'FR' then
  begin
    Stripe := W div 3;
    Bmp.Canvas.Brush.Color := TColor($9B2300); // Blue
    Bmp.Canvas.Rectangle(0, 0, Stripe, H);
    Bmp.Canvas.Brush.Color := clWhite;
    Bmp.Canvas.Rectangle(Stripe, 0, Stripe * 2, H);
    Bmp.Canvas.Brush.Color := TColor($2D24EF); // Red
    Bmp.Canvas.Rectangle(Stripe * 2, 0, W, H);
  end
  else if CountryCode = 'DE' then
  begin
    Stripe := H div 3;
    Bmp.Canvas.Brush.Color := clBlack;
    Bmp.Canvas.Rectangle(0, 0, W, Stripe);
    Bmp.Canvas.Brush.Color := TColor($2D24EF); // Red
    Bmp.Canvas.Rectangle(0, Stripe, W, Stripe * 2);
    Bmp.Canvas.Brush.Color := TColor($00D0F0); // Gold/Yellow
    Bmp.Canvas.Rectangle(0, Stripe * 2, W, H);
  end
  else if CountryCode = 'IT' then
  begin
    Stripe := W div 3;
    Bmp.Canvas.Brush.Color := TColor($40A000); // Green
    Bmp.Canvas.Rectangle(0, 0, Stripe, H);
    Bmp.Canvas.Brush.Color := clWhite;
    Bmp.Canvas.Rectangle(Stripe, 0, Stripe * 2, H);
    Bmp.Canvas.Brush.Color := TColor($2D24EF); // Red
    Bmp.Canvas.Rectangle(Stripe * 2, 0, W, H);
  end
  else if CountryCode = 'NL' then
  begin
    Stripe := H div 3;
    Bmp.Canvas.Brush.Color := TColor($2D24EF); // Red
    Bmp.Canvas.Rectangle(0, 0, W, Stripe);
    Bmp.Canvas.Brush.Color := clWhite;
    Bmp.Canvas.Rectangle(0, Stripe, W, Stripe * 2);
    Bmp.Canvas.Brush.Color := TColor($9B2300); // Blue
    Bmp.Canvas.Rectangle(0, Stripe * 2, W, H);
  end
  else if CountryCode = 'ES' then
  begin
    Bmp.Canvas.Brush.Color := TColor($2D24EF); // Red
    Bmp.Canvas.Rectangle(0, 0, W, H div 4);
    Bmp.Canvas.Brush.Color := TColor($00D0F0); // Yellow
    Bmp.Canvas.Rectangle(0, H div 4, W, (3 * H) div 4);
    Bmp.Canvas.Brush.Color := TColor($2D24EF); // Red
    Bmp.Canvas.Rectangle(0, (3 * H) div 4, W, H);
  end;
  
  Result := Bmp;
end;

procedure TAddressForm.FormCreate(Sender: TObject);
var
  Item: TMenuItem;
  Bmp: TBitmap;
begin
  FDragging := False;
  FSelectedCountryCode := 'FR';
  Self.DoubleBuffered := True;
  
  // France
  Item := TMenuItem.Create(popCountries);
  Item.Caption := 'France';
  Bmp := CreateFlagBitmap('FR');
  try
    Item.Bitmap.Assign(Bmp);
  finally
    Bmp.Free;
  end;
  Item.OnClick := @CountryMenuItemClick;
  popCountries.Items.Add(Item);
  
  // Germany
  Item := TMenuItem.Create(popCountries);
  Item.Caption := 'Germany';
  Bmp := CreateFlagBitmap('DE');
  try
    Item.Bitmap.Assign(Bmp);
  finally
    Bmp.Free;
  end;
  Item.OnClick := @CountryMenuItemClick;
  popCountries.Items.Add(Item);
  
  // Italy
  Item := TMenuItem.Create(popCountries);
  Item.Caption := 'Italy';
  Bmp := CreateFlagBitmap('IT');
  try
    Item.Bitmap.Assign(Bmp);
  finally
    Bmp.Free;
  end;
  Item.OnClick := @CountryMenuItemClick;
  popCountries.Items.Add(Item);
  
  // Netherlands
  Item := TMenuItem.Create(popCountries);
  Item.Caption := 'Netherlands';
  Bmp := CreateFlagBitmap('NL');
  try
    Item.Bitmap.Assign(Bmp);
  finally
    Bmp.Free;
  end;
  Item.OnClick := @CountryMenuItemClick;
  popCountries.Items.Add(Item);
  
  // Spain
  Item := TMenuItem.Create(popCountries);
  Item.Caption := 'Spain';
  Bmp := CreateFlagBitmap('ES');
  try
    Item.Bitmap.Assign(Bmp);
  finally
    Bmp.Free;
  end;
  Item.OnClick := @CountryMenuItemClick;
  popCountries.Items.Add(Item);
end;

procedure TAddressForm.FormPaint(Sender: TObject);
begin
  // Draw the custom 1px steel blue border around the borderless window
  Canvas.Pen.Color := TColor($A07040); // Steel blue border in BGR
  Canvas.Pen.Width := 1;
  Canvas.Brush.Style := bsClear;
  Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);
end;

procedure TAddressForm.lblCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TAddressForm.lblCloseMouseEnter(Sender: TObject);
begin
  lblClose.Font.Color := clRed;
end;

procedure TAddressForm.lblCloseMouseLeave(Sender: TObject);
begin
  lblClose.Font.Color := TColor($333333);
end;

procedure TAddressForm.paintFlagPaint(Sender: TObject);
var
  LCanvas: TCanvas;
  W, H: Integer;
  StripeW, StripeH: Integer;
begin
  LCanvas := paintFlag.Canvas;
  W := paintFlag.Width;
  H := paintFlag.Height;
  LCanvas.Pen.Style := psClear;
  LCanvas.Brush.Style := bsSolid;
  
  if FSelectedCountryCode = 'FR' then
  begin
    StripeW := W div 3;
    LCanvas.Brush.Color := TColor($9B2300); // Blue
    LCanvas.Rectangle(0, 0, StripeW, H);
    LCanvas.Brush.Color := clWhite;
    LCanvas.Rectangle(StripeW, 0, StripeW * 2, H);
    LCanvas.Brush.Color := TColor($2D24EF); // Red
    LCanvas.Rectangle(StripeW * 2, 0, W, H);
  end
  else if FSelectedCountryCode = 'DE' then
  begin
    StripeH := H div 3;
    LCanvas.Brush.Color := clBlack;
    LCanvas.Rectangle(0, 0, W, StripeH);
    LCanvas.Brush.Color := TColor($2D24EF); // Red
    LCanvas.Rectangle(0, StripeH, W, StripeH * 2);
    LCanvas.Brush.Color := TColor($00D0F0); // Gold/Yellow
    LCanvas.Rectangle(0, StripeH * 2, W, H);
  end
  else if FSelectedCountryCode = 'IT' then
  begin
    StripeW := W div 3;
    LCanvas.Brush.Color := TColor($40A000); // Green
    LCanvas.Rectangle(0, 0, StripeW, H);
    LCanvas.Brush.Color := clWhite;
    LCanvas.Rectangle(StripeW, 0, StripeW * 2, H);
    LCanvas.Brush.Color := TColor($2D24EF); // Red
    LCanvas.Rectangle(StripeW * 2, 0, W, H);
  end
  else if FSelectedCountryCode = 'NL' then
  begin
    StripeH := H div 3;
    LCanvas.Brush.Color := TColor($2D24EF); // Red
    LCanvas.Rectangle(0, 0, W, StripeH);
    LCanvas.Brush.Color := clWhite;
    LCanvas.Rectangle(0, StripeH, W, StripeH * 2);
    LCanvas.Brush.Color := TColor($9B2300); // Blue
    LCanvas.Rectangle(0, StripeH * 2, W, H);
  end
  else if FSelectedCountryCode = 'ES' then
  begin
    LCanvas.Brush.Color := TColor($2D24EF); // Red
    LCanvas.Rectangle(0, 0, W, H div 4);
    LCanvas.Brush.Color := TColor($00D0F0); // Yellow
    LCanvas.Rectangle(0, H div 4, W, (3 * H) div 4);
    LCanvas.Brush.Color := TColor($2D24EF); // Red
    LCanvas.Rectangle(0, (3 * H) div 4, W, H);
  end;
end;

procedure TAddressForm.btnAcceptClick(Sender: TObject);
begin
  if (edtAddress1.Text = '') or (edtCity.Text = '') or (edtZipCode.Text = '') then
  begin
    ShowMessage('Please fill in Address Line 1, City, and ZIP code!');
  end
  else
  begin
    ShowMessage('Address Accepted!' + sLineBreak +
                'Country: ' + lblCountryText.Caption + sLineBreak +
                'Line 1: ' + edtAddress1.Text + sLineBreak +
                'Line 2: ' + edtAddress2.Text + sLineBreak +
                'City: ' + edtCity.Text + sLineBreak +
                'State: ' + edtState.Text + sLineBreak +
                'ZIP Code: ' + edtZipCode.Text);
    Close;
  end;
end;

procedure TAddressForm.btnAcceptMouseEnter(Sender: TObject);
begin
  btnAccept.Color := TColor($EAEAEA); // Highlight button
end;

procedure TAddressForm.btnAcceptMouseLeave(Sender: TObject);
begin
  btnAccept.Color := TColor($E0E0E0); // Standard button color
end;

procedure TAddressForm.pnlCountryDropdownClick(Sender: TObject);
var
  P: TPoint;
begin
  P := pnlCountryDropdown.ClientToScreen(Point(0, pnlCountryDropdown.Height));
  popCountries.PopUp(P.X, P.Y);
end;

procedure TAddressForm.CountryMenuItemClick(Sender: TObject);
var
  Item: TMenuItem;
begin
  Item := TMenuItem(Sender);
  lblCountryText.Caption := Item.Caption;
  
  if Item.Caption = 'France' then FSelectedCountryCode := 'FR'
  else if Item.Caption = 'Germany' then FSelectedCountryCode := 'DE'
  else if Item.Caption = 'Italy' then FSelectedCountryCode := 'IT'
  else if Item.Caption = 'Netherlands' then FSelectedCountryCode := 'NL'
  else if Item.Caption = 'Spain' then FSelectedCountryCode := 'ES';
  
  paintFlag.Invalidate;
end;

procedure TAddressForm.pnlTitleBarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDragging := True;
    FDragStart := Point(X, Y);
  end;
end;

procedure TAddressForm.pnlTitleBarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
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

procedure TAddressForm.pnlTitleBarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
end;

end.
