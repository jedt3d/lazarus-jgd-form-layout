unit ujgdformslayout;

{$mode objfpc}{$H+}
{$scopedenums on}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Graphics, Types, Math, LCLType;

type
  TJgdHAlign = (jgdLeft, jgdRight, jgdCenter, jgdFill, jgdDefault);
  TJgdVAlign = (jgdTop, jgdBottom, jgdCenter, jgdFill, jgdDefault);
  TJgdSizeKind = (szConstant, szPreferred, szMinimum, szDefault);

  TJgdColSpec = record
    Align: TJgdHAlign;
    SizeKind: TJgdSizeKind;
    SizeValue: Double;
    SizeUnit: string;  // 'px' or 'dlu'
    GrowWeight: Double;
  end;
  
  TJgdRowSpec = record
    Align: TJgdVAlign;
    SizeKind: TJgdSizeKind;
    SizeValue: Double;
    SizeUnit: string;  // 'px' or 'dlu'
    GrowWeight: Double;
  end;

  TColSpecArray = array of TJgdColSpec;
  TRowSpecArray = array of TJgdRowSpec;

  TJgdFormLayout = class;

  // Design-time mapping item for child controls
  TJgdFormLayoutControlItem = class(TCollectionItem)
  private
    FControl: TControl;
    FColumn: Integer;
    FRow: Integer;
    FColumnSpan: Integer;
    FRowSpan: Integer;
    FHAlign: TJgdHAlign;
    FVAlign: TJgdVAlign;
    procedure SetControl(AValue: TControl);
    procedure SetColumn(AValue: Integer);
    procedure SetRow(AValue: Integer);
    procedure SetColumnSpan(AValue: Integer);
    procedure SetRowSpan(AValue: Integer);
    procedure SetHAlign(AValue: TJgdHAlign);
    procedure SetVAlign(AValue: TJgdVAlign);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Control: TControl read FControl write SetControl;
    property Column: Integer read FColumn write SetColumn default 1;
    property Row: Integer read FRow write SetRow default 1;
    property ColumnSpan: Integer read FColumnSpan write SetColumnSpan default 1;
    property RowSpan: Integer read FRowSpan write SetRowSpan default 1;
    property HAlign: TJgdHAlign read FHAlign write SetHAlign default TJgdHAlign.jgdDefault;
    property VAlign: TJgdVAlign read FVAlign write SetVAlign default TJgdVAlign.jgdDefault;
  end;

  // Collection to store mappings
  TJgdFormLayoutControlCollection = class(TOwnedCollection)
  private
    FLayout: TJgdFormLayout;
    function GetItem(Index: Integer): TJgdFormLayoutControlItem;
    procedure SetItem(Index: Integer; AValue: TJgdFormLayoutControlItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TJgdFormLayout);
    function Add: TJgdFormLayoutControlItem;
    function FindControlItem(AControl: TControl): TJgdFormLayoutControlItem;
    property Items[Index: Integer]: TJgdFormLayoutControlItem read GetItem write SetItem; default;
  end;

  // The custom layout panel component
  TJgdFormLayout = class(TPanel)
  private
    FColumnSpecs: string;
    FRowSpecs: string;
    FControlConstraints: TJgdFormLayoutControlCollection;
    FIsAligning: Boolean;
    
    FColSpecsParsed: TColSpecArray;
    FRowSpecsParsed: TRowSpecArray;
    
    procedure SetColumnSpecs(const AValue: string);
    procedure SetRowSpecs(const AValue: string);
    procedure SetControlConstraints(AValue: TJgdFormLayoutControlCollection);
    procedure ParseSpecs;
    procedure ParseColSpecString(const ASpecStr: string; var ASpecs: TColSpecArray);
    procedure ParseRowSpecString(const ASpecStr: string; var ASpecs: TRowSpecArray);
  protected
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function DluToPx(ADlu: Double; AIsHorizontal: Boolean): Integer;
    property ColSpecsParsed: TColSpecArray read FColSpecsParsed;
    property RowSpecsParsed: TRowSpecArray read FRowSpecsParsed;
  published
    property ColumnSpecs: string read FColumnSpecs write SetColumnSpecs;
    property RowSpecs: string read FRowSpecs write SetRowSpecs;
    property ControlConstraints: TJgdFormLayoutControlCollection read FControlConstraints write SetControlConstraints;
    
    // Publish standard panel design-time options
    property Align;
    property Anchors;
    property BorderWidth;
    property BorderStyle;
    property Color;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentFont;
    property Visible;
  end;

