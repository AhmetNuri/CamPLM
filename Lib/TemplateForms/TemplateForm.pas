unit TemplateForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  FormDataModel, FormController;

type
  /// <summary>
  /// Base template form with automatic JSON serialization and ORM capabilities
  /// Following MVC pattern:
  /// - Model: TFormDataModel (data operations)
  /// - View: TTemplateForm (UI)
  /// - Controller: TFormController (UI data conversion)
  /// </summary>
  TTemplateForm = class(TForm)
  private
    FDataModel: TFormDataModel;
    FController: TFormController;
    FFDQuery1: TFDQuery;
    
    procedure SetConnection(AConnection: TFDConnection; const ATableName: string;
      const APrimaryKeyField: string = 'ID'; const AUIJSONField: string = 'UIJSON');
  protected
    /// <summary>
    /// Called after form is created - override to add custom initialization
    /// </summary>
    procedure AfterConstruction; override;
    
    /// <summary>
    /// Override to perform actions before loading data from JSON
    /// </summary>
    procedure BeforeLoadFromJSON; virtual;
    
    /// <summary>
    /// Override to perform actions after loading data from JSON
    /// </summary>
    procedure AfterLoadFromJSON; virtual;
    
    /// <summary>
    /// Override to perform actions before saving data to JSON
    /// </summary>
    procedure BeforeSaveToJSON; virtual;
    
    /// <summary>
    /// Override to perform actions after saving data to JSON
    /// </summary>
    procedure AfterSaveToJSON; virtual;
    
  public
    /// <summary>
    /// Creates the template form with database connection
    /// </summary>
    constructor Create(AOwner: TComponent; AConnection: TFDConnection; 
      const ATableName: string; const APrimaryKeyField: string = 'ID'; 
      const AUIJSONField: string = 'UIJSON'); reintroduce; virtual;
    
    destructor Destroy; override;
    
    /// <summary>
    /// Saves all form control values to JSON string
    /// </summary>
    function SaveToJSON: string; virtual;
    
    /// <summary>
    /// Loads form control values from JSON string
    /// </summary>
    function LoadFromJSON(const AJSON: string): Boolean; virtual;
    
    /// <summary>
    /// Creates a new record (clears form and sets to insert mode)
    /// </summary>
    procedure NewRecord; virtual;
    
    /// <summary>
    /// Loads an existing record by ID
    /// </summary>
    function LoadRecord(const ARecordID: Variant): Boolean; virtual;
    
    /// <summary>
    /// Saves current form data to database (Insert or Update)
    /// </summary>
    function SaveRecord: Boolean; virtual;
    
    /// <summary>
    /// Deletes current record from database
    /// </summary>
    function DeleteRecord: Boolean; virtual;
    
    /// <summary>
    /// Clears all form controls
    /// </summary>
    procedure ClearForm; virtual;
    
    /// <summary>
    /// Gets the current record ID
    /// </summary>
    function GetCurrentRecordID: Variant;
    
    /// <summary>
    /// Checks if current record is new (not yet saved)
    /// </summary>
    function IsNewRecord: Boolean;
    
    /// <summary>
    /// Access to the internal FDQuery component
    /// </summary>
    property FDQuery1: TFDQuery read FFDQuery1;
    
    /// <summary>
    /// Access to the data model
    /// </summary>
    property DataModel: TFormDataModel read FDataModel;
    
    /// <summary>
    /// Access to the controller
    /// </summary>
    property Controller: TFormController read FController;
  end;

var
  TemplateFormInstance: TTemplateForm;

implementation

{$R *.fmx}

{ TTemplateForm }

constructor TTemplateForm.Create(AOwner: TComponent; AConnection: TFDConnection; 
  const ATableName, APrimaryKeyField, AUIJSONField: string);
begin
  inherited Create(AOwner);
  
  // Create internal FDQuery component
  FFDQuery1 := TFDQuery.Create(Self);
  FFDQuery1.Connection := AConnection;
  FFDQuery1.Name := 'FDQuery1';
  
  // Initialize MVC components
  FDataModel := TFormDataModel.Create(AConnection, ATableName, APrimaryKeyField, AUIJSONField);
  FController := TFormController.Create(Self);
