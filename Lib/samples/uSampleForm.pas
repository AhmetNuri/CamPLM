unit uSampleForm;

{
  ============================================================================
  CamPLM - FireMonkey Template Forms Library
  Sample Application - Product Management Form
  ============================================================================
  Bu örnek uygulama, TemplateForm kütüphanesinin tüm özelliklerini göstermek
  amacıyla oluşturulmuştur.

  Gösterilen özellikler:
  - TEdit, TNumberBox, TMemo, TComboBox, TCheckBox, TRadioButton
  - TDateEdit, TTimeEdit, TSpinBox
  - TListBox (JSON import/export via ListBoxHelper)
  - TStringGrid (JSON import/export via StringGridHelper)
  - TLang (çok dilli destek - .txt dosyalarından yükleme)
  - CRUD işlemleri: NewRecord, LoadRecord, SaveRecord, DeleteRecord
  - SQLite veritabanı entegrasyonu
  ============================================================================
}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Memo, FMX.DateTimeCtrls,
  FMX.NumberBox, FMX.ListBox, FMX.SpinBox, FMX.Grid, FMX.Grid.Style,
  FMX.Objects, FMX.Layouts, FMX.ScrollBox, FMX.Memo.Types, FMX.EditBox,
  System.Rtti,
  FireDAC.Comp.Client, FireDAC.Drivers.SQLite,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.VCLUI.Wait, FireDAC.DApt,
  TemplateForm, StringGridHelper, ListBoxHelper;

type
  /// <summary>
  /// Ürün Yönetimi örnek formu.
  /// TTemplateForm'dan türetilmiş, tüm kütüphane özelliklerini gösteren
  /// tam bir CRUD formu.
  /// </summary>
  TSampleForm = class(TTemplateForm)
    // --- Temel Bilgiler ---
    LabelProductName: TLabel;
    EditProductName: TEdit;
    LabelProductCode: TLabel;
    EditProductCode: TEdit;
    LabelCategory: TLabel;
    ComboBoxCategory: TComboBox;

    // --- Sayısal Alanlar ---
    LabelPrice: TLabel;
    NumberBoxPrice: TNumberBox;
    LabelStock: TLabel;
    NumberBoxStock: TNumberBox;
    LabelPriority: TLabel;
    SpinBoxPriority: TSpinBox;

    // --- Tarih / Saat ---
    LabelManufactureDate: TLabel;
    DateEditManufacture: TDateEdit;
    LabelRestockTime: TLabel;
    TimeEditRestockAlert: TTimeEdit;

    // --- Açıklama (Memo) ---
    LabelDescription: TLabel;
    MemoDescription: TMemo;

    // --- CheckBox ---
    CheckBoxActive: TCheckBox;
    CheckBoxFeatured: TCheckBox;

    // --- RadioButton (Durum) ---
    LabelCondition: TLabel;
    RadioButtonNew: TRadioButton;
    RadioButtonUsed: TRadioButton;

    // --- TListBox (Ürün Özellikleri) ---
    LabelFeatures: TLabel;
    ListBoxFeatures: TListBox;
    ButtonAddFeature: TButton;
    ButtonClearFeatures: TButton;

    // --- TStringGrid (Sipariş Geçmişi) ---
    LabelOrderHistory: TLabel;
    StringGridOrderHistory: TStringGrid;
    ButtonAddOrder: TButton;

    // --- Çok Dilli Destek ---
    LabelLanguage: TLabel;
    ComboBoxLanguage: TComboBox;

    // --- CRUD Butonları ---
    ButtonNew: TButton;
    ButtonSave: TButton;
    ButtonDelete: TButton;
    ButtonShowJSON: TButton;
    LabelLoadRecord: TLabel;
    EditLoadID: TEdit;
    ButtonLoad: TButton;

    // --- Event Handlers ---
    procedure FormCreate(Sender: TObject);
    procedure ButtonNewClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonShowJSONClick(Sender: TObject);
    procedure ButtonAddFeatureClick(Sender: TObject);
    procedure ButtonClearFeaturesClick(Sender: TObject);
    procedure ButtonAddOrderClick(Sender: TObject);
    procedure ComboBoxLanguageChange(Sender: TObject);

  protected
    procedure BeforeLoadFromJSON; override;
    procedure AfterLoadFromJSON; override;
    procedure BeforeSaveToJSON; override;
    procedure AfterSaveToJSON; override;

  private
    procedure SetupForm;
    procedure SetupMultiLanguage;
    procedure InitializeOrderGrid;
    procedure LoadLanguageFromFile(const ALang: string);
    function GetMsg(const AKey: string): string;

  public
    { Public declarations }
  end;

