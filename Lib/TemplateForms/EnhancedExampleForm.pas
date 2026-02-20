unit EnhancedExampleForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Memo, FMX.DateTimeCtrls, FMX.NumberBox,
  FMX.ListBox, FMX.SpinBox, FMX.Grid, FireDAC.Comp.Client,
  TemplateForm, FMX.Memo.Types, System.Rtti, FMX.Grid.Style, FMX.Layouts,
  FMX.ScrollBox, FMX.EditBox, FMX.Objects, StringGridHelper;

type
  /// <summary>
  /// Enhanced example form demonstrating:
  /// - TListBox with JSON import/export
  /// - TStringGrid with JSON import/export
  /// - Multi-language support with TLang component
  /// </summary>
  TEnhancedExampleForm = class(TTemplateForm)
    Label1: TLabel;
    EditCustomerName: TEdit;
    Label2: TLabel;
    EditEmail: TEdit;
    Label3: TLabel;
    MemoNotes: TMemo;
    CheckBoxActive: TCheckBox;
    Label4: TLabel;
    DateEditRegistration: TDateEdit;
    ButtonSave: TButton;
    ButtonNew: TButton;
    ButtonDelete: TButton;
    ButtonLoad: TButton;
    Label5: TLabel;
    NumberBoxAge: TNumberBox;
    Label6: TLabel;
    SpinBoxRating: TSpinBox;
    ButtonShowJSON: TButton;
    Label7: TLabel;
    EditLoadID: TEdit;
    ListBoxTags: TListBox;
    Label8: TLabel;
    StringGridOrders: TStringGrid;
    Label9: TLabel;
    ButtonAddTag: TButton;
    ButtonClearTags: TButton;
    ComboBoxLanguage: TComboBox;
    Label10: TLabel;
    ButtonSetupGrid: TButton;
    ButtonExportLang: TButton;
    ButtonImportLang: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonNewClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonShowJSONClick(Sender: TObject);
    procedure ButtonAddTagClick(Sender: TObject);
    procedure ButtonClearTagsClick(Sender: TObject);
    procedure ComboBoxLanguageChange(Sender: TObject);
    procedure ButtonSetupGridClick(Sender: TObject);
    procedure ButtonExportLangClick(Sender: TObject);
    procedure ButtonImportLangClick(Sender: TObject);
  protected
    procedure BeforeLoadFromJSON; override;
    procedure AfterLoadFromJSON; override;
  private
    procedure SetupMultiLanguage;
    procedure InitializeGrid;
  public
    { Public declarations }
  end;

var
  FrmEnhancedExampleForm: TEnhancedExampleForm;

implementation

{$R *.fmx}

procedure TEnhancedExampleForm.FormCreate(Sender: TObject);
begin
  inherited;
  
  // Setup language combo box
  ComboBoxLanguage.Items.Clear;
  ComboBoxLanguage.Items.Add('English');
  ComboBoxLanguage.Items.Add('Türkçe');
  ComboBoxLanguage.Items.Add('Deutsch');
  ComboBoxLanguage.ItemIndex := 0;
  
  // Set default values
  DateEditRegistration.Date := Now;
  SpinBoxRating.Min := 0;
  SpinBoxRating.Max := 10;
  SpinBoxRating.Value := 5;
  NumberBoxAge.Min := 0;
  NumberBoxAge.Max := 150;
  
  // Setup multi-language support
  SetupMultiLanguage;
  
  // Initialize the StringGrid
  InitializeGrid;
  
  // Add some sample tags to ListBox
  ListBoxTags.Items.Add('VIP');
  ListBoxTags.Items.Add('Premium');
  ListBoxTags.Items.Add('Regular');
end;

