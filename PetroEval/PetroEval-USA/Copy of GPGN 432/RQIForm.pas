unit RQIForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TRQI_Form = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Edit1: TEdit;
    Button3: TButton;
    GroupBox4: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    Edit2: TEdit;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RQI_Form: TRQI_Form;

implementation

uses Main_Form, SelectLog;

{$R *.dfm}

procedure TRQI_Form.Button1Click(Sender: TObject);
var
Temp_Value: Extended;
Error_Code:Integer;
begin
  with MainForm do
    begin
      Operation_Canceled:=False;
      Value_Is_Constant[1]:=RadioButton1.Checked;
      Value_Is_Constant[2]:=RadioButton3.Checked;
      if Value_Is_Constant[1] then
        begin
          Val(Edit1.Text, Temp_Value, Error_Code);
          if Error_Code=0 then
            Constant_Value[1]:=Temp_Value
          else
            begin
              MessageDlg('Please enter a valid number for effective porosity!', mtError, [mbOk], 0);
              Exit;
            end;
          PHI_Track_Number:=-1;
        end;
      if Value_Is_Constant[2] then
        begin
          Val(Edit2.Text, Temp_Value, Error_Code);
          if Error_Code=0 then
            Constant_Value[2]:=Temp_Value
          else
            begin
              MessageDlg('Please enter a valid number for permeability!', mtError, [mbOk], 0);
              Exit;
            end;
          Kh_Track_Number:=-1;
        end;
    end;
  Close;
end;

procedure TRQI_Form.Button2Click(Sender: TObject);
begin
  MainForm.Operation_Canceled:=True;
  Close;
end;

procedure TRQI_Form.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=True;
  with MainForm do
    begin
      if (not(Operation_Canceled))and(PHI_Track_Number=-1)and(not(Value_Is_Constant[1])) then
        begin
          CanClose:=False;
          MessageDlg('Please select a track for porosity!', mtWarning,[mbOk],0);
          Exit;
        end;
      if (not(Operation_Canceled))and(Kh_Track_Number=-1)and(not(Value_Is_Constant[2])) then
        begin
          CanClose:=False;
          MessageDlg('Please select a track for permeability!', mtWarning,[mbOk],0);
          Exit;
        end;
    end;
end;

procedure TRQI_Form.Button3Click(Sender: TObject);
begin
  Select_Log:=TSelect_Log.Create(Self);
  Select_Log.ShowModal;
  MainForm.PHI_Track_Number:=Select_Log.Selected_Track_Number;
  if Select_Log.Selected_Track_Number<>-1 then
    begin
      MainForm.PHI_Track_Number:=Select_Log.Selected_Track_Number;
      Label2.Caption:=MainForm.Charts[MainForm.PHI_Track_Number].Axes.Top.Title.Caption;
    end;
  Select_Log.Free;
end;

procedure TRQI_Form.Button4Click(Sender: TObject);
begin
  Select_Log:=TSelect_Log.Create(Self);
  Select_Log.ShowModal;
  MainForm.Kh_Track_Number:=Select_Log.Selected_Track_Number;
  if Select_Log.Selected_Track_Number<>-1 then
    begin
      MainForm.Kh_Track_Number:=Select_Log.Selected_Track_Number;
      Label4.Caption:=MainForm.Charts[MainForm.Kh_Track_Number].Axes.Top.Title.Caption;
    end;
  Select_Log.Free;
end;

procedure TRQI_Form.RadioButton2Click(Sender: TObject);
begin
  Edit1.Enabled:=RadioButton1.Checked;
  Edit1.Color:=clBtnFace;
  Button3.Enabled:=RadioButton2.Checked;
  if MainForm.PHI_Track_Number<>-1 then
    begin
      Label2.Caption:=MainForm.Charts[MainForm.PHI_Track_Number].Axes.Top.Title.Caption;
    end;
end;

procedure TRQI_Form.RadioButton1Click(Sender: TObject);
begin
  Edit1.Enabled:=RadioButton1.Checked;
  Edit1.Color:=clWindow;
  Button3.Enabled:=RadioButton2.Checked;
  Label2.Caption:='NONE';
  Edit1.SetFocus;
end;

procedure TRQI_Form.RadioButton4Click(Sender: TObject);
begin
  Edit2.Enabled:=RadioButton3.Checked;
  Edit2.Color:=clBtnFace;
  Button4.Enabled:=RadioButton4.Checked;
  if MainForm.Kh_Track_Number<>-1 then
    begin
      Label4.Caption:=MainForm.Charts[MainForm.Kh_Track_Number].Axes.Top.Title.Caption;
    end;
end;

procedure TRQI_Form.RadioButton3Click(Sender: TObject);
begin
  Edit2.Enabled:=RadioButton3.Checked;
  Edit2.Color:=clWindow;
  Button4.Enabled:=RadioButton4.Checked;
  Label4.Caption:='NONE';
  Edit2.SetFocus;
end;


end.