var
  SampleForm: TSampleForm;

implementation

{$R *.fmx}

{ TSampleForm }

procedure TSampleForm.FormCreate(Sender: TObject);
begin
  inherited;
  SetupForm;
  SetupMultiLanguage;
  InitializeOrderGrid;
end;

procedure TSampleForm.SetupForm;
begin
  // --- Kategori seçenekleri ---
  ComboBoxCategory.Items.Clear;
  ComboBoxCategory.Items.Add('Electronics');
  ComboBoxCategory.Items.Add('Accessories');
  ComboBoxCategory.Items.Add('Software');
  ComboBoxCategory.Items.Add('Books');
  ComboBoxCategory.Items.Add('Other');

  // --- Dil seçenekleri ---
  ComboBoxLanguage.Items.Clear;
  ComboBoxLanguage.Items.Add('English');
  ComboBoxLanguage.Items.Add('Türkçe');
  ComboBoxLanguage.Items.Add('Deutsch');
  ComboBoxLanguage.ItemIndex := 0;

  // --- Varsayılan değerler ---
  DateEditManufacture.Date := Now;
  TimeEditRestockAlert.Time := Now;

  NumberBoxPrice.Min := 0;
  NumberBoxPrice.Max := 999999;
  NumberBoxPrice.DecimalDigits := 2;

  NumberBoxStock.Min := 0;
  NumberBoxStock.Max := 99999;
  NumberBoxStock.DecimalDigits := 0;

  SpinBoxPriority.Min := 1;
  SpinBoxPriority.Max := 10;
  SpinBoxPriority.Value := 5;

  CheckBoxActive.IsChecked := True;
  RadioButtonNew.IsChecked := True;
end;

