//Bismillahirrahmanirrahim.

//   بِسْمِ ٱللهِ ٱلرَّحْمَٰنِ ٱلرَّحِيْمِ

unit uMainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, EnhancedExampleForm,
  ExampleCustomerForm,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client;

type
  TMenuForm = class(TForm)
    ButtonEnhanced: TButton;
    ButtonCustomer: TButton;
    FDConnection1: TFDConnection;
    procedure ButtonEnhancedClick(Sender: TObject);
    procedure ButtonCustomerClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MenuForm: TMenuForm;

implementation

{$R *.fmx}

const
  DB_TABLE_NAME      = 'customers';
  DB_PRIMARY_KEY     = 'ID';
  DB_UIJSON_FIELD    = 'UIJSON';

procedure TMenuForm.ButtonEnhancedClick(Sender: TObject);
var
  Frm: TEnhancedExampleForm;
begin
  Frm := TEnhancedExampleForm.Create(Self, FDConnection1, DB_TABLE_NAME, DB_PRIMARY_KEY, DB_UIJSON_FIELD);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

procedure TMenuForm.ButtonCustomerClick(Sender: TObject);
var
  Frm: TExampleCustomerForm;
begin
  Frm := TExampleCustomerForm.Create(Self, FDConnection1, DB_TABLE_NAME, DB_PRIMARY_KEY, DB_UIJSON_FIELD);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

end.