end;

destructor TTemplateForm.Destroy;
begin
  FController.Free;
  FDataModel.Free;
  // FFDQuery1 will be freed automatically as it's owned by Self
  inherited;
end;

procedure TTemplateForm.AfterConstruction;
begin
  inherited;
  // Override in descendant classes for custom initialization
end;

procedure TTemplateForm.SetConnection(AConnection: TFDConnection; 
  const ATableName, APrimaryKeyField, AUIJSONField: string);
begin
  if FDataModel <> nil then
  begin
    FDataModel.Free;
    FDataModel := TFormDataModel.Create(AConnection, ATableName, APrimaryKeyField, AUIJSONField);
  end;
  
  if FFDQuery1 <> nil then
    FFDQuery1.Connection := AConnection;
end;

procedure TTemplateForm.BeforeLoadFromJSON;
begin
  // Override in descendant classes
end;

procedure TTemplateForm.AfterLoadFromJSON;
begin
  // Override in descendant classes
end;

procedure TTemplateForm.BeforeSaveToJSON;
begin
  // Override in descendant classes
end;

procedure TTemplateForm.AfterSaveToJSON;
begin
  // Override in descendant classes
end;

function TTemplateForm.SaveToJSON: string;
begin
  Result := '{}';
  
  try
    BeforeSaveToJSON;
    Result := FController.SaveToJSON;
    AfterSaveToJSON;
  except
    on E: Exception do
    begin
      // Silent exception handling
      Result := '{}';
    end;
  end;
end;

function TTemplateForm.LoadFromJSON(const AJSON: string): Boolean;
begin
  Result := False;
  
  try
    BeforeLoadFromJSON;
    Result := FController.LoadFromJSON(AJSON);
    AfterLoadFromJSON;
  except
    on E: Exception do
    begin
      // Silent exception handling
      Result := False;
    end;
  end;
end;

procedure TTemplateForm.NewRecord;
begin
  try
    FDataModel.NewRecord;
    ClearForm;
  except
    on E: Exception do
    begin
      // Silent exception handling
    end;
  end;
end;

function TTemplateForm.LoadRecord(const ARecordID: Variant): Boolean;
var
  UJSON: string;
begin
  Result := False;
  
  try
    if FDataModel.LoadRecord(ARecordID) then
    begin
      UJSON := FDataModel.GetUIJSON;
      Result := LoadFromJSON(UJSON);
    end;
  except
    on E: Exception do
    begin
      // Silent exception handling
      Result := False;
    end;
  end;
end;

function TTemplateForm.SaveRecord: Boolean;
var
  JSONData: string;
  NewID: Variant;
begin
  Result := False;
  
  try
    JSONData := SaveToJSON;
    
    if FDataModel.IsNewRecord then
    begin
      // Insert new record
      NewID := FDataModel.InsertRecord(JSONData);
      Result := not VarIsNull(NewID);
    end
    else
    begin
      // Update existing record
      Result := FDataModel.UpdateRecord(JSONData);
    end;
  except
    on E: Exception do
    begin
      // Silent exception handling
      Result := False;
    end;
  end;
end;

function TTemplateForm.DeleteRecord: Boolean;
begin
  Result := False;
  
  try
    if not FDataModel.IsNewRecord then
    begin
      Result := FDataModel.DeleteRecord;
      if Result then
        ClearForm;
    end;
  except
    on E: Exception do
    begin
      // Silent exception handling
      Result := False;
    end;
  end;
end;

procedure TTemplateForm.ClearForm;
begin
  try
    FController.ClearControls;
  except
    on E: Exception do
    begin
      // Silent exception handling
    end;
  end;
end;

function TTemplateForm.GetCurrentRecordID: Variant;
begin
  Result := FDataModel.CurrentRecordID;
end;

function TTemplateForm.IsNewRecord: Boolean;
begin
  Result := FDataModel.IsNewRecord;
end;

end.