procedure TSampleForm.SetupMultiLanguage;
begin
  // --- Türkçe çeviriler (UI kontrolleri) ---
  Lang.SetControlTranslation('LabelProductName', 'tr', 'Ürün Adı:');
  Lang.SetControlTranslation('LabelProductCode', 'tr', 'Ürün Kodu:');
  Lang.SetControlTranslation('LabelCategory', 'tr', 'Kategori:');
  Lang.SetControlTranslation('LabelPrice', 'tr', 'Birim Fiyat:');
  Lang.SetControlTranslation('LabelStock', 'tr', 'Stok Miktarı:');
  Lang.SetControlTranslation('LabelPriority', 'tr', 'Öncelik (1-10):');
  Lang.SetControlTranslation('LabelManufactureDate', 'tr', 'Üretim Tarihi:');
  Lang.SetControlTranslation('LabelRestockTime', 'tr', 'Stok Uyarı Saati:');
  Lang.SetControlTranslation('LabelDescription', 'tr', 'Açıklama:');
  Lang.SetControlTranslation('LabelFeatures', 'tr', 'Ürün Özellikleri:');
  Lang.SetControlTranslation('LabelOrderHistory', 'tr', 'Sipariş Geçmişi:');
  Lang.SetControlTranslation('LabelCondition', 'tr', 'Durum:');
  Lang.SetControlTranslation('LabelLanguage', 'tr', 'Dil:');
  Lang.SetControlTranslation('LabelLoadRecord', 'tr', 'ID ile Kayıt Yükle:');
  Lang.SetControlTranslation('CheckBoxActive', 'tr', 'Aktif Ürün');
  Lang.SetControlTranslation('CheckBoxFeatured', 'tr', 'Öne Çıkan Ürün');
  Lang.SetControlTranslation('RadioButtonNew', 'tr', 'Yeni');
  Lang.SetControlTranslation('RadioButtonUsed', 'tr', 'Kullanılmış');
  Lang.SetControlTranslation('ButtonSave', 'tr', 'Kaydet');
  Lang.SetControlTranslation('ButtonNew', 'tr', 'Yeni');
  Lang.SetControlTranslation('ButtonDelete', 'tr', 'Sil');
  Lang.SetControlTranslation('ButtonLoad', 'tr', 'Yükle');
  Lang.SetControlTranslation('ButtonShowJSON', 'tr', 'JSON Göster');
  Lang.SetControlTranslation('ButtonAddFeature', 'tr', 'Özellik Ekle');
  Lang.SetControlTranslation('ButtonClearFeatures', 'tr', 'Özellikleri Temizle');
  Lang.SetControlTranslation('ButtonAddOrder', 'tr', 'Sipariş Satırı Ekle');

  // --- Türkçe çeviriler (mesajlar) ---
  Lang.SetControlTranslation('MsgSaveSuccess', 'tr', 'Kayıt başarıyla kaydedildi!' + sLineBreak + 'Kayıt ID: ');
  Lang.SetControlTranslation('MsgSaveError', 'tr', 'Kayıt sırasında hata oluştu!');
  Lang.SetControlTranslation('MsgDeleteNotSaved', 'tr', 'Henüz kaydedilmemiş bir kayıt silinemez!');
  Lang.SetControlTranslation('MsgDeleteConfirm', 'tr', 'Bu ürünü silmek istediğinizden emin misiniz?');
  Lang.SetControlTranslation('MsgDeleteSuccess', 'tr', 'Ürün başarıyla silindi!');
  Lang.SetControlTranslation('MsgDeleteError', 'tr', 'Silme işlemi sırasında hata oluştu!');
  Lang.SetControlTranslation('MsgLoadSuccess', 'tr', 'Kayıt başarıyla yüklendi! ID: ');
  Lang.SetControlTranslation('MsgLoadError', 'tr', 'Kayıt bulunamadı veya yükleme sırasında hata oluştu!');
  Lang.SetControlTranslation('MsgLoadInvalidID', 'tr', 'Lütfen geçerli bir sayısal ID giriniz!');
  Lang.SetControlTranslation('MsgJSONTitle', 'tr', 'Mevcut Form Verileri (JSON):');
  Lang.SetControlTranslation('MsgAddFeatureTitle', 'tr', 'Özellik Ekle');
  Lang.SetControlTranslation('MsgAddFeaturePrompt', 'tr', 'Ürün özelliğini giriniz:');
  Lang.SetControlTranslation('MsgAddOrderID', 'tr', 'Sipariş ID:');
  Lang.SetControlTranslation('MsgAddOrderDate', 'tr', 'Sipariş Tarihi:');
  Lang.SetControlTranslation('MsgAddOrderQty', 'tr', 'Miktar:');
  Lang.SetControlTranslation('MsgAddOrderTotal', 'tr', 'Toplam:');
  Lang.SetControlTranslation('MsgAddOrderTitle', 'tr', 'Sipariş Ekle');

  // --- Almanca çeviriler (UI kontrolleri) ---
  Lang.SetControlTranslation('LabelProductName', 'de', 'Produktname:');
  Lang.SetControlTranslation('LabelProductCode', 'de', 'Produktcode:');
  Lang.SetControlTranslation('LabelCategory', 'de', 'Kategorie:');
  Lang.SetControlTranslation('LabelPrice', 'de', 'Stückpreis:');
  Lang.SetControlTranslation('LabelStock', 'de', 'Lagermenge:');
  Lang.SetControlTranslation('LabelPriority', 'de', 'Priorität (1-10):');
  Lang.SetControlTranslation('LabelManufactureDate', 'de', 'Herstellungsdatum:');
  Lang.SetControlTranslation('LabelRestockTime', 'de', 'Nachbestellzeit:');
  Lang.SetControlTranslation('LabelDescription', 'de', 'Beschreibung:');
  Lang.SetControlTranslation('LabelFeatures', 'de', 'Produktmerkmale:');
  Lang.SetControlTranslation('LabelOrderHistory', 'de', 'Bestellverlauf:');
  Lang.SetControlTranslation('LabelCondition', 'de', 'Zustand:');
  Lang.SetControlTranslation('LabelLanguage', 'de', 'Sprache:');
  Lang.SetControlTranslation('LabelLoadRecord', 'de', 'Datensatz per ID laden:');
  Lang.SetControlTranslation('CheckBoxActive', 'de', 'Aktives Produkt');
  Lang.SetControlTranslation('CheckBoxFeatured', 'de', 'Empfohlenes Produkt');
  Lang.SetControlTranslation('RadioButtonNew', 'de', 'Neu');
  Lang.SetControlTranslation('RadioButtonUsed', 'de', 'Gebraucht');
  Lang.SetControlTranslation('ButtonSave', 'de', 'Speichern');
  Lang.SetControlTranslation('ButtonNew', 'de', 'Neu');
  Lang.SetControlTranslation('ButtonDelete', 'de', 'Löschen');
  Lang.SetControlTranslation('ButtonLoad', 'de', 'Laden');
  Lang.SetControlTranslation('ButtonShowJSON', 'de', 'JSON anzeigen');
  Lang.SetControlTranslation('ButtonAddFeature', 'de', 'Merkmal hinzufügen');
  Lang.SetControlTranslation('ButtonClearFeatures', 'de', 'Merkmale löschen');
  Lang.SetControlTranslation('ButtonAddOrder', 'de', 'Bestellzeile hinzufügen');

  // --- Almanca çeviriler (mesajlar) ---
  Lang.SetControlTranslation('MsgSaveSuccess', 'de', 'Datensatz erfolgreich gespeichert!' + sLineBreak + 'Datensatz-ID: ');
  Lang.SetControlTranslation('MsgSaveError', 'de', 'Fehler beim Speichern des Datensatzes!');
  Lang.SetControlTranslation('MsgDeleteNotSaved', 'de', 'Ein noch nicht gespeicherter Datensatz kann nicht gelöscht werden!');
  Lang.SetControlTranslation('MsgDeleteConfirm', 'de', 'Möchten Sie dieses Produkt wirklich löschen?');
  Lang.SetControlTranslation('MsgDeleteSuccess', 'de', 'Produkt erfolgreich gelöscht!');
  Lang.SetControlTranslation('MsgDeleteError', 'de', 'Fehler beim Löschen!');
  Lang.SetControlTranslation('MsgLoadSuccess', 'de', 'Datensatz erfolgreich geladen! ID: ');
  Lang.SetControlTranslation('MsgLoadError', 'de', 'Datensatz nicht gefunden oder Fehler beim Laden!');
  Lang.SetControlTranslation('MsgLoadInvalidID', 'de', 'Bitte geben Sie eine gültige numerische ID ein!');
  Lang.SetControlTranslation('MsgJSONTitle', 'de', 'Aktuelle Formulardaten (JSON):');
  Lang.SetControlTranslation('MsgAddFeatureTitle', 'de', 'Merkmal hinzufügen');
  Lang.SetControlTranslation('MsgAddFeaturePrompt', 'de', 'Produktmerkmal eingeben:');
  Lang.SetControlTranslation('MsgAddOrderID', 'de', 'Bestell-ID:');
  Lang.SetControlTranslation('MsgAddOrderDate', 'de', 'Bestelldatum:');
  Lang.SetControlTranslation('MsgAddOrderQty', 'de', 'Menge:');
  Lang.SetControlTranslation('MsgAddOrderTotal', 'de', 'Gesamt:');
  Lang.SetControlTranslation('MsgAddOrderTitle', 'de', 'Bestellung hinzufügen');

  // --- İngilizce çeviriler (mesajlar) ---
  Lang.SetControlTranslation('MsgSaveSuccess', 'en', 'Record saved successfully!' + sLineBreak + 'Record ID: ');
  Lang.SetControlTranslation('MsgSaveError', 'en', 'An error occurred while saving!');
  Lang.SetControlTranslation('MsgDeleteNotSaved', 'en', 'Cannot delete a record that has not been saved yet!');
  Lang.SetControlTranslation('MsgDeleteConfirm', 'en', 'Are you sure you want to delete this product?');
  Lang.SetControlTranslation('MsgDeleteSuccess', 'en', 'Product deleted successfully!');
  Lang.SetControlTranslation('MsgDeleteError', 'en', 'An error occurred while deleting!');
  Lang.SetControlTranslation('MsgLoadSuccess', 'en', 'Record loaded successfully! ID: ');
  Lang.SetControlTranslation('MsgLoadError', 'en', 'Record not found or an error occurred while loading!');
  Lang.SetControlTranslation('MsgLoadInvalidID', 'en', 'Please enter a valid numeric ID!');
  Lang.SetControlTranslation('MsgJSONTitle', 'en', 'Current Form Data (JSON):');
  Lang.SetControlTranslation('MsgAddFeatureTitle', 'en', 'Add Feature');
  Lang.SetControlTranslation('MsgAddFeaturePrompt', 'en', 'Enter product feature:');
  Lang.SetControlTranslation('MsgAddOrderID', 'en', 'Order ID:');
  Lang.SetControlTranslation('MsgAddOrderDate', 'en', 'Order Date:');
  Lang.SetControlTranslation('MsgAddOrderQty', 'en', 'Quantity:');
  Lang.SetControlTranslation('MsgAddOrderTotal', 'en', 'Total:');
  Lang.SetControlTranslation('MsgAddOrderTitle', 'en', 'Add Order');

  // --- Varsayılan dil: İngilizce ---
  Lang.CurrentLanguage := 'en';