implementation

{ Helper functions for layout preferred size }
function GetControlPrefSize(AControl: TControl): TPoint;
var
  W, H: LongInt;
begin
  W := 0;
  H := 0;
  AControl.GetPreferredSize(W, H);
  Result.X := W;
  Result.Y := H;
end;

function ParseGrowWeight(const S: string): Double;
var
  PStart, PEnd: Integer;
  WeightStr: string;
  Code: Integer;
begin
  Result := 0.0;
  if (S = 'grow') or (S = 'g') then
    Result := 1.0
  else if (Pos('grow(', S) = 1) or (Pos('g(', S) = 1) then
  begin
    PStart := Pos('(', S);
    PEnd := Pos(')', S);
    if (PStart > 0) and (PEnd > PStart) then
    begin
      WeightStr := Copy(S, PStart + 1, PEnd - PStart - 1);
      Val(WeightStr, Result, Code);
      if Code <> 0 then
        Result := 1.0; // fallback
    end;
  end;
end;

{ Helper unit functions for string parsing }
function SplitString(const S: string; Separator: Char): TStringList;
var
  StartIdx, FoundIdx: Integer;
begin
  Result := TStringList.Create;
  StartIdx := 1;
  while StartIdx <= Length(S) do
  begin
    FoundIdx := Pos(Separator, S, StartIdx);
    if FoundIdx = 0 then
    begin
      Result.Add(Trim(Copy(S, StartIdx, Length(S) - StartIdx + 1)));
      Break;
    end;
    Result.Add(Trim(Copy(S, StartIdx, FoundIdx - StartIdx)));
    StartIdx := FoundIdx + 1;
  end;
end;

{ TJgdFormLayoutControlItem }

constructor TJgdFormLayoutControlItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FColumn := 1;
  FRow := 1;
  FColumnSpan := 1;
  FRowSpan := 1;
  FHAlign := TJgdHAlign.jgdDefault;
  FVAlign := TJgdVAlign.jgdDefault;
end;

procedure TJgdFormLayoutControlItem.Assign(Source: TPersistent);
var
  Src: TJgdFormLayoutControlItem;
begin
  if Source is TJgdFormLayoutControlItem then
  begin
    Src := TJgdFormLayoutControlItem(Source);
    FControl := Src.Control;
    FColumn := Src.Column;
    FRow := Src.Row;
    FColumnSpan := Src.ColumnSpan;
    FRowSpan := Src.RowSpan;
    FHAlign := Src.HAlign;
    FVAlign := Src.VAlign;
    Changed(False);
  end
  else
    inherited Assign(Source);
end;

function TJgdFormLayoutControlItem.GetDisplayName: string;
begin
  if FControl <> nil then
    Result := FControl.Name + ' (Col:' + IntToStr(FColumn) + ', Row:' + IntToStr(FRow) + ')'
  else
    Result := 'Empty (Col:' + IntToStr(FColumn) + ', Row:' + IntToStr(FRow) + ')';
end;

procedure TJgdFormLayoutControlItem.SetControl(AValue: TControl);
begin
  if FControl <> AValue then
  begin
    FControl := AValue;
    Changed(False);
  end;
end;

procedure TJgdFormLayoutControlItem.SetColumn(AValue: Integer);
begin
  if AValue < 1 then AValue := 1;
  if FColumn <> AValue then
  begin
    FColumn := AValue;
    Changed(False);
  end;
