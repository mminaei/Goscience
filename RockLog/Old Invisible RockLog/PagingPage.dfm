object paging: Tpaging
  Left = 364
  Top = 347
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Paging'
  ClientHeight = 170
  ClientWidth = 115
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 18
    Top = 8
    Width = 79
    Height = 33
    Caption = 'First Page <<<<'
    TabOrder = 0
    WordWrap = True
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 18
    Top = 48
    Width = 79
    Height = 33
    Caption = 'Previous Page  <<'
    TabOrder = 1
    WordWrap = True
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 18
    Top = 88
    Width = 79
    Height = 33
    Caption = 'Next Pag     >>'
    Default = True
    TabOrder = 2
    WordWrap = True
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 18
    Top = 128
    Width = 79
    Height = 33
    Caption = 'Last Page >>>>'
    TabOrder = 3
    WordWrap = True
    OnClick = Button4Click
  end
end
