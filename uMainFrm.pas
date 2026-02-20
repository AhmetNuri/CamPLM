//Bismillahirrahmanirrahim.

//   بِسْمِ ٱللهِ ٱلرَّحْمَٰنِ ٱلرَّحِيْمِ

unit uMainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, EnhancedExampleForm,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client;

type
  TForm6 = class(TForm)
    Button1: TButton;
    FDConnection1: TFDConnection;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.fmx}

procedure TForm6.Button1Click(Sender: TObject);
begin
   FrmEnhancedExampleForm := TEnhancedExampleForm.Create(self,FDConnection1,'if','1');
    try
    FrmEnhancedExampleForm.ShowModal;
   finally
     FrmEnhancedExampleForm.Free;
   end;

end;

end.
