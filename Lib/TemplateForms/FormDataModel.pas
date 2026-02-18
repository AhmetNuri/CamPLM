unit FormDataModel;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Stan.Intf;

type
  /// <summary>
  /// Model class for handling data operations and JSON serialization
  /// Following SOLID principles - Single Responsibility: Data management only
  /// </summary>
  TFormDataModel = class
  private
    FConnection: TFDConnection;
    FTableName: string;
    FPrimaryKeyField: string;
    FUIJSONField: string;
    FQuery: TFDQuery;
    FCurrentRecordID: Variant;
    
    function GetIsNewRecord: Boolean;
  public
    constructor Create(AConnection: TFDConnection; const ATableName: string; 
      const APrimaryKeyField: string = 'ID'; const AUIJSONField: string = 'UIJSON');
    destructor Destroy; override;
    
    /// <summary>
    /// Executes a query and returns the result
    /// </summary>
    function ExecuteQuery(const ASQL: string; const AParams: TArray<Variant> = []): Boolean;
    
    /// <summary>
    /// Loads a record by ID
    /// </summary>
    function LoadRecord(const ARecordID: Variant): Boolean;
    
    /// <summary>
    /// Inserts a new record with JSON data
    /// </summary>
    function InsertRecord(const AJSON: string): Variant;
    
    /// <summary>
    /// Updates current record with JSON data
    /// </summary>
    function UpdateRecord(const AJSON: string): Boolean;
    
    /// <summary>
    /// Deletes current record
    /// </summary>
    function DeleteRecord: Boolean;
    
    /// <summary>
    /// Gets the UIJSON field value from current record
    /// </summary>
    function GetUIJSON: string;
    
    /// <summary>
    /// Sets a new record state
    /// </summary>
    procedure NewRecord;
    
    property Connection: TFDConnection read FConnection;
    property TableName: string read FTableName;
    property PrimaryKeyField: string read FPrimaryKeyField;
    property UIJSONField: string read FUIJSONField;
    property CurrentRecordID: Variant read FCurrentRecordID;
    property IsNewRecord: Boolean read GetIsNewRecord;
    property Query: TFDQuery read FQuery;
  end;

implementation

uses
  System.Variants;

{ TFormDataModel }

constructor TFormDataModel.Create(AConnection: TFDConnection; 
  const ATableName, APrimaryKeyField, AUIJSONField: string);
begin
  inherited Create;
  FConnection := AConnection;
  FTableName := ATableName;
  FPrimaryKeyField := APrimaryKeyField;
  FUIJSONField := AUIJSONField;
  FCurrentRecordID := Null;
  
  // Create internal query component
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection;
end;

destructor TFormDataModel.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TFormDataModel.GetIsNewRecord: Boolean;
begin
  Result := VarIsNull(FCurrentRecordID) or VarIsEmpty(FCurrentRecordID);
end;

function TFormDataModel.ExecuteQuery(const ASQL: string; 
  const AParams: TArray<Variant>): Boolean;
var
  I: Integer;
begin
  Result := False;
  try
    FQuery.Close;
    FQuery.SQL.Text := ASQL;
    
    // Set parameters if any
    for I := 0 to Length(AParams) - 1 do
    begin
      FQuery.Params[I].Value := AParams[I];
    end;
    
    FQuery.Open;
    Result := True;
  except
    on E: Exception do
    begin
      // Silent exception handling - log if needed
      // Could implement logging here
      Result := False;
    end;
  end;
end;

function TFormDataModel.LoadRecord(const ARecordID: Variant): Boolean;
var
  SQL: string;
begin
  Result := False;
  try
    SQL := Format('SELECT * FROM %s WHERE %s = :ID', 
      [FTableName, FPrimaryKeyField]);
    
    FQuery.Close;
    FQuery.SQL.Text := SQL;
    FQuery.ParamByName('ID').Value := ARecordID;
    FQuery.Open;
    
    if not FQuery.IsEmpty then
    begin
      FCurrentRecordID := ARecordID;
      Result := True;
    end;
  except
    on E: Exception do
    begin
      // Silent exception handling
      FCurrentRecordID := Null;
      Result := False;
    end;
  end;
end;

function TFormDataModel.InsertRecord(const AJSON: string): Variant;
var
  SQL: string;
begin
  Result := Null;
  try
    SQL := Format('INSERT INTO %s (%s) VALUES (:UIJSON)', 
      [FTableName, FUIJSONField]);
    
    FQuery.Close;
    FQuery.SQL.Text := SQL;
    FQuery.ParamByName('UIJSON').AsString := AJSON;
    FQuery.ExecSQL;
    
    // Get the last inserted ID
    SQL := Format('SELECT MAX(%s) AS LastID FROM %s', 
      [FPrimaryKeyField, FTableName]);
    FQuery.Close;
    FQuery.SQL.Text := SQL;
    FQuery.Open;
    
    if not FQuery.IsEmpty then
    begin
      Result := FQuery.FieldByName('LastID').Value;
      FCurrentRecordID := Result;
    end;
  except
    on E: Exception do
    begin
      // Silent exception handling
      Result := Null;
    end;
  end;
end;

function TFormDataModel.UpdateRecord(const AJSON: string): Boolean;
var
  SQL: string;
begin
  Result := False;
  
  if IsNewRecord then
    Exit;
    
  try
    SQL := Format('UPDATE %s SET %s = :UIJSON WHERE %s = :ID', 
      [FTableName, FUIJSONField, FPrimaryKeyField]);
    
    FQuery.Close;
    FQuery.SQL.Text := SQL;
    FQuery.ParamByName('UIJSON').AsString := AJSON;
    FQuery.ParamByName('ID').Value := FCurrentRecordID;
    FQuery.ExecSQL;
    
    Result := True;
  except
    on E: Exception do
    begin
      // Silent exception handling
      Result := False;
    end;
  end;
end;

function TFormDataModel.DeleteRecord: Boolean;
var
  SQL: string;
begin
  Result := False;
  
  if IsNewRecord then
    Exit;
    
  try
    SQL := Format('DELETE FROM %s WHERE %s = :ID', 
      [FTableName, FPrimaryKeyField]);
    
    FQuery.Close;
    FQuery.SQL.Text := SQL;
    FQuery.ParamByName('ID').Value := FCurrentRecordID;
    FQuery.ExecSQL;
    
    FCurrentRecordID := Null;
    Result := True;
  except
    on E: Exception do
    begin
      // Silent exception handling
      Result := False;
    end;
  end;
end;

function TFormDataModel.GetUIJSON: string;
begin
  Result := '';
  try
    if not FQuery.IsEmpty and (FQuery.FindField(FUIJSONField) <> nil) then
    begin
      Result := FQuery.FieldByName(FUIJSONField).AsString;
    end;
  except
    on E: Exception do
    begin
      // Silent exception handling
      Result := '';
    end;
  end;
end;

procedure TFormDataModel.NewRecord;
begin
  FCurrentRecordID := Null;
  FQuery.Close;
end;

end.
