{
--------------------------------------------------------------------
Copyright (c) 2009 KSP Developers Team
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}

unit KSPStartup;

interface

{$I ksp_version.inc}

uses Forms, SysUtils, Classes, Dialogs, FileSupportLst, mplayer,
  {$IFDEF KSP_USE_QT}Qt4, {$ENDIF}BassPlayer, AsyncProcess;

procedure SetupKSP;

implementation

uses KSPConstsVars, ProfileFunc, IniFiles, MultiLog, kspfiles{$IFDEF KSP_USE_QT},
  qtproc{$ENDIF};

procedure CheckUpdater;
var
  Ini: TIniFile;
  RunUpdate: boolean;
  p: TAsyncProcess;
begin
  Ini:=TIniFile.Create(KSPDataFolder+'updater.ini');
  RunUpdate:=Ini.ReadBool('updater', 'run_update', false);
  Ini.WriteBool('updater', 'run_update', false);
  Ini.Free;
  if RunUpdate and FileExists(KSPDataFolder+'temp\setup.exe') then begin
    p:=TAsyncProcess.Create(nil);
    p.CommandLine:=KSPDataFolder+'temp\setup.exe';
    p.Execute;
    Application.Terminate;
  end;
end;

//Clear old logs
procedure ClearLogs;
var
  LogsFolder: string;
  s: TStringList;
  i: integer;
begin
  hLog.Send('Clearing old logs');

  LogsFolder := KSPDataFolder + 'logs';
  s := TStringList.Create;

  ListFolders(LogsFolder, s, 7);

  for i := 0 to s.Count - 1 do
  begin
    hLog.Send('Deleting log: ' + s.Strings[i]);
    KSPDeleteFolder(s.Strings[i]);
  end;

  s.Free;
end;

procedure SetupStage1;
var
  i: integer;
  W: WideString;
  s: string;
begin
  Application.Title := 'KSP';
  KSPStartupTime    := Now;

  KSPDataFolder := GetUserDataFolder + '.KSP/';

  FixFolderNames(KSPDataFolder);

  CheckUpdater;

  for i := 0 to MaxInt do
  begin
    KSPLogFilename := KSPDataFolder + 'logs\' +
      FormatDateTime('DD_MM_YYYY_hh_mm', KSPStartupTime) + '_' + IntToStr(i);
    FixFolderNames(KSPLogFilename);
    if not DirectoryExists(KSPLogFilename) then
      Break;
  end;

  ForceDirectories(KSPLogFilename);

  hLog := TLogger.Create;

  ClearLogs;

  hLog.Send('Loading version info...');

  //    KSPMainWindow.ApplicationVisible:=true;
  KSPVersion  := GetKSPVersion;
  KSPVersion2 := GetKSPVersion2;

  hLog.Send('Version loaded: ' + Application.Title + ' ' + KSPVersion +
    ' (' + KSPVersion2 + ')');

  hLog.Send('Setting basic file support');

  ForceDirectoriesKSP(KSPDataFolder);
  ForceDirectoriesKSP(KSPDataFolder + 'data');

  SetupFileName := KSPDataFolder + DefSetupFileName;
  FixFolderNames(SetupFileName);

  GetCountSem2 := 0;
  LoadPlsSem2 := 0;
{$IFDEF KSP_USE_QT}
  s := ExtractFilePath(Application.ExeName) + 'plugins_qt\';
  W := GetUtf8String(s);
  QCoreApplication_addLibraryPath(@W);
{$ENDIF}

  Application.ShowMainForm := True;
{$IFDEF MULTI_PLAYER}
  Player: TMainPlayer.Create;
{$ELSE}
  Player:=TBassPlayer.Create(nil);
{$ENDIF}
end;

procedure SetupKSP;
begin
  SetupStage1;

  ForceDirectoriesKSP(KSPDataFolder + 'data');
  ForceDirectoriesKSP(KSPDataFolder + 'data\db\cd');
  ForceDirectoriesKSP(KSPDataFolder + 'data\vdj');

  FileSupportList := TFileSupportList.Create;
end;

end.
