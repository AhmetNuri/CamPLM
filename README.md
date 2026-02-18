# CamPLM

## FireMonkey Template Forms Library

Bu proje, Delphi FireMonkey platformu için geliştirilmiş bir form tabanlı mini ORM kütüphanesi içermektedir.

### Özellikler

- **MVC Mimarisi** - Model-View-Controller yaklaşımı ile temiz kod yapısı
- **Otomatik JSON Serialization** - Form kontrollerinin otomatik JSON dönüşümü
- **FireDAC Entegrasyonu** - Tam veritabanı desteği
- **CRUD İşlemleri** - Insert, Update, Delete, LoadRecord
- **SOLID Prensipleri** - Temiz ve bakımı kolay kod yapısı

### Kullanım

Detaylı dokümantasyon ve kullanım örnekleri için:

📖 [Lib/TemplateForms/README.md](Lib/TemplateForms/README.md)

### Hızlı Başlangıç

```pascal
// Form oluştur
CustomerForm := TMyCustomerForm.Create(Self, FDConnection1, 'Customers');

// Yeni kayıt
CustomerForm.NewRecord;

// Kaydet
CustomerForm.SaveRecord;

// Yükle
CustomerForm.LoadRecord(123);
```

### Kütüphane Yapısı

```
Lib/TemplateForms/
├── FormDataModel.pas       - Model katmanı (Data işlemleri)
├── FormController.pas      - Controller katmanı (JSON dönüşümleri)
├── TemplateForm.pas        - Base form sınıfı
├── TemplateForm.fmx        - Form tasarımı
├── ExampleCustomerForm.pas - Örnek kullanım
├── ExampleCustomerForm.fmx - Örnek form tasarımı
└── README.md              - Detaylı dokümantasyon
```