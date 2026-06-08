unit uAddressForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, Types, Menus, ujgdformslayout;

type
  { TAddressForm - Modern Dialog with Custom Chrome and Nested Layouts
    
    This example demonstrates:
    1. Custom window chrome (no standard frame, custom title bar, drag to move)
    2. Nested TJgdFormLayout panels (main and city/state/zip sub-layout)
    3. Popup menu for country selection with flag graphics
    4. Custom drawing (flag icons with canvas)
    5. Mouse tracking for drag operations
    6. Right-aligned button using HAlign = jgdRight
    7. Composite controls (country dropdown with custom rendering)
    
    Key Layout Features:
    - pnlTitleBar: Custom title bar with close button (no standard border)
    - pnlFields: Main layout using single column that fills available space
      ColumnSpecs = 'fill:pref:grow' (one column, fills space, responsive)
      RowSpecs = 9 rows with varying DLU gaps (10dlu, 14dlu, etc.)
      BorderWidth = 20 (padding around form content)
    
    - pnlCityStateZip: Nested layout for three related fields in one row
      ColumnSpecs = 5 columns (city, gap, state, gap, zip)
      RowSpecs = 1 row (all on same line)
      This sub-layout is placed at Row 7, Column 1, HAlign=jgdFill
      to make it responsive with the parent layout
  }
  TAddressForm = class(TForm)
    { Title Bar - Custom window chrome without standard frame }
    pnlTitleBar: TPanel;
    lblTitle: TLabel;
    lblClose: TLabel;  // Custom close button (✕ symbol)
    
    { Main Form Layout }
    pnlFields: TJgdFormLayout;
    
    { Country Selection Composite Control
      This demonstrates a custom composite control:
      - paintFlag: TPaintBox for drawing flag graphics
      - lblCountryText: Shows current selection
      - lblDownArrow: Visual indicator for dropdown
      All contained in pnlCountryDropdown panel
    }
    pnlCountryDropdown: TPanel;
    paintFlag: TPaintBox;
    lblCountryText: TLabel;
    lblDownArrow: TLabel;
    
    { Address Fields }
    edtAddress1: TEdit;  { Row 3 - Address Line 1 }
    edtAddress2: TEdit;  { Row 5 - Address Line 2 (optional) }
    
    { City/State/ZIP - Nested layout example
      This is a separate TJgdFormLayout that arranges three fields horizontally
      - ColumnSpecs: 'fill:120dlu:grow, 8dlu, fill:120dlu:grow, 8dlu, fill:60dlu'
        Creates 5 columns: City (grows to min 120dlu), gap, State, gap, ZIP
      - RowSpecs: 'pref' (single row)
      
      This nested layout is placed at Row 7 in the parent layout,
      allowing it to be managed independently but positioned within the grid
    }
    pnlCityStateZip: TJgdFormLayout;
    edtCity: TEdit;
    edtState: TEdit;
    edtZipCode: TEdit;
    
    { Accept Button - Right-aligned using HAlign = jgdRight }
    btnAccept: TPanel;
    
    { Popup Menu for country selection with flag bitmaps }
    popCountries: TPopupMenu;
    
    { Event Handlers }
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
    
    { Draggable Window Implementation }
    procedure pnlTitleBarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnlTitleBarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pnlTitleBarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    { Drag state variables }
    FDragging: Boolean;      // Currently dragging?
    FDragStart: TPoint;      // Starting drag position relative to title bar
    FSelectedCountryCode: string; // Current country code (FR, DE, IT, NL, ES)
    
    { Helper Methods }
    function CreateFlagBitmap(CountryCode: string): TBitmap;
  public
  end;

var
  AddressForm: TAddressForm;

implementation

{$R *.lfm}

