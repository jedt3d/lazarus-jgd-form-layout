program test_layout;

{$mode objfpc}{$H+}

uses
  Interfaces, // this is needed for LCL to initialize GUI handles properly, even for console test runs using LCL controls!
  consoletestrunner, fpcunit, testregistry, Classes, SysUtils, ujgdformslayout, Controls;

type
  TJgdLayoutTests = class(TTestCase)
  published
    procedure TestColSpecParser;
    procedure TestRowSpecParser;
    procedure TestDluConversion;
  end;

procedure TJgdLayoutTests.TestColSpecParser;
var
  Layout: TJgdFormLayout;
begin
  Layout := TJgdFormLayout.Create(nil);
  try
    Layout.ColumnSpecs := 'left:pref, 10px, fill:pref:grow, r:50dlu:g(0.5)';
    
    // Check that we parsed 4 columns
    AssertEquals('Should parse 4 column specs', 4, Length(Layout.ColSpecsParsed));
    
    // Column 1: 'left:pref'
    AssertEquals('Col 1 Align', Ord(TJgdHAlign.jgdLeft), Ord(Layout.ColSpecsParsed[0].Align));
    AssertEquals('Col 1 SizeKind', Ord(TJgdSizeKind.szPreferred), Ord(Layout.ColSpecsParsed[0].SizeKind));
    AssertEquals('Col 1 GrowWeight', 0.0, Layout.ColSpecsParsed[0].GrowWeight);
    
    // Column 2: '10px'
    AssertEquals('Col 2 Align', Ord(TJgdHAlign.jgdDefault), Ord(Layout.ColSpecsParsed[1].Align));
    AssertEquals('Col 2 SizeKind', Ord(TJgdSizeKind.szConstant), Ord(Layout.ColSpecsParsed[1].SizeKind));
    AssertEquals('Col 2 SizeValue', 10.0, Layout.ColSpecsParsed[1].SizeValue);
    AssertEquals('Col 2 SizeUnit', 'px', Layout.ColSpecsParsed[1].SizeUnit);
    AssertEquals('Col 2 GrowWeight', 0.0, Layout.ColSpecsParsed[1].GrowWeight);

    // Column 3: 'fill:pref:grow'
    AssertEquals('Col 3 Align', Ord(TJgdHAlign.jgdFill), Ord(Layout.ColSpecsParsed[2].Align));
    AssertEquals('Col 3 SizeKind', Ord(TJgdSizeKind.szPreferred), Ord(Layout.ColSpecsParsed[2].SizeKind));
    AssertEquals('Col 3 GrowWeight', 1.0, Layout.ColSpecsParsed[2].GrowWeight);

    // Column 4: 'r:50dlu:g(0.5)'
    AssertEquals('Col 4 Align', Ord(TJgdHAlign.jgdRight), Ord(Layout.ColSpecsParsed[3].Align));
    AssertEquals('Col 4 SizeKind', Ord(TJgdSizeKind.szConstant), Ord(Layout.ColSpecsParsed[3].SizeKind));
    AssertEquals('Col 4 SizeValue', 50.0, Layout.ColSpecsParsed[3].SizeValue);
    AssertEquals('Col 4 SizeUnit', 'dlu', Layout.ColSpecsParsed[3].SizeUnit);
    AssertEquals('Col 4 GrowWeight', 0.5, Layout.ColSpecsParsed[3].GrowWeight);
  finally
    Layout.Free;
  end;
end;

procedure TJgdLayoutTests.TestRowSpecParser;
var
  Layout: TJgdFormLayout;
begin
  Layout := TJgdFormLayout.Create(nil);
  try
    Layout.RowSpecs := 'top:pref, 4dlu, bottom:pref:grow, t:100px:g(2.0)';
    
    AssertEquals('Should parse 4 row specs', 4, Length(Layout.RowSpecsParsed));
    
    // Row 1: 'top:pref'
    AssertEquals('Row 1 Align', Ord(TJgdVAlign.jgdTop), Ord(Layout.RowSpecsParsed[0].Align));
    AssertEquals('Row 1 SizeKind', Ord(TJgdSizeKind.szPreferred), Ord(Layout.RowSpecsParsed[0].SizeKind));
    AssertEquals('Row 1 GrowWeight', 0.0, Layout.RowSpecsParsed[0].GrowWeight);
    
    // Row 2: '4dlu'
    AssertEquals('Row 2 Align', Ord(TJgdVAlign.jgdDefault), Ord(Layout.RowSpecsParsed[1].Align));
    AssertEquals('Row 2 SizeKind', Ord(TJgdSizeKind.szConstant), Ord(Layout.RowSpecsParsed[1].SizeKind));
    AssertEquals('Row 2 SizeValue', 4.0, Layout.RowSpecsParsed[1].SizeValue);
    AssertEquals('Row 2 SizeUnit', 'dlu', Layout.RowSpecsParsed[1].SizeUnit);

    // Row 3: 'bottom:pref:grow'
    AssertEquals('Row 3 Align', Ord(TJgdVAlign.jgdBottom), Ord(Layout.RowSpecsParsed[2].Align));
    AssertEquals('Row 3 GrowWeight', 1.0, Layout.RowSpecsParsed[2].GrowWeight);

    // Row 4: 't:100px:g(2.0)'
    AssertEquals('Row 4 Align', Ord(TJgdVAlign.jgdTop), Ord(Layout.RowSpecsParsed[3].Align));
    AssertEquals('Row 4 SizeValue', 100.0, Layout.RowSpecsParsed[3].SizeValue);
    AssertEquals('Row 4 GrowWeight', 2.0, Layout.RowSpecsParsed[3].GrowWeight);
  finally
    Layout.Free;
  end;
end;

procedure TJgdLayoutTests.TestDluConversion;
var
  Layout: TJgdFormLayout;
begin
  Layout := TJgdFormLayout.Create(nil);
  try
    Layout.Font.Height := -16; // 16px font height
    // 4dlu horizontal: average char width FW = FH div 2 = 8.
    // DluToPx(4, True) = Round(4 * (FW / 4)) = Round(4 * 2) = 8.
    // 8dlu vertical: DluToPx(8, False) = Round(8 * (FH / 8)) = Round(8 * 2) = 16.
    AssertEquals('Horizontal DLU to Px', 8, Layout.DluToPx(4, True));
    AssertEquals('Vertical DLU to Px', 16, Layout.DluToPx(8, False));
  finally
    Layout.Free;
  end;
end;

var
  App: TTestRunner;
begin
  RegisterTest(TJgdLayoutTests);
  App := TTestRunner.Create(nil);
  App.Initialize;
  App.Run;
  App.Free;
end.
