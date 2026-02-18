unit ListBoxHelper;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  FMX.ListBox, FMX.Types;

type
  /// <summary>
  /// Class helper for TListBox to provide JSON import/export functionality
  /// </summary>
  TListBoxHelper = class helper for TListBox
  public
    /// <summary>
    /// Exports all listbox items to JSON format
    /// Returns a JSON array containing all items with their text and data
    /// </summary>
    function SaveToJSON: string;
    
    /// <summary>
    /// Imports items from JSON format
    /// Clears existing items and loads from JSON array
    /// Returns True if successful, False otherwise
    /// </summary>
    function LoadFromJSON(const AJSON: string): Boolean;
    
    /// <summary>
    /// Clears all items from the listbox
    /// </summary>
    procedure ClearItems;
  end;

implementation

{ TListBoxHelper }

function TListBoxHelper.SaveToJSON: string;
var
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
  I: Integer;
begin
  Result := '[]';
  JSONArray := TJSONArray.Create;
  try
    try
      for I := 0 to Self.Items.Count - 1 do
      begin
        JSONObj := TJSONObject.Create;
        JSONObj.AddPair('text', Self.Items[I]);
        
        // If item has associated data object, try to include it
        if Self.ListItems[I].Data <> nil then
        begin
          JSONObj.AddPair('data', IntToStr(NativeInt(Self.ListItems[I].Data)));
        end;
        
        // Include selection state
        JSONObj.AddPair('selected', TJSONBool.Create(Self.ListItems[I].IsSelected));
        
        JSONArray.AddElement(JSONObj);
      end;
      
      Result := JSONArray.ToString;
    except
      on E: Exception do
      begin
        // Silent exception handling - return empty array
        Result := '[]';
      end;
    end;
  finally
    JSONArray.Free;
  end;
end;

function TListBoxHelper.LoadFromJSON(const AJSON: string): Boolean;
var
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
  JSONValue: TJSONValue;
  I: Integer;
  ItemText: string;
  ItemData: NativeInt;
  IsSelected: Boolean;
  ListItem: TListBoxItem;
begin
  Result := False;
  
  if Trim(AJSON) = '' then
    Exit;
    
  try
    try
      JSONValue := TJSONObject.ParseJSONValue(AJSON);
      if JSONValue = nil then
        Exit;
        
      if not (JSONValue is TJSONArray) then
      begin
        JSONValue.Free;
        Exit;
      end;
      
      JSONArray := JSONValue as TJSONArray;
      try
        // Clear existing items
        Self.Clear;
        
        // Load items from JSON
        for I := 0 to JSONArray.Count - 1 do
        begin
          if JSONArray.Items[I] is TJSONObject then
          begin
            JSONObj := JSONArray.Items[I] as TJSONObject;
            
            // Get item text
            if JSONObj.TryGetValue<string>('text', ItemText) then
            begin
              ListItem := TListBoxItem.Create(Self);
              ListItem.Parent := Self;
              ListItem.Text := ItemText;
              
              // Try to restore data if present
              if JSONObj.TryGetValue<string>('data', ItemText) then
              begin
                if TryStrToInt64(ItemText, ItemData) then
                  ListItem.Data := Pointer(ItemData);
              end;
              
              // Restore selection state
              if JSONObj.TryGetValue<Boolean>('selected', IsSelected) then
                ListItem.IsSelected := IsSelected;
            end;
          end;
        end;
        
        Result := True;
      finally
        JSONArray.Free;
      end;
    except
      on E: Exception do
      begin
        // Silent exception handling
        Result := False;
      end;
    end;
  except
    Result := False;
  end;
end;

procedure TListBoxHelper.ClearItems;
begin
  try
    Self.Clear;
  except
    // Silent exception handling
  end;
end;

end.
