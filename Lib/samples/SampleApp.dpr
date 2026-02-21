program SampleApp;

{
  ============================================================================
  CamPLM - FireMonkey Template Forms Library
  Sample Application
  ============================================================================
  Bu proje, TemplateForm kütüphanesinin tüm özelliklerini gösteren bir
  örnek uygulamadır.

  Kütüphane Özellikleri:
  - MVC Mimarisi (Model-View-Controller)
  - Otomatik JSON Serialization / Deserialization
  - CRUD İşlemleri (Insert, Update, Delete, LoadRecord)
  - FireDAC + SQLite Entegrasyonu
  - TListBox JSON import/export (ListBoxHelper)
  - TStringGrid JSON import/export (StringGridHelper)
  - Çok Dilli Destek (TLang - .txt dosyalarından yükleme)
  - Hook Metodları (BeforeLoadFromJSON, AfterLoadFromJSON, vb.)

  Veritabanı:
  - demo.db (SQLite)
  - Tablo: Products (ID, UIJSON, CreatedDate, ModifiedDate)

  Dil Dosyaları (.txt):
  - lang_en.txt  (İngilizce)
  - lang_tr.txt  (Türkçe)
  - lang_de.txt  (Almanca)
  ============================================================================
}

uses
  System.StartUpCopy,
  FMX.Forms,
  FireDAC.DApt,
  uSampleForm in 'uSampleForm.pas' {SampleForm},
  TemplateForm in '..\TemplateForms\TemplateForm.pas' {TemplateFormInstance},
  FormDataModel in '..\TemplateForms\FormDataModel.pas',
  FormController in '..\TemplateForms\FormController.pas',
  LangComponent in '..\TemplateForms\LangComponent.pas',
  ListBoxHelper in '..\TemplateForms\ListBoxHelper.pas',
  StringGridHelper in '..\TemplateForms\StringGridHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TSampleForm, SampleForm);
  Application.Run;
end.
