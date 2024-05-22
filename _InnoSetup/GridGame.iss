; GridGame Setup Script for InnoSetup
; by Daniel Marschall

[Setup]
AppName=GridGame
AppVerName=GridGame 1.1
AppVersion=1.1
AppCopyright=© Copyright 2023 - 2024 ViaThinkSoft
AppPublisher=ViaThinkSoft
AppPublisherURL=https://www.viathinksoft.de/
AppSupportURL=https://www.daniel-marschall.de/
AppUpdatesURL=https://www.viathinksoft.de/
DefaultDirName={autopf}\GridGame
DefaultGroupName=GridGame
VersionInfoCompany=ViaThinkSoft
VersionInfoCopyright=© Copyright 2023 - 2024 ViaThinkSoft
VersionInfoDescription=GridGame Setup
VersionInfoTextVersion=1.0.0.0
VersionInfoVersion=1.1
PrivilegesRequiredOverridesAllowed=dialog
UsePreviousPrivileges=no
ShowLanguageDialog=no
OutputBaseFilename=GridGame_Setup
OutputDir=.
; Configure Sign Tool in InnoSetup at "Tools => Configure Sign Tools" (adjust the path to your SVN repository location)
; Name    = sign_single   
; Command = "C:\SVN\...\sign_single.bat" $f
SignTool=sign_single
SignedUninstaller=yes

[Languages]
Name: en; MessagesFile: "compiler:Default.isl"
Name: de; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "Erstelle eine Verknüpfung auf dem &Desktop"; GroupDescription: "Programmverknüpfungen:"; MinVersion: 4,4

[Files]
Source: "..\GridGame.exe"; DestDir: "{app}"; Flags: ignoreversion signonce
Source: "..\Sounds\*.wav"; DestDir: "{app}\Sounds"; Flags: ignoreversion

[Icons]
Name: "{group}\GridGame"; Filename: "{app}\GridGame.exe"
Name: "{autodesktop}\GridGame"; Filename: "{app}\GridGame.exe"; MinVersion: 4,4; Tasks: desktopicon

[Run]
Filename: "{app}\GridGame.exe"; Description: "GridGame starten"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
begin
  if CheckForMutexes('GridGameSetup')=false then
  begin
    Createmutex('GridGameSetup');
    Result := true;
  end
  else
  begin
    Result := False;
  end;
end;
