unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, dcrHexEditor, FileCtrl;

type
  TMainForm = class( TForm )
    Panel1 : TPanel;
    Label1 : TLabel;
    edtFullNameOfJLINKARM : TEdit;
    Label2 : TLabel;
    edtVersionOfJLINKARM : TEdit;
    btnSelectJLinkARM : TButton;
    DlgOpen : TOpenDialog;
    Page : TPageControl;
    Firmware : TTabSheet;
    TabDevice : TTabSheet;
    Panel2 : TPanel;
    Panel3 : TPanel;
    lbJLinktype : TListBox;
    Panel5 : TPanel;
    Panel6 : TPanel;
    Hex : TMPHexEditor;
    Panel4 : TPanel;
    Label3 : TLabel;
    Panel7 : TPanel;
    Label4 : TLabel;
    edtJLinkFirmwareName : TEdit;
    edtJLinkFirmwareSize : TEdit;
    Label5 : TLabel;
    btnSaveJLinkFirmware : TButton;
    DlgSave : TSaveDialog;
    btnSaveAllJLinkFirmware : TButton;
    procedure FormCreate( Sender : TObject );
    procedure FormDestroy( Sender : TObject );
    procedure btnSelectJLinkARMClick( Sender : TObject );
    procedure lbJLinktypeClick( Sender : TObject );
    procedure btnSaveJLinkFirmwareClick( Sender : TObject );
    procedure btnSaveAllJLinkFirmwareClick( Sender : TObject );
  private
    { Private declarations }
    procedure UpdateInformationOfDLL( FullName : string );
    procedure UpdateInformationOfFirmware( );
    procedure UpdateInformationOfJLinkType( );
  public
    { Public declarations }
  end;

var
  MainForm : TMainForm;

implementation

{$R *.dfm}

uses uJLinkUtility;

var
  MapView : TJLINKARM_MapView;
  DosHeader : PImageDosHeader;
  NTHeader : PImageNtHeaders32;
  FileHeader : pImageFileHeader;
  OptionalHeader : PImageOptionalHeader32;

  // OptionalHeader.NumberOfSections
  SectionTable : array of IMAGE_SECTION_HEADER;
  RDATA_Section : pImageSectionHeader;
  DATA_Section : pImageSectionHeader;
  DLL_ImageBase : Cardinal;

  JLinkFirmwareTable : PJLinkFirmwareInformation;
  JLinkFirmwareCount : Cardinal;

procedure TMainForm.btnSaveAllJLinkFirmwareClick( Sender : TObject );
var
  OpenDialog : TFileOpenDialog;
  SelectedFolder : string;
  FileName : string;
  I : Integer;
  X : Integer;

  JLinkFirmwareInformation : PJLinkFirmwareInformation;
  msFirmware : TMemoryStream;
  Dump : PByte;
begin
  if lbJLinktype.Items.Count = 0 then
    Exit;

  OpenDialog := TFileOpenDialog.Create( MainForm );
  try
    OpenDialog.Options := OpenDialog.Options + [ fdoPickFolders ];
    if not OpenDialog.Execute then
      Exit;
    SelectedFolder := OpenDialog.FileName;
  finally
    OpenDialog.Free;
  end;

  if SelectedFolder[ Length( SelectedFolder ) ] <> '\' then
    SelectedFolder := SelectedFolder + '\';

  msFirmware := TMemoryStream.Create;
  try
    for X := 0 to lbJLinktype.Items.Count - 1 do
    begin
      JLinkFirmwareInformation := PJLinkFirmwareInformation
        ( lbJLinktype.Items.Objects[ X ] );

      FileName := lbJLinktype.Items[ X ] + '_V' + edtVersionOfJLINKARM.Text;
      for I := 1 to Length( FileName ) do
      begin
        if not( FileName[ I ] in [ 'a' .. 'z', 'A' .. 'Z', '0' .. '9' ] ) then
          FileName[ I ] := '_';
      end;

      FileName := SelectedFolder + FileName + '.bin';

      Dump := PByte( JLinkFirmwareInformation.Dump - DLL_ImageBase +
        MapView.Memory );

      msFirmware.Seek( 0, soBeginning );
      msFirmware.Write( Dump^, JLinkFirmwareInformation.Size );
      msFirmware.SaveToFile( FileName );
    end;
  finally
    msFirmware.Free;
  end;
