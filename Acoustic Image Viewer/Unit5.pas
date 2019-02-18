unit Unit5;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ESBPCSEdit, ESBPCSNumEdit;

type
  TForm5 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ESBPosFloatEdit1: TESBPosFloatEdit;
    ESBPosFloatEdit2: TESBPosFloatEdit;
    Label7: TLabel;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    ESBPosFloatEdit3: TESBPosFloatEdit;
    ESBPosFloatEdit4: TESBPosFloatEdit;
    procedure BitBtn2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

uses Unit1;

{$R *.DFM}

procedure TForm5.BitBtn2Click(Sender: TObject);
begin
Form1.Canceled:=True;
end;

procedure TForm5.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
if not Form1.Canceled then
  begin
    Form1.Max_Value3:=ESBPosFloatEdit1.AsFloat;
    Form1.Min_Value3:=ESBPosFloatEdit2.AsFloat;
    Form1.Max_Value4:=ESBPosFloatEdit3.AsFloat;
    Form1.Min_Value4:=ESBPosFloatEdit4.AsFloat;
  end;
end;

end.