procedure TEnhancedExampleForm.SetupMultiLanguage;
begin
  // Setup English translations
  Lang.SetControlTranslation('Label1', 'en', 'Customer Name:');
  Lang.SetControlTranslation('Label1', 'tr', 'Müşteri Adı:');
  Lang.SetControlTranslation('Label1', 'de', 'Kundenname:');
  
  Lang.SetControlTranslation('Label2', 'en', 'Email:');
  Lang.SetControlTranslation('Label2', 'tr', 'E-posta:');
  Lang.SetControlTranslation('Label2', 'de', 'E-Mail:');
  
  Lang.SetControlTranslation('Label3', 'en', 'Notes:');
  Lang.SetControlTranslation('Label3', 'tr', 'Notlar:');
  Lang.SetControlTranslation('Label3', 'de', 'Notizen:');
  
  Lang.SetControlTranslation('CheckBoxActive', 'en', 'Active');
  Lang.SetControlTranslation('CheckBoxActive', 'tr', 'Aktif');
  Lang.SetControlTranslation('CheckBoxActive', 'de', 'Aktiv');
  
  Lang.SetControlTranslation('Label4', 'en', 'Registration Date:');
  Lang.SetControlTranslation('Label4', 'tr', 'Kayıt Tarihi:');
  Lang.SetControlTranslation('Label4', 'de', 'Registrierungsdatum:');
  
  Lang.SetControlTranslation('ButtonSave', 'en', 'Save');
  Lang.SetControlTranslation('ButtonSave', 'tr', 'Kaydet');
  Lang.SetControlTranslation('ButtonSave', 'de', 'Speichern');
  
  Lang.SetControlTranslation('ButtonNew', 'en', 'New');
  Lang.SetControlTranslation('ButtonNew', 'tr', 'Yeni');
  Lang.SetControlTranslation('ButtonNew', 'de', 'Neu');
  
  Lang.SetControlTranslation('ButtonDelete', 'en', 'Delete');
  Lang.SetControlTranslation('ButtonDelete', 'tr', 'Sil');
  Lang.SetControlTranslation('ButtonDelete', 'de', 'Löschen');
  
  Lang.SetControlTranslation('ButtonLoad', 'en', 'Load');
  Lang.SetControlTranslation('ButtonLoad', 'tr', 'Yükle');
  Lang.SetControlTranslation('ButtonLoad', 'de', 'Laden');
  
  Lang.SetControlTranslation('Label5', 'en', 'Age:');
  Lang.SetControlTranslation('Label5', 'tr', 'Yaş:');
  Lang.SetControlTranslation('Label5', 'de', 'Alter:');
  
  Lang.SetControlTranslation('Label6', 'en', 'Rating:');
  Lang.SetControlTranslation('Label6', 'tr', 'Değerlendirme:');
  Lang.SetControlTranslation('Label6', 'de', 'Bewertung:');
  
  Lang.SetControlTranslation('ButtonShowJSON', 'en', 'Show JSON');
  Lang.SetControlTranslation('ButtonShowJSON', 'tr', 'JSON Göster');
  Lang.SetControlTranslation('ButtonShowJSON', 'de', 'JSON Anzeigen');
  
  Lang.SetControlTranslation('Label7', 'en', 'Load ID:');
  Lang.SetControlTranslation('Label7', 'tr', 'Yüklenecek ID:');
  Lang.SetControlTranslation('Label7', 'de', 'Lade-ID:');
  
  Lang.SetControlTranslation('Label8', 'en', 'Customer Tags:');
  Lang.SetControlTranslation('Label8', 'tr', 'Müşteri Etiketleri:');
  Lang.SetControlTranslation('Label8', 'de', 'Kunden-Tags:');
  
  Lang.SetControlTranslation('Label9', 'en', 'Order History:');
  Lang.SetControlTranslation('Label9', 'tr', 'Sipariş Geçmişi:');
  Lang.SetControlTranslation('Label9', 'de', 'Bestellverlauf:');
  
  Lang.SetControlTranslation('ButtonAddTag', 'en', 'Add Tag');
  Lang.SetControlTranslation('ButtonAddTag', 'tr', 'Etiket Ekle');
  Lang.SetControlTranslation('ButtonAddTag', 'de', 'Tag Hinzufügen');
  
  Lang.SetControlTranslation('ButtonClearTags', 'en', 'Clear Tags');
  Lang.SetControlTranslation('ButtonClearTags', 'tr', 'Etiketleri Temizle');
  Lang.SetControlTranslation('ButtonClearTags', 'de', 'Tags Löschen');
  
  Lang.SetControlTranslation('Label10', 'en', 'Language:');
  Lang.SetControlTranslation('Label10', 'tr', 'Dil:');
  Lang.SetControlTranslation('Label10', 'de', 'Sprache:');
  
  Lang.SetControlTranslation('ButtonSetupGrid', 'en', 'Setup Grid');
  Lang.SetControlTranslation('ButtonSetupGrid', 'tr', 'Tabloyu Ayarla');
  Lang.SetControlTranslation('ButtonSetupGrid', 'de', 'Raster Einrichten');
  
  Lang.SetControlTranslation('ButtonExportLang', 'en', 'Export Language');
  Lang.SetControlTranslation('ButtonExportLang', 'tr', 'Dili Dışa Aktar');
  Lang.SetControlTranslation('ButtonExportLang', 'de', 'Sprache Exportieren');
  
  Lang.SetControlTranslation('ButtonImportLang', 'en', 'Import Language');
  Lang.SetControlTranslation('ButtonImportLang', 'tr', 'Dili İçe Aktar');
  Lang.SetControlTranslation('ButtonImportLang', 'de', 'Sprache Importieren');
end;

