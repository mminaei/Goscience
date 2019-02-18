unit Unit1;

interface

uses
  SysUtils, StrUtils, Classes, Forms, Windows, Math,
  Dialogs, Menus, ComCtrls, StdCtrls, Controls, ToolWin, ExtCtrls, DB, DBTables,
  Grids, DBGrids;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Edit1: TMenuItem;
    View1: TMenuItem;
    About1: TMenuItem;
    StatusBar1: TStatusBar;
    OpenDialog1: TOpenDialog;
    Open1: TMenuItem;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DataSource2: TDataSource;
    DBGrid2: TDBGrid;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    LAS1: TMenuItem;
    ext1: TMenuItem;
    Exit1: TMenuItem;
    procedure ReadLAS(File_Name: string);
    procedure ChangePath;
    procedure LAS1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



  TLASFile = class(TObject)
  private
    { Private declarations }
  public
     FileName              :String ;
     LASVersion            :ShortString ;
     IsWrapped             :Boolean ;
     DLMChar               :Char ;
     StartValue            :Single ;
     StopValue             :Single ;
     StepValue             :Single ;
     NullValue             :Single;
     DepthUnit             :ShortString ;
     NoTracks              :Byte;
     NoColumns             :Integer;
     NoLinesPerDepth       :Shortint;
     NoRecords             :Integer;
     DataStartLineNo       :Integer;
     Properties            :TTable;
     Values                :TTable;
    { Public declarations }
  end;

var
  Form1: TForm1;
  Lines: TStringList;
  LasFiles: array of TLASFile;
  File_Opened:Boolean;
  Files: array of TFileName;

implementation


{$R *.dfm}

procedure TForm1.ReadLAS(File_Name: string);
var
i,j,k,m,n: integer;
p1,p2,p3:Smallint;
s1,s2,s3,s4:string;
Depth_Value:Single;
Log_Value:Single;
OneChar: Char;
Temp_Integer:integer;
Int1,Int2,Int3:integer;
NVS, LGS: String;
begin
with LasFiles[Length(LasFiles)-1] do
  begin
    File_Opened:=False;
  try
