program CamPLM;

uses
  System.StartUpCopy,
  FMX.Forms,
  FireDAC.DApt,
  uMainFrm in 'uMainFrm.pas' {MenuForm},
  EnhancedExampleForm in 'Lib\TemplateForms\EnhancedExampleForm.pas',
  ExampleCustomerForm in 'Lib\TemplateForms\ExampleCustomerForm.pas' {ExampleCustomerForm},
  FormController in 'Lib\TemplateForms\FormController.pas',
  FormDataModel in 'Lib\TemplateForms\FormDataModel.pas',
  LangComponent in 'Lib\TemplateForms\LangComponent.pas',
  ListBoxHelper in 'Lib\TemplateForms\ListBoxHelper.pas',
  StringGridHelper in 'Lib\TemplateForms\StringGridHelper.pas',
  TemplateForm in 'Lib\TemplateForms\TemplateForm.pas' {TemplateForm},
  uCentralLogger in 'Lib\helpers\uCentralLogger.pas',
  uExceptionHandler in 'Lib\helpers\uExceptionHandler.pas',
  ufdConnectionHelper in 'Lib\helpers\ufdConnectionHelper.pas',
  uFDQueryHelper in 'Lib\helpers\uFDQueryHelper.pas',
  uFileSecurityUtils in 'Lib\helpers\uFileSecurityUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMenuForm, MenuForm);
  Application.Run;
end.