{ CreateFlagBitmap - Generate flag graphics programmatically
  
  This helper creates a bitmap representation of country flags using
  canvas drawing operations. It's used both for the menu items and
  for the main flag display during runtime painting.
  
  Flags created:
  - France: Blue | White | Red (vertical stripes)
  - Germany: Black | Red | Gold (horizontal stripes)
  - Italy: Green | White | Red (vertical stripes)
  - Netherlands: Red | White | Blue (horizontal stripes)
  - Spain: Red | Yellow | Red (horizontal stripes)
  
  Note: These are simplified representations for demonstration purposes.
}
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
    { Vertical stripes }
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
    { Horizontal stripes }
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
    { Vertical stripes }
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
    { Horizontal stripes }
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
    { Horizontal stripes with ratio }
    Bmp.Canvas.Brush.Color := TColor($2D24EF); // Red
    Bmp.Canvas.Rectangle(0, 0, W, H div 4);
    Bmp.Canvas.Brush.Color := TColor($00D0F0); // Yellow
    Bmp.Canvas.Rectangle(0, H div 4, W, (3 * H) div 4);
    Bmp.Canvas.Brush.Color := TColor($2D24EF); // Red
    Bmp.Canvas.Rectangle(0, (3 * H) div 4, W, H);
  end;
  
  Result := Bmp;
end;

{ FormCreate - Initialize the form
  
  This event handler:
  1. Sets up drag state
  2. Initializes the country selection (default to France)
  3. Creates popup menu items with flag bitmaps for each country
  4. Enables double-buffering to reduce flicker
  
  Note: The layout is configured in the .lfm file through the designer.
}
procedure TAddressForm.FormCreate(Sender: TObject);
var
  Item: TMenuItem;
  Bmp: TBitmap;
begin
  FDragging := False;
  FSelectedCountryCode := 'FR';
  Self.DoubleBuffered := True;
  
  { Create France menu item with flag }
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
  
  { Create Germany menu item }
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
  
  { Create Italy menu item }
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
  
  { Create Netherlands menu item }
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
  
  { Create Spain menu item }
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

{ FormPaint - Draw custom border around borderless form
  
  Since we set BorderStyle = bsNone in the .lfm, we need to manually
  draw a border to define the form's edges. This is called whenever
  the form needs to be repainted.
}
procedure TAddressForm.FormPaint(Sender: TObject);
begin
  Canvas.Pen.Color := TColor($A07040); // Steel blue border
  Canvas.Pen.Width := 1;
  Canvas.Brush.Style := bsClear;
  Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);
end;

{ lblCloseClick - Handle close button click }
procedure TAddressForm.lblCloseClick(Sender: TObject);
begin
  Close;
end;

{ lblCloseMouseEnter - Visual feedback when hovering over close button }
procedure TAddressForm.lblCloseMouseEnter(Sender: TObject);
begin
  lblClose.Font.Color := clRed;
end;

{ lblCloseMouseLeave - Restore close button appearance }
procedure TAddressForm.lblCloseMouseLeave(Sender: TObject);
begin
  lblClose.Font.Color := TColor($333333);
end;

{ paintFlagPaint - Draw selected country's flag
  
  This TPaintBox is used to display the flag graphic dynamically.
  It's called whenever the selected country changes or the control
  needs to be redrawn. The flag is drawn directly to the canvas,
  scaling to fit the control's size.
  
  Note: This control is part of the pnlCountryDropdown composite
  and is positioned at Row 1 in the main form layout.
}
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
  
  { Draw flag based on current selection }
  if FSelectedCountryCode = 'FR' then
  begin
    StripeW := W div 3;
    LCanvas.Brush.Color := TColor($9B2300);
    LCanvas.Rectangle(0, 0, StripeW, H);
    LCanvas.Brush.Color := clWhite;
    LCanvas.Rectangle(StripeW, 0, StripeW * 2, H);
    LCanvas.Brush.Color := TColor($2D24EF);
    LCanvas.Rectangle(StripeW * 2, 0, W, H);
  end
  else if FSelectedCountryCode = 'DE' then
  begin
    StripeH := H div 3;
    LCanvas.Brush.Color := clBlack;
    LCanvas.Rectangle(0, 0, W, StripeH);
    LCanvas.Brush.Color := TColor($2D24EF);
    LCanvas.Rectangle(0, StripeH, W, StripeH * 2);
    LCanvas.Brush.Color := TColor($00D0F0);
    LCanvas.Rectangle(0, StripeH * 2, W, H);
  end
  else if FSelectedCountryCode = 'IT' then
  begin
    StripeW := W div 3;
    LCanvas.Brush.Color := TColor($40A000);
    LCanvas.Rectangle(0, 0, StripeW, H);
    LCanvas.Brush.Color := clWhite;
    LCanvas.Rectangle(StripeW, 0, StripeW * 2, H);
    LCanvas.Brush.Color := TColor($2D24EF);
    LCanvas.Rectangle(StripeW * 2, 0, W, H);
  end
  else if FSelectedCountryCode = 'NL' then
  begin
    StripeH := H div 3;
    LCanvas.Brush.Color := TColor($2D24EF);
    LCanvas.Rectangle(0, 0, W, StripeH);
    LCanvas.Brush.Color := clWhite;
    LCanvas.Rectangle(0, StripeH, W, StripeH * 2);
    LCanvas.Brush.Color := TColor($9B2300);
    LCanvas.Rectangle(0, StripeH * 2, W, H);
  end
  else if FSelectedCountryCode = 'ES' then
  begin
    LCanvas.Brush.Color := TColor($2D24EF);
    LCanvas.Rectangle(0, 0, W, H div 4);
    LCanvas.Brush.Color := TColor($00D0F0);
    LCanvas.Rectangle(0, H div 4, W, (3 * H) div 4);
    LCanvas.Brush.Color := TColor($2D24EF);
    LCanvas.Rectangle(0, (3 * H) div 4, W, H);
  end;
