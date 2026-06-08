unit uSimpleForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ujgdformslayout;

type
  { TSimpleForm
    A beginner-level example demonstrating the basics of the jgd-forms-layout component.
    
    This form showcases:
    - Two-panel layout structure (main content area + bottom button panel)
    - Simple grid specifications using the declarative layout system
    - Responsive column/row scaling with grow weights
    - Control alignment within grid cells (HAlign, VAlign)
    - Button row organization using fill and fixed spacing
    
    Layout Structure:
    ================
    The form is organized into two main TJgdFormLayout panels:
    
    1. pnlMain (top content area):
       - Columns: 3 columns (left label | 10px gap | right label) with grow weights
       - Rows: 1 row with preferred sizing and fill growth
       - Controls: Two labels (lblMessage, lblMessageRight) centered and filled
       - Purpose: Display two messages side-by-side with equal spacing
    
    2. pnlBottom (bottom button panel):
       - Columns: 5 columns (don't save button | grow space | cancel button | gap | save button)
       - Rows: 1 row with preferred sizing
       - Controls: Three buttons (btnDontSave, btnCancel, btnSave)
       - Purpose: Standard dialog buttons with flexible spacing
    
    Learning Points:
    ================
    - Column specs 'fill:0:grow' with multiple columns distributes space equally
    - '10px' creates fixed-width gaps between controls
    - VAlign = jgdCenter vertically centers controls in their cells
    - HAlign = jgdFill makes controls stretch to fill available width
    - Button panels use 'fill:0:grow' for flexible button spacing
  }
  TSimpleForm = class(TForm)
    { Main layout panel containing the message labels }
    pnlMain: TJgdFormLayout;
    
    { Left-side label: displays greeting message }
    lblMessage: TLabel;
    
    { Right-side label: displays greeting message }
    lblMessageRight: TLabel;
    
    { Bottom layout panel containing action buttons }
    pnlBottom: TJgdFormLayout;
    
    { "Don't Save" button: first action button }
    btnDontSave: TButton;
    
    { "Cancel" button: second action button, positioned in column 3 }
    btnCancel: TButton;
    
    { "Save" button: third action button, positioned in column 5 }
    btnSave: TButton;
    
    { Form initialization: sets up initial control captions }
    procedure FormCreate(Sender: TObject);
    
    { Handler for "Don't Save" button click event }
    procedure btnDontSaveClick(Sender: TObject);
    
    { Handler for "Cancel" button click event }
    procedure btnCancelClick(Sender: TObject);
    
    { Handler for "Save" button click event }
    procedure btnSaveClick(Sender: TObject);
  private
  public
  end;

var
  SimpleForm: TSimpleForm;

implementation

{$R *.lfm}

{ TSimpleForm.FormCreate
  
  Purpose: Initialize form controls with messages when the form is created.
  
  Behavior:
  - Sets the caption for the left-side label to "Hello from Left side!"
  - Sets the caption for the right-side label to "Hello from Right side!"
  
  Notes:
  - This is called automatically when the form is created (TForm creates components first,
    then calls this FormCreate handler)
  - The layout is already set up from the .lfm file, so controls are positioned
    automatically by the TJgdFormLayout grid engine
  - No manual repositioning is needed; the grid layout handles all alignment and sizing
}
procedure TSimpleForm.FormCreate(Sender: TObject);
begin
  lblMessage.Caption := 'Hello from Left side!';
  lblMessageRight.Caption := 'Hello from Right side!';
end;

{ TSimpleForm.btnDontSaveClick
  
  Purpose: Handle clicks on the "Don't Save" button.
  
  Behavior:
  - Displays a modal message dialog with text "Don't Save clicked!"
  - User must dismiss the dialog before interacting with the form again
  
  Notes:
  - This is a simple example handler demonstrating button click events
  - In a real application, this would trigger actual "don't save" logic
  - The button is positioned in column 1 of pnlBottom using the grid layout
}
procedure TSimpleForm.btnDontSaveClick(Sender: TObject);
begin
  ShowMessage('Don''t Save clicked!');
end;

{ TSimpleForm.btnCancelClick
  
  Purpose: Handle clicks on the "Cancel" button.
  
  Behavior:
  - Displays a modal message dialog with text "Cancel clicked!"
  - User must dismiss the dialog before interacting with the form again
  
  Notes:
  - This button is positioned in column 3 of pnlBottom (middle button)
  - The column spacing is managed by the grid layout with fill:0:grow gaps
}
procedure TSimpleForm.btnCancelClick(Sender: TObject);
begin
  ShowMessage('Cancel clicked!');
end;

{ TSimpleForm.btnSaveClick
  
  Purpose: Handle clicks on the "Save" button.
  
  Behavior:
  - Displays a modal message dialog with text "Save clicked!"
  - User must dismiss the dialog before interacting with the form again
  
  Notes:
  - This button is positioned in column 5 of pnlBottom (right-most button)
  - Standard button padding between btnCancel and btnSave is handled by the 10px gap
  - In a real application, this would trigger actual "save" logic
}
procedure TSimpleForm.btnSaveClick(Sender: TObject);
begin
  ShowMessage('Save clicked!');
end;

end.
