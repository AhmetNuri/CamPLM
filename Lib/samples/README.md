# CamPLM - Örnek Uygulama (Sample Application)

Bu klasör, **FireMonkey Template Forms** kütüphanesinin tüm özelliklerini gösteren bir örnek uygulama içermektedir.

## Dosya Yapısı

```
Lib/samples/
├── SampleApp.dpr          - Delphi proje dosyası
├── SampleApp.dproj        - Proje yapılandırma dosyası
├── uSampleForm.pas        - Örnek form (Pascal birimi)
├── uSampleForm.fmx        - Örnek form tasarımı (FireMonkey)
├── demo.db                - SQLite demo veritabanı (örnek verilerle)
├── lang_en.txt            - İngilizce dil dosyası (.txt formatında JSON)
├── lang_tr.txt            - Türkçe dil dosyası (.txt formatında JSON)
├── lang_de.txt            - Almanca dil dosyası (.txt formatında JSON)
└── README.md              - Bu dokümantasyon dosyası
```

## Gösterilen Özellikler

### 1. Desteklenen Kontroller (Tüm Tipler)

| Kontrol         | Form Adı                   | Açıklama                        |
|-----------------|----------------------------|---------------------------------|
| `TEdit`         | `EditProductName`          | Ürün adı                        |
| `TEdit`         | `EditProductCode`          | Ürün kodu                       |
| `TNumberBox`    | `NumberBoxPrice`           | Birim fiyat                     |
| `TNumberBox`    | `NumberBoxStock`           | Stok miktarı                    |
| `TSpinBox`      | `SpinBoxPriority`          | Öncelik (1-10)                  |
| `TComboBox`     | `ComboBoxCategory`         | Kategori seçimi                 |
| `TDateEdit`     | `DateEditManufacture`      | Üretim tarihi                   |
| `TTimeEdit`     | `TimeEditRestockAlert`     | Stok uyarı saati                |
| `TMemo`         | `MemoDescription`          | Ürün açıklaması                 |
| `TCheckBox`     | `CheckBoxActive`           | Aktif ürün durumu               |
| `TCheckBox`     | `CheckBoxFeatured`         | Öne çıkan ürün                  |
| `TRadioButton`  | `RadioButtonNew`           | Durum: Yeni                     |
| `TRadioButton`  | `RadioButtonUsed`          | Durum: Kullanılmış              |
| `TListBox`      | `ListBoxFeatures`          | Ürün özellikleri (JSON export)  |
| `TStringGrid`   | `StringGridOrderHistory`   | Sipariş geçmişi (JSON export)   |

### 2. CRUD İşlemleri

```pascal
// Yeni kayıt başlat
ButtonNew → NewRecord

// Kaydet (Insert veya Update)
ButtonSave → SaveRecord

// Sil
ButtonDelete → DeleteRecord

// ID ile yükle
ButtonLoad → LoadRecord(ID)

// JSON görüntüle
ButtonShowJSON → SaveToJSON
```

### 3. TListBox ile JSON İşlemleri

```pascal
// Özellik ekle
ButtonAddFeature → ListBoxFeatures.Items.Add(...)

// Tüm özellikleri temizle
ButtonClearFeatures → ListBoxFeatures.ClearItems

// Otomatik JSON serialize/deserialize
// SaveRecord / LoadRecord sırasında otomatik yapılır
```

### 4. TStringGrid ile JSON İşlemleri

```pascal
// Sipariş satırı ekle
ButtonAddOrder → StringGridOrderHistory.RowCount := +1

// Grid kurulumu
StringGridOrderHistory.SetupGrid(0, 4, 100)
StringGridOrderHistory.SetColumnHeaders(['Order ID', 'Date', 'Qty', 'Total'])

// Otomatik JSON serialize/deserialize
// SaveRecord / LoadRecord sırasında otomatik yapılır
```

### 5. Çok Dilli Destek (TLang)

Dil dosyaları `.txt` formatında `lang_XX.txt` şeklinde saklanır. Her dil dosyası JSON formatında çeviri verisi içerir:

```json
{
  "ButtonSave": {
    "en": "Save",
    "tr": "Kaydet",
    "de": "Speichern"
  },
  "LabelProductName": {
    "en": "Product Name:",
    "tr": "Ürün Adı:",
    "de": "Produktname:"
  }
}
```

