# JGD Forms Layout for Lazarus IDE

A powerful grid-based layout manager component for Lazarus IDE, inspired by the JGoodies Forms Layout library from the Java world. Build responsive, professional desktop forms with declarative grid specifications.

**Language:** Pascal (Free Pascal Compiler)  
**License:** MIT  
**Repository:** [jedt3d/lazarus-jgd-form-layout](https://github.com/jedt3d/lazarus-jgd-form-layout)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Core Component Architecture](#core-component-architecture)
- [Usage Guide](#usage-guide)
  - [Basic Layout Specification](#basic-layout-specification)
  - [Column and Row Specifications](#column-and-row-specifications)
  - [Control Placement and Spanning](#control-placement-and-spanning)
  - [Alignment Options](#alignment-options)
- [Examples](#examples)
  - [Simple Application](#simple-application)
  - [Login Form](#login-form)
  - [Employee Form](#employee-form)
  - [Address Form](#address-form)
  - [Credit Card Form](#credit-card-form)
- [Unit Tests](#unit-tests)
- [Key Classes & Types](#key-classes--types)
- [Design Principles](#design-principles)
- [Troubleshooting](#troubleshooting)

---

## Overview

The **JGD Forms Layout** component brings the elegance and power of the JGoodies Forms Layout pattern to Lazarus and Free Pascal development. Instead of struggling with anchors, margins, and manual calculations, simply declare your grid layout as a string specification.

This layout engine handles:
- **Grid-based positioning** of controls
- **Automatic sizing** (preferred, minimum, constant)
- **Dialog Unit (DLU) support** for DPI-independent layouts
- **Flexible growth weights** for responsive resizing
- **Column/row spanning** for complex layouts
- **Alignment control** (left, right, center, fill) per control

---

## Features

✅ **Declarative Layout System** – Define grids with human-readable string specs  
✅ **Dialog Units (DLU)** – Font-relative sizing for DPI-independent layouts  
✅ **Growth Weights** – Distribute surplus space proportionally  
✅ **Design-Time Integration** – Full Object Inspector support in Lazarus IDE  
✅ **Span Support** – Controls can occupy multiple cells  
✅ **Automatic Sizing** – Preferred, minimum, and constant size modes  
✅ **Unit Tested** – Comprehensive FPCUnit test suite  
✅ **Production Ready** – Clean architecture with zero external dependencies beyond LCL

---

## Installation

### Step 1: Get the Package

Clone or download the repository:

```bash
git clone https://github.com/jedt3d/lazarus-jgd-form-layout.git
cd lazarus-jgd-form-layout
```

### Step 2: Install in Lazarus IDE

1. Open Lazarus IDE
2. Go to **Package** → **Open Package File**
3. Navigate to and select `jgd_forms_layout.lpk`
4. Click **Compile**
5. After compilation, click **Install** to register the component in the IDE
6. Lazarus will rebuild and the `TJgdFormLayout` component will appear in the **JGoodies** component palette

### Step 3: Verify Installation

Create a new application and check that `TJgdFormLayout` is available in the Designer component palette under the **JGoodies** tab.

---

## Core Component Architecture

### Main Classes

#### `TJgdFormLayout`

The primary layout component. Inherits from `TPanel` and overrides the `AlignControls` method to implement the grid-based layout algorithm.

**Key Properties:**
- `ColumnSpecs: string` – Comma-separated column specifications
- `RowSpecs: string` – Comma-separated row specifications
- `ControlConstraints: TJgdFormLayoutControlCollection` – Design-time mapping of controls to grid cells

**Key Methods:**
- `DluToPx(ADlu: Double; AIsHorizontal: Boolean): Integer` – Convert Dialog Units to pixels
- `ColSpecsParsed: TColSpecArray` – Read-only parsed column specifications
- `RowSpecsParsed: TRowSpecArray` – Read-only parsed row specifications

#### `TJgdFormLayoutControlItem`

Represents a single control's placement and alignment constraints within the grid.

**Properties:**
- `Control: TControl` – Reference to the child control
- `Column: Integer` – Starting column (1-based)
- `Row: Integer` – Starting row (1-based)
- `ColumnSpan: Integer` – Number of columns to span
- `RowSpan: Integer` – Number of rows to span
- `HAlign: TJgdHAlign` – Horizontal alignment
- `VAlign: TJgdVAlign` – Vertical alignment

#### `TJgdFormLayoutControlCollection`

Collection container for `TJgdFormLayoutControlItem` instances. Automatically maintained by the layout engine.

### Type Definitions

```pascal
TJgdHAlign = (jgdLeft, jgdRight, jgdCenter, jgdFill, jgdDefault);
TJgdVAlign = (jgdTop, jgdBottom, jgdCenter, jgdFill, jgdDefault);
TJgdSizeKind = (szConstant, szPreferred, szMinimum, szDefault);
```

---

## Usage Guide

### Basic Layout Specification

Layout specifications are strings containing comma-separated column or row definitions.

```pascal
procedure TMyForm.FormCreate(Sender: TObject);
begin
  pnlLayout.ColumnSpecs := 'pref, 4dlu, pref, fill:pref:grow';
  pnlLayout.RowSpecs    := 'pref, 4dlu, pref, 4dlu, pref';
end;
```

This creates:
- **4 columns**: Two fixed-width columns (preferred size), a 4-DLU gap, and one growing column
- **5 rows**: Three rows with preferred sizing, separated by 4-DLU gaps

### Column and Row Specifications

Each specification can include:

1. **Size Kind** (left part before `:` if multiple parts):
   - `pref` or `p` – Preferred size (size of largest child in that column/row)
   - `min` or `m` – Minimum size (useful for spacing)
   - `d` or `default` – Default size
   - A number with unit – Constant size

2. **Size Value**:
   - `pref` – Use component's preferred size
   - `min` – Use component's minimum size
   - `100px` – 100 pixels (explicit pixel value)
   - `10dlu` – 10 Dialog Units (DPI-independent)
   - `75` – Number without unit defaults to pixels

3. **Alignment** (optional, before first `:`):
   - For columns: `left` or `l`, `right` or `r`, `center` or `c`, `fill` or `f`
   - For rows: `top` or `t`, `bottom` or `b`, `center` or `c`, `fill` or `f`

4. **Growth Weight** (optional, after last `:`):
   - `grow` or `g` – Grow weight of 1.0
   - `g(2.5)` or `grow(2.5)` – Custom grow weight

#### Examples:

```pascal
// Simple preferred size
'pref'

// Fixed pixel width
'100px'

// Dialog units
'12dlu'

// Left-aligned with preferred size
'left:pref'

// Grow weight
'pref:grow'

// Full specification: right-aligned, 50 pixels, grow weight 0.5
'right:50px:g(0.5)'

// Fill entire space with custom grow weight
'fill:pref:grow(2.0)'
```

### Control Placement and Spanning

Add controls to the form and set their layout constraints via the **ControlConstraints** collection in the Object Inspector:

1. Select the `TJgdFormLayout` panel
2. In the Object Inspector, locate the `ControlConstraints` property
3. Click the `(...)` button to open the collection editor
4. For each control you want to place:
   - Click **Add**
   - Set `Control` to your child control
   - Set `Column` and `Row` (1-based indices)
   - Set `ColumnSpan` and `RowSpan` if needed
   - Set alignment options (`HAlign`, `VAlign`)

Or programmatically:

```pascal
procedure SetupLayout(ALayout: TJgdFormLayout);
var
  Item: TJgdFormLayoutControlItem;
begin
  ALayout.ColumnSpecs := 'right:pref, 4dlu, fill:100dlu:grow';
  ALayout.RowSpecs    := 'pref, 4dlu, pref';
  
  // Place a label in column 1, row 1
  Item := ALayout.ControlConstraints.Add;
  Item.Control := Label1;
  Item.Column := 1;
  Item.Row := 1;
  
  // Place an edit in column 3, row 1
  Item := ALayout.ControlConstraints.Add;
  Item.Control := Edit1;
  Item.Column := 3;
  Item.Row := 1;
  Item.HAlign := jgdFill;
end;
```

### Alignment Options

**Horizontal Alignment (Columns):**
- `jgdLeft` – Align control to left edge of cell
- `jgdRight` – Align control to right edge of cell
- `jgdCenter` – Center control in cell
- `jgdFill` – Stretch control to fill cell width
- `jgdDefault` – Use column specification default, or `jgdFill` if unspecified

**Vertical Alignment (Rows):**
- `jgdTop` – Align control to top edge of cell
- `jgdBottom` – Align control to bottom edge of cell
- `jgdCenter` – Center control vertically in cell
- `jgdFill` – Stretch control to fill cell height
- `jgdDefault` – Use row specification default, or `jgdFill` if unspecified

---

## Examples

This repository includes five comprehensive example applications demonstrating different layout scenarios.

### Simple Application

**Location:** `ex_simple/`

A minimal "Hello World" form showing basic layout setup.

**Key File:** `ex_simple/uSimpleForm.pas`

```pascal
type
  TSimpleForm = class(TForm)
    pnlMain: TJgdFormLayout;
    lblMessage: TLabel;
    procedure FormCreate(Sender: TObject);
  end;

procedure TSimpleForm.FormCreate(Sender: TObject);
begin
  lblMessage.Caption := 'Hello from Simple standard application!';
end;
```

**To Run:**
```bash
cd ex_simple
lazbuild SimpleApp.lpi
./lib/x86_64-*/SimpleApp
```

---

### Login Form

**Location:** `ex_login/`

A classic login dialog demonstrating multi-row layouts, gaps, and button panels.

**Layout Structure:**
- **3 Columns**: Right-aligned labels (col 1), 6-DLU gap (col 2), growing input fields (col 3)
- **7 Rows**: Title, gap, username field, gap, password field, gap, button panel

**Key Features:**
- Uses `right:pref` to align labels to the right
- Uses `fill:100dlu:grow` for responsive input fields
- Strategic use of `12dlu` and `6dlu` gaps for visual hierarchy
- Demonstrates button grouping in a panel

**File:** `ex_login/README.md` (includes detailed layout specification)

**To Run:**
```bash
cd ex_login
lazbuild LoginForm.lpi
./lib/x86_64-*/LoginForm
```

---

### Employee Form

**Location:** `ex_employee/`

A comprehensive data entry form with multiple sections and advanced layout patterns.

**Key Features:**
- Complex multi-section layout (personal info, address, employment details)
- Grid-based spacing and alignment
- Demonstrates control spanning
- Shows how to organize large forms hierarchically

**Key Files:**
- `ex_employee/uEmployee.pas` – Data model
- `ex_employee/uEmployeeForm.pas` – Form UI and business logic
- `ex_employee/uEmployeeForm.lfm` – Form design (extensive layout configuration)

**To Run:**
```bash
cd ex_employee
lazbuild EmployeeApp.lpi
./lib/x86_64-*/EmployeeApp
```

---

### Address Form

**Location:** `ex_address/`

A detailed address entry form showcasing multi-control rows and section grouping.

**Key Features:**
- Multi-line address fields with proper alignment
- Complex grid layout with various column spans
- Demonstrates responsive field sizing
- Section-based organization with visual separators

**Key Files:**
- `ex_address/uAddressForm.pas` – Form implementation
- `ex_address/uAddressForm.lfm` – Extensive layout with address fields

**To Run:**
```bash
cd ex_address
lazbuild AddressApp.lpi
./lib/x86_64-*/AddressApp
```

---

### Credit Card Form

**Location:** `ex_creditcard/`

A sophisticated payment form demonstrating advanced layout techniques for sensitive data entry.

**Key Features:**
- Multi-row card details entry (number, expiry, CVV)
- Aligned input fields with appropriate widths
- Professional spacing and visual hierarchy
- Demonstrates mixed column spans for complex layouts
- Shows best practices for sensitive information presentation

**Key Files:**
- `ex_creditcard/uCreditCardForm.pas` – Form implementation with validation logic
- `ex_creditcard/uCreditCardForm.lfm` – Payment form layout design

**To Run:**
```bash
cd ex_creditcard
lazbuild CreditCardApp.lpi
./lib/x86_64-*/CreditCardApp
```

---

## Unit Tests

The project includes a comprehensive automated test suite using FPCUnit.

**Location:** `tests/`

**Test Files:**
- `tests/test_layout.lpr` – Main test program entry point
- `tests/test_layout.lpi` – Lazarus project file

### Test Cases

#### `TestColSpecParser`

Validates column specification parsing with various format combinations:

```pascal
procedure TJgdLayoutTests.TestColSpecParser;
var
  Layout: TJgdFormLayout;
begin
  Layout := TJgdFormLayout.Create(nil);
  try
    Layout.ColumnSpecs := 'left:pref, 10px, fill:pref:grow, r:50dlu:g(0.5)';
    
    // Validates:
    // - Column count parsing
    // - Alignment extraction (left, fill, right)
    // - Size kind detection (pref, constant)
    // - Size unit handling (px, dlu)
    // - Growth weight parsing including custom values like g(0.5)
    
    AssertEquals('Should parse 4 column specs', 4, Length(Layout.ColSpecsParsed));
    AssertEquals('Col 1 Align', Ord(TJgdHAlign.jgdLeft), ...);
    // ... more assertions
  finally
    Layout.Free;
  end;
end;
```

#### `TestRowSpecParser`

Similar to `TestColSpecParser` but for row specifications with vertical alignment options:

```pascal
Layout.RowSpecs := 'top:pref, 4dlu, bottom:pref:grow, t:100px:g(2.0)';

// Validates:
// - Vertical alignment keywords (top, bottom, center, fill)
// - Row count and spec parsing
// - Growth weight handling
```

#### `TestDluConversion`

Validates the Dialog Unit to pixel conversion function:

```pascal
procedure TJgdLayoutTests.TestDluConversion;
var
  Layout: TJgdFormLayout;
begin
  Layout := TJgdFormLayout.Create(nil);
  try
    Layout.Font.Height := -16; // 16px font height
    
    // Horizontal DLU: char width = font height / 2
    // 4 DLU horizontal = 8 pixels
    AssertEquals('Horizontal DLU to Px', 8, Layout.DluToPx(4, True));
    
    // Vertical DLU: row height = font height / 8 (approximation)
    // 8 DLU vertical = 16 pixels
    AssertEquals('Vertical DLU to Px', 16, Layout.DluToPx(8, False));
  finally
    Layout.Free;
  end;
end;
```

### Running Tests

Compile and run the test suite:

```bash
cd tests
lazbuild test_layout.lpi
./test_layout
```

Expected output (0 failures, all tests passing):
```
======= Test Results =======
Test classes run: 1
Tests run: 3
Failures: 0
Errors: 0
OK
```

---

## Key Classes & Types

### Type Definitions

```pascal
// Horizontal alignment options for columns
TJgdHAlign = (jgdLeft, jgdRight, jgdCenter, jgdFill, jgdDefault);

// Vertical alignment options for rows
TJgdVAlign = (jgdTop, jgdBottom, jgdCenter, jgdFill, jgdDefault);

// Size specification kind
TJgdSizeKind = (szConstant, szPreferred, szMinimum, szDefault);

// Parsed column specification record
TJgdColSpec = record
  Align: TJgdHAlign;          // Horizontal alignment
  SizeKind: TJgdSizeKind;     // How to calculate size
  SizeValue: Double;          // Size value (if constant)
  SizeUnit: string;           // Unit: 'px' or 'dlu'
  GrowWeight: Double;         // Growth weight for surplus distribution
end;

// Parsed row specification record (similar structure, vertical alignment)
TJgdRowSpec = record
  Align: TJgdVAlign;
  SizeKind: TJgdSizeKind;
  SizeValue: Double;
  SizeUnit: string;
  GrowWeight: Double;
end;
```

### Class Hierarchy

```
TComponent
  └─ TControl
       └─ TWinControl
            └─ TPanel
                 └─ TJgdFormLayout
                      ├─ Properties: ColumnSpecs, RowSpecs, ControlConstraints
                      ├─ Methods: DluToPx(), AlignControls() (overridden)
                      └─ Collections
                           └─ TJgdFormLayoutControlCollection
                                └─ TJgdFormLayoutControlItem[]
```

---

## Design Principles

### 1. **Separation of Concerns**

- **ujgdformslayout.pas** – Core layout engine and data structures
- **ujgdformslayoutregister.pas** – Component registration (design-time integration)
- **jgd_forms_layout.lpk** – Package configuration

### 2. **Memory Efficiency**

- Uses `record` types (`TJgdColSpec`, `TJgdRowSpec`) instead of classes for parsed specifications to optimize cache locality
- Parsed specs are cached in arrays, not recreated on every layout pass

### 3. **Infinite Loop Prevention**

- The `FIsAligning` flag prevents recursive collection updates during the alignment algorithm
- Child control automatic registration is skipped during component loading to avoid redundant work

### 4. **DPI Independence**

- Dialog Units (DLU) are calculated relative to the current font, not absolute pixel values
- This allows layouts to scale automatically with system font settings

### 5. **Declarative Configuration**

- Users specify layouts as strings, not through complex property dialogs
- String specs are parsed and cached, minimizing performance impact

---

## Troubleshooting

### Issue: Controls Not Appearing

**Solution:** Ensure you've added all child controls to the `ControlConstraints` collection and that their column/row values are within the bounds of your grid specification.

### Issue: Layout Not Updating After Property Change

**Solution:** The layout automatically updates when you change `ColumnSpecs` or `RowSpecs`. If it doesn't, try calling `Realign()` or `Invalidate()` on the panel.

### Issue: DPI-Dependent Sizing

**Cause:** Using pixel-based specifications (`100px`) instead of Dialog Units.

**Solution:** Use `dlu` units for DPI-independent sizing:
```pascal
// Avoid this for cross-platform layouts:
'pref, 10px, pref'

// Use this instead:
'pref, 10dlu, pref'
```

### Issue: Package Won't Install

**Solution:** 
1. Ensure you have the latest Lazarus IDE installed
2. Go to **Tools** → **Options** → **Environment** → **Lazarus Directory** and verify the path is correct
3. Try **Package** → **Clean Up** before reinstalling

### Issue: Test Suite Compilation Fails

**Cause:** Missing FPCUnit framework or incorrect path configuration.

**Solution:** In Lazarus, go to **Project** → **Project Options** → **Compiler Options** and ensure the unit search paths include the FPC source directory containing the `fpcunit` unit.

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file in the repository for details.

---

## Contributing

Contributions are welcome! Feel free to:

- Report issues and feature requests
- Submit pull requests with improvements
- Improve documentation and examples
- Add additional test cases

---

## References

- **JGoodies Forms Layout** (Java): https://www.jgoodies.com/freeware/libraries/forms/
- **Lazarus IDE**: https://www.lazarus-ide.org/
- **Free Pascal Compiler**: https://www.freepascal.org/
- **Dialog Units Documentation**: Microsoft Windows documentation on dialog units for DPI-independent UI sizing

---

## Author

**Project:** jedt3d  
**Repository:** https://github.com/jedt3d/lazarus-jgd-form-layout

---

**Last Updated:** June 2026
