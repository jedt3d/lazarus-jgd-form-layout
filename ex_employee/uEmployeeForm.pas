unit uEmployeeForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, Buttons, Types, Math, ujgdformslayout, uEmployee;

type
  TEmployeeForm = class(TForm)
    pnlTopToolbar: TPanel;
    btnNewSupervisor: TSpeedButton;
    btnNewEmployee: TSpeedButton;
    btnSaveChanges: TSpeedButton;
    btnResetChanges: TSpeedButton;
    btnDeleteEmployee: TSpeedButton;
    
    pnlMain: TPanel;
    tvEmployees: TTreeView;
    splitterMain: TSplitter;
    
    pnlDetails: TJgdFormLayout;
    
    lblFirstName: TLabel;
    edtFirstName: TEdit;
    
    lblLastName: TLabel;
    edtLastName: TEdit;
    
    lblFullName: TLabel;
    edtFullName: TEdit;
    
    lblBirthDate: TLabel;
    edtBirthDate: TEdit;
    
    lblAddress: TLabel;
    edtAddress: TEdit;
    
    lblCity: TLabel;
    pnlCityStateZip: TJgdFormLayout;
    edtCity: TEdit;
    lblState: TLabel;
    cboState: TComboBox;
    lblZipCode: TLabel;
    edtZipCode: TEdit;
    
    lblHomePhone: TLabel;
    edtHomePhone: TEdit;
    
    lblMobilePhone: TLabel;
    edtMobilePhone: TEdit;
    
    lblEmail: TLabel;
    edtEmail: TEdit;
    
    lblTitle: TLabel;
    edtTitle: TEdit;
    
    pnlPrefixContainer: TJgdFormLayout;
    lblPrefix: TLabel;
    cboPrefix: TComboBox;
    
    lblDepartment: TLabel;
    cboDepartment: TComboBox;
    
    lblHireDate: TLabel;
    edtHireDate: TEdit;
    
    pnlStatusContainer: TJgdFormLayout;
    lblStatus: TLabel;
    cboStatus: TComboBox;
    
    pnlPhoto: TPanel;
    paintPhoto: TPaintBox;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvEmployeesSelectionChanged(Sender: TObject);
    procedure paintPhotoPaint(Sender: TObject);
    procedure btnSaveChangesClick(Sender: TObject);
    procedure btnResetChangesClick(Sender: TObject);
    procedure btnNewEmployeeClick(Sender: TObject);
    procedure btnNewSupervisorClick(Sender: TObject);
    procedure btnDeleteEmployeeClick(Sender: TObject);
  private
    FEmployeesList: TList;
    FCurrentEmployee: TEmployee;
    procedure LoadDefaultData;
    procedure PopulateTree;
    procedure ShowEmployeeDetails(Emp: TEmployee);
    procedure ClearForm;
  public
  end;

var
  EmployeeForm: TEmployeeForm;

implementation

{$R *.lfm}

{ TEmployeeForm }

procedure TEmployeeForm.FormCreate(Sender: TObject);
begin
  FEmployeesList := TList.Create;
  LoadDefaultData;
  PopulateTree;
  
  // Select first item
  if tvEmployees.Items.Count > 0 then
  begin
    tvEmployees.Selected := tvEmployees.Items[0];
  end;
end;

procedure TEmployeeForm.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FEmployeesList.Count - 1 do
    TEmployee(FEmployeesList[I]).Free;
  FEmployeesList.Free;
end;

procedure TEmployeeForm.LoadDefaultData;
begin
  FEmployeesList.Add(TEmployee.Create('John', 'Heart', 'CEO', 'jheart@dx-email.com', '3/16/1964', '351 S Hill St.', 'Los Angeles', 'CA', '90013', '(213) 555-92-08', '(213) 555-93-92', 'Management', '1/15/1995', 'Salaried', 'Mr'));
  FEmployeesList.Add(TEmployee.Create('Bradley', 'Jameson', 'Software Developer', 'bradleyj@dx-email.com', '10/12/1985', '142 S Spring St.', 'Los Angeles', 'CA', '90012', '(213) 555-88-21', '(213) 555-44-33', 'IT', '8/24/2012', 'Salaried', 'Mr'));
  FEmployeesList.Add(TEmployee.Create('Leah', 'Simpson', 'Test Coordinator', 'leahs@dx-email.com', '5/22/1988', '587 N Broadway', 'Los Angeles', 'CA', '90012', '(213) 555-11-22', '(213) 555-33-44', 'Quality Assurance', '6/01/2016', 'Salaried', 'Mrs'));
end;

procedure TEmployeeForm.PopulateTree;
var
  NodeCEO, NodeDev, NodeQA: TTreeNode;
