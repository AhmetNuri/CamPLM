unit uFileSecurityUtils;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils;

type
  /// <summary>
  /// Helper class for secure file operations
  /// </summary>
  TFileSecurityUtils = class
  public
    /// <summary>
    /// Reads all text from a file safely, returns empty string on error
    /// </summary>
    class function ReadAllText(const AFileName: string): string;

    /// <summary>
    /// Writes text to a file safely, returns False on error
    /// </summary>
    class function WriteAllText(const AFileName, AContent: string): Boolean;

    /// <summary>
    /// Appends text to a file safely, returns False on error
    /// </summary>
    class function AppendText(const AFileName, AContent: string): Boolean;

    /// <summary>
    /// Checks whether a file exists and is accessible
    /// </summary>
    class function FileExists(const AFileName: string): Boolean;

    /// <summary>
    /// Deletes a file safely, returns False on error
    /// </summary>
    class function DeleteFile(const AFileName: string): Boolean;

    /// <summary>
    /// Creates all directories in the given path safely
    /// </summary>
    class function EnsureDirectory(const APath: string): Boolean;
  end;

implementation

class function TFileSecurityUtils.ReadAllText(const AFileName: string): string;
begin
  Result := '';
  try
    if TFile.Exists(AFileName) then
      Result := TFile.ReadAllText(AFileName, TEncoding.UTF8);
  except
    on E: Exception do
      Result := '';
  end;
end;

class function TFileSecurityUtils.WriteAllText(const AFileName, AContent: string): Boolean;
begin
  Result := False;
  try
    TFile.WriteAllText(AFileName, AContent, TEncoding.UTF8);
    Result := True;
  except
    on E: Exception do
      Result := False;
  end;
end;

class function TFileSecurityUtils.AppendText(const AFileName, AContent: string): Boolean;
begin
  Result := False;
  try
    TFile.AppendAllText(AFileName, AContent, TEncoding.UTF8);
    Result := True;
  except
    on E: Exception do
      Result := False;
  end;
end;

class function TFileSecurityUtils.FileExists(const AFileName: string): Boolean;
begin
  try
    Result := TFile.Exists(AFileName);
  except
    Result := False;
  end;
end;

class function TFileSecurityUtils.DeleteFile(const AFileName: string): Boolean;
begin
  Result := False;
  try
    if TFile.Exists(AFileName) then
    begin
      TFile.Delete(AFileName);
      Result := True;
    end;
  except
    on E: Exception do
      Result := False;
  end;
end;

class function TFileSecurityUtils.EnsureDirectory(const APath: string): Boolean;
begin
  Result := False;
  try
    if not TDirectory.Exists(APath) then
      TDirectory.CreateDirectory(APath);
    Result := True;
  except
    on E: Exception do
      Result := False;
  end;
end;

end.