end;

procedure TJgdFormLayoutControlItem.SetRow(AValue: Integer);
begin
  if AValue < 1 then AValue := 1;
  if FRow <> AValue then
  begin
    FRow := AValue;
    Changed(False);
  end;
end;

procedure TJgdFormLayoutControlItem.SetColumnSpan(AValue: Integer);
begin
  if AValue < 1 then AValue := 1;
  if FColumnSpan <> AValue then
  begin
    FColumnSpan := AValue;
    Changed(False);
  end;
end;

procedure TJgdFormLayoutControlItem.SetRowSpan(AValue: Integer);
begin
  if AValue < 1 then AValue := 1;
  if FRowSpan <> AValue then
  begin
    FRowSpan := AValue;
    Changed(False);
  end;
end;

procedure TJgdFormLayoutControlItem.SetHAlign(AValue: TJgdHAlign);
begin
  if FHAlign <> AValue then
  begin
    FHAlign := AValue;
    Changed(False);
  end;
end;

procedure TJgdFormLayoutControlItem.SetVAlign(AValue: TJgdVAlign);
begin
  if FVAlign <> AValue then
  begin
    FVAlign := AValue;
    Changed(False);
  end;
end;

{ TJgdFormLayoutControlCollection }

constructor TJgdFormLayoutControlCollection.Create(AOwner: TJgdFormLayout);
begin
  inherited Create(AOwner, TJgdFormLayoutControlItem);
  FLayout := AOwner;
end;

function TJgdFormLayoutControlCollection.Add: TJgdFormLayoutControlItem;
begin
  Result := TJgdFormLayoutControlItem(inherited Add);
end;

function TJgdFormLayoutControlCollection.GetItem(Index: Integer): TJgdFormLayoutControlItem;
begin
  Result := TJgdFormLayoutControlItem(inherited GetItem(Index));
end;

procedure TJgdFormLayoutControlCollection.SetItem(Index: Integer; AValue: TJgdFormLayoutControlItem);
begin
  inherited SetItem(Index, AValue);
end;

procedure TJgdFormLayoutControlCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if (FLayout <> nil) and not FLayout.FIsAligning then
    FLayout.Realign; // Force alignment redraw
end;

function TJgdFormLayoutControlCollection.FindControlItem(AControl: TControl): TJgdFormLayoutControlItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if Items[I].Control = AControl then
    begin
      Result := Items[I];
      Exit;
    end;
  end;
end;

{ TJgdFormLayout }

constructor TJgdFormLayout.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIsAligning := False;
  FControlConstraints := TJgdFormLayoutControlCollection.Create(Self);
  FColumnSpecs := 'pref, 4dlu, pref';
  FRowSpecs := 'pref, 4dlu, pref';
  ParseSpecs;
end;

destructor TJgdFormLayout.Destroy;
begin
  FControlConstraints.Free;
  inherited Destroy;
end;

procedure TJgdFormLayout.SetColumnSpecs(const AValue: string);
begin
  if FColumnSpecs <> AValue then
  begin
    FColumnSpecs := AValue;
    ParseSpecs;
    Invalidate;
    Realign;
  end;
end;

procedure TJgdFormLayout.SetRowSpecs(const AValue: string);
begin
  if FRowSpecs <> AValue then
  begin
    FRowSpecs := AValue;
    ParseSpecs;
    Invalidate;
    Realign;
  end;
end;

procedure TJgdFormLayout.SetControlConstraints(AValue: TJgdFormLayoutControlCollection);
begin
  FControlConstraints.Assign(AValue);
end;

procedure TJgdFormLayout.Notification(AComponent: TComponent; Operation: TOperation);
var
  Item: TJgdFormLayoutControlItem;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FControlConstraints <> nil) then
  begin
    if AComponent is TControl then
    begin
      Item := FControlConstraints.FindControlItem(TControl(AComponent));
      if Item <> nil then
        Item.Free;
    end;
  end;