begin
  tvEmployees.Items.Clear;
  
  if FEmployeesList.Count > 0 then
  begin
    // CEO is root
    NodeCEO := tvEmployees.Items.AddObject(nil, 'CEO - ' + TEmployee(FEmployeesList[0]).FullName, FEmployeesList[0]);
    
    if FEmployeesList.Count > 1 then
      NodeDev := tvEmployees.Items.AddChildObject(NodeCEO, 'Software Developer - ' + TEmployee(FEmployeesList[1]).FullName, FEmployeesList[1]);
      
    if FEmployeesList.Count > 2 then
      NodeQA := tvEmployees.Items.AddChildObject(NodeCEO, 'Test Coordinator - ' + TEmployee(FEmployeesList[2]).FullName, FEmployeesList[2]);
      
    NodeCEO.Expand(True);
  end;
end;

procedure TEmployeeForm.tvEmployeesSelectionChanged(Sender: TObject);
var
  Node: TTreeNode;
begin
  Node := tvEmployees.Selected;
  if (Node <> nil) and (Node.Data <> nil) then
  begin
    FCurrentEmployee := TEmployee(Node.Data);
    ShowEmployeeDetails(FCurrentEmployee);
  end
  else
  begin
    FCurrentEmployee := nil;
    ClearForm;
  end;
end;

procedure TEmployeeForm.ShowEmployeeDetails(Emp: TEmployee);
begin
  if Emp = nil then Exit;
  
  edtFirstName.Text := Emp.FirstName;
  edtLastName.Text := Emp.LastName;
  edtFullName.Text := Emp.FullName;
  edtBirthDate.Text := Emp.BirthDate;
  edtAddress.Text := Emp.Address;
  edtCity.Text := Emp.City;
  cboState.Text := Emp.State;
  edtZipCode.Text := Emp.ZipCode;
  edtHomePhone.Text := Emp.HomePhone;
  edtMobilePhone.Text := Emp.MobilePhone;
  edtEmail.Text := Emp.Email;
  edtTitle.Text := Emp.Title;
  cboPrefix.Text := Emp.Prefix;
  cboDepartment.Text := Emp.Department;
  edtHireDate.Text := Emp.HireDate;
  cboStatus.Text := Emp.Status;
  
  paintPhoto.Invalidate;
end;

procedure TEmployeeForm.ClearForm;
begin
  edtFirstName.Text := '';
  edtLastName.Text := '';
  edtFullName.Text := '';
  edtBirthDate.Text := '';
  edtAddress.Text := '';
  edtCity.Text := '';
  cboState.Text := '';
  edtZipCode.Text := '';
  edtHomePhone.Text := '';
  edtMobilePhone.Text := '';
  edtEmail.Text := '';
  edtTitle.Text := '';
  cboPrefix.Text := '';
  cboDepartment.Text := '';
  edtHireDate.Text := '';
  cboStatus.Text := '';
  
  paintPhoto.Invalidate;
end;

procedure TEmployeeForm.paintPhotoPaint(Sender: TObject);
var
  LCanvas: TCanvas;
  W, H: Integer;
begin
  LCanvas := paintPhoto.Canvas;
  W := paintPhoto.Width;
  H := paintPhoto.Height;
  
  // Fill background
  LCanvas.Brush.Color := clWhite;
  LCanvas.Brush.Style := bsSolid;
  LCanvas.Pen.Color := clSilver;
  LCanvas.Pen.Width := 1;
  LCanvas.Rectangle(0, 0, W, H);
  
  if FCurrentEmployee = nil then Exit;
  
  // Draw silhouette
  // Body (Shirt/Suit)
  LCanvas.Brush.Color := TColor($2A2A2A); // dark charcoal suit
  LCanvas.Pen.Color := TColor($151515);
  LCanvas.Ellipse(-10, H div 2 + 10, W + 10, H + 20);
  
  // Tie/Collar
  LCanvas.Brush.Color := clWhite;
  LCanvas.Pen.Color := clSilver;
  LCanvas.Polygon([
    Point(W div 2 - 12, H div 2 + 10),
    Point(W div 2 + 12, H div 2 + 10),
    Point(W div 2, H div 2 + 30)
  ]);
  
  LCanvas.Brush.Color := TColor($601010); // Red tie
  LCanvas.Pen.Color := TColor($400505);
  LCanvas.Polygon([
    Point(W div 2 - 4, H div 2 + 18),
    Point(W div 2 + 4, H div 2 + 18),
    Point(W div 2 + 6, H div 2 + 65),
    Point(W div 2, H div 2 + 75),
    Point(W div 2 - 6, H div 2 + 65)
  ]);
  
  // Face
  LCanvas.Brush.Color := TColor($D9B596); // Warm skin tone
  LCanvas.Pen.Color := TColor($A67558);
  LCanvas.Ellipse(W div 2 - 25, H div 2 - 65, W div 2 + 25, H div 2 + 15);
  
  // Hair
  LCanvas.Brush.Color := TColor($100C08); // Dark hair
  LCanvas.Pen.Color := TColor($080604);
  if FCurrentEmployee.LastName = 'Simpson' then
  begin
    // Leah Simpson: longer blonde hair
    LCanvas.Brush.Color := TColor($50D0E0);
    LCanvas.Pen.Color := TColor($30A0B0);
    LCanvas.Ellipse(W div 2 - 28, H div 2 - 68, W div 2 - 12, H div 2 + 20);
    LCanvas.Ellipse(W div 2 + 12, H div 2 - 68, W div 2 + 28, H div 2 + 20);
    LCanvas.Ellipse(W div 2 - 25, H div 2 - 72, W div 2 + 25, H div 2 - 50);
  end
  else
  begin
    // Male short hair
    LCanvas.Chord(W div 2 - 26, H div 2 - 70, W div 2 + 26, H div 2 - 35, W div 2 + 26, H div 2 - 50, W div 2 - 26, H div 2 - 50);
  end;
