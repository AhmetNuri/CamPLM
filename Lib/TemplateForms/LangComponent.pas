unit LangComponent;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  FMX.Controls, FMX.StdCtrls, FMX.Forms, FMX.ListBox;

type
  /// <summary>
  /// Component for multi-language support
  /// Manages translations for all text-based controls in a form
  /// </summary>
  TLang = class(TComponent)
  private
    FCurrentLanguage: string;
    FTranslations: TDictionary<string, TDictionary<string, string>>;
    FForm: TForm;
    FLanguageFile: string;
    
    procedure SetCurrentLanguage(const Value: string);
    procedure LoadLanguageFile(const AFileName: string);
    procedure ApplyTranslations;
    procedure CollectTexts;
    
    /// <summary>
    /// Gets translation for a control in the current language
    /// </summary>
    function GetTranslation(const AControlName: string): string;
    
    /// <summary>
    /// Sets translation for a control in a specific language
    /// </summary>
    procedure SetTranslation(const AControlName, ALanguage, AText: string);
    
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    /// <summary>
    /// Initializes the language component for a form
    /// </summary>
    procedure Initialize(AForm: TForm);
    
    /// <summary>
    /// Adds a new language to the system
    /// </summary>
    procedure AddLanguage(const ALanguageCode: string);
    
    /// <summary>
    /// Removes a language from the system
    /// </summary>
    procedure RemoveLanguage(const ALanguageCode: string);
    
    /// <summary>
    /// Gets list of available languages
    /// </summary>
    function GetAvailableLanguages: TArray<string>;
    
    /// <summary>
    /// Exports all translations to JSON file
    /// </summary>
    function SaveToFile(const AFileName: string): Boolean;
    
    /// <summary>
    /// Imports translations from JSON file
    /// </summary>
    function LoadFromFile(const AFileName: string): Boolean;
    
    /// <summary>
    /// Exports translations to JSON string
    /// </summary>
    function SaveToJSON: string;
    
    /// <summary>
    /// Imports translations from JSON string
    /// </summary>
    function LoadFromJSON(const AJSON: string): Boolean;
    
    /// <summary>
    /// Sets translation for a specific control and language
    /// </summary>
    procedure SetControlTranslation(const AControlName, ALanguage, AText: string);
    
    /// <summary>
    /// Gets translation for a specific control and language
    /// </summary>
    function GetControlTranslation(const AControlName, ALanguage: string): string;
    
  published
    /// <summary>
    /// Current active language code (e.g., 'en', 'tr', 'de')
    /// </summary>
    property CurrentLanguage: string read FCurrentLanguage write SetCurrentLanguage;
    
    /// <summary>
    /// Language file path for automatic loading
    /// </summary>
    property LanguageFile: string read FLanguageFile write FLanguageFile;
  end;

procedure Register;

implementation

uses
  FMX.Types;

{ TLang }

constructor TLang.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTranslations := TDictionary<string, TDictionary<string, string>>.Create;
  FCurrentLanguage := 'en'; // Default language
  FForm := nil;
  FLanguageFile := '';
end;

destructor TLang.Destroy;
var
  LangDict: TDictionary<string, string>;
begin
  if FTranslations <> nil then
  begin
    for LangDict in FTranslations.Values do
      LangDict.Free;
    FTranslations.Free;
  end;
  inherited;
end;

procedure TLang.Initialize(AForm: TForm);
begin
  FForm := AForm;
  
  // Collect all text from controls
  CollectTexts;
  
  // Load language file if specified
  if FLanguageFile <> '' then
    LoadLanguageFile(FLanguageFile);
end;

