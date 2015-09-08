object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'JLink Utility'
  ClientHeight = 707
  ClientWidth = 1040
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Fixedsys'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1040
    Height = 49
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 17
      Width = 64
      Height = 16
      Caption = 'JLinkARM'
    end
    object Label2: TLabel
      Left = 789
      Top = 16
      Width = 56
      Height = 16
      Caption = 'Version'
    end
    object edtFullNameOfJLINKARM: TEdit
      Left = 85
      Top = 13
      Width = 691
      Height = 24
      ReadOnly = True
      TabOrder = 0
    end
    object edtVersionOfJLINKARM: TEdit
      Left = 856
      Top = 13
      Width = 65
      Height = 24
      ReadOnly = True
      TabOrder = 1
      Text = '5.02a'
    end
    object btnSelectJLinkARM: TButton
      Left = 934
      Top = 13
      Width = 94
      Height = 25
      Caption = 'Load ...'
      TabOrder = 2
      OnClick = btnSelectJLinkARMClick
    end
  end
  object Page: TPageControl
    Left = 0
    Top = 54
    Width = 1040
    Height = 653
    ActivePage = Firmware
    Align = alClient
    Style = tsFlatButtons
    TabOrder = 1
    object Firmware: TTabSheet
      Caption = 'Firmware'
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 350
        Height = 618
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object lbJLinktype: TListBox
          Left = 0
          Top = 35
          Width = 350
          Height = 583
          Align = alClient
          Items.Strings = (
            'J-Link / Flasher Portable V1'
            'J-Link ARM / Flasher ARM V2'
            'J-Link ARM / Flasher ARM V3'
            'J-Link ARM / Flasher ARM V4'
            'J-Link ARM Lite V8'
            'J-Link ARM V6'
            'J-Link ARM V7'
            'J-Link ARM V8'
            'J-Link ARM-LPC Rev.1'
            'J-Link ARM-LPC2146 Rev.2'
            'J-Link ARM-OB SAM7'
            'J-Link ARM-OB STM32'
            'J-Link ARM-Pro V1.x'
            'J-Link ARM-Pro V3.x'
            'J-Link ARM-STR711'
            'J-Link CF V1'
            'J-Link LITE-Cortex-M-5V'
            'J-Link Lite-ADI Rev.1'
            'J-Link Lite-Cortex-M V8'
            'J-Link Lite-FSL V1'
            'J-Link Lite-LPC Rev.1'
            'J-Link Lite-STM32 Rev.1'
            'J-Link Lite-XMC4000 Rev.1'
            'J-Link Lite-XMC4200 Rev.1'
            'J-Link OB RX200 V1'
            'J-Link OB RX621-ARM-SWD V1'
            'J-Link OB RX6xx V1'
            'J-Link OB-MB9AF312K-Spansion'
            'J-Link OB-RX621-RX1xx V1'
            'J-Link OB-SAM3U128 V1'
            'J-Link OB-SAM3U128-V2-NordicSemi'
            'J-Link OB-STM32F072-CortexM'
            'J-Link OB-STM32F103 V1'
            'J-Link PPC / Flasher PPC V1'
            'J-Link PPC / Flasher PPC V4'
            'J-Link PRO / Flasher PRO V4'
            'J-Link Pro V4'
            'J-Link RX / Flasher RX V1'
            'J-Link RX / Flasher RX V4'
            'J-Link Ultra Rev.1'
            'J-Link Ultra V4'
            'J-Link V10'
            'J-Link V9')
          TabOrder = 0
          OnClick = lbJLinktypeClick
        end
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 350
          Height = 35
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object Label3: TLabel
            Left = 0
            Top = 5
            Width = 80
            Height = 16
            Caption = 'JLink Type'
          end
          object btnSaveAllJLinkFirmware: TButton
            Left = 152
            Top = 0
            Width = 177
            Height = 25
            Caption = 'Save All'
            TabOrder = 0
            OnClick = btnSaveAllJLinkFirmwareClick
          end
        end
      end
      object Panel5: TPanel
        Left = 350
        Top = 0
        Width = 10
        Height = 618
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
      end
      object Panel6: TPanel
        Left = 360
        Top = 0
        Width = 672
        Height = 618
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 2
        object Hex: TMPHexEditor
          Left = 0
          Top = 35
          Width = 672
          Height = 583
          Cursor = crIBeam
          Align = alClient
          Font.Charset = GB2312_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Fixedsys'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          BytesPerRow = 16
          BytesPerColumn = 1
          Translation = tkASCII
          OffsetFormat = '8!10:0x|'
          Colors.Background = clWindow
          Colors.ChangedBackground = 11075583
          Colors.ChangedText = clRed
          Colors.CursorFrame = clNavy
          Colors.Offset = clBlack
          Colors.OddColumn = clBlack
          Colors.EvenColumn = clBlue
          Colors.CurrentOffsetBackground = clBtnFace
          Colors.OffsetBackground = clBtnFace
          Colors.CurrentOffset = clBlue
          Colors.Grid = clBtnFace
          Colors.NonFocusCursorFrame = clAqua
          Colors.ActiveFieldBackground = clWindow
          FocusFrame = True
          NoSizeChange = True
          DrawGridLines = True
          ReadOnlyView = True
          GutterWidth = 85
          Version = 'october 7th, 2010; ?markus stephany, http://launchpad.net/dcr'
          DrawGutterGradient = False
          ShowRuler = True
        end
        object Panel7: TPanel
          Left = 0
          Top = 0
          Width = 672
          Height = 35
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object Label4: TLabel
            Left = 0
            Top = 5
            Width = 104
            Height = 16
            Caption = 'Firmware Name'
          end
          object Label5: TLabel
            Left = 425
            Top = 4
            Width = 32
            Height = 16
            Caption = 'Size'
          end
          object edtJLinkFirmwareName: TEdit
            Left = 112
            Top = 0
            Width = 300
            Height = 24
            ReadOnly = True
            TabOrder = 0
          end
          object edtJLinkFirmwareSize: TEdit
            Left = 489
            Top = 0
            Width = 65
            Height = 24
            ReadOnly = True
            TabOrder = 1
            Text = '7FFFF'
          end
          object btnSaveJLinkFirmware: TButton
            Left = 565
            Top = 0
            Width = 94
            Height = 25
            Caption = 'Save ...'
            TabOrder = 2
            OnClick = btnSaveJLinkFirmwareClick
          end
        end
      end
    end
    object TabDevice: TTabSheet
      Caption = 'Device'
      ImageIndex = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 49
    Width = 1040
    Height = 5
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
  end
  object DlgOpen: TOpenDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 560
    Top = 8
  end
  object DlgSave: TSaveDialog
    Filter = 'Binary File ( *.bin )|*.bin'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 512
    Top = 8
  end
end