end;

procedure TJgdFormLayout.ParseSpecs;
begin
  ParseColSpecString(FColumnSpecs, FColSpecsParsed);
  ParseRowSpecString(FRowSpecs, FRowSpecsParsed);
end;

procedure TJgdFormLayout.ParseColSpecString(const ASpecStr: string; var ASpecs: TColSpecArray);
var
  Tokens: TStringList;
  I, J: Integer;
  Token: string;
  Parts: TStringList;
  NewSpec: TJgdColSpec;
  SizeStr: string;
begin
  SetLength(ASpecs, 0);
  Tokens := SplitString(ASpecStr, ',');
  try
    for I := 0 to Tokens.Count - 1 do
    begin
      Token := LowerCase(Tokens[I]);
      if Token = '' then Continue;

      Parts := SplitString(Token, ':');
      try
        NewSpec.Align := TJgdHAlign.jgdDefault;
        NewSpec.SizeKind := TJgdSizeKind.szPreferred;
        NewSpec.SizeValue := 0;
        NewSpec.SizeUnit := 'px';
        NewSpec.GrowWeight := 0.0;

        if Parts.Count = 1 then
        begin
          SizeStr := Parts[0];
        end
        else if Parts.Count = 2 then
        begin
          if (Parts[0] = 'left') or (Parts[0] = 'l') or
             (Parts[0] = 'right') or (Parts[0] = 'r') or
             (Parts[0] = 'center') or (Parts[0] = 'c') or
             (Parts[0] = 'fill') or (Parts[0] = 'f') then
          begin
            if (Parts[0] = 'left') or (Parts[0] = 'l') then NewSpec.Align := TJgdHAlign.jgdLeft
            else if (Parts[0] = 'right') or (Parts[0] = 'r') then NewSpec.Align := TJgdHAlign.jgdRight
            else if (Parts[0] = 'center') or (Parts[0] = 'c') then NewSpec.Align := TJgdHAlign.jgdCenter
            else if (Parts[0] = 'fill') or (Parts[0] = 'f') then NewSpec.Align := TJgdHAlign.jgdFill;
            SizeStr := Parts[1];
          end
          else
          begin
            SizeStr := Parts[0];
            NewSpec.GrowWeight := ParseGrowWeight(Parts[1]);
          end;
        end
        else if Parts.Count >= 3 then
        begin
          if (Parts[0] = 'left') or (Parts[0] = 'l') then NewSpec.Align := TJgdHAlign.jgdLeft
          else if (Parts[0] = 'right') or (Parts[0] = 'r') then NewSpec.Align := TJgdHAlign.jgdRight
          else if (Parts[0] = 'center') or (Parts[0] = 'c') then NewSpec.Align := TJgdHAlign.jgdCenter
          else if (Parts[0] = 'fill') or (Parts[0] = 'f') then NewSpec.Align := TJgdHAlign.jgdFill;
          
          SizeStr := Parts[1];
          NewSpec.GrowWeight := ParseGrowWeight(Parts[2]);
        end;

        if (SizeStr = 'pref') or (SizeStr = 'p') then
          NewSpec.SizeKind := TJgdSizeKind.szPreferred
        else if (SizeStr = 'min') or (SizeStr = 'm') then
          NewSpec.SizeKind := TJgdSizeKind.szMinimum
        else if (SizeStr = 'default') or (SizeStr = 'd') then
          NewSpec.SizeKind := TJgdSizeKind.szDefault
        else
        begin
          NewSpec.SizeKind := TJgdSizeKind.szConstant;
          if Pos('dlu', SizeStr) > 0 then
          begin
            NewSpec.SizeUnit := 'dlu';
            Val(Copy(SizeStr, 1, Pos('dlu', SizeStr) - 1), NewSpec.SizeValue, J);
          end
          else if Pos('px', SizeStr) > 0 then
          begin
            NewSpec.SizeUnit := 'px';
            Val(Copy(SizeStr, 1, Pos('px', SizeStr) - 1), NewSpec.SizeValue, J);
          end
          else
          begin
            NewSpec.SizeUnit := 'px';
            Val(SizeStr, NewSpec.SizeValue, J);
          end;
        end;

        SetLength(ASpecs, Length(ASpecs) + 1);
        ASpecs[Length(ASpecs) - 1] := NewSpec;

      finally
        Parts.Free;
      end;
    end;
  finally
    Tokens.Free;
  end;