procedure TLang.CollectTexts;
  
  procedure CollectFromContainer(AContainer: TFmxObject);
  var
    I: Integer;
    Child: TFmxObject;
    Control: TControl;
    ControlName: string;
    ControlText: string;
  begin
    if AContainer = nil then
      Exit;
      
    for I := 0 to AContainer.ChildrenCount - 1 do
    begin
      Child := AContainer.Children[I];
      
      if Child is TControl then
      begin
        Control := TControl(Child);
        ControlName := Control.Name;
        
        if ControlName <> '' then
        begin
          // Collect text from various control types
          if Control is TLabel then
            ControlText := TLabel(Control).Text
          else if Control is TButton then
            ControlText := TButton(Control).Text
          else if Control is TCheckBox then
            ControlText := TCheckBox(Control).Text
          else if Control is TRadioButton then
            ControlText := TRadioButton(Control).Text
          else if Control is TComboBox then
          begin
            // For ComboBox, we'll store items separately
            // This is handled in the ApplyTranslations method
            ControlText := '';
          end
          else
            ControlText := '';
            
          // Store the original text as default language translation
          if ControlText <> '' then
            SetTranslation(ControlName, FCurrentLanguage, ControlText);
        end;
      end;
      
      // Recursively search in child containers
      if Child.ChildrenCount > 0 then
        CollectFromContainer(Child);
    end;
  end;

begin
  if FForm <> nil then
    CollectFromContainer(FForm);
end;

procedure TLang.SetCurrentLanguage(const Value: string);
begin
  if FCurrentLanguage <> Value then
  begin
    FCurrentLanguage := Value;
    ApplyTranslations;
  end;
end;

procedure TLang.ApplyTranslations;

  procedure ApplyToContainer(AContainer: TFmxObject);
  var
    I: Integer;
    Child: TFmxObject;
    Control: TControl;
    ControlName: string;
    Translation: string;
  begin
    if AContainer = nil then
      Exit;
      
    for I := 0 to AContainer.ChildrenCount - 1 do
    begin
      Child := AContainer.Children[I];
      
      if Child is TControl then
      begin
        Control := TControl(Child);
        ControlName := Control.Name;
        
        if ControlName <> '' then
        begin
          Translation := GetTranslation(ControlName);
          
          if Translation <> '' then
          begin
            // Apply translation to various control types
            if Control is TLabel then
              TLabel(Control).Text := Translation
            else if Control is TButton then
              TButton(Control).Text := Translation
            else if Control is TCheckBox then
              TCheckBox(Control).Text := Translation
            else if Control is TRadioButton then
              TRadioButton(Control).Text := Translation;
          end;
        end;
      end;
      
      // Recursively apply to child containers
      if Child.ChildrenCount > 0 then
        ApplyToContainer(Child);
    end;
  end;

begin
  if FForm <> nil then
    ApplyToContainer(FForm);
end;

function TLang.GetTranslation(const AControlName: string): string;
var
  LangDict: TDictionary<string, string>;
begin
  Result := '';
  
  if FTranslations.TryGetValue(AControlName, LangDict) then
  begin
    if not LangDict.TryGetValue(FCurrentLanguage, Result) then
    begin
      // Fallback to default language if translation not found
      LangDict.TryGetValue('en', Result);
    end;
  end;
end;

procedure TLang.SetTranslation(const AControlName, ALanguage, AText: string);
var
  LangDict: TDictionary<string, string>;
begin
  if not FTranslations.TryGetValue(AControlName, LangDict) then
  begin
    LangDict := TDictionary<string, string>.Create;
    FTranslations.Add(AControlName, LangDict);
  end;
  
  if LangDict.ContainsKey(ALanguage) then
    LangDict[ALanguage] := AText
  else
    LangDict.Add(ALanguage, AText);
end;

procedure TLang.AddLanguage(const ALanguageCode: string);
begin
  // Language is automatically added when SetTranslation is called
  // This method is here for explicit language addition if needed
end;

procedure TLang.RemoveLanguage(const ALanguageCode: string);
var
  LangDict: TDictionary<string, string>;
begin
  for LangDict in FTranslations.Values do
  begin
    if LangDict.ContainsKey(ALanguageCode) then
      LangDict.Remove(ALanguageCode);
  end;
end;

function TLang.GetAvailableLanguages: TArray<string>;
var
  Languages: TList<string>;
  LangDict: TDictionary<string, string>;
  Lang: string;
begin
  Languages := TList<string>.Create;
  try
    for LangDict in FTranslations.Values do
    begin
      for Lang in LangDict.Keys do
      begin
        if Languages.IndexOf(Lang) = -1 then
          Languages.Add(Lang);
      end;
    end;
    Result := Languages.ToArray;
  finally
    Languages.Free;
  end;
