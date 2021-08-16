object Downloader: TDownloader
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Downloader msg_audio from VK'
  ClientHeight = 289
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label_Status: TLabel
    Left = 8
    Top = 93
    Width = 35
    Height = 13
    Caption = 'Status:'
  end
  object Status: TLabel
    Left = 45
    Top = 93
    Width = 78
    Height = 13
    Caption = 'not authorized..'
  end
  object Label1: TLabel
    Left = 3
    Top = 210
    Width = 34
    Height = 13
    Caption = #1055#1086#1080#1089#1082':'
  end
  object Label2: TLabel
    Left = 57
    Top = 233
    Width = 6
    Height = 13
    Caption = '0'
  end
  object LoginEdit: TEdit
    Left = 8
    Top = 8
    Width = 545
    Height = 21
    TabOrder = 0
  end
  object PassEdit: TEdit
    Left = 8
    Top = 35
    Width = 545
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
  end
  object AuthBtn: TButton
    Left = 8
    Top = 62
    Width = 545
    Height = 25
    Caption = 'Auth'
    TabOrder = 2
    OnClick = AuthBtnClick
  end
  object Button2: TButton
    Left = 8
    Top = 145
    Width = 161
    Height = 25
    Caption = 'Save all msg_audio to mp3'
    Enabled = False
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button1: TButton
    Left = 7
    Top = 114
    Width = 161
    Height = 25
    Caption = 'Take all messages with:'
    Enabled = False
    TabOrder = 4
    OnClick = Button1Click
  end
  object ListBox1: TListBox
    Left = 174
    Top = 145
    Width = 378
    Height = 139
    Enabled = False
    ItemHeight = 13
    TabOrder = 5
    OnClick = ListBox1Click
  end
  object Edit1: TEdit
    Left = 52
    Top = 207
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 6
    OnChange = Edit1Change
  end
  object Edit2: TEdit
    Left = 175
    Top = 116
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 7
  end
  object Button3: TButton
    Left = 8
    Top = 176
    Width = 160
    Height = 25
    Caption = 'Save all msg_photo to jpg'
    Enabled = False
    TabOrder = 8
    OnClick = Button3Click
  end
  object CheckBox1: TCheckBox
    Left = 302
    Top = 122
    Width = 155
    Height = 17
    Caption = #1057#1088#1072#1079#1091' '#1089#1086#1093#1088#1072#1085#1103#1090#1100' '#1074' '#1092#1072#1081#1083'?'
    TabOrder = 9
  end
end