end;

procedure TJgdFormLayout.ParseRowSpecString(const ASpecStr: string; var ASpecs: TRowSpecArray);
var
  Tokens: TStringList;
  I, J: Integer;
  Token: string;
  Parts: TStringList;
  NewSpec: TJgdRowSpec;
  SizeStr: string;
begin
  SetLength(ASpecs, 0);
  Tokens := SplitString(ASpecStr, ',');
  try
    for I := 0 to Tokens.Count - 1 do
    begin
      Token := LowerCase(Tokens[I]);
      if Token = '' then Continue;

      Parts := SplitString(Token, ':');
      try
        NewSpec.Align := TJgdVAlign.jgdDefault;
        NewSpec.SizeKind := TJgdSizeKind.szPreferred;
        NewSpec.SizeValue := 0;
        NewSpec.SizeUnit := 'px';
        NewSpec.GrowWeight := 0.0;

        if Parts.Count = 1 then
        begin
          SizeStr := Parts[0];
        end
        else if Parts.Count = 2 then
        begin
          if (Parts[0] = 'top') or (Parts[0] = 't') or
             (Parts[0] = 'bottom') or (Parts[0] = 'b') or
             (Parts[0] = 'center') or (Parts[0] = 'c') or
             (Parts[0] = 'fill') or (Parts[0] = 'f') then
          begin
            if (Parts[0] = 'top') or (Parts[0] = 't') then NewSpec.Align := TJgdVAlign.jgdTop
            else if (Parts[0] = 'bottom') or (Parts[0] = 'b') then NewSpec.Align := TJgdVAlign.jgdBottom
            else if (Parts[0] = 'center') or (Parts[0] = 'c') then NewSpec.Align := TJgdVAlign.jgdCenter
            else if (Parts[0] = 'fill') or (Parts[0] = 'f') then NewSpec.Align := TJgdVAlign.jgdFill;
            SizeStr := Parts[1];
          end
          else
          begin
            SizeStr := Parts[0];
            NewSpec.GrowWeight := ParseGrowWeight(Parts[1]);
          end;
        end
        else if Parts.Count >= 3 then
        begin
          if (Parts[0] = 'top') or (Parts[0] = 't') then NewSpec.Align := TJgdVAlign.jgdTop
          else if (Parts[0] = 'bottom') or (Parts[0] = 'b') then NewSpec.Align := TJgdVAlign.jgdBottom
          else if (Parts[0] = 'center') or (Parts[0] = 'c') then NewSpec.Align := TJgdVAlign.jgdCenter
          else if (Parts[0] = 'fill') or (Parts[0] = 'f') then NewSpec.Align := TJgdVAlign.jgdFill;
          
          SizeStr := Parts[1];
          NewSpec.GrowWeight := ParseGrowWeight(Parts[2]);
        end;

        if (SizeStr = 'pref') or (SizeStr = 'p') then
          NewSpec.SizeKind := TJgdSizeKind.szPreferred
        else if (SizeStr = 'min') or (SizeStr = 'm') then
          NewSpec.SizeKind := TJgdSizeKind.szMinimum
        else if (SizeStr = 'default') or (SizeStr = 'd') then
          NewSpec.SizeKind := TJgdSizeKind.szDefault
        else
        begin
          NewSpec.SizeKind := TJgdSizeKind.szConstant;
          if Pos('dlu', SizeStr) > 0 then
          begin
            NewSpec.SizeUnit := 'dlu';
            Val(Copy(SizeStr, 1, Pos('dlu', SizeStr) - 1), NewSpec.SizeValue, J);
          end
          else if Pos('px', SizeStr) > 0 then
          begin
            NewSpec.SizeUnit := 'px';
            Val(Copy(SizeStr, 1, Pos('px', SizeStr) - 1), NewSpec.SizeValue, J);
          end
          else
          begin
            NewSpec.SizeUnit := 'px';
            Val(SizeStr, NewSpec.SizeValue, J);
          end;
        end;

        SetLength(ASpecs, Length(ASpecs) + 1);
        ASpecs[Length(ASpecs) - 1] := NewSpec;

      finally
        Parts.Free;
      end;
    end;
  finally
    Tokens.Free;
  end;