(********* Get file name without its complete path *)
    s1:=ReverseString(File_Name);
    p1:=Pos('\',s1);
    s1:=ReverseString(s1);
    p2:=Length(s1)-p1+2;
    s2:=Copy(s1,p2,p1);
    FileName:=s2;
(**********Load file into the memory*********)
    Lines:=TStringList.Create;
    Lines.LoadFromFile(File_Name);
(**********To find version number *********)
    for i:=0 to Lines.Count-1 do
      begin
        s1:=Trim(Lines[i]);
        p1:=Pos('VERS',s1);
          if (p1<>0)then Break;
      end;
    j:=i;
    s1:=(Lines[j]);
    s1:=Trim(s1);
    m:=Pos('.',s1);
    n:=PosEx(':', s1, m);
    s2:=Copy(s1,m+1,n-m-1);
    s2:=Trim(UpperCase(s2));
    LASVersion:=s2;
(**********To find if it is wrapped *********)
    for i:=j to Lines.Count-1 do
      begin
        s1:=(Lines[i]);
        p1:=Pos('WRAP',s1);
        if (p1<>0)then Break;
      end;
    j:=i;
    s1:=(Lines[j]);
    s1:=Trim(s1);
    m:=Pos('.',s1);
    n:=PosEx(':', s1, m);
    s2:=Copy(s1,m+1,n-m-1);
    s2:=Trim(UpperCase(s2));
    if UpperCase(s2)='YES' then
      IsWrapped:=True
    else
      IsWrapped:=False;
  (********* To find DLM character *********************)
    for i:=j to Lines.Count-1 do
      begin
        s1:=(Lines[i]);
        p1:=Pos('DLM',s1);
        p2:=Pos('~W',s1);
        if (p1<>0)or(p2<>0) then Break;
      end;
    j:=i;
    s1:=(Lines[j]);
    s1:=Trim(s1);
    m:=Pos('.',s1);
    n:=PosEx(':', s1, m);
    s2:=Copy(s1,m+1,n-m-1);
    s2:=Trim(UpperCase(s2));
    if s2='COMMA' then DLMChar:=','
    else if s2='SPACE' then DLMChar:=' '
    else if s2='TAB' then DLMChar:=#9
    else DLMChar:=' ';
(********* To find start value *********************)
    for i:=j to Lines.Count-1 do
        begin
        s1:=(Lines[i]);
        p1:=Pos('STRT',s1);
        if p1<>0 then Break;
        end;
    j:=i;
    s1:=Trim(Lines[j]);

//  To find depth units
    m:=Pos('.',s1);
    s2:=Copy(s1,m+1,1);
    DepthUnit:=UpperCase(s2);
//
    p3:=0;
    p2:=0;
    p1:=PosEx(' ',s1, m);
    for k := p1 to Length(s1) do
      begin
        OneChar:=s1[k];
        if OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+'] then
          begin
            p2:=k;
            Break;
          end;
      end;
    for k := p2 to Length(s1) do
      begin
        OneChar:=s1[k];
        if not(OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+']) then
          begin
            p3:=k;
            Break;
          end;
      end;
    s2:=Copy(s1,p2,p3-p2);
    s2:=Trim(s2);
    StartValue:=StrToFloat(s2);
(********* To find stop value *********************)
    for i:=j to Lines.Count-1 do
      begin
          s1:=(Lines[i]);
        p1:=Pos('STOP',s1);
        if p1<>0 then Break;
      end;
    j:=i;
    s1:=(Lines[j]);
    p3:=0;
    p2:=0;
    m:=Pos('.',s1);
    p1:=PosEx(' ',s1, m);
    for k := p1 to Length(s1) do
      begin
        OneChar:=s1[k];
        if OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+'] then
          begin
            p2:=k;
            Break;
          end;
      end;
    for k := p2 to Length(s1) do
      begin
        OneChar:=s1[k];
        if not(OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+']) then
          begin
            p3:=k;
            Break;
          end;
      end;
    s2:=Copy(s1,p2,p3-p2);
    s2:=Trim(s2);
    StopValue:=StrToFloat(s2);
(********* To find step value *********************)
    for i:=j to Lines.Count-1 do
      begin
        s1:=(Lines[i]);
        p1:=Pos('STEP',s1);
        if p1<>0 then Break;
      end;
    j:=i;
    s1:=Trim(Lines[j]);
    p3:=0;
    p2:=0;
    m:=Pos('.',s1);
    p1:=PosEx(' ',s1, m);
    for k := p1 to Length(s1) do
      begin
        OneChar:=s1[k];
       if OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+'] then
         begin
           p2:=k;
           Break;
         end;
     end;
    for k := p2 to Length(s1) do
      begin
        OneChar:=s1[k];
        if not(OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+']) then
          begin
            p3:=k;
            Break;
          end;
      end;
    s2:=Copy(s1,p2,p3-p2);
    s2:=Trim(s2);
    StepValue:=StrToFloat(s2);
(********* To find number of records *********************)
    NoRecords:=Trunc(ABS((StartValue-StopValue) / StepValue)) + 1;
(********* To find null value *********************)
    for i:=j to Lines.Count-1 do
      begin
        s1:=(Lines[i]);
        p1:=Pos('NULL',s1);
        if p1<>0 then Break;
      end;
    j:=i;
    s1:=Trim(Lines[j]);
    p3:=0;
    p2:=0;
    p1:=Pos('.',s1);
    for k := p1+1 to Length(s1) do
      begin
        OneChar:=s1[k];
        if OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+'] then
          begin
            p2:=k;
            Break;
          end;
      end;
    for k := p2 to Length(s1) do
      begin
        OneChar:=s1[k];
        if not(OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+']) then
          begin
            p3:=k;
            Break;
          end;
      end;
    s2:=Copy(s1,p2,p3-p2);
    s2:=Trim(s2);
    NullValue:=StrToFloat(s2);
    NVS:=FloatToStr(NullValue);
(*******************To find number of tracks ***********)
    for i:=j+1 to Lines.Count-1 do
      begin
        s1:=Trim(Lines[i]);
        p1:=Pos('~C',s1);
        p2:=Pos('~LOG_DEFINITION', s1);
        if (p1<>0)or(p2<>0) then Break;
      end;
    k:=i;
    Temp_Integer:=0;
    for j := k+1 to Lines.Count - 1 do
      begin
        s1:=Trim(Lines[j]);
        if (s1<>' ')and(s1<>'') then
          begin
            s2:=s1[1];
            if (s2<>'~')and(s2<>'#') then
              begin
                Inc(Temp_Integer);
                s3:=Lines[j+1];
                if (s3<>' ')and(s3<>'') then
                  begin
                    s4:=s3[1];
                    if (s4='~')or(s4='#') then
                      Break;
                  end
                else
                  Break;
              end;
          end;
      end;
    NoTracks:=Temp_Integer;
    if IsWrapped then
      NoLinesPerDepth:=Trunc((NoTracks-1)/6)+1
    else
      NoLinesPerDepth:=1;
(*******************To find tracks names and units ***********)
    j:=k+1;
    Properties.Edit;
    k:=0;
    repeat
      try
(* To find track name *)
        s1:=Trim(Lines[j]);
        if (s1<>' ')and(s1<>'') then
          begin
            s2:=Trim(s1[1]);
            if (s2='#')or(s2='')or(s2='~') then
              begin
                Inc(j);
                Continue;
              end;
          end
        else
          begin
            Inc(j);
            Continue;
          end;
        p1:=Pos('.', s1);
        s2:= Copy( s1, 1, p1-1);
        Properties.Append;
        Properties.Fields[0].Value:=Trim(s2);
        Values.FieldDefs.Add(Trim(s2), ftFloat, 0, False);
(* to find track unit  *)
        p1:=Pos('.', s1);
        p2:=PosEx(' ', s1, p1);
        s2:= Copy( s1, p1+1, p2-p1);
        Properties.Fields[1].Value:=Trim(s2);
        Properties.Fields[2].Value:=-99999999;
        Properties.Fields[3].Value:=99999999;
        Inc(j);
        Inc(k);
      except
        on E:EdataBaseError do
          begin
            MessageDlg('Field '+s2+' already exists.'+#13+'Please check your file.', mtError, [mbok], 0);
            Values.FieldDefs.Add(Trim(s2)+IntToStr(k), ftFloat, 0, False);
            p1:=Pos('.', s1);
            p2:=PosEx(' ', s1, p1);
            s2:= Copy( s1, p1+1, p2-p1);
            Properties.Fields[1].Value:=Trim(s2);
            Properties.Fields[2].Value:=-99999999;
            Properties.Fields[3].Value:=99999999;
            Inc(j);
            Inc(k);
          end;
      end;
    until k=NoTracks;
    Values.CreateTable;
    Values.Open;
    Properties.First;
    for n := 0 to NoTracks-1 do
      begin
        s1:=Properties.FieldByName('TRACK_NAME').AsString+'.'+Properties.FieldByName('TRACK_UNIT').AsString;
        Values.Fields[n].DisplayLabel:=s1;
        Properties.Next;
      end;
    Values.Open;
    Values.First;
(**************** Reading file data ************************)
    for k:=j-2 to Lines.Count-1 do
      begin
        s1:=Trim(Lines[k]);
        p1:=Pos('~A',s1);
        p2:=Pos('~LOG_DATA',s1);
        if (p1<>0)or(p2<>0) then
          begin
            DataStartLineNo:=k+1;
            Break;
          end;
      end;

 {
  j:=StrToInt(No_Lines_Skip)-1;
  s1:=(Lines[j]);
  p3:=1;
  p2:=0;
  p1:=1;
  m:=0;
  s3:='';
  repeat
    for k := p3 to Length(s1) do
      begin
        OneChar:=s1[k];
        if OneChar<>DLMChar then   //['0','1','2','3','4','5','6','7','8','9','.','-','+'] then
          begin
            p2:=k;
            Break;
          end;
      end;
    for k := p2 to Length(s1) do
      begin
        OneChar:=s1[k];
        if OneChar=DLMChar then //['0','1','2','3','4','5','6','7','8','9','.','-','+']) then
          begin
            p3:=k;
            Break;
          end;
      end;
    if p2>p3 then
      begin
        p3:=Length(s1)+1;
        s3:='FINISHED';
      end;
    s2:=Copy(s1,p2,p3-p2);
    s2:=Trim(s2);
    Child_Name:=s2;
    p2:=Pos('DEPT', UpperCase(s2));
    if ((p2=0)and(s2<>'')) then
      begin
        Preparation(Root_Name, Child_Name, DepthUnit_String,StrToFloat(Step_Value_String),StrToFloat(Null_Value_String));
        m:=m+1;
      end;
  until s3='FINISHED';
}



   n:=0;
   Values.DisableControls;
   Properties.DisableControls;
// If the LAS file is not wrapped, version 1.1, 2 and 3
   if not IsWrapped then
     begin
       for i := 0 to NoRecords-1 do
         begin
           s1:=Trim(Lines[DataStartLineNo+i]);
           Properties.First;
           p3:=1;
           Values.Edit;
           Values.Append;
           for j:=0 to NoTracks-1 do
             begin
               for k := p3 to Length(s1) do
                 begin
                   OneChar:=s1[k];
                   if not(OneChar in [DLMChar,' ']) then//['0','1','2','3','4','5','6','7','8','9','.','-','+'] then
                     begin
                       p2:=k;
                       Break;
                     end;
                 end;
               for k := p2 to Length(s1) do
                 begin
                   OneChar:=s1[k];
                   if OneChar in [DLMChar,' '] then//not(OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+']) then
                     begin
                       p3:=k;
                       Break;
                     end;
                 end;
               if p2>p3 then
                 p3:=Length(s1);
               s2:=Copy(s1,p2,p3-p2);
               s2:=Trim(s2);
               Log_Value:=StrToFloat(Trim(s2));
               LGS:=FloatToStr(Log_Value);
               Values.Fields[j].AsString:=Trim(s2);
               Properties.Edit;
               if LGS<>NVS then
                 begin
                   if Log_Value>Properties.Fields[2].AsFloat then
                     Properties.Fields[2].AsFloat:=RoundTo(Log_Value, -4);
                   if Log_Value<Properties.Fields[3].AsFloat then
                     Properties.Fields[3].AsFloat:=RoundTo(Log_Value, -4);
                 end;
               Properties.Next;
             end;
         end;
     end
// if it is wrapped
   else
     begin
       try
         NoColumns:=0;
         NoColumns:=StrToInt(InputBox('Number of Columns', 'Your LAS file is wrapped:'+#13+'File: '+FileName+#13+'Please enter number of columns in the file:', '0'));
         if NoColumns=0 then
           Exit;
       except
         on E:EConvertError do
           begin
             MessageDlg(E.Message+#13+'The program will continue with 6 columns', mtError, [MbOk], 0);
             NoColumns:=6;
           end;
       end;
       for i := 0 to NoRecords-1 do
         begin
           s1:=Trim(Lines[DataStartLineNo+n]);
           Inc(n);
           for k := 0 to Length(s1) do
             begin
               OneChar:=s1[k];
               if not(OneChar in [DLMChar,' ']) then//OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+'] then
                 begin
                   p2:=k;
                   Break;
                 end;
             end;
           for k := p2 to Length(s1) do
             begin
               OneChar:=s1[k];
               if OneChar in [DLMChar,' '] then//not(OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+']) then
                 begin
                   p3:=k;
                   Break;
                 end;
             end;
           if p2>p3 then
             p3:=Length(s1);
           s2:=Copy(s1,p2,p3-p2);
           s2:=Trim(s2);
           Log_Value:=StrToFloat(Trim(s2));
           LGS:=FloatToStr(Log_Value);
           Values.Edit;
           Values.Append;
           Values.Fields[0].AsString:=s2;
           Properties.First;
           Properties.Edit;
           if LGS<>NVS then
             begin
               if Log_Value>Properties.Fields[2].AsFloat then
                 Properties.Fields[2].AsFloat:=RoundTo(Log_Value, -4);
               if Log_Value<Properties.Fields[3].AsFloat then
                 Properties.Fields[3].AsFloat:=RoundTo(Log_Value, -4);
             end;
           Properties.Next;
           for m := 1 to NoLinesPerDepth-1 do
             begin
               s1:=Trim(Lines[DataStartLineNo+n]);
               Inc(n);
               p3:=0;
               for j:=1 to NoColumns do
                 begin
                   for k := p3 to Length(s1) do
                     begin
                       OneChar:=s1[k];
                       if not(OneChar in [DLMChar,' ']) then//OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+'] then
                         begin
                           p2:=k;
                           Break;
                         end;
                     end;
                   for k := p2 to Length(s1) do
                     begin
                       OneChar:=s1[k];
                       if OneChar in [DLMChar,' '] then//not(OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+']) then
                         begin
                           p3:=k;
                           Break;
                         end;
                     end;
                   if p2>p3 then
                     p3:=Length(s1);
                   s2:=Copy(s1,p2,p3-p2);
                   s2:=Trim(s2);
                   Log_Value:=StrToFloat(Trim(s2));
                   LGS:=FloatToStr(Log_Value);
                   Values.Fields[(m-1)*6+j].AsString:=s2;
                   Properties.Edit;
                   if LGS<>NVS then
                     begin
                       if Log_Value>Properties.Fields[2].AsFloat then
                         Properties.Fields[2].AsFloat:=RoundTo(Log_Value, -4);
                       if Log_Value<Properties.Fields[3].AsFloat then
                         Properties.Fields[3].AsFloat:=RoundTo(Log_Value, -4);
                     end;
                   Properties.Next;
                 end;
             end;
// Last Line for wrapped file
           Temp_integer:=(NoTracks-1) mod NoColumns;
           if Temp_Integer<>0 then
             begin
               s1:=Trim(Lines[DataStartLineNo+n]);
               Inc(n);
               for j:=1 to ((NoTracks-1) mod NoColumns) do
                 begin
                   for k := 0 to Length(s1) do
                     begin
                       OneChar:=s1[k];
                       if not(OneChar in [DLMChar,' ']) then//OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+'] then
                         begin
                           p2:=k;
                           Break;
                         end;
                     end;
                   for k := p2 to Length(s1) do
                     begin
                       OneChar:=s1[k];
                       if OneChar in [DLMChar,' '] then//not(OneChar in ['0','1','2','3','4','5','6','7','8','9','.','-','+']) then
                         begin
                           p3:=k;
                           Break;
                         end;
                     end;
                   if p2>p3 then
                     p3:=Length(s1);
                   s2:=Copy(s1,p2,p3-p2);
                   s2:=Trim(s2);
                   Log_Value:=StrToFloat(Trim(s2));
                   LGS:=FloatToStr(Log_Value);
                   Values.Fields[(NoLinesPerDepth-1)*6+j].AsString:=s2;
                   Properties.Edit;
                   if LGS<>NVS then
                     begin
                       if Log_Value>Properties.Fields[2].AsFloat then
                         Properties.Fields[2].AsFloat:=RoundTo(Log_Value, -4);
                       if Log_Value<Properties.Fields[3].AsFloat then
                         Properties.Fields[3].AsFloat:=RoundTo(Log_Value, -4);
                     end;
                   Properties.Next;
                 end;
             end;
         end;
     end;
(***********************************************************)
    Lines.Free;
    Values.Edit;
    Values.Post;
    Properties.Edit;
    Properties.Post;
    DataSource1.DataSet:=Properties;
    DataSource2.DataSet:=Values;
    Values.EnableControls;
    Properties.EnableControls;
  except
    Lines.Free;
    Values.Edit;
    Values.Post;
    Properties.Edit;
    Properties.Post;
    DataSource1.DataSet:=Properties;
    DataSource2.DataSet:=Values;
    Values.Close;
    Properties.Close;
    Values.EnableControls;
    Properties.EnableControls;
  end;
end;
end;

procedure TForm1.Exit1Click(Sender: TObject);
var
i:integer;
begin
//  for I := 0 to Length(LasFiles) - 1 do
//    LasFiles[i].Free;
//  DeleteFile(OpenDialog1.FileName);
  Close;
end;

procedure TForm1.LAS1Click(Sender: TObject);
var
i: Smallint;
s1,s2:string;
p1,p2:integer;
File_Name:string;
begin
try
  with OpenDialog1 do
    begin
      DefaultExt:='LAS';
      Filter:='LAS files|*.LAS';
      Title:='Open LAS files';
    end;
  if OpenDialog1.Execute then
    begin
      for i:=0 to OpenDialog1.Files.Count-1 do
        begin
          StatusBar1.Panels[0].Text:='Reading file(s) data. Please wait ...';
          Repaint;
          s1:=ReverseString(OpenDialog1.Files[i]);
          p1:=Pos('\',s1);
          s1:=ReverseString(s1);
          p2:=Length(s1)-p1+2;
          s2:=Copy(s1,p2,p1-5);
          File_Name:=s2;
          ChangePath;
//          SetLength(Files, Length(Files)+1);
//          Files[Length(Files)]:=OpenDialog1.FileName[i];
          try
            SetLength(LASFiles, Length(LASFiles)+1);
            LASFiles[Length(LASFiles)-1]:=TLASFile.Create;
            ChangePath;
            with LasFiles[Length(LASFiles)-1] do
              begin
                Properties:=TTable.Create(Self);
                Properties.TableName:=File_Name+'_Properties'+'.DB';
                Properties.FieldDefs.Add('TRACK_NAME', ftString, 10, False);
                Properties.FieldDefs.Add('TRACK_UNIT', ftString, 7, False);
                Properties.FieldDefs.Add('MAX_VALUE', ftFloat, 0, False);
                Properties.FieldDefs.Add('MIN_VALUE', ftFloat, 0, False);
                Properties.CreateTable;
                Properties.Open;
                Values:=TTable.Create(Self);
                Values.TableName:=File_Name+'_Values'+'.DB';
              end;
            ReadLAS(OpenDialog1.Files[i]);
          except
            MessageDlg('Error occured while reading '+#13+OpenDialog1.FileName[i], mtError, [mbOk], 0);
            Continue;
          end;
        end;
      StatusBar1.Panels[0].Text:='Ready';
    end;
finally
  StatusBar1.Panels[0].Text:='Ready.';
end;
end;

procedure TForm1.ChangePath;
var
Pat, Path:String;
P:integer;
begin
  Pat:=Application.ExeName;
  P:=Pos('Project1.exe',Pat);
  if P=0 then
    P:=Pos('PROJECT1.EXE',Pat);
  Path := Copy(Pat, 1, P - 1);
  ChDir(Path);
end;

end.
