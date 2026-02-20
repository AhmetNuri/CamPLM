unit uFDQueryHelper;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DApt,
  uCentralLogger, uExceptionHandler;

type
  /// <summary>
  /// Helper class for FireDAC TFDQuery operations
  /// </summary>
  TFDQueryHelper = class
  public
    /// <summary>
    /// Opens a query with the given SQL, returns False on failure
    /// </summary>
    class function TryOpen(AQuery: TFDQuery; const ASQL: string): Boolean;

    /// <summary>
    /// Executes a non-SELECT SQL statement, returns affected rows or -1 on error
    /// </summary>
    class function TryExecSQL(AQuery: TFDQuery; const ASQL: string): Integer;

    /// <summary>
    /// Safely closes a query
    /// </summary>
    class procedure SafeClose(AQuery: TFDQuery);

    /// <summary>
    /// Sets a named parameter value on a query
    /// </summary>
    class procedure SetParam(AQuery: TFDQuery; const AParamName: string;
      const AValue: Variant);

    /// <summary>
    /// Returns a field value as string, returns ADefault on error
    /// </summary>
    class function FieldAsString(AQuery: TFDQuery; const AFieldName: string;
      const ADefault: string = ''): string;

    /// <summary>
    /// Returns a field value as Integer, returns ADefault on error
    /// </summary>
    class function FieldAsInteger(AQuery: TFDQuery; const AFieldName: string;
      ADefault: Integer = 0): Integer;

    /// <summary>
    /// Returns a field value as Double, returns ADefault on error
    /// </summary>
    class function FieldAsFloat(AQuery: TFDQuery; const AFieldName: string;
      ADefault: Double = 0.0): Double;

    /// <summary>
    /// Returns True if the query is open and not empty
    /// </summary>
    class function HasRows(AQuery: TFDQuery): Boolean;
  end;

implementation

{ TFDQueryHelper }

class function TFDQueryHelper.TryOpen(AQuery: TFDQuery;
  const ASQL: string): Boolean;
begin
  Result := False;
  try
    AQuery.Close;
    if ASQL <> '' then
      AQuery.SQL.Text := ASQL;
    AQuery.Open;
    Result := True;
  except
    on E: Exception do
    begin
      TExceptionHandler.HandleSilent(E, 'TFDQueryHelper.TryOpen');
      Result := False;
    end;
  end;
end;

class function TFDQueryHelper.TryExecSQL(AQuery: TFDQuery;
  const ASQL: string): Integer;
begin
  Result := -1;
  try
    AQuery.Close;
    if ASQL <> '' then
      AQuery.SQL.Text := ASQL;
    AQuery.ExecSQL;
    Result := AQuery.RowsAffected;
  except
    on E: Exception do
    begin
      TExceptionHandler.HandleSilent(E, 'TFDQueryHelper.TryExecSQL');
      Result := -1;
    end;
  end;
end;

class procedure TFDQueryHelper.SafeClose(AQuery: TFDQuery);
begin
  try
    if AQuery.Active then
      AQuery.Close;
  except
    on E: Exception do
      TExceptionHandler.HandleSilent(E, 'TFDQueryHelper.SafeClose');
  end;
end;

class procedure TFDQueryHelper.SetParam(AQuery: TFDQuery;
  const AParamName: string; const AValue: Variant);
begin
  try
    AQuery.ParamByName(AParamName).Value := AValue;
  except
    on E: Exception do
      TExceptionHandler.HandleSilent(E, 'TFDQueryHelper.SetParam:' + AParamName);
  end;
end;

class function TFDQueryHelper.FieldAsString(AQuery: TFDQuery;
  const AFieldName, ADefault: string): string;
begin
  try
    if AQuery.Active and (AQuery.FindField(AFieldName) <> nil) then
      Result := AQuery.FieldByName(AFieldName).AsString
    else
      Result := ADefault;
  except
    Result := ADefault;
  end;
end;

class function TFDQueryHelper.FieldAsInteger(AQuery: TFDQuery;
  const AFieldName: string; ADefault: Integer): Integer;
begin
  try
    if AQuery.Active and (AQuery.FindField(AFieldName) <> nil) then
      Result := AQuery.FieldByName(AFieldName).AsInteger
    else
      Result := ADefault;
  except
    Result := ADefault;
  end;
end;

class function TFDQueryHelper.FieldAsFloat(AQuery: TFDQuery;
  const AFieldName: string; ADefault: Double): Double;
begin
  try
    if AQuery.Active and (AQuery.FindField(AFieldName) <> nil) then
      Result := AQuery.FieldByName(AFieldName).AsFloat
    else
      Result := ADefault;
  except
    Result := ADefault;
  end;
end;

class function TFDQueryHelper.HasRows(AQuery: TFDQuery): Boolean;
begin
  try
    Result := AQuery.Active and not AQuery.IsEmpty;
  except
    Result := False;
  end;
end;

end.
