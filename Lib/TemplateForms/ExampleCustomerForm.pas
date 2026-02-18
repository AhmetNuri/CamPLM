unit ExampleCustomerForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Memo, FMX.DateTimeCtrls, FMX.NumberBox,
  FMX.ListBox, FMX.SpinBox, FireDAC.Comp.Client,
  TemplateForm;

type
  /// <summary>
  /// Example form demonstrating the TemplateForm usage
  /// This form inherits all CRUD and JSON functionality automatically
  /// </summary>
  TExampleCustomerForm = class(TTemplateForm)
    Label1: TLabel;
    EditCustomerName: TEdit;
    Label2: TLabel;
    EditEmail: TEdit;
    Label3: TLabel;
    EditPhone: TEdit;
    Label4: TLabel;
    MemoNotes: TMemo;
    CheckBoxActive: TCheckBox;
    Label5: TLabel;
    DateEditRegistration: TDateEdit;
    ButtonSave: TButton;
    ButtonNew: TButton;
    ButtonDelete: TButton;
    ButtonLoad: TButton;
    Label6: TLabel;
    NumberBoxAge: TNumberBox;
    Label7: TLabel;
    ComboBoxCity: TComboBox;
    Label8: TLabel;
    SpinBoxRating: TSpinBox;
    ButtonShowJSON: TButton;
    RadioButtonMale: TRadioButton;
    RadioButtonFemale: TRadioButton;
    Label9: TLabel;
    TimeEditPreferredContactTime: TTimeEdit;
    Label10: TLabel;
    EditLoadID: TEdit;
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonNewClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonShowJSONClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  protected
    procedure BeforeLoadFromJSON; override;
    procedure AfterLoadFromJSON; override;
    procedure BeforeSaveToJSON; override;
    procedure AfterSaveToJSON; override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ExampleCustomerForm: TExampleCustomerForm;

implementation

{$R *.fmx}

procedure TExampleCustomerForm.FormCreate(Sender: TObject);
begin
  inherited;
  
  // Populate ComboBox with sample data
  ComboBoxCity.Items.Clear;
  ComboBoxCity.Items.Add('Istanbul');
  ComboBoxCity.Items.Add('Ankara');
  ComboBoxCity.Items.Add('Izmir');
  ComboBoxCity.Items.Add('Bursa');
  ComboBoxCity.Items.Add('Antalya');
  
  // Set default values
  DateEditRegistration.Date := Now;
  TimeEditPreferredContactTime.Time := Now;
  SpinBoxRating.Min := 0;
  SpinBoxRating.Max := 10;
  SpinBoxRating.Value := 5;
  NumberBoxAge.Min := 0;
  NumberBoxAge.Max := 150;
end;

procedure TExampleCustomerForm.ButtonSaveClick(Sender: TObject);
begin
  if SaveRecord then
  begin
    ShowMessage('Kayıt başarıyla kaydedildi!' + sLineBreak +
                'Kayıt ID: ' + VarToStr(GetCurrentRecordID));
  end
  else
  begin
    ShowMessage('Kayıt sırasında hata oluştu!');
  end;
end;

procedure TExampleCustomerForm.ButtonNewClick(Sender: TObject);
begin
  NewRecord;
  ShowMessage('Yeni kayıt modu - Form temizlendi');
end;

procedure TExampleCustomerForm.ButtonDeleteClick(Sender: TObject);
begin
  if IsNewRecord then
  begin
    ShowMessage('Henüz kaydedilmemiş bir kayıt silinemez!');
    Exit;
  end;
  
  if MessageDlg('Kaydı silmek istediğinizden emin misiniz?', 
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    if DeleteRecord then
      ShowMessage('Kayıt başarıyla silindi!')
    else
      ShowMessage('Silme sırasında hata oluştu!');
  end;
end;

procedure TExampleCustomerForm.ButtonLoadClick(Sender: TObject);
var
  RecordID: Integer;
begin
  if TryStrToInt(EditLoadID.Text, RecordID) then
  begin
    if LoadRecord(RecordID) then
      ShowMessage('Kayıt başarıyla yüklendi!')
    else
      ShowMessage('Kayıt bulunamadı veya yükleme sırasında hata oluştu!');
  end
  else
  begin
    ShowMessage('Geçerli bir ID giriniz!');
  end;
end;

procedure TExampleCustomerForm.ButtonShowJSONClick(Sender: TObject);
var
  JSONData: string;
begin
  JSONData := SaveToJSON;
  ShowMessage('Mevcut Form Verileri (JSON):' + sLineBreak + sLineBreak + JSONData);
end;

procedure TExampleCustomerForm.BeforeLoadFromJSON;
begin
  inherited;
  // JSON yüklenmeden önce yapılacak işlemler
  // Örneğin: validasyon, ön hazırlık, vb.
end;

procedure TExampleCustomerForm.AfterLoadFromJSON;
begin
  inherited;
  // JSON yüklendikten sonra yapılacak işlemler
  // Örneğin: hesaplamalar, görsel güncellemeler, vb.
end;

procedure TExampleCustomerForm.BeforeSaveToJSON;
begin
  inherited;
  // JSON oluşturulmadan önce yapılacak işlemler
  // Örneğin: validasyon, veri temizleme, vb.
end;

procedure TExampleCustomerForm.AfterSaveToJSON;
begin
  inherited;
  // JSON oluşturulduktan sonra yapılacak işlemler
  // Örneğin: loglama, bildirim, vb.
end;

end.
