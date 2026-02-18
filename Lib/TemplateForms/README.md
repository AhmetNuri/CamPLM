# FireMonkey Template Forms - Mini ORM Framework

Bu kütüphane, Delphi FireMonkey platformu için basit ama güçlü bir form tabanlı mini ORM sistemi sağlar.

## Özellikler

- **MVC Mimarisi**: Model-View-Controller yaklaşımı ile temiz kod yapısı
- **Otomatik JSON Serileştirme**: Form kontrollerinin değerleri otomatik olarak JSON'a dönüştürülür
- **CRUD İşlemleri**: Insert, Update, Delete, LoadRecord metodları ile tam veritabanı desteği
- **FireDAC Entegrasyonu**: FireDAC bileşenleri ile sorunsuz veritabanı bağlantısı
- **Dinamik Yapı**: Hangi kontrollerin formda olduğu otomatik algılanır
- **Hata Yönetimi**: Tüm kritik noktalarda try-except blokları ile güvenli çalışma
- **SOLID Prensipleri**: Temiz kod ve bakım kolaylığı için SOLID prensiplerine uygun tasarım

## Desteklenen Kontroller

Framework aşağıdaki FireMonkey kontrollerini otomatik olarak destekler:

- TEdit
- TNumberBox
- TMemo
- TComboBox
- TCheckBox
- TRadioButton
- TDateEdit
- TTimeEdit
- TSpinBox

## Mimari

Framework üç ana katmandan oluşur:

### 1. Model Katmanı (FormDataModel.pas)
Veritabanı işlemlerini yönetir:
- Sorgu yönetimi
- CRUD operasyonları
- JSON verisinin veritabanına kaydedilmesi/yüklenmesi

### 2. Controller Katmanı (FormController.pas)
UI kontrolleri ve JSON arasında dönüşüm yapar:
- Kontrol değerlerini JSON'a serileştirir
- JSON'dan kontrol değerlerini yükler
- Dinamik kontrol keşfi

### 3. View Katmanı (TemplateForm.pas)
Base form sınıfı:
- Model ve Controller'ı bir araya getirir
- Public API sağlar
- Override edilebilir hook metodları

## Kurulum

1. Projenize şu dosyaları ekleyin:
   - `Lib/TemplateForms/FormDataModel.pas`
   - `Lib/TemplateForms/FormController.pas`
   - `Lib/TemplateForms/TemplateForm.pas`
   - `Lib/TemplateForms/TemplateForm.fmx`

2. Projenizin arama yollarına (Search Path) `Lib/TemplateForms` klasörünü ekleyin.

## Kullanım

### Veritabanı Tablosu Hazırlama

Her tablo için bir `UIJSON` alanı oluşturun:

```sql
CREATE TABLE Customers (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    UIJSON TEXT
);
```

veya SQL Server için:

```sql
CREATE TABLE Customers (
    ID INT PRIMARY KEY IDENTITY(1,1),
    UIJSON VARCHAR(4000)
);
```

### Basit Form Örneği

```pascal
unit MyCustomerForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FireDAC.Comp.Client,
  TemplateForm;

type
  TMyCustomerForm = class(TTemplateForm)
    EditCustomerName: TEdit;
    EditEmail: TEdit;
    EditPhone: TEdit;
    MemoNotes: TMemo;
    CheckBoxActive: TCheckBox;
    DateEditRegistration: TDateEdit;
    ButtonSave: TButton;
    ButtonNew: TButton;
    ButtonDelete: TButton;
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonNewClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MyCustomerForm: TMyCustomerForm;

implementation

{$R *.fmx}

procedure TMyCustomerForm.ButtonSaveClick(Sender: TObject);
begin
  if SaveRecord then
    ShowMessage('Kayıt başarıyla kaydedildi!')
  else
    ShowMessage('Kayıt sırasında hata oluştu!');
end;

procedure TMyCustomerForm.ButtonNewClick(Sender: TObject);
begin
  NewRecord;
end;

procedure TMyCustomerForm.ButtonDeleteClick(Sender: TObject);
begin
  if MessageDlg('Kaydı silmek istediğinizden emin misiniz?', 
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    if DeleteRecord then
      ShowMessage('Kayıt başarıyla silindi!')
    else
      ShowMessage('Silme sırasında hata oluştu!');
  end;
end;

end.
```

### Form Oluşturma

```pascal
var
  CustomerForm: TMyCustomerForm;
  FDConnection1: TFDConnection;
begin
  // FDConnection1 bağlantınız hazır olmalı
  
  CustomerForm := TMyCustomerForm.Create(Self, FDConnection1, 'Customers');
  try
    CustomerForm.ShowModal;
  finally
    CustomerForm.Free;
  end;
end;
```

### Özel Primary Key Kullanımı

```pascal
CustomerForm := TMyCustomerForm.Create(Self, FDConnection1, 'Customers', 'CustomerID');
```

### Özel UIJSON Alan Adı Kullanımı

```pascal
CustomerForm := TMyCustomerForm.Create(Self, FDConnection1, 'Customers', 'ID', 'FormData');
```

## API Referansı

### TTemplateForm Metodları

#### NewRecord
Yeni bir kayıt oluşturur (formu temizler ve insert moduna geçer):
```pascal
MyForm.NewRecord;
```

#### LoadRecord(ARecordID: Variant): Boolean
Mevcut bir kaydı ID ile yükler:
```pascal
if MyForm.LoadRecord(123) then
  ShowMessage('Kayıt yüklendi!');
```

