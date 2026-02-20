unit uCentralLogger;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs,
  uFileSecurityUtils;

type
  TLogLevel = (llDebug, llInfo, llWarning, llError, llCritical);

  /// <summary>
  /// Centralized logger with thread-safe file and in-memory logging
  /// </summary>
  TCentralLogger = class
  private
    class var FInstance: TCentralLogger;
    class var FInstanceLock: TCriticalSection;
    FLogFileName: string;
    FLock: TCriticalSection;
    FLogLevel: TLogLevel;

    function LevelToString(ALevel: TLogLevel): string;
  public
    constructor Create;
    destructor Destroy; override;

    class function GetInstance: TCentralLogger;
    class procedure FreeInstance;
    class procedure InitInstanceLock;

    /// <summary>
    /// Sets the log file path
    /// </summary>
    procedure SetLogFile(const AFileName: string);

    /// <summary>
    /// Sets the minimum log level to record
    /// </summary>
    procedure SetLogLevel(ALevel: TLogLevel);

    /// <summary>
    /// Writes a message at the given log level
    /// </summary>
    procedure Log(ALevel: TLogLevel; const AMessage: string); overload;

    /// <summary>
    /// Convenience methods for each log level
    /// </summary>
    procedure Debug(const AMessage: string);
    procedure Info(const AMessage: string);
    procedure Warning(const AMessage: string);
    procedure Error(const AMessage: string);
    procedure Critical(const AMessage: string);

    property LogFileName: string read FLogFileName;
    property LogLevel: TLogLevel read FLogLevel write FLogLevel;
  end;

/// <summary>
/// Global accessor for the central logger singleton
/// </summary>
function Logger: TCentralLogger;

implementation

function Logger: TCentralLogger;
begin
  Result := TCentralLogger.GetInstance;
end;

{ TCentralLogger }

constructor TCentralLogger.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FLogLevel := llInfo;
  FLogFileName := '';
end;

destructor TCentralLogger.Destroy;
begin
  FLock.Free;
  inherited;
end;

class procedure TCentralLogger.InitInstanceLock;
begin
  if FInstanceLock = nil then
    FInstanceLock := TCriticalSection.Create;
end;

class function TCentralLogger.GetInstance: TCentralLogger;
begin
  if FInstance = nil then
  begin
    FInstanceLock.Enter;
    try
      if FInstance = nil then
        FInstance := TCentralLogger.Create;
    finally
      FInstanceLock.Leave;
    end;
  end;
  Result := FInstance;
end;

class procedure TCentralLogger.FreeInstance;
begin
  FInstanceLock.Enter;
  try
    FreeAndNil(FInstance);
  finally
    FInstanceLock.Leave;
  end;
end;

procedure TCentralLogger.SetLogFile(const AFileName: string);
begin
  FLock.Enter;
  try
    FLogFileName := AFileName;
    if AFileName <> '' then
      TFileSecurityUtils.EnsureDirectory(ExtractFileDir(AFileName));
  finally
    FLock.Leave;
  end;
end;

procedure TCentralLogger.SetLogLevel(ALevel: TLogLevel);
begin
  FLogLevel := ALevel;
end;

function TCentralLogger.LevelToString(ALevel: TLogLevel): string;
begin
  case ALevel of
    llDebug:    Result := 'DEBUG';
    llInfo:     Result := 'INFO';
    llWarning:  Result := 'WARNING';
    llError:    Result := 'ERROR';
    llCritical: Result := 'CRITICAL';
  else
    Result := 'UNKNOWN';
  end;
end;

procedure TCentralLogger.Log(ALevel: TLogLevel; const AMessage: string);
var
  LogEntry: string;
begin
  if ALevel < FLogLevel then
    Exit;

  LogEntry := Format('[%s] [%s] %s' + sLineBreak,
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now),
     LevelToString(ALevel),
     AMessage]);

  FLock.Enter;
  try
    if FLogFileName <> '' then
      TFileSecurityUtils.AppendText(FLogFileName, LogEntry);
  finally
    FLock.Leave;
  end;
end;

procedure TCentralLogger.Debug(const AMessage: string);
begin
  Log(llDebug, AMessage);
end;

procedure TCentralLogger.Info(const AMessage: string);
begin
  Log(llInfo, AMessage);
end;

procedure TCentralLogger.Warning(const AMessage: string);
begin
  Log(llWarning, AMessage);
end;

procedure TCentralLogger.Error(const AMessage: string);
begin
  Log(llError, AMessage);
end;

procedure TCentralLogger.Critical(const AMessage: string);
begin
  Log(llCritical, AMessage);
end;

initialization
  TCentralLogger.InitInstanceLock;

finalization
  TCentralLogger.FreeInstance;
  FreeAndNil(TCentralLogger.FInstanceLock);

end.
