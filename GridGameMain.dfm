object Form1: TForm1
  Left = 0
  Top = 0
  ClientHeight = 603
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Segoe UI'
  Font.Style = []
  WindowState = wsMaximized
  DesignSize = (
    624
    603)
  TextHeight = 25
  object Label1: TLabel
    Left = 19
    Top = 554
    Width = 34
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Size'
  end
  object Label2: TLabel
    Left = 347
    Top = 554
    Width = 261
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Grid Game by Daniel Marschall'
  end
  object Button1: TButton
    Left = 186
    Top = 554
    Width = 138
    Height = 35
    Anchors = [akLeft, akBottom]
    Caption = 'New game'
    TabOrder = 0
    OnClick = Button1Click
  end
  object SpinEdit1: TSpinEdit
    Left = 59
    Top = 554
    Width = 121
    Height = 35
    Anchors = [akLeft, akBottom]
    MaxValue = 14
    MinValue = 2
    TabOrder = 1
    Value = 6
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 608
    Height = 532
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'Play'
      object ScrollBox1: TScrollBox
        Left = 41
        Top = 41
        Width = 518
        Height = 410
        Align = alClient
        Color = 4227072
        ParentColor = False
        TabOrder = 0
        ExplicitLeft = 123
        ExplicitTop = 56
        ExplicitWidth = 256
        ExplicitHeight = 281
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 600
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        Caption = #9824#8595
        Color = clBlack
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -27
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 1
        ExplicitLeft = 56
        ExplicitTop = 232
        ExplicitWidth = 185
      end
      object Panel2: TPanel
        Left = 0
        Top = 451
        Width = 600
        Height = 41
        Align = alBottom
        BevelOuter = bvNone
        Caption = #9827#8593
        Color = clBlack
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -27
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 2
        ExplicitTop = 8
      end
      object Panel3: TPanel
        Left = 0
        Top = 41
        Width = 41
        Height = 410
        Align = alLeft
        BevelOuter = bvNone
        Caption = #9830#8594
        Color = clMaroon
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -27
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 3
        ExplicitTop = 407
        ExplicitHeight = 600
      end
      object Panel4: TPanel
        Left = 559
        Top = 41
        Width = 41
        Height = 410
        Align = alRight
        BevelOuter = bvNone
        Caption = #8592#9829
        Color = clMaroon
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -27
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 4
        ExplicitLeft = 565
        ExplicitTop = 35
        ExplicitHeight = 407
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Text'
      ImageIndex = 1
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 600
        Height = 492
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        ExplicitLeft = 3
        ExplicitHeight = 489
      end
    end
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 456
    Top = 552
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer2Timer
    Left = 544
    Top = 560
  end
end