#### SaveRecord: Boolean
Formdaki değerleri veritabanına kaydeder (yeni kayıt veya güncelleme):
```pascal
if MyForm.SaveRecord then
  ShowMessage('Başarılı!');
```

#### DeleteRecord: Boolean
Mevcut kaydı siler:
```pascal
if MyForm.DeleteRecord then
  ShowMessage('Silindi!');
```

#### SaveToJSON: string
Formdaki tüm kontrollerin değerlerini JSON string olarak döndürür:
```pascal
var
  JSONData: string;
begin
  JSONData := MyForm.SaveToJSON;
  // {"EditCustomerName":"John Doe","EditEmail":"john@example.com",...}
end;
```

#### LoadFromJSON(AJSON: string): Boolean
JSON string'den kontrollere değerleri yükler:
```pascal
MyForm.LoadFromJSON('{"EditCustomerName":"Jane Smith","CheckBoxActive":true}');
```

#### ClearForm
Tüm kontrolleri temizler:
```pascal
MyForm.ClearForm;
```

#### GetCurrentRecordID: Variant
Mevcut kaydın ID'sini döndürür:
```pascal
var
  CurrentID: Variant;
begin
  CurrentID := MyForm.GetCurrentRecordID;
end;
```

#### IsNewRecord: Boolean
Kaydın yeni olup olmadığını kontrol eder:
```pascal
if MyForm.IsNewRecord then
  ShowMessage('Bu yeni bir kayıt');
```

### Override Edilebilir Hook Metodları

Framework, özelleştirme için hook metodları sağlar:

```pascal
type
  TMyCustomForm = class(TTemplateForm)
  protected
    procedure BeforeLoadFromJSON; override;
    procedure AfterLoadFromJSON; override;
    procedure BeforeSaveToJSON; override;
    procedure AfterSaveToJSON; override;
  end;

implementation

procedure TMyCustomForm.BeforeLoadFromJSON;
begin
  inherited;
  // JSON yüklenmeden önce yapılacak işlemler
end;

procedure TMyCustomForm.AfterLoadFromJSON;
begin
  inherited;
  // JSON yüklendikten sonra yapılacak işlemler
end;

procedure TMyCustomForm.BeforeSaveToJSON;
begin
  inherited;
  // JSON oluşturulmadan önce yapılacak işlemler
end;

procedure TMyCustomForm.AfterSaveToJSON;
begin
  inherited;
  // JSON oluşturulduktan sonra yapılacak işlemler
end;
```

## İleri Seviye Kullanım

### Doğrudan FDQuery Kullanımı

Form içinde `FDQuery1` property'si aracılığıyla doğrudan sorgu çalıştırabilirsiniz:

```pascal
procedure TMyCustomerForm.LoadActiveCustomers;
begin
  FDQuery1.SQL.Text := 'SELECT * FROM Customers WHERE Active = 1';
  FDQuery1.Open;
  
  while not FDQuery1.Eof do
  begin
    // Her kaydı işle
    FDQuery1.Next;
  end;
end;
```

### DataModel'e Doğrudan Erişim

```pascal
var
  RecordExists: Boolean;
begin
  RecordExists := DataModel.LoadRecord(123);
  if RecordExists then
    ShowMessage(DataModel.GetUIJSON);
end;
```

### Controller'a Doğrudan Erişim

```pascal
var
  JSONData: string;
begin
  JSONData := Controller.SaveToJSON;
  // JSON'ı başka bir yere kaydet veya gönder
end;
```

## Hata Yönetimi

Framework, tüm kritik noktalarda try-except blokları kullanır ve hataları sessizce yönetir. Bu, uygulamanızın çökmesini önler ancak hata loglaması eklemek isteyebilirsiniz:

```pascal
type
  TMyCustomForm = class(TTemplateForm)
  public
    function SaveRecord: Boolean; override;
  end;

implementation

function TMyCustomForm.SaveRecord: Boolean;
begin
  Result := inherited SaveRecord;
  
  if not Result then
  begin
    // Hata logla
    MyLogger.Log('Kayıt başarısız oldu');
  end;
end;
```

## JSON Formatı

Örnek bir JSON çıktısı:

```json
{
  "EditCustomerName": "John Doe",
  "EditEmail": "john@example.com",
  "EditPhone": "+90 555 123 4567",
  "MemoNotes": "Önemli müşteri",
  "CheckBoxActive": true,
  "DateEditRegistration": "18.02.2026",
  "NumberBoxAge": 35,
  "ComboBoxCity": "Istanbul",
  "SpinBoxRating": 5
}
```

## Önemli Notlar

1. **Kontrol İsimleri**: Tüm data entry kontrolleriniz benzersiz isimlere sahip olmalıdır (örn: EditCustomerName, CheckBoxActive)
2. **Veritabanı Bağlantısı**: Form oluşturulmadan önce FireDAC bağlantısı aktif olmalıdır
3. **UIJSON Alanı**: Her tabloda mutlaka UIJSON adında bir alan bulunmalıdır
4. **Primary Key**: Varsayılan olarak "ID" kullanılır, farklı bir alan kullanıyorsanız constructor'da belirtin
5. **Thread Safety**: Framework thread-safe değildir, ana UI thread'den kullanın

## Lisans

Bu proje açık kaynak kodludur ve serbestçe kullanılabilir.

## Katkıda Bulunma

Katkılarınızı bekliyoruz! Pull request göndermekten çekinmeyin.

## Destek

Sorularınız için issue açabilirsiniz.