Kod içinde dil değiştirme:

```pascal
// Dil combo box'ından değişim
procedure TSampleForm.ComboBoxLanguageChange(Sender: TObject);
begin
  case ComboBoxLanguage.ItemIndex of
    0: LoadLanguageFromFile('en');  // lang_en.txt dosyasından yükler
    1: LoadLanguageFromFile('tr');  // lang_tr.txt dosyasından yükler
    2: LoadLanguageFromFile('de');  // lang_de.txt dosyasından yükler
  end;
end;
```

### 6. Hook Metodları

```pascal
procedure TSampleForm.BeforeLoadFromJSON;
begin
  inherited;
  StringGridOrderHistory.ClearGrid; // Grid'i yüklemeden önce temizle
end;

procedure TSampleForm.AfterLoadFromJSON;
begin
  inherited;
  // Sütun başlıklarını yeniden düzelt
  StringGridOrderHistory.SetColumnHeaders(['Order ID', 'Date', 'Qty', 'Total']);
end;
```

### 7. SQLite Veritabanı

`demo.db` dosyası aşağıdaki tablo yapısını içerir:

```sql
CREATE TABLE Products (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    UIJSON TEXT,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

3 adet örnek ürün kaydıyla gelir:
- **ID=1**: Wireless Mouse
- **ID=2**: Mechanical Keyboard
- **ID=3**: USB-C Hub

## Kurulum ve Çalıştırma

### Gereksinimler

- **Delphi** 10.3 Rio veya üzeri (RAD Studio)
- **FireMonkey** (FMX) platform desteği
- **FireDAC** bileşenleri
- **SQLite** sürücüsü (FireDAC ile birlikte gelir)

### Adımlar

1. `SampleApp.dproj` dosyasını Delphi IDE'de açın.
2. Proje arama yollarına şunu ekleyin: `..\TemplateForms`
3. Derleme yapın ve çalıştırın.
4. `demo.db` dosyasını çalıştırılabilir dosyanın yanına kopyalayın.
5. `lang_*.txt` dosyalarını da aynı dizine kopyalayın.

### Veritabanı Bağlantısı

Örnek uygulama, `demo.db` SQLite dosyasını kullanır. `uSampleForm.pas` içindeki bağlantı kurulumunu kendi ortamınıza göre ayarlayın.

```pascal
// Ana form'da bağlantı oluşturma örneği
FDConnection := TFDConnection.Create(Self);
FDConnection.DriverName := 'SQLite';
FDConnection.Params.Values['Database'] := ExtractFilePath(ParamStr(0)) + 'demo.db';
FDConnection.Connected := True;

SampleForm := TSampleForm.Create(Self, FDConnection, 'Products');
```

## Örnek Kullanım Senaryoları

### Yeni Ürün Ekle

1. **New** butonuna tıklayın.
2. Form alanlarını doldurun.
3. Ürün özelliklerini **Add Feature** ile ekleyin.
4. Sipariş satırlarını **Add Order Row** ile ekleyin.
5. **Save** butonuna tıklayın.

### Kayıt Yükle

1. **Load Record by ID** alanına kayıt ID'sini girin (örn: 1, 2, 3).
2. **Load** butonuna tıklayın.
3. Form tüm alanları otomatik olarak doldurur.

### Dil Değiştir

- **Language** combo box'ından istediğiniz dili seçin.
- Tüm etiketler ve butonlar anında değişir.
- Dil dosyaları uygulama dizinindeki `lang_XX.txt` dosyalarından yüklenir.

### JSON Görüntüle

- **Show JSON** butonuna tıklayın.
- Form verilerinin JSON formatındaki çıktısını görebilirsiniz.

## İlgili Dosyalar

📖 Ana kütüphane dokümantasyonu: [`Lib/TemplateForms/README.md`](../TemplateForms/README.md)  
⚡ Hızlı başvuru: [`Lib/TemplateForms/QUICKREF.md`](../TemplateForms/QUICKREF.md)  
🗄️ Veritabanı kurulum: [`Lib/TemplateForms/DatabaseSetup.sql`](../TemplateForms/DatabaseSetup.sql)
