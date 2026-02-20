program CamPLM;

uses
  System.StartUpCopy,
  FMX.Forms,
  FireDAC.DApt,
  uMainFrm in 'uMainFrm.pas' {Form6},
  EnhancedExampleForm in 'Lib\TemplateForms\EnhancedExampleForm.pas',
  ExampleCustomerForm in 'Lib\TemplateForms\ExampleCustomerForm.pas' {ExampleCustomerForm},
  FormController in 'Lib\TemplateForms\FormController.pas',
  FormDataModel in 'Lib\TemplateForms\FormDataModel.pas',
  LangComponent in 'Lib\TemplateForms\LangComponent.pas',
  ListBoxHelper in 'Lib\TemplateForms\ListBoxHelper.pas',
  StringGridHelper in 'Lib\TemplateForms\StringGridHelper.pas',
  TemplateForm in 'Lib\TemplateForms\TemplateForm.pas' {TemplateForm},
  uFileSecurityUtils in 'Lib\uFileSecurityUtils.pas',
  uCentralLogger in 'Lib\uCentralLogger.pas',
  uExceptionHandler in 'Lib\uExceptionHandler.pas',
  ufdConnectionHelper in 'Lib\ufdConnectionHelper.pas',
  uFDQueryHelper in 'Lib\uFDQueryHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm6, Form6);
  Application.CreateForm(TExampleCustomerForm, FrmExampleCustomerForm);
  Application.Run;
end.