end;

function TJgdFormLayout.DluToPx(ADlu: Double; AIsHorizontal: Boolean): Integer;
var
  FH, FW: Integer;
begin
  FH := Font.Height;
  if FH < 0 then FH := -FH;
  if FH = 0 then FH := 13; // Fallback standard font height in px
  FW := FH div 2;          // Average character width is roughly half height
  if FW = 0 then FW := 6;

  if AIsHorizontal then
    Result := Round(ADlu * (FW / 4))
  else
    Result := Round(ADlu * (FH / 8));

  if Result < 1 then Result := 1;
end;

procedure TJgdFormLayout.AlignControls(AControl: TControl; var ARect: TRect);
var
  ColWidths, RowHeights: array of Integer;
  ColLeft, RowTop: array of Integer;
  I, C, R, TargetIdx: Integer;
  ChildControl: TControl;
  Item: TJgdFormLayoutControlItem;
  MaxPref: Integer;
  PrefSize: TPoint;
  RemainingW, RemainingH: Integer;
  TotalGrowW, TotalGrowH: Double;
  GrowShare: Integer;
  CellLeft, CellWidth, CellTop, CellHeight: Integer;
  TargetLeft, TargetWidth, TargetTop, TargetHeight: Integer;
  ActualHAlign: TJgdHAlign;
  ActualVAlign: TJgdVAlign;
