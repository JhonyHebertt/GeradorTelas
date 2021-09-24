object uGeradorTelas: TuGeradorTelas
  Left = 0
  Top = 0
  Caption = 'Gerador de Telas'
  ClientHeight = 399
  ClientWidth = 328
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 16
    Width = 312
    Height = 41
    Caption = 'Gerar Controller Horse'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 63
    Width = 312
    Height = 41
    Caption = 'Gerar Arquivos React JS'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 120
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Sair'
    TabOrder = 2
    OnClick = Button3Click
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=delphireact'
      'User_Name=admin'
      'Password=admin777'
      'Server=delphireact.cm7ojuhyicsr.sa-east-1.rds.amazonaws.com'
      'DriverID=MySQL')
    Left = 176
    Top = 152
  end
end
