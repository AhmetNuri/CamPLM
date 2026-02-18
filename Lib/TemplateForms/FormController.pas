unit FormController;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  FMX.Controls, FMX.StdCtrls, FMX.Edit, FMX.NumberBox, FMX.Memo, FMX.ListBox,
  FMX.DateTimeCtrls, FMX.SpinBox, FMX.Forms;

type
  /// <summary>
  /// Controller class for handling UI component serialization/deserialization
  /// Following SOLID principles - Single Responsibility: UI data conversion only
  /// </summary>
  TFormController = class
  private
    FForm: TForm;
    
    /// <summary>
    /// Gets value from a control as a JSON value
    /// </summary>
    function GetControlValue(AControl: TControl): TJSONValue;
    
    /// <summary>
    /// Sets value to a control from a JSON value
    /// </summary>
    procedure SetControlValue(AControl: TControl; AValue: TJSONValue);
    
    /// <summary>
    /// Recursively finds all data entry controls in a container
    /// </summary>
    procedure FindDataControls(AContainer: TFmxObject; AList: TList<TControl>);
    
    /// <summary>
    /// Checks if a control is a data entry control
    /// </summary>
    function IsDataControl(AControl: TControl): Boolean;
    
  public
    constructor Create(AForm: TForm);
    destructor Destroy; override;
    
    /// <summary>
    /// Serializes all data controls to JSON string
    /// </summary>
    function SaveToJSON: string;
    
    /// <summary>
    /// Deserializes JSON string to data controls
    /// </summary>
    function LoadFromJSON(const AJSON: string): Boolean;
    
    /// <summary>
    /// Clears all data controls
    /// </summary>
    procedure ClearControls;
    
    property Form: TForm read FForm;
  end;

implementation

uses
  System.Rtti, System.TypInfo, System.Variants;

{ TFormController }

constructor TFormController.Create(AForm: TForm);
begin
  inherited Create;
  FForm := AForm;
end;

destructor TFormController.Destroy;
begin
  inherited;
end;

function TFormController.IsDataControl(AControl: TControl): Boolean;
begin
  Result := (AControl is TEdit) or
            (AControl is TNumberBox) or
            (AControl is TMemo) or
            (AControl is TComboBox) or
            (AControl is TCheckBox) or
            (AControl is TRadioButton) or
            (AControl is TDateEdit) or
            (AControl is TTimeEdit) or
            (AControl is TSpinBox);
end;

procedure TFormController.FindDataControls(AContainer: TFmxObject; AList: TList<TControl>);
var
  I: Integer;
  Child: TFmxObject;
  Control: TControl;
begin
  if AContainer = nil then
    Exit;
    
  for I := 0 to AContainer.ChildrenCount - 1 do
  begin
    Child := AContainer.Children[I];
    
    if Child is TControl then
    begin
      Control := TControl(Child);
      if IsDataControl(Control) then
        AList.Add(Control);
    end;
    
    // Recursively search in child containers
    if Child.ChildrenCount > 0 then
      FindDataControls(Child, AList);
  end;
end;

function TFormController.GetControlValue(AControl: TControl): TJSONValue;
begin
  Result := nil;
  
  try
    if AControl is TEdit then
      Result := TJSONString.Create(TEdit(AControl).Text)
    else if AControl is TNumberBox then
      Result := TJSONNumber.Create(TNumberBox(AControl).Value)
    else if AControl is TMemo then
      Result := TJSONString.Create(TMemo(AControl).Text)
    else if AControl is TComboBox then
    begin
      if TComboBox(AControl).ItemIndex >= 0 then
        Result := TJSONString.Create(TComboBox(AControl).Items[TComboBox(AControl).ItemIndex])
      else
        Result := TJSONString.Create('');
    end
    else if AControl is TCheckBox then
      Result := TJSONBool.Create(TCheckBox(AControl).IsChecked)
    else if AControl is TRadioButton then
      Result := TJSONBool.Create(TRadioButton(AControl).IsChecked)
    else if AControl is TDateEdit then
      Result := TJSONString.Create(DateToStr(TDateEdit(AControl).Date))
    else if AControl is TTimeEdit then
      Result := TJSONString.Create(TimeToStr(TTimeEdit(AControl).Time))
    else if AControl is TSpinBox then
      Result := TJSONNumber.Create(TSpinBox(AControl).Value)
    else
      Result := TJSONNull.Create;
  except
    on E: Exception do
    begin
      // Silent exception handling
      Result := TJSONNull.Create;
    end;
  end;
end;

procedure TFormController.SetControlValue(AControl: TControl; AValue: TJSONValue);
var
  I: Integer;
  ComboText: string;
