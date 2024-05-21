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
  OnCreate = FormCreate
  OnShow = FormShow
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
    Left = 339
    Top = 554
    Width = 54
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Music:'
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
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Help'
      ImageIndex = 2
      object Memo2: TMemo
        Left = 0
        Top = 0
        Width = 600
        Height = 492
        Align = alClient
        Lines.Strings = (
          'Known by the game "Brown Away", Grid Game is a game where you '
          'need to navigate through a grid of playing cards. The card suit '
          
            'defines the direction and the value of the card defines the dist' +
            'ance.'
          'Start and move with the Joker card.'
          ''
          'The values of the cards are A=1, J=11, Q=12, K=13'
          ''
          'Directions:'
          '- Hearts = Left'
          '- Diamonds = Right'
          '- Clubs = Up'
          '- Spades = Down'
          ''
          'Download latest version here:  '
          'https://www.viathinksoft.com/projects/gridgame'
          ''
          'Source code:  https://github.com/danielmarschall/gridgame'
          ''
          'Developed in 2023 by Daniel Marschall, ViaThinkSoft'
          'Licensed under the terms of the Apache 2.0 License')
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Highscores'
      ImageIndex = 3
      object Memo3: TMemo
        Left = 0
        Top = 0
        Width = 600
        Height = 492
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        PopupMenu = PopupMenu1
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object MediaPlayer1: TMediaPlayer
    Left = 408
    Top = 554
    Width = 57
    Height = 30
    VisibleButtons = [btPlay, btStop]
    Anchors = [akLeft, akBottom]
    AutoEnable = False
    AutoRewind = False
    DoubleBuffered = True
    FileName = 'D:\SVN\Grid Game\trunk\music.wav'
    ParentDoubleBuffered = False
    TabOrder = 3
    OnClick = MediaPlayer1Click
    OnNotify = MediaPlayer1Notify
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
  object PopupMenu1: TPopupMenu
    Left = 532
    Top = 76
    object Deleteallentries1: TMenuItem
      Caption = 'Delete all entries'
      OnClick = Deleteallentries1Click
    end
  end
end
