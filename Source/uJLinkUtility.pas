unit uJLinkUtility;

interface

uses
  System.SysUtils, Vcl.Forms, Vcl.Dialogs, Windows, Classes;

type
  TJLINKARM_MapView = record
    hFile : THANDLE;
    hFileMapping : THANDLE;
    lpFileBase : Pointer;
    Memory : Cardinal;
    MagicDWORD : DWORD;
  end;

  // 10106A20 : IDSEGGER
  // 10106A70 : First Firmware Information
  //
  // First Firmware Information : alignment at 16 Bytes
  // Last Firmware Information : all members are 0x00.
  // Sizeof( Firmware ) = 0x3C
  PJLinkFirmwareInformation = ^TJLinkFirmwareInformation;

  TJLinkFirmwareInformation = record
    Name : DWORD;
    Dump : DWORD;
    Size : DWORD;
    FlashSize : DWORD;
    AllowedSize : DWORD;
    Dummy0 : DWORD;
    NameInDump : DWORD;
    NameOffset : DWORD;
    Dummy1 : DWORD;
    WriteInPlace : DWORD;
    Dummy2 : DWORD;
    Dummy3 : DWORD;
    Dump2 : DWORD;
    Size2 : DWORD;
    Dump2Function : DWORD;
  end;

function JLINKARM_GetFullName( ) : string;

function JLINKARM_GetVersionStr( ) : string; overload;

function JLINKARM_GetVersionStr( FullName : string ) : string; overload;

function JLINKARM_MapView( const FullName : string;
  var MapView : TJLINKARM_MapView ) : boolean;

procedure JLINKARM_UnmapView( MapView : TJLINKARM_MapView );

implementation

var
  VersionValue : Cardinal;

function JLINKARM_GetFullName( ) : string;
const
  JLinkRegKey = HKEY_CURRENT_USER;
  JLinkRegPath : string = 'Software\SEGGER\J-Link';
  JLinkArmDllName : string = 'JLINKARM.DLL';
var
  hRegKey : HKEY;
  iType : DWORD;
  iSize : DWORD;
  JLinkPath : string;
  CurrentVersion : DWORD; // 4.92 : 49200, 5.02a : 50201
begin
  Result := '';
  if ( RegOpenKeyEx( JLinkRegKey, PChar( JLinkRegPath ), 0, KEY_QUERY_VALUE,
    hRegKey ) = ERROR_SUCCESS ) then
  begin
    try
      iType := REG_SZ;
      if ( RegQueryValueEx( hRegKey, 'InstallPath', nil, @iType, nil, @iSize )
        = ERROR_SUCCESS ) then
      begin
        SetLength( JLinkPath, iSize );
        RegQueryValueEx( hRegKey, 'InstallPath', nil, @iType,
          PByte( JLinkPath ), @iSize );
        iSize := Pos( AnsiChar( #0 ), JLinkPath );
        Dec( iSize );
        SetLength( JLinkPath, iSize );
        Result := JLinkPath + JLinkArmDllName;
        if not FileExists( Result ) then
          Result := ''
        else
        begin
          iType := REG_DWORD;
          if ( RegQueryValueEx( hRegKey, 'CurrentVersion', nil, @iType,
            PByte( @CurrentVersion ), @iSize ) = ERROR_SUCCESS ) then
          begin
          end;
        end;
      end;
    finally
      RegCloseKey( hRegKey );
    end;
  end;
end;

function JLINKARM_GetDLLVersion( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetDLLVersion' delayed;

// Load DLL Delayed
function JLINKARM_GetVersionStr( ) : string;
var
  Version : integer;
  // 4.92 : 49200, 5.02a : 50201
begin
  Version := JLINKARM_GetDLLVersion( );

  Result := IntToStr( Version div 10000 ) + '.' +
    IntToHex( ( ( Version mod 10000 ) div 100 ), 2 );

  Version := Version mod 10;
  if Version <> 0 then //
    Result := Result + Char( Ord( 'a' ) + Version - 1 );
end;

// Load DLL Dynamic -- Min Version : 4.90e
function JLINKARM_GetVersionStr( FullName : string ) : string;
type
  TJLINKARM_GetDLLVersion = function : integer; cdecl;
var
  Handle : THANDLE;
  Version : integer; // 4.92 : 49200, 5.02a : 50201
  JLINKARM_GetDLLVersion : TJLINKARM_GetDLLVersion;
begin
  Result := 'Unknown';

  Handle := LoadLibrary( PChar( FullName ) );
  if Handle <> 0 then
  begin
    @JLINKARM_GetDLLVersion := GetProcAddress( Handle,
      'JLINKARM_GetDLLVersion' );

    if @JLINKARM_GetDLLVersion <> nil then
    begin
      VersionValue := JLINKARM_GetDLLVersion( ); // 49103 : 4.91c

      if VersionValue < 49103 then
        Result := 'Unknown'
      else
      begin
        Result := IntToStr( VersionValue div 10000 ) + '.';
        Result := Result + Format( '%.*d',
          [ 2, ( VersionValue mod 10000 ) div 100 ] );

        Version := VersionValue mod 10;
        if Version <> 0 then //
          Result := Result + Char( Ord( 'a' ) + Version - 1 );
      end;
    end;

    FreeLibrary( Handle );
  end;
end;

function JLINKARM_MapView( const FullName : string;
  var MapView : TJLINKARM_MapView ) : boolean;
begin
  if MapView.MagicDWORD = $55AA55AA then
    JLINKARM_UnmapView( MapView );

  Result := FALSE;

  if VersionValue < 49103 then
    Exit;

  MapView.hFile := CreateFile( PChar( FullName ), GENERIC_READ, FILE_SHARE_READ,
    nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0 );
  if MapView.hFile <> 0 then
  begin
    MapView.hFileMapping := CreateFileMapping( MapView.hFile, nil,
      PAGE_READONLY, 0, 0, nil );
    if MapView.hFileMapping <> 0 then
    begin
      MapView.lpFileBase := MapViewOfFile( MapView.hFileMapping, FILE_MAP_READ,
        0, 0, 0 );

      if MapView.lpFileBase <> nil then
      begin
        MapView.Memory := Cardinal( MapView.lpFileBase );
        MapView.MagicDWORD := $55AA55AA;
        Result := TRUE;
      end;
    end;
  end;
end;

procedure JLINKARM_UnmapView( MapView : TJLINKARM_MapView );
begin
  if MapView.lpFileBase <> nil then
    UnmapViewOfFile( MapView.lpFileBase );

  if MapView.hFileMapping <> 0 then
    CloseHandle( MapView.hFileMapping );

  if MapView.hFile <> 0 then
    CloseHandle( MapView.hFile );

  MapView.MagicDWORD := 0;
end;

end.