procedure TEnhancedExampleForm.InitializeGrid;
begin
  // Setup StringGrid columns
  StringGridOrders.RowCount := 5;
  StringGridOrders.AddColumns ( 4);

  // Set column headers
  if StringGridOrders.ColumnCount > 0 then
  begin
    StringGridOrders.Columns[0].Header := 'Order ID';
    StringGridOrders.Columns[0].Width := 80;
    StringGridOrders.Columns[1].Header := 'Product';
    StringGridOrders.Columns[1].Width := 150;
    StringGridOrders.Columns[2].Header := 'Quantity';
    StringGridOrders.Columns[2].Width := 80;
    StringGridOrders.Columns[3].Header := 'Price';
    StringGridOrders.Columns[3].Width := 100;
  end;
  
  // Add sample data
  StringGridOrders.Cells[0, 0] := '1001';
  StringGridOrders.Cells[1, 0] := 'Widget A';
  StringGridOrders.Cells[2, 0] := '5';
  StringGridOrders.Cells[3, 0] := '$50.00';
  
  StringGridOrders.Cells[0, 1] := '1002';
  StringGridOrders.Cells[1, 1] := 'Widget B';
  StringGridOrders.Cells[2, 1] := '3';
  StringGridOrders.Cells[3, 1] := '$75.00';
end;

procedure TEnhancedExampleForm.ComboBoxLanguageChange(Sender: TObject);
begin
  case ComboBoxLanguage.ItemIndex of
    0: Lang.CurrentLanguage := 'en'; // English
    1: Lang.CurrentLanguage := 'tr'; // Türkçe
    2: Lang.CurrentLanguage := 'de'; // Deutsch
  end;
end;

procedure TEnhancedExampleForm.ButtonSaveClick(Sender: TObject);
begin
  if SaveRecord then
  begin
    ShowMessage('Record saved successfully!' + sLineBreak +
                'Record ID: ' + VarToStr(GetCurrentRecordID));
  end
  else
  begin
    ShowMessage('Error saving record!');
  end;
end;

procedure TEnhancedExampleForm.ButtonNewClick(Sender: TObject);
begin
  NewRecord;
  ShowMessage('New record mode - Form cleared');
end;

procedure TEnhancedExampleForm.ButtonDeleteClick(Sender: TObject);
begin
  if IsNewRecord then
  begin
    ShowMessage('Cannot delete an unsaved record!');
    Exit;
  end;
  
  if MessageDlg('Are you sure you want to delete this record?', 
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    if DeleteRecord then
      ShowMessage('Record deleted successfully!')
    else
      ShowMessage('Error deleting record!');
  end;
end;

procedure TEnhancedExampleForm.ButtonLoadClick(Sender: TObject);
var
  RecordID: Integer;
begin
  if TryStrToInt(EditLoadID.Text, RecordID) then
  begin
    if LoadRecord(RecordID) then
      ShowMessage('Record loaded successfully!')
    else
      ShowMessage('Record not found or error loading!');
  end
  else
  begin
    ShowMessage('Please enter a valid ID!');
  end;
end;

procedure TEnhancedExampleForm.ButtonShowJSONClick(Sender: TObject);
var
  JSONData: string;
begin
  JSONData := SaveToJSON;
  ShowMessage('Current Form Data (JSON):' + sLineBreak + sLineBreak + JSONData);
end;

procedure TEnhancedExampleForm.ButtonAddTagClick(Sender: TObject);
var
  TagName: string;
begin
  TagName := InputBox('Add Tag', 'Enter tag name:', '');
  if TagName <> '' then
  begin
    ListBoxTags.Items.Add(TagName);
  end;
end;

procedure TEnhancedExampleForm.ButtonClearTagsClick(Sender: TObject);
begin
  ListBoxTags.Clear;
end;

procedure TEnhancedExampleForm.ButtonSetupGridClick(Sender: TObject);
begin
  InitializeGrid;
  ShowMessage('Grid initialized with sample data');
end;

procedure TEnhancedExampleForm.ButtonExportLangClick(Sender: TObject);
var
  JSONData: string;
begin
  JSONData := Lang.SaveToJSON;
  ShowMessage('Language translations (JSON):' + sLineBreak + sLineBreak + JSONData);
  
  // Optionally save to file
  // Lang.SaveToFile('translations.json');
end;

procedure TEnhancedExampleForm.ButtonImportLangClick(Sender: TObject);
begin
  // Example: Load translations from file
  // if Lang.LoadFromFile('translations.json') then
  //   ShowMessage('Translations imported successfully!')
  // else
  //   ShowMessage('Error importing translations!');
  
  ShowMessage('To import: Use Lang.LoadFromFile(''filename.json'')');
end;

procedure TEnhancedExampleForm.BeforeLoadFromJSON;
begin
  inherited;
  // Custom logic before loading JSON
end;

procedure TEnhancedExampleForm.AfterLoadFromJSON;
begin
  inherited;
  // Custom logic after loading JSON
  // For example, refresh calculated fields or update UI
end;

end.