end;

function TLang.SaveToJSON: string;
var
  JSONObj: TJSONObject;
  ControlObj: TJSONObject;
  ControlName: string;
  LangDict: TDictionary<string, string>;
  Language, Translation: string;
begin
  Result := '{}';
  JSONObj := TJSONObject.Create;
  try
    try
      for ControlName in FTranslations.Keys do
      begin
        if FTranslations.TryGetValue(ControlName, LangDict) then
        begin
          ControlObj := TJSONObject.Create;
          for Language in LangDict.Keys do
          begin
            if LangDict.TryGetValue(Language, Translation) then
              ControlObj.AddPair(Language, Translation);
          end;
          JSONObj.AddPair(ControlName, ControlObj);
        end;
      end;
      
      Result := JSONObj.ToString;
    except
      on E: Exception do
        Result := '{}';
    end;
  finally
    JSONObj.Free;
  end;
end;

function TLang.LoadFromJSON(const AJSON: string): Boolean;
var
  JSONObj: TJSONObject;
  JSONValue: TJSONValue;
  ControlName: string;
  ControlObj: TJSONObject;
  I, J: Integer;
  Language, Translation: string;
begin
  Result := False;
  
  if Trim(AJSON) = '' then
    Exit;
    
  try
    JSONValue := TJSONObject.ParseJSONValue(AJSON);
    if JSONValue = nil then
      Exit;
      
    if not (JSONValue is TJSONObject) then
    begin
      JSONValue.Free;
      Exit;
    end;
    
    JSONObj := JSONValue as TJSONObject;
    try
      // Clear existing translations
      for ControlObj in FTranslations.Values do
        ControlObj.Free;
      FTranslations.Clear;
      
      // Load translations from JSON
      for I := 0 to JSONObj.Count - 1 do
      begin
        ControlName := JSONObj.Pairs[I].JsonString.Value;
        
        if JSONObj.Pairs[I].JsonValue is TJSONObject then
        begin
          ControlObj := JSONObj.Pairs[I].JsonValue as TJSONObject;
          
          for J := 0 to ControlObj.Count - 1 do
          begin
            Language := ControlObj.Pairs[J].JsonString.Value;
            Translation := ControlObj.Pairs[J].JsonValue.Value;
            
            SetTranslation(ControlName, Language, Translation);
          end;
        end;
      end;
      
      Result := True;
    finally
      JSONObj.Free;
    end;
  except
    on E: Exception do
      Result := False;
  end;
end;

function TLang.SaveToFile(const AFileName: string): Boolean;
var
  JSONStr: string;
  FileStream: TStringStream;
begin
  Result := False;
  try
    JSONStr := SaveToJSON;
    FileStream := TStringStream.Create(JSONStr, TEncoding.UTF8);
    try
      FileStream.SaveToFile(AFileName);
      Result := True;
    finally
      FileStream.Free;
    end;
  except
    on E: Exception do
      Result := False;
  end;
end;

function TLang.LoadFromFile(const AFileName: string): Boolean;
var
  FileStream: TStringStream;
  JSONStr: string;
begin
  Result := False;
  
  if not FileExists(AFileName) then
    Exit;
    
  try
    FileStream := TStringStream.Create('', TEncoding.UTF8);
    try
      FileStream.LoadFromFile(AFileName);
      JSONStr := FileStream.DataString;
      Result := LoadFromJSON(JSONStr);
    finally
      FileStream.Free;
    end;
  except
    on E: Exception do
      Result := False;
  end;
end;

procedure TLang.LoadLanguageFile(const AFileName: string);
begin
  LoadFromFile(AFileName);
end;

procedure TLang.SetControlTranslation(const AControlName, ALanguage, AText: string);
begin
  SetTranslation(AControlName, ALanguage, AText);
end;

function TLang.GetControlTranslation(const AControlName, ALanguage: string): string;
var
  LangDict: TDictionary<string, string>;
begin
  Result := '';
  
  if FTranslations.TryGetValue(AControlName, LangDict) then
    LangDict.TryGetValue(ALanguage, Result);
end;

procedure Register;
begin
  RegisterComponents('TemplateForms', [TLang]);
end;

end.