end;

procedure TSampleForm.InitializeOrderGrid;
begin
  // Sipariş geçmişi gridi başlangıç yapılandırması
  StringGridOrderHistory.SetupGrid(0, 4, 100);
  StringGridOrderHistory.SetColumnHeaders(['Order ID', 'Date', 'Qty', 'Total']);
  StringGridOrderHistory.Columns[0].Width := 90;
  StringGridOrderHistory.Columns[1].Width := 100;
  StringGridOrderHistory.Columns[2].Width := 60;
  StringGridOrderHistory.Columns[3].Width := 90;
end;

procedure TSampleForm.LoadLanguageFromFile(const ALang: string);
var
  LangFile: string;
  AppDir: string;
begin
  // Dil dosyasını uygulama dizininde ara
  AppDir := ExtractFilePath(ParamStr(0));
  LangFile := AppDir + 'lang_' + ALang + '.txt';

  if FileExists(LangFile) then
  begin
    Lang.LoadFromFile(LangFile);
    Lang.CurrentLanguage := ALang;
  end
  else
  begin
    // Dosya bulunamadıysa, bellekteki çevirileri kullan
    Lang.CurrentLanguage := ALang;
  end;
end;

// ============================================================================
// CRUD İşlemleri
// ============================================================================

procedure TSampleForm.ButtonNewClick(Sender: TObject);
begin
  NewRecord;
  // Yeni kayıt için varsayılan grid başlığını sıfırla
  InitializeOrderGrid;