end;

procedure TMainForm.btnSaveJLinkFirmwareClick( Sender : TObject );
var
  FileName : string;
  I : Integer;
begin
  if Hex.DataSize = 0 then
    Exit;

  FileName := edtJLinkFirmwareName.Text + '_V' + edtVersionOfJLINKARM.Text;
  for I := 1 to Length( FileName ) do
  begin
    if not( FileName[ I ] in [ 'a' .. 'z', 'A' .. 'Z', '0' .. '9' ] ) then
      FileName[ I ] := '_';
  end;

  FileName := FileName + '.bin';
  DlgSave.FileName := FileName;
  if not DlgSave.Execute then
    Exit;

  FileName := DlgSave.FileName;
  Hex.SaveToFile( FileName );

end;

procedure TMainForm.btnSelectJLinkARMClick( Sender : TObject );
var
  ModuleHandle : THandle;
begin
  DlgOpen.FileName := 'JLinkARM.dll';
  DlgOpen.InitialDir := ExtractFilePath( edtFullNameOfJLINKARM.Text );
  if DlgOpen.Execute then
  begin
    if UpperCase( ExtractFileName( DlgOpen.FileName ) )
      = UpperCase( 'JLinkARM.dll' ) then
    begin
      UpdateInformationOfDLL( DlgOpen.FileName );
      UpdateInformationOfJLinkType( );
    end;
  end;
end;

procedure TMainForm.FormCreate( Sender : TObject );
begin
  MapView.MagicDWORD := 0;
  UpdateInformationOfDLL( JLINKARM_GetFullName( ) );
  UpdateInformationOfJLinkType( );
end;

procedure TMainForm.FormDestroy( Sender : TObject );
begin
  JLINKARM_UnmapView( MapView );
end;

procedure TMainForm.lbJLinktypeClick( Sender : TObject );
begin
  UpdateInformationOfFirmware( );
end;

procedure TMainForm.UpdateInformationOfDLL( FullName : string );
var
  VersionStr : string;
  NumberOfSections : Cardinal;
  I : Integer;
  ASection : pImageSectionHeader;
begin
  VersionStr := '';
  if FullName <> '' then
  begin
    // SetDllDirectory( PWideChar( ExtractFilePath( FullName ) ) );
    VersionStr := JLINKARM_GetVersionStr( FullName );
  end;

  edtVersionOfJLINKARM.Text := VersionStr;
  edtFullNameOfJLINKARM.Text := FullName;
  edtFullNameOfJLINKARM.SelectAll;

  RDATA_Section := nil;
  DATA_Section := nil;

  if JLINKARM_MapView( edtFullNameOfJLINKARM.Text, MapView ) then
  begin
    DosHeader := PImageDosHeader( MapView.Memory );
    NTHeader := PImageNtHeaders32( MapView.Memory +
      Cardinal( DosHeader._lfanew ) );
    FileHeader := @NTHeader.FileHeader;
    OptionalHeader := @NTHeader.OptionalHeader;
    DLL_ImageBase := OptionalHeader.ImageBase;

    NumberOfSections := FileHeader.NumberOfSections;
    ASection := IMAGE_FIRST_SECTION( NTHeader^ );
    for I := 0 to NumberOfSections - 1 do
    begin
      if ( ASection.Name[ 0 ] = Byte( '.' ) ) and
        ( ASection.Name[ 1 ] = Byte( 'r' ) ) and
        ( ASection.Name[ 2 ] = Byte( 'd' ) ) and
        ( ASection.Name[ 3 ] = Byte( 'a' ) ) and
        ( ASection.Name[ 4 ] = Byte( 't' ) ) and
        ( ASection.Name[ 5 ] = Byte( 'a' ) ) then
      begin
        RDATA_Section := ASection;
      end
      else if ( ASection.Name[ 0 ] = Byte( '.' ) ) and
        ( ASection.Name[ 1 ] = Byte( 'd' ) ) and
        ( ASection.Name[ 2 ] = Byte( 'a' ) ) and
        ( ASection.Name[ 3 ] = Byte( 't' ) ) and
        ( ASection.Name[ 4 ] = Byte( 'a' ) ) then
      begin
        DATA_Section := ASection;
      end;

      Inc( ASection );
    end;

    // SetLength( SectionTable, FileHeader.NumberOfSections );
    // CopyMemory( @SectionTable[ 0 ], IMAGE_FIRST_SECTION( NTHeader^ ),
    // FileHeader.NumberOfSections * sizeof( IMAGE_SECTION_HEADER ) );
  end;