begin
  if FIsAligning then Exit;
  if (Length(FColSpecsParsed) = 0) or (Length(FRowSpecsParsed) = 0) then
  begin
    inherited AlignControls(AControl, ARect);
    Exit;
  end;

  FIsAligning := True;
  try
    // 1. Sync controls collection (automatically add child controls, but not during loading)
    if not (csLoading in ComponentState) then
    begin
      for I := 0 to ControlCount - 1 do
      begin
        ChildControl := Controls[I];
        Item := FControlConstraints.FindControlItem(ChildControl);
        if Item = nil then
        begin
          Item := FControlConstraints.Add;
          Item.Control := ChildControl;
        end;
      end;
    end;

  // Initialize arrays
  SetLength(ColWidths, Length(FColSpecsParsed));
  SetLength(RowHeights, Length(FRowSpecsParsed));

  // PASS 1: Calculate constants
  for C := 0 to Length(FColSpecsParsed) - 1 do
  begin
    if FColSpecsParsed[C].SizeKind = TJgdSizeKind.szConstant then
    begin
      if FColSpecsParsed[C].SizeUnit = 'dlu' then
        ColWidths[C] := DluToPx(FColSpecsParsed[C].SizeValue, True)
      else
        ColWidths[C] := Round(FColSpecsParsed[C].SizeValue);
    end
    else
      ColWidths[C] := 0;
  end;

  for R := 0 to Length(FRowSpecsParsed) - 1 do
  begin
    if FRowSpecsParsed[R].SizeKind = TJgdSizeKind.szConstant then
    begin
      if FRowSpecsParsed[R].SizeUnit = 'dlu' then
        RowHeights[R] := DluToPx(FRowSpecsParsed[R].SizeValue, False)
      else
        RowHeights[R] := Round(FRowSpecsParsed[R].SizeValue);
    end
    else
      RowHeights[R] := 0;
  end;

  // PASS 2: Calculate preferred / minimum component sizes (only checking ColumnSpan/RowSpan = 1)
  for C := 0 to Length(FColSpecsParsed) - 1 do
  begin
    if FColSpecsParsed[C].SizeKind in [TJgdSizeKind.szPreferred, TJgdSizeKind.szMinimum, TJgdSizeKind.szDefault] then
    begin
      MaxPref := 0;
      for I := 0 to FControlConstraints.Count - 1 do
      begin
        Item := FControlConstraints[I];
        if (Item.Control <> nil) and (Item.Control.Parent = Self) and (Item.Column = C + 1) and (Item.ColumnSpan = 1) then
        begin
          PrefSize := GetControlPrefSize(Item.Control);
          if PrefSize.X > MaxPref then
            MaxPref := PrefSize.X;
        end;
      end;
      ColWidths[C] := MaxPref;
    end;
  end;

  for R := 0 to Length(FRowSpecsParsed) - 1 do
  begin
    if FRowSpecsParsed[R].SizeKind in [TJgdSizeKind.szPreferred, TJgdSizeKind.szMinimum, TJgdSizeKind.szDefault] then
    begin
      MaxPref := 0;
      for I := 0 to FControlConstraints.Count - 1 do
      begin
        Item := FControlConstraints[I];
        if (Item.Control <> nil) and (Item.Control.Parent = Self) and (Item.Row = R + 1) and (Item.RowSpan = 1) then
        begin
          PrefSize := GetControlPrefSize(Item.Control);
          if PrefSize.Y > MaxPref then
            MaxPref := PrefSize.Y;
        end;
      end;
      RowHeights[R] := MaxPref;
    end;
  end;

  // PASS 3: Distribute Grow Space
  RemainingW := ClientRect.Width - BorderWidth * 2;
  for C := 0 to Length(ColWidths) - 1 do
    RemainingW := RemainingW - ColWidths[C];

  if RemainingW > 0 then
  begin
    TotalGrowW := 0.0;
    for C := 0 to Length(FColSpecsParsed) - 1 do
      TotalGrowW := TotalGrowW + FColSpecsParsed[C].GrowWeight;

    if TotalGrowW > 0.0 then
    begin
      for C := 0 to Length(FColSpecsParsed) - 1 do
      begin
        if FColSpecsParsed[C].GrowWeight > 0.0 then
        begin
          GrowShare := Round(RemainingW * (FColSpecsParsed[C].GrowWeight / TotalGrowW));
          ColWidths[C] := ColWidths[C] + GrowShare;
        end;
      end;
    end;
  end;

  RemainingH := ClientRect.Height - BorderWidth * 2;
  for R := 0 to Length(RowHeights) - 1 do
    RemainingH := RemainingH - RowHeights[R];

  if RemainingH > 0 then
  begin
    TotalGrowH := 0.0;
    for R := 0 to Length(FRowSpecsParsed) - 1 do
      TotalGrowH := TotalGrowH + FRowSpecsParsed[R].GrowWeight;

    if TotalGrowH > 0.0 then
    begin
      for R := 0 to Length(FRowSpecsParsed) - 1 do
      begin
        if FRowSpecsParsed[R].GrowWeight > 0.0 then
        begin
          GrowShare := Round(RemainingH * (FRowSpecsParsed[R].GrowWeight / TotalGrowH));
          RowHeights[R] := RowHeights[R] + GrowShare;
        end;
      end;
    end;
  end;

  // Calculate layout grid starting positions
  SetLength(ColLeft, Length(ColWidths) + 1);
  ColLeft[0] := BorderWidth;
  for C := 1 to Length(ColWidths) do
    ColLeft[C] := ColLeft[C - 1] + ColWidths[C - 1];

  SetLength(RowTop, Length(RowHeights) + 1);
  RowTop[0] := BorderWidth;
  for R := 1 to Length(RowHeights) do
    RowTop[R] := RowTop[R - 1] + RowHeights[R - 1];

  // 4. Place each child control
  for I := 0 to FControlConstraints.Count - 1 do
  begin
    Item := FControlConstraints[I];
    ChildControl := Item.Control;
    if (ChildControl = nil) or (ChildControl.Parent <> Self) then Continue;

    // Bounds checking
    C := Item.Column - 1;
    if C < 0 then C := 0;
    if C >= Length(ColWidths) then C := Length(ColWidths) - 1;
    
    R := Item.Row - 1;
    if R < 0 then R := 0;
    if R >= Length(RowHeights) then R := Length(RowHeights) - 1;

    // Calculate Cell bounds including spans
    CellLeft := ColLeft[C];
    CellWidth := 0;
    for TargetIdx := C to Min(C + Item.ColumnSpan - 1, Length(ColWidths) - 1) do
      CellWidth := CellWidth + ColWidths[TargetIdx];

    CellTop := RowTop[R];
    CellHeight := 0;
    for TargetIdx := R to Min(R + Item.RowSpan - 1, Length(RowHeights) - 1) do
      CellHeight := CellHeight + RowHeights[TargetIdx];

    PrefSize := GetControlPrefSize(ChildControl);

    // Resolve Horizontal Alignment
    ActualHAlign := Item.HAlign;
    if ActualHAlign = TJgdHAlign.jgdDefault then
      ActualHAlign := FColSpecsParsed[C].Align;
    if ActualHAlign = TJgdHAlign.jgdDefault then
      ActualHAlign := TJgdHAlign.jgdFill;

    case ActualHAlign of
      TJgdHAlign.jgdLeft:
        begin
          TargetWidth := Min(PrefSize.X, CellWidth);
          TargetLeft := CellLeft;
        end;
      TJgdHAlign.jgdRight:
        begin
          TargetWidth := Min(PrefSize.X, CellWidth);
          TargetLeft := CellLeft + CellWidth - TargetWidth;
        end;
      TJgdHAlign.jgdCenter:
        begin
          TargetWidth := Min(PrefSize.X, CellWidth);
          TargetLeft := CellLeft + (CellWidth - TargetWidth) div 2;
        end;
      else // TJgdHAlign.jgdFill
        begin
          TargetWidth := CellWidth;
          TargetLeft := CellLeft;
        end;
    end;

    // Resolve Vertical Alignment
    ActualVAlign := Item.VAlign;
    if ActualVAlign = TJgdVAlign.jgdDefault then
      ActualVAlign := FRowSpecsParsed[R].Align;
    if ActualVAlign = TJgdVAlign.jgdDefault then
      ActualVAlign := TJgdVAlign.jgdFill;

    case ActualVAlign of
      TJgdVAlign.jgdTop:
        begin
          TargetHeight := Min(PrefSize.Y, CellHeight);
          TargetTop := CellTop;
        end;
      TJgdVAlign.jgdBottom:
        begin
          TargetHeight := Min(PrefSize.Y, CellHeight);
          TargetTop := CellTop + CellHeight - TargetHeight;
        end;
      TJgdVAlign.jgdCenter:
        begin
          TargetHeight := Min(PrefSize.Y, CellHeight);
          TargetTop := CellTop + (CellHeight - TargetHeight) div 2;
        end;
      else // TJgdVAlign.jgdFill
        begin
          TargetHeight := CellHeight;
          TargetTop := CellTop;
        end;
    end;

    ChildControl.SetBounds(TargetLeft, TargetTop, TargetWidth, TargetHeight);
  end;
  finally
    FIsAligning := False;
  end;
end;

initialization
  RegisterClass(TJgdFormLayout);

end.
