unit uExceptionHandler;

interface

uses
  System.SysUtils, System.Classes,
  uCentralLogger;

type
  /// <summary>
  /// Centralized exception handling helper
  /// </summary>
  TExceptionHandler = class
  public
    /// <summary>
    /// Handles an exception: logs it and optionally re-raises
    /// </summary>
    class procedure Handle(E: Exception; const AContext: string = '';
      ARaise: Boolean = False);

    /// <summary>
    /// Handles an exception and returns a default value without re-raising
    /// </summary>
    class procedure HandleSilent(E: Exception; const AContext: string = '');

    /// <summary>
    /// Builds a formatted error message from an exception
    /// </summary>
    class function FormatMessage(E: Exception; const AContext: string = ''): string;

    /// <summary>
    /// Executes a procedure and handles any exception that occurs
    /// Returns True on success, False if an exception was caught
    /// </summary>
    class function TryExecute(AProc: TProc; const AContext: string = ''): Boolean;
  end;

implementation

{ TExceptionHandler }

class function TExceptionHandler.FormatMessage(E: Exception;
  const AContext: string): string;
begin
  if AContext <> '' then
    Result := Format('[%s] %s: %s', [AContext, E.ClassName, E.Message])
  else
    Result := Format('%s: %s', [E.ClassName, E.Message]);
end;

class procedure TExceptionHandler.Handle(E: Exception; const AContext: string;
  ARaise: Boolean);
var
  Msg: string;
begin
  Msg := FormatMessage(E, AContext);
  Logger.Error(Msg);
  if ARaise then
    raise Exception.Create(Msg);
end;

class procedure TExceptionHandler.HandleSilent(E: Exception;
  const AContext: string);
begin
  Logger.Warning(FormatMessage(E, AContext));
end;

class function TExceptionHandler.TryExecute(AProc: TProc;
  const AContext: string): Boolean;
begin
  Result := False;
  try
    AProc;
    Result := True;
  except
    on E: Exception do
      HandleSilent(E, AContext);
  end;
end;

end.