end;

procedure TMainForm.UpdateInformationOfFirmware;
var
  JLinkFirmwareInformation : PJLinkFirmwareInformation;
  msFirmware : TMemoryStream;
  Dump : PByte;
begin
  edtJLinkFirmwareName.Text := lbJLinktype.Items[ lbJLinktype.ItemIndex ];

  JLinkFirmwareInformation := PJLinkFirmwareInformation
    ( lbJLinktype.Items.Objects[ lbJLinktype.ItemIndex ] );

  edtJLinkFirmwareSize.Text := IntToHex( JLinkFirmwareInformation.Size, 6 );

  msFirmware := TMemoryStream.Create;
  try
    Dump := PByte( JLinkFirmwareInformation.Dump - DLL_ImageBase +
      MapView.Memory );
    msFirmware.Write( Dump^, JLinkFirmwareInformation.Size );
    Hex.LoadFromStream( msFirmware );
    Hex.TopRow := ( ( JLinkFirmwareInformation.NameInDump + Hex.BytesPerRow -
      1 ) div Hex.BytesPerRow ) + 2;
  finally
    msFirmware.Free;
  end;

end;

procedure TMainForm.UpdateInformationOfJLinkType;

var
  RDATA_Offset : Cardinal;
  RDATA_Size : Cardinal;

  RDATA_VirtualOffset : Cardinal;
  RDATA_VirtualMax : Cardinal;

  DATA_Offset : Cardinal;
  DATA_Size : Cardinal;

  DATA_VirtualOffset : Cardinal;
  DATA_VirtualMax : Cardinal;

  JLinkNameOffset : Cardinal;
  JLinkDumpOffset : Cardinal;
  NameInDll : PByte;
  NameInDump : PByte;
  CompareOK : boolean;
  NameInDllSize : Cardinal;

  FirmwareNameInMemory : Cardinal;
  FirmwareName : AnsiString;
  FirmwareSize : Cardinal;
  JLinkFirmwareInformation : PJLinkFirmwareInformation;
