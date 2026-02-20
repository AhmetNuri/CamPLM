unit ufdConnectionHelper;

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.DApt,
  uCentralLogger, uExceptionHandler;

type
  /// <summary>
  /// Helper class for FireDAC connection management
  /// </summary>
  TFDConnectionHelper = class
  public
    /// <summary>
    /// Configures a TFDConnection for SQLite
    /// </summary>
    class procedure SetupSQLite(AConnection: TFDConnection;
      const ADatabase: string; AOpen: Boolean = True);

    /// <summary>
    /// Configures a TFDConnection for MS SQL Server
    /// </summary>
    class procedure SetupMSSQL(AConnection: TFDConnection;
      const AServer, ADatabase, AUsername, APassword: string;
      AOpen: Boolean = True);

    /// <summary>
    /// Safely opens a connection, returns False on failure
    /// </summary>
    class function TryOpen(AConnection: TFDConnection): Boolean;

    /// <summary>
    /// Safely closes a connection
    /// </summary>
    class procedure SafeClose(AConnection: TFDConnection);

    /// <summary>
    /// Returns True if the connection is active
    /// </summary>
    class function IsConnected(AConnection: TFDConnection): Boolean;

    /// <summary>
    /// Executes a SQL statement on the connection and returns affected rows
    /// Returns -1 on error
    /// </summary>
    class function ExecSQL(AConnection: TFDConnection;
      const ASQL: string): Integer;
  end;

implementation

{ TFDConnectionHelper }

class procedure TFDConnectionHelper.SetupSQLite(AConnection: TFDConnection;
  const ADatabase: string; AOpen: Boolean);
begin
  try
    AConnection.Connected := False;
    AConnection.DriverName := 'SQLite';
    AConnection.Params.Clear;
    AConnection.Params.Add('DriverID=SQLite');
    AConnection.Params.Add('Database=' + ADatabase);
    if AOpen then
      TryOpen(AConnection);
  except
    on E: Exception do
      TExceptionHandler.HandleSilent(E, 'TFDConnectionHelper.SetupSQLite');
  end;
end;

class procedure TFDConnectionHelper.SetupMSSQL(AConnection: TFDConnection;
  const AServer, ADatabase, AUsername, APassword: string; AOpen: Boolean);
begin
  try
    AConnection.Connected := False;
    AConnection.DriverName := 'MSSQL';
    AConnection.Params.Clear;
    AConnection.Params.Add('DriverID=MSSQL');
    AConnection.Params.Add('Server=' + AServer);
    AConnection.Params.Add('Database=' + ADatabase);
    if AUsername <> '' then
    begin
      AConnection.Params.Add('User_Name=' + AUsername);
      AConnection.Params.Add('Password=' + APassword);
    end
    else
    begin
      AConnection.Params.Add('OSAuthent=Yes');
    end;
    if AOpen then
      TryOpen(AConnection);
  except
    on E: Exception do
      TExceptionHandler.HandleSilent(E, 'TFDConnectionHelper.SetupMSSQL');
  end;
end;

class function TFDConnectionHelper.TryOpen(AConnection: TFDConnection): Boolean;
begin
  Result := False;
  try
    if not AConnection.Connected then
      AConnection.Open;
    Result := AConnection.Connected;
  except
    on E: Exception do
    begin
      TExceptionHandler.HandleSilent(E, 'TFDConnectionHelper.TryOpen');
      Result := False;
    end;
  end;
end;

class procedure TFDConnectionHelper.SafeClose(AConnection: TFDConnection);
begin
  try
    if AConnection.Connected then
      AConnection.Close;
  except
    on E: Exception do
      TExceptionHandler.HandleSilent(E, 'TFDConnectionHelper.SafeClose');
  end;
end;

class function TFDConnectionHelper.IsConnected(AConnection: TFDConnection): Boolean;
begin
  try
    Result := Assigned(AConnection) and AConnection.Connected;
  except
    Result := False;
  end;
end;

class function TFDConnectionHelper.ExecSQL(AConnection: TFDConnection;
  const ASQL: string): Integer;
begin
  Result := -1;
  try
    Result := AConnection.ExecSQL(ASQL);
  except
    on E: Exception do
    begin
      TExceptionHandler.HandleSilent(E, 'TFDConnectionHelper.ExecSQL');
      Result := -1;
    end;
  end;
end;

end.