end;

procedure TEmployeeForm.btnSaveChangesClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  if FCurrentEmployee = nil then Exit;
  
  FCurrentEmployee.FirstName := edtFirstName.Text;
  FCurrentEmployee.LastName := edtLastName.Text;
  FCurrentEmployee.FullName := edtFirstName.Text + ' ' + edtLastName.Text;
  FCurrentEmployee.BirthDate := edtBirthDate.Text;
  FCurrentEmployee.Address := edtAddress.Text;
  FCurrentEmployee.City := edtCity.Text;
  FCurrentEmployee.State := cboState.Text;
  FCurrentEmployee.ZipCode := edtZipCode.Text;
  FCurrentEmployee.HomePhone := edtHomePhone.Text;
  FCurrentEmployee.MobilePhone := edtMobilePhone.Text;
  FCurrentEmployee.Email := edtEmail.Text;
  FCurrentEmployee.Title := edtTitle.Text;
  FCurrentEmployee.Prefix := cboPrefix.Text;
  FCurrentEmployee.Department := cboDepartment.Text;
  FCurrentEmployee.HireDate := edtHireDate.Text;
  FCurrentEmployee.Status := cboStatus.Text;
  
  // Refresh Tree Text
  Node := tvEmployees.Selected;
  if Node <> nil then
  begin
    Node.Text := FCurrentEmployee.Title + ' - ' + FCurrentEmployee.FullName;
  end;
  
  ShowMessage('Changes saved for: ' + FCurrentEmployee.FullName);
end;

procedure TEmployeeForm.btnResetChangesClick(Sender: TObject);
begin
  if FCurrentEmployee <> nil then
    ShowEmployeeDetails(FCurrentEmployee);
end;

procedure TEmployeeForm.btnNewEmployeeClick(Sender: TObject);
var
  NewEmp: TEmployee;
  NewNode: TTreeNode;
  ParentNode: TTreeNode;
begin
  ParentNode := tvEmployees.Selected;
  if ParentNode = nil then
    ParentNode := tvEmployees.Items.GetFirstNode;
    
  NewEmp := TEmployee.Create('New', 'Employee', 'Software Developer', 'new@dx-email.com', '1/1/1990', '123 St.', 'City', 'CA', '90000', '(213) 555-00-00', '(213) 555-00-01', 'IT', '1/1/2026', 'Salaried', 'Mr');
  FEmployeesList.Add(NewEmp);
  
  if ParentNode <> nil then
    NewNode := tvEmployees.Items.AddChildObject(ParentNode, NewEmp.Title + ' - ' + NewEmp.FullName, NewEmp)
  else
    NewNode := tvEmployees.Items.AddObject(nil, NewEmp.Title + ' - ' + NewEmp.FullName, NewEmp);
    
  tvEmployees.Selected := NewNode;
  NewNode.MakeVisible;
end;

procedure TEmployeeForm.btnNewSupervisorClick(Sender: TObject);
var
  NewEmp: TEmployee;
  NewNode: TTreeNode;
begin
  NewEmp := TEmployee.Create('New', 'Supervisor', 'Manager', 'mgr@dx-email.com', '1/1/1980', '123 St.', 'City', 'CA', '90000', '(213) 555-00-00', '(213) 555-00-01', 'Management', '1/1/2026', 'Salaried', 'Mr');
  FEmployeesList.Add(NewEmp);
  
  NewNode := tvEmployees.Items.AddObject(nil, NewEmp.Title + ' - ' + NewEmp.FullName, NewEmp);
  tvEmployees.Selected := NewNode;
  NewNode.MakeVisible;
end;

procedure TEmployeeForm.btnDeleteEmployeeClick(Sender: TObject);
var
  Node: TTreeNode;
  Emp: TEmployee;
begin
  Node := tvEmployees.Selected;
  if Node = nil then Exit;
  
  if MessageDlg('Confirm Delete', 'Are you sure you want to delete this employee node?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    Emp := TEmployee(Node.Data);
    if Emp <> nil then
    begin
      FEmployeesList.Remove(Emp);
      Emp.Free;
    end;
    Node.Delete;
  end;
end;

end.
