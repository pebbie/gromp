object frmMap: TfrmMap
  Left = 333
  Top = 147
  Align = alClient
  BorderStyle = bsNone
  Caption = 'frmMap'
  ClientHeight = 473
  ClientWidth = 862
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 862
    Height = 473
    ActivePage = TabSheet1
    Align = alClient
    MultiLine = True
    TabOrder = 0
    TabPosition = tpBottom
    object TabSheet1: TTabSheet
      Caption = 'Map'
      object lbTiles: TListBox
        Left = 733
        Top = 0
        Width = 121
        Height = 447
        Style = lbOwnerDrawFixed
        Align = alRight
        ItemHeight = 96
        PopupMenu = ppTileLib
        TabOrder = 0
        OnDrawItem = lbTilesDrawItem
      end
      object layers: TCheckListBox
        Left = 0
        Top = 0
        Width = 145
        Height = 447
        Align = alLeft
        ItemHeight = 13
        PopupMenu = ppLayer
        TabOrder = 1
        OnClick = layersClick
      end
      object Panel2: TPanel
        Left = 145
        Top = 0
        Width = 588
        Height = 447
        Align = alClient
        Caption = 'Panel2'
        TabOrder = 2
        object ScrollBox1: TScrollBox
          Left = 1
          Top = 43
          Width = 586
          Height = 403
          Align = alClient
          TabOrder = 0
          object Image1: TImage
            Left = 0
            Top = 0
            Width = 105
            Height = 105
            Stretch = True
            OnMouseDown = Image1MouseDown
            OnMouseMove = Image1MouseMove
            OnMouseUp = Image1MouseUp
          end
        end
        object ToolBar1: TToolBar
          Left = 1
          Top = 1
          Width = 586
          Height = 42
          ButtonHeight = 38
          ButtonWidth = 39
          Caption = 'ToolBar1'
          Images = main.appicon
          TabOrder = 1
          object SaveMap: TToolButton
            Left = 0
            Top = 2
            Hint = 'Save Map'
            Caption = 'SaveMap'
            ImageIndex = 2
            OnClick = SaveMapClick
          end
          object ToolButton2: TToolButton
            Left = 39
            Top = 2
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 1
            Style = tbsSeparator
          end
          object ToolButton3: TToolButton
            Left = 47
            Top = 2
            Hint = 'Pencil'
            Caption = 'ToolButton3'
            ImageIndex = 6
            OnClick = ToolButton3Click
          end
          object ToolButton4: TToolButton
            Left = 86
            Top = 2
            Hint = 'Erase'
            Caption = 'ToolButton4'
            ImageIndex = 9
            OnClick = ToolButton4Click
          end
          object ToolButton5: TToolButton
            Left = 125
            Top = 2
            Hint = 'Fill'
            Caption = 'ToolButton5'
            OnClick = ToolButton5Click
          end
          object ToolButton6: TToolButton
            Left = 164
            Top = 2
            Width = 8
            Caption = 'ToolButton6'
            ImageIndex = 4
            Style = tbsSeparator
          end
          object ToolButton7: TToolButton
            Left = 172
            Top = 2
            Hint = 'Zoom Out'
            Caption = 'ToolButton7'
            ImageIndex = 4
            OnClick = ToolButton7Click
          end
          object ToolButton8: TToolButton
            Left = 211
            Top = 2
            Hint = 'Zoom In'
            Caption = 'ToolButton8'
            ImageIndex = 5
            OnClick = ToolButton8Click
          end
          object ToolButton9: TToolButton
            Left = 250
            Top = 2
            Hint = 'Reset Zoom'
            Caption = 'ToolButton9'
            ImageIndex = 3
            OnClick = ToolButton9Click
          end
          object ToolButton10: TToolButton
            Left = 289
            Top = 2
            Width = 8
            Caption = 'ToolButton10'
            ImageIndex = 7
            Style = tbsSeparator
          end
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Properties'
      ImageIndex = 1
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 193
        Height = 73
        Caption = 'Map Dimension'
        TabOrder = 0
        object Label1: TLabel
          Left = 16
          Top = 24
          Width = 28
          Height = 13
          Caption = 'Width'
        end
        object Label2: TLabel
          Left = 16
          Top = 48
          Width = 31
          Height = 13
          Caption = 'Height'
        end
        object SpinEdit1: TSpinEdit
          Left = 64
          Top = 16
          Width = 121
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 0
          Value = 10
        end
        object SpinEdit2: TSpinEdit
          Left = 64
          Top = 40
          Width = 121
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 1
          Value = 10
        end
      end
      object Panel1: TPanel
        Left = 768
        Top = 0
        Width = 86
        Height = 447
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        object Button1: TButton
          Left = 8
          Top = 8
          Width = 75
          Height = 25
          Caption = 'OK'
          TabOrder = 0
        end
        object Button2: TButton
          Left = 9
          Top = 38
          Width = 75
          Height = 25
          Caption = 'Cancel'
          TabOrder = 1
        end
      end
    end
  end
  object ImageList1: TImageList
    Left = 792
    Top = 264
  end
  object ppTileLib: TPopupMenu
    Left = 796
    Top = 308
    object Remove1: TMenuItem
      Caption = 'Remove'
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Import1: TMenuItem
      Caption = 'Import'
      OnClick = Import1Click
    end
  end
  object ppLayer: TPopupMenu
    Left = 84
    Top = 172
    object NewLayer1: TMenuItem
      Caption = 'New Layer'
      OnClick = NewLayer1Click
    end
    object DeleteLayer1: TMenuItem
      Caption = 'Delete Layer'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object toTop1: TMenuItem
      Caption = 'Front'
    end
    object MoveUp1: TMenuItem
      Caption = 'Move Up'
    end
    object MoveDown1: TMenuItem
      Caption = 'Move Down'
    end
    object Bottom1: TMenuItem
      Caption = 'Bottom'
    end
  end
end