end;

procedure TSampleForm.ButtonSaveClick(Sender: TObject);
var
  RecordID: Variant;
begin
  if SaveRecord then
  begin
    RecordID := GetCurrentRecordID;
    ShowMessage(GetMsg('MsgSaveSuccess') + VarToStr(RecordID));
  end
  else
    ShowMessage(GetMsg('MsgSaveError'));
end;

procedure TSampleForm.ButtonDeleteClick(Sender: TObject);
begin
  if IsNewRecord then
  begin
    ShowMessage(GetMsg('MsgDeleteNotSaved'));
    Exit;
  end;

  if MessageDlg(GetMsg('MsgDeleteConfirm'),
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    if DeleteRecord then
      ShowMessage(GetMsg('MsgDeleteSuccess'))
    else
      ShowMessage(GetMsg('MsgDeleteError'));
  end;
end;

procedure TSampleForm.ButtonLoadClick(Sender: TObject);
var
  RecordID: Integer;
begin
  if TryStrToInt(EditLoadID.Text, RecordID) then
  begin
    if LoadRecord(RecordID) then
      ShowMessage(GetMsg('MsgLoadSuccess') + IntToStr(RecordID))
    else
      ShowMessage(GetMsg('MsgLoadError'));
  end
  else
    ShowMessage(GetMsg('MsgLoadInvalidID'));
end;

procedure TSampleForm.ButtonShowJSONClick(Sender: TObject);
var
  JSONData: string;
begin
  JSONData := SaveToJSON;
  ShowMessage(GetMsg('MsgJSONTitle') + sLineBreak + sLineBreak + JSONData);
end;

// ============================================================================
// TListBox İşlemleri (Ürün Özellikleri)
// ============================================================================

procedure TSampleForm.ButtonAddFeatureClick(Sender: TObject);
var
  FeatureText: string;
begin
  FeatureText := InputBox(GetMsg('MsgAddFeatureTitle'), GetMsg('MsgAddFeaturePrompt'), '');
  if Trim(FeatureText) <> '' then
    ListBoxFeatures.Items.Add(FeatureText);
end;

procedure TSampleForm.ButtonClearFeaturesClick(Sender: TObject);
begin
  ListBoxFeatures.ClearItems;
end;

// ============================================================================
// TStringGrid İşlemleri (Sipariş Geçmişi)
// ============================================================================

procedure TSampleForm.ButtonAddOrderClick(Sender: TObject);
var
  OrderID, OrderDate, Qty, Total: string;
  CurrentRow: Integer;
begin
  OrderID   := InputBox(GetMsg('MsgAddOrderTitle'), GetMsg('MsgAddOrderID'), 'ORD-' + FormatDateTime('yyyymmdd', Now));
  OrderDate := InputBox(GetMsg('MsgAddOrderTitle'), GetMsg('MsgAddOrderDate'), FormatDateTime('dd.mm.yyyy', Now));
  Qty       := InputBox(GetMsg('MsgAddOrderTitle'), GetMsg('MsgAddOrderQty'), '1');
  Total     := InputBox(GetMsg('MsgAddOrderTitle'), GetMsg('MsgAddOrderTotal'), '0.00');

  if Trim(OrderID) <> '' then
  begin
    CurrentRow := StringGridOrderHistory.RowCount;
    StringGridOrderHistory.RowCount := CurrentRow + 1;
    StringGridOrderHistory.Cells[0, CurrentRow] := OrderID;
    StringGridOrderHistory.Cells[1, CurrentRow] := OrderDate;
    StringGridOrderHistory.Cells[2, CurrentRow] := Qty;
    StringGridOrderHistory.Cells[3, CurrentRow] := Total;
  end;
end;

// ============================================================================
// Yardımcı Metodlar
// ============================================================================

function TSampleForm.GetMsg(const AKey: string): string;
begin
  Result := Lang.GetControlTranslation(AKey, Lang.CurrentLanguage);
  if Result = '' then
    Result := Lang.GetControlTranslation(AKey, 'en');
  if Result = '' then
    Result := AKey;
end;

// ============================================================================
// Çok Dilli Destek (TLang)
// ============================================================================

procedure TSampleForm.ComboBoxLanguageChange(Sender: TObject);
var
  LangCode: string;
begin
  case ComboBoxLanguage.ItemIndex of
    0: LangCode := 'en';
    1: LangCode := 'tr';
    2: LangCode := 'de';
  else
    LangCode := 'en';
  end;

  // Önce harici .txt dil dosyasından yüklemeyi dene
  LoadLanguageFromFile(LangCode);
end;

// ============================================================================
// Hook Metodları
// ============================================================================

procedure TSampleForm.BeforeLoadFromJSON;
begin
  inherited;
  // Grid yapısını sıfırla; LoadFromJSON grid satırlarını yeniden kuracak
  StringGridOrderHistory.ClearGrid;
end;

procedure TSampleForm.AfterLoadFromJSON;
begin
  inherited;
  // Grid sütun başlıklarını düzelt (JSON yüklemesi sütun isimlerini değiştirebilir)
  if StringGridOrderHistory.ColumnCount = 4 then
    StringGridOrderHistory.SetColumnHeaders(['Order ID', 'Date', 'Qty', 'Total']);
end;

procedure TSampleForm.BeforeSaveToJSON;
begin
  inherited;
  // Kayıt öncesi kontroller buraya eklenebilir
end;

procedure TSampleForm.AfterSaveToJSON;
begin
  inherited;
  // Kayıt sonrası işlemler buraya eklenebilir
end;

end.
