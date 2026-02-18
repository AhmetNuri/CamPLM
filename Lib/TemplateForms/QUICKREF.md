# FireMonkey Template Forms - Hızlı Başvuru Kılavuzu

## Temel Kullanım

### 1. Projenize Ekleme

```pascal
// uses bölümüne ekleyin
uses
  TemplateForm, FormDataModel, FormController;
```

### 2. Form Sınıfı Oluşturma

```pascal
type
  TMyForm = class(TTemplateForm)
    // UI bileşenleriniz
    EditName: TEdit;
    CheckBoxActive: TCheckBox;
    // Buton event'leri
    procedure ButtonSaveClick(Sender: TObject);
  end;
```

### 3. Form Oluşturma

```pascal
MyForm := TMyForm.Create(Self, FDConnection1, 'TableName');
// veya özel primary key ile
MyForm := TMyForm.Create(Self, FDConnection1, 'TableName', 'CustomID');
```

## API Hızlı Referans

| Metod | Açıklama | Örnek |
|-------|----------|-------|
| `NewRecord` | Yeni kayıt başlat | `MyForm.NewRecord;` |
| `LoadRecord(ID)` | Kayıt yükle | `MyForm.LoadRecord(123);` |
| `SaveRecord` | Kaydet (Insert/Update) | `if MyForm.SaveRecord then ...` |
| `DeleteRecord` | Sil | `if MyForm.DeleteRecord then ...` |
| `SaveToJSON` | JSON al | `json := MyForm.SaveToJSON;` |
| `LoadFromJSON` | JSON'dan yükle | `MyForm.LoadFromJSON(json);` |
| `ClearForm` | Formu temizle | `MyForm.ClearForm;` |
| `GetCurrentRecordID` | Mevcut ID | `id := MyForm.GetCurrentRecordID;` |
| `IsNewRecord` | Yeni mi? | `if MyForm.IsNewRecord then ...` |

## Desteklenen Kontroller

✅ TEdit
✅ TNumberBox
✅ TMemo
✅ TComboBox
✅ TCheckBox
✅ TRadioButton
✅ TDateEdit
✅ TTimeEdit
✅ TSpinBox

## Hook Metodları

```pascal
protected
  procedure BeforeLoadFromJSON; override;  // JSON yüklenmeden önce
  procedure AfterLoadFromJSON; override;   // JSON yüklendikten sonra
  procedure BeforeSaveToJSON; override;    // JSON oluşturulmadan önce
  procedure AfterSaveToJSON; override;     // JSON oluşturulduktan sonra
```

## Veritabanı Gereksinimi

Her tabloda `UIJSON` alanı olmalı:

```sql
-- SQLite
CREATE TABLE MyTable (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    UIJSON TEXT
);

-- SQL Server
CREATE TABLE MyTable (
    ID INT PRIMARY KEY IDENTITY(1,1),
    UIJSON VARCHAR(4000)
);
```

## Tam Örnek - Kayıt Formu

```pascal
unit CustomerForm;

interface

uses
  TemplateForm, FMX.StdCtrls, FMX.Edit, FireDAC.Comp.Client;

type
  TCustomerForm = class(TTemplateForm)
    EditName: TEdit;
    EditEmail: TEdit;
    CheckBoxActive: TCheckBox;
    ButtonSave: TButton;
    ButtonNew: TButton;
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonNewClick(Sender: TObject);
  end;

implementation

procedure TCustomerForm.ButtonSaveClick(Sender: TObject);
begin
  if SaveRecord then
    ShowMessage('Kaydedildi! ID: ' + VarToStr(GetCurrentRecordID));
end;

procedure TCustomerForm.ButtonNewClick(Sender: TObject);
begin
  NewRecord;
end;

end.
```

## Ana Program'dan Kullanım

```pascal
var
  Form: TCustomerForm;
begin
  Form := TCustomerForm.Create(Self, FDConnection1, 'Customers');
  try
    // Yeni kayıt
    Form.NewRecord;
    Form.ShowModal;
    
    // veya mevcut kayıt
    Form.LoadRecord(123);
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;
```

## İpuçları

1. **Kontrol İsimleri**: Benzersiz olmalı (EditName, EditEmail vb.)
2. **Bağlantı**: Form oluşturmadan önce aktif olmalı
3. **UIJSON**: Her tabloda bulunmalı
4. **Hata Kontrolü**: Tüm işlemler Boolean döner, kontrol edin
5. **Primary Key**: Varsayılan "ID", değiştirebilirsiniz

## Sık Kullanılan Senaryolar

### Kayıt Ekle
```pascal
MyForm.NewRecord;
// Kullanıcı verileri girer
if MyForm.SaveRecord then
  ShowMessage('Eklendi');
```

### Kayıt Güncelle
```pascal
MyForm.LoadRecord(123);
// Kullanıcı değişiklik yapar
if MyForm.SaveRecord then
  ShowMessage('Güncellendi');
```

### Kayıt Sil
```pascal
MyForm.LoadRecord(123);
if MessageDlg('Silmek istediğinizden emin misiniz?', ...) = mrYes then
  if MyForm.DeleteRecord then
    ShowMessage('Silindi');
```

### JSON'ı Başka Yere Kaydet
```pascal
var
  JSONData: string;
begin
  JSONData := MyForm.SaveToJSON;
  // JSONData'yı dosyaya, API'ye, vb. gönderin
end;
```

## Property'lere Erişim

```pascal
// FDQuery'ye erişim
MyForm.FDQuery1.SQL.Text := 'SELECT * FROM ...';
MyForm.FDQuery1.Open;

// DataModel'e erişim
if MyForm.DataModel.IsNewRecord then ...

// Controller'a erişim
json := MyForm.Controller.SaveToJSON;
```

---

📖 Detaylı dokümantasyon: [README.md](README.md)
💡 Örnek kod: [ExampleCustomerForm.pas](ExampleCustomerForm.pas)
🗄️ Database setup: [DatabaseSetup.sql](DatabaseSetup.sql)