end;

{ btnAcceptClick - Validate and accept form submission
  
  Demonstrates form validation:
  - Checks required fields (Address1, City, ZIP)
  - Displays entered data in a confirmation message
  - Closes the form on success
}
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

{ btnAcceptMouseEnter - Visual feedback for accept button }
procedure TAddressForm.btnAcceptMouseEnter(Sender: TObject);
begin
  btnAccept.Color := TColor($EAEAEA); // Lighter grey
end;

{ btnAcceptMouseLeave - Restore accept button appearance }
procedure TAddressForm.btnAcceptMouseLeave(Sender: TObject);
begin
  btnAccept.Color := TColor($E0E0E0); // Standard grey
end;

{ pnlCountryDropdownClick - Show country selection popup menu
  
  This positions the popup menu below the country dropdown control
  and displays the list of available countries. Users can click on
  any country to change the selection.
}
procedure TAddressForm.pnlCountryDropdownClick(Sender: TObject);
var
  P: TPoint;
begin
  P := pnlCountryDropdown.ClientToScreen(Point(0, pnlCountryDropdown.Height));
  popCountries.PopUp(P.X, P.Y);
end;

{ CountryMenuItemClick - Handle country selection from popup menu
  
  When user selects a country from the menu:
  1. Update the display label
  2. Update the country code
  3. Invalidate the flag display to trigger repaint
}
procedure TAddressForm.CountryMenuItemClick(Sender: TObject);
var
  Item: TMenuItem;
begin
  Item := TMenuItem(Sender);
  lblCountryText.Caption := Item.Caption;
  
  { Update the country code based on selection }
  if Item.Caption = 'France' then FSelectedCountryCode := 'FR'
  else if Item.Caption = 'Germany' then FSelectedCountryCode := 'DE'
  else if Item.Caption = 'Italy' then FSelectedCountryCode := 'IT'
  else if Item.Caption = 'Netherlands' then FSelectedCountryCode := 'NL'
  else if Item.Caption = 'Spain' then FSelectedCountryCode := 'ES';
  
  { Force repaint of the flag display with new country }
  paintFlag.Invalidate;
end;

{ pnlTitleBarMouseDown - Start drag operation
  
  Implements window dragging by detecting mouse button press on the title bar.
  Stores the starting position for use in the MouseMove handler.
}
procedure TAddressForm.pnlTitleBarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDragging := True;
    FDragStart := Point(X, Y);
  end;
end;

{ pnlTitleBarMouseMove - Handle window dragging
  
  While dragging (FDragging = True), this updates the form's position
  to follow the mouse, creating the effect of dragging the window.
  
  How it works:
  1. Get current mouse position in screen coordinates
  2. Calculate how far the mouse has moved from FDragStart
  3. Update form's Left and Top to move the form with the mouse
}
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

{ pnlTitleBarMouseUp - Stop drag operation }
procedure TAddressForm.pnlTitleBarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
end;

end.