begin
  if AValue = nil then
    Exit;
    
  try
    if AControl is TEdit then
    begin
      if AValue is TJSONString then
        TEdit(AControl).Text := AValue.Value
      else
        TEdit(AControl).Text := AValue.ToString;
    end
    else if AControl is TNumberBox then
    begin
      if AValue is TJSONNumber then
        TNumberBox(AControl).Value := TJSONNumber(AValue).AsDouble
      else
        TNumberBox(AControl).Value := StrToFloatDef(AValue.Value, 0);
    end
    else if AControl is TMemo then
    begin
      if AValue is TJSONString then
        TMemo(AControl).Text := AValue.Value
      else
        TMemo(AControl).Text := AValue.ToString;
    end
    else if AControl is TComboBox then
    begin
      if AValue is TJSONString then
      begin
        ComboText := AValue.Value;
        I := TComboBox(AControl).Items.IndexOf(ComboText);
        if I >= 0 then
          TComboBox(AControl).ItemIndex := I;
      end;
    end
    else if AControl is TCheckBox then
    begin
      if AValue is TJSONBool then
        TCheckBox(AControl).IsChecked := TJSONBool(AValue).AsBoolean
      else
        TCheckBox(AControl).IsChecked := StrToBoolDef(AValue.Value, False);
    end
    else if AControl is TRadioButton then
    begin
      if AValue is TJSONBool then
        TRadioButton(AControl).IsChecked := TJSONBool(AValue).AsBoolean
      else
        TRadioButton(AControl).IsChecked := StrToBoolDef(AValue.Value, False);
    end
    else if AControl is TDateEdit then
    begin
      try
        if AValue is TJSONString then
          TDateEdit(AControl).Date := StrToDate(AValue.Value);
      except
        // Invalid date, skip
      end;
    end
    else if AControl is TTimeEdit then
    begin
      try
        if AValue is TJSONString then
          TTimeEdit(AControl).Time := StrToTime(AValue.Value);
      except
        // Invalid time, skip
      end;
    end
    else if AControl is TSpinBox then
    begin
      if AValue is TJSONNumber then
        TSpinBox(AControl).Value := TJSONNumber(AValue).AsDouble
      else
        TSpinBox(AControl).Value := StrToFloatDef(AValue.Value, 0);
    end;
  except
    on E: Exception do
    begin
      // Silent exception handling - skip this control
    end;
  end;
end;

function TFormController.SaveToJSON: string;
var
  JSONObj: TJSONObject;
  ControlList: TList<TControl>;
  Control: TControl;
  JSONValue: TJSONValue;
begin
  Result := '{}';
  JSONObj := TJSONObject.Create;
  ControlList := TList<TControl>.Create;
  
  try
    try
      // Find all data controls in the form
      FindDataControls(FForm, ControlList);
      
      // Serialize each control
      for Control in ControlList do
      begin
        if Control.Name <> '' then
        begin
          JSONValue := GetControlValue(Control);
          if JSONValue <> nil then
            JSONObj.AddPair(Control.Name, JSONValue);
        end;
      end;
      
      Result := JSONObj.ToString;
    except
      on E: Exception do
      begin
        // Silent exception handling - return empty JSON
        Result := '{}';
      end;
    end;
  finally
    JSONObj.Free;
    ControlList.Free;
  end;
end;

function TFormController.LoadFromJSON(const AJSON: string): Boolean;
var
  JSONObj: TJSONObject;
  JSONPair: TJSONPair;
  ControlList: TList<TControl>;
  Control: TControl;
  I: Integer;
begin
  Result := False;
  
  if Trim(AJSON) = '' then
    Exit;
    
  ControlList := TList<TControl>.Create;
  
  try
    try
      // Parse JSON
      JSONObj := TJSONObject.ParseJSONValue(AJSON) as TJSONObject;
      if JSONObj = nil then
        Exit;
        
      try
        // Find all data controls in the form
        FindDataControls(FForm, ControlList);
        
        // For each JSON pair, find matching control and set value
        for I := 0 to JSONObj.Count - 1 do
        begin
          JSONPair := JSONObj.Pairs[I];
          
          // Find control with matching name
          for Control in ControlList do
          begin
            if SameText(Control.Name, JSONPair.JsonString.Value) then
            begin
              SetControlValue(Control, JSONPair.JsonValue);
              Break;
            end;
          end;
        end;
        
        Result := True;
      finally
        JSONObj.Free;
      end;
    except
      on E: Exception do
      begin
        // Silent exception handling
        Result := False;
      end;
    end;
  finally
    ControlList.Free;
  end;
end;

procedure TFormController.ClearControls;
var
  ControlList: TList<TControl>;
  Control: TControl;
begin
  ControlList := TList<TControl>.Create;
  try
    FindDataControls(FForm, ControlList);
    
    for Control in ControlList do
    begin
      try
        if Control is TEdit then
          TEdit(Control).Text := ''
        else if Control is TNumberBox then
          TNumberBox(Control).Value := 0
        else if Control is TMemo then
          TMemo(Control).Text := ''
        else if Control is TComboBox then
          TComboBox(Control).ItemIndex := -1
        else if Control is TCheckBox then
          TCheckBox(Control).IsChecked := False
        else if Control is TRadioButton then
          TRadioButton(Control).IsChecked := False
        else if Control is TDateEdit then
          TDateEdit(Control).Date := Now
        else if Control is TTimeEdit then
          TTimeEdit(Control).Time := Now
        else if Control is TSpinBox then
          TSpinBox(Control).Value := 0;
      except
        // Skip on error
      end;
    end;
  finally
    ControlList.Free;
  end;
end;

end.