begin
  if RDATA_Section = nil then
    Exit;
  if DATA_Section = nil then
    Exit;

  lbJLinktype.Items.Clear;
  edtJLinkFirmwareName.Text := '';
  edtJLinkFirmwareSize.Text := '';
  if Hex.DataSize > 0 then
  begin
    Hex.CreateEmptyFile( 'Unsaved Firmware' );
    // Hex.SelectAll( );
    // Hex.DeleteSelection('Clear All');
  end;

  // .rdata: Const/read-only (and initialized) data
  // JLink Firmware Table
  RDATA_Offset := MapView.Memory + RDATA_Section.PointerToRawData;
  RDATA_Size := RDATA_Section.SizeOfRawData;
  RDATA_VirtualOffset := RDATA_Section.PointerToRawData + DLL_ImageBase;
  RDATA_VirtualMax := RDATA_VirtualOffset + RDATA_Size;

  // .data: Initialized data
  // JLink Firmware Dump, Name
  DATA_Offset := MapView.Memory + DATA_Section.PointerToRawData;
  DATA_Size := DATA_Section.SizeOfRawData;
  DATA_VirtualOffset := DATA_Section.PointerToRawData + DLL_ImageBase;
  DATA_VirtualMax := DATA_VirtualOffset + DATA_Size;

  CompareOK := True;
  NameInDllSize := 0;
  JLinkFirmwareCount := 0;

  // Find JLink Firmware Table
  //
  // JLinkFirmwareTable.Dump[ NameInDump ]
  // :: J-Link V9 compiled Sep  4 2015 18:09:29
  // :: J-Link V9 <--- JLinkFirmwareTable.Name : strlen( Name )
  // :: ^^^^^^^^^
  while True do
  begin
    // Firmware Table in RDATA Section
    JLinkFirmwareTable := PJLinkFirmwareInformation( RDATA_Offset );

    // Name in DATA Section : J-Link V9
    if ( JLinkFirmwareTable.Name >= DATA_VirtualOffset ) and
      ( JLinkFirmwareTable.Name < DATA_VirtualMax ) then
    begin
      // Dump in DATA Section
      if ( JLinkFirmwareTable.Dump >= DATA_VirtualOffset ) and
        ( JLinkFirmwareTable.Dump < DATA_VirtualMax ) then
      begin
        if ( JLinkFirmwareTable.Size > 0 ) and
          ( JLinkFirmwareTable.FlashSize > 0 ) and
          ( JLinkFirmwareTable.Size <= JLinkFirmwareTable.FlashSize ) then
        begin

          // J-Link V9 compiled Sep  4 2015 18:09:29 in Dump
          if ( JLinkFirmwareTable.NameInDump < JLinkFirmwareTable.Size ) then
          begin
            NameInDll := PByte( MapView.Memory + JLinkFirmwareTable.Name -
              DLL_ImageBase );

            NameInDump := PByte( MapView.Memory + JLinkFirmwareTable.Dump -
              DLL_ImageBase + JLinkFirmwareTable.NameInDump );

            // Compare Name : J-Link V9 & J-Link V9 compiled Sep  4 2015 18:09:29
            CompareOK := True;
            NameInDllSize := 0;
            while True do
            begin
              if NameInDll^ = 0 then
                break;

              if NameInDll^ <> NameInDump^ then
              begin
                CompareOK := False;
                break;
              end;

              Inc( NameInDll );
              Inc( NameInDump );
              Inc( NameInDllSize );
            end;
          end;
        end;
      end;
    end;

    if CompareOK and ( NameInDllSize > 0 ) then
      break;

    if ( DLL_ImageBase + RDATA_Offset + Sizeof( TJLinkFirmwareInformation ) >
      MapView.Memory + RDATA_VirtualMax ) then
      Exit;

    Inc( RDATA_Offset, 4 );
  end;

  // JLinkFirmwareTable : First Firmware Informtion : J-Trace ARM Rev.1
  if CompareOK then
  begin
    JLinkFirmwareInformation := JLinkFirmwareTable;
    JLinkFirmwareCount := 0;
    while JLinkFirmwareInformation.Name <> 0 do
    begin
      FirmwareNameInMemory := JLinkFirmwareInformation.Name - DLL_ImageBase +
        MapView.Memory;
      FirmwareName := PAnsiChar( FirmwareNameInMemory );
      FirmwareSize := JLinkFirmwareInformation.Size;

      if FirmwareName = 'Rev.5' then
      begin
        FirmwareName := 'J-Link ARM V5';
      end;

      lbJLinktype.Items.AddObject( FirmwareName,
        TObject( JLinkFirmwareInformation ) );

      Inc( JLinkFirmwareInformation );
      Inc( JLinkFirmwareCount );
    end;
  end;

  if lbJLinktype.Items.Count > 0 then
  begin
    lbJLinktype.ItemIndex := 0;
    UpdateInformationOfFirmware( );
  end;
end;

end.
