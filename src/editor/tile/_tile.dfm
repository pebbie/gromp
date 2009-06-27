object frmTile: TfrmTile
  Left = 367
  Top = 170
  Align = alClient
  BorderStyle = bsNone
  Caption = 'Tile'
  ClientHeight = 471
  ClientWidth = 858
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 858
    Height = 471
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    TabPosition = tpBottom
    object TabSheet1: TTabSheet
      Caption = 'Tile'
      object ScrollBox1: TScrollBox
        Left = 0
        Top = 40
        Width = 752
        Height = 405
        Align = alClient
        Color = clGray
        ParentColor = False
        TabOrder = 0
        object Image1: TImage
          Left = 0
          Top = 0
          Width = 105
          Height = 105
          Stretch = True
        end
        object Image3: TImage
          Left = 0
          Top = 0
          Width = 105
          Height = 105
          Stretch = True
          Transparent = True
          OnMouseDown = Image3MouseDown
          OnMouseMove = Image3MouseMove
          OnMouseUp = Image3MouseUp
        end
      end
      object ToolBar1: TToolBar
        Left = 0
        Top = 0
        Width = 850
        Height = 40
        ButtonHeight = 38
        ButtonWidth = 39
        Caption = 'ToolBar1'
        EdgeBorders = []
        Flat = True
        Images = main.appicon
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        object SaveTile: TToolButton
          Left = 0
          Top = 0
          Hint = 'Save Tile'
          Caption = 'Save'
          ImageIndex = 15
          OnClick = SaveTileClick
        end
        object ToolButton3: TToolButton
          Left = 39
          Top = 0
          Width = 8
          Caption = 'ToolButton3'
          ImageIndex = 2
          Style = tbsSeparator
        end
        object ToolButton10: TToolButton
          Left = 47
          Top = 0
          Hint = 'Pick Color'
          Caption = 'ToolButton10'
          ImageIndex = 14
          OnClick = ToolButton10Click
        end
        object ToolButton2: TToolButton
          Left = 86
          Top = 0
          Hint = 'Pencil'
          Caption = 'ToolButton2'
          ImageIndex = 12
          OnClick = ToolButton2Click
        end
        object ToolButton4: TToolButton
          Left = 125
          Top = 0
          Hint = 'Line'
          Caption = 'ToolButton4'
          ImageIndex = 16
          OnClick = ToolButton4Click
        end
        object ToolButton5: TToolButton
          Left = 164
          Top = 0
          Hint = 'Fill'
          Caption = 'ToolButton5'
          ImageIndex = 13
          OnClick = ToolButton5Click
        end
        object ToolButton7: TToolButton
          Left = 203
          Top = 0
          Width = 8
          Caption = 'ToolButton7'
          ImageIndex = 5
          Style = tbsSeparator
        end
        object ToolButton6: TToolButton
          Left = 211
          Top = 0
          Hint = 'Zoom Out'
          Caption = 'ToolButton6'
          ImageIndex = 4
          OnClick = ToolButton6Click
        end
        object ToolButton8: TToolButton
          Left = 250
          Top = 0
          Hint = 'Zoom In'
          Caption = 'ToolButton8'
          ImageIndex = 5
          OnClick = ToolButton8Click
        end
        object ToolButton9: TToolButton
          Left = 289
          Top = 0
          Hint = 'Reset Zoom'
          Caption = 'ToolButton9'
          ImageIndex = 3
          OnClick = ToolButton9Click
        end
        object ToolButton11: TToolButton
          Left = 328
          Top = 0
          Width = 8
          Caption = 'ToolButton11'
          ImageIndex = 7
          Style = tbsSeparator
        end
        object curcol: TShape
          Left = 336
          Top = 0
          Width = 38
          Height = 38
          Pen.Style = psClear
        end
      end
      object Panel1: TPanel
        Left = 752
        Top = 40
        Width = 98
        Height = 405
        Align = alRight
        TabOrder = 2
        object Image4: TImage
          Left = 1
          Top = 113
          Width = 96
          Height = 32
          Align = alTop
        end
        object ScrollBox2: TScrollBox
          Left = 1
          Top = 1
          Width = 96
          Height = 112
          HorzScrollBar.Increment = 96
          Align = alTop
          BorderStyle = bsNone
          TabOrder = 0
          object Image2: TImage
            Left = 0
            Top = 0
            Width = 576
            Height = 96
            AutoSize = True
            OnMouseDown = Image2MouseDown
            OnMouseMove = Image2MouseMove
          end
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Properties'
      ImageIndex = 1
    end
  end
end
