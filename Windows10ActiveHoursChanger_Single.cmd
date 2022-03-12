@ECHO OFF
SETLOCAL EnableExtensions  EnableDelayedExpansion 

SET "balloon_script_name=Show-BalloonTip.ps1"
SET "balloon_icon=Windows10ActiveHoursChanger_compressed.ico"
SET "balloon_title=Active Hours Changer for Windows"
SET "balloon_icon_type=Info"
SET /A balloon_timeout=3000
SET "balloon_icon_location="
SET "current_path=%~dp0"

ECHO Current Path: %current_path%
ECHO Initializing the script.. Please wait..

For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set current_hour=%%a)
ECHO Current Hour: %current_hour%

::Check registry keys existence
reg query "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" 
::/e >nul 2>nul

IF EXIST "%current_path%%balloon_icon%" (
	SET "balloon_icon_location=%current_path%%balloon_icon%"
)
ECHO Balloon Icon Location: %balloon_icon_location%
CALL SET "current_path=%current_path: =` %"

IF %ERRORLEVEL% EQU 1 (
	SET "exception_message=No Folder Found (Path: HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings).. Quitting.."
	ECHO %exception_message%
	::Displaying exception as balloon in Action Center
	powershell.exe -noprofile -executionpolicy bypass -Command "& {$Text='%exception_message%'; $Title='%balloon_title%'; $IconType='%balloon_icon_type%'; $Timeout=%balloon_timeout%; $Icon='%balloon_icon_location%'; Add-Type -AssemblyName System.Windows.Forms; if ($script:balloon -eq $null){ $script:balloon=New-Object System.Windows.Forms.NotifyIcon; } if ([string]::IsNullOrEmpty($Icon)) { $path=Get-Process -id $pid | Select-Object -ExpandProperty Path; $balloon.Icon=[System.Drawing.Icon]::ExtractAssociatedIcon($path); } else { $balloon.Icon=[System.Drawing.Icon]::ExtractAssociatedIcon($Icon) } $balloon.BalloonTipIcon=$IconType; $balloon.BalloonTipText=$Text; $balloon.BalloonTipTitle=$Title; $balloon.Visible=$true; $balloon.ShowBalloonTip($Timeout); Start-Sleep -s ($Timeout / 1000); $balloon.Dispose();}"
	TIMEOUT 2 > NUL
)

SET set_hour_start=%current_hour%
SET /A set_hour_start_length=0
CALL :StrLen %set_hour_start% set_hour_start_length
REM ECHO %set_hour_start_length%

REM A percent character that is used as the modulus operator in the SET /A command in a batch file, should always be passed as a pair of double %%'s.

IF "%set_hour_start:~0,1%" == "0" (
	IF %set_hour_start_length% GTR 1 (
		SET /A set_hour_start=10000%set_hour_start% %% 10000
	)
) ELSE (
	SET /A set_hour_start=%set_hour_start%
)
SET set_hour_start_hex=%set_hour_start%

SET /A set_hour_end=%set_hour_start%+18
SET /A set_hour_end_length=0
CALL :StrLen %set_hour_end% set_hour_end_length
REM ECHO %set_hour_end_length%

IF "%set_hour_end:~0,1%" == "0" (
	IF %set_hour_end_length% GTR 1 (
		SET /A set_hour_end=10000%set_hour_end% %% 10000
	)
) ELSE (
	SET /A set_hour_end=%set_hour_end%
)
SET set_hour_end_hex=%set_hour_end%

IF %set_hour_start% GTR 9 (
	CALL :ConvertDecToHex %set_hour_start% set_hour_start_hex
)

IF %set_hour_end% GTR 24 (
	SET /A set_hour_end=%set_hour_end%-24
	SET /A set_hour_end_hex=%set_hour_end%
)

IF %set_hour_end% GTR 9 (
	CALL :ConvertDecToHex %set_hour_end% set_hour_end_hex
)

SET set_hour_start_hex=0x%set_hour_start_hex%
SET set_hour_end_hex=0x%set_hour_end_hex%

ECHO START HOUR (IN DEC): %set_hour_start%
ECHO END HOUR (IN DEC): %set_hour_end%

ECHO START HOUR (IN HEX): %set_hour_start_hex%
ECHO END HOUR (IN HEX): %set_hour_end_hex%

FOR /f "tokens=1-3" %%a IN ('reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v ActiveHoursStart /t REG_DWORD /d %set_hour_start_hex% /f') DO SET "var=%%a %%b %%c"
FOR /f "tokens=1-3" %%a IN ('reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v ActiveHoursEnd /t REG_DWORD /d %set_hour_end_hex% /f') DO SET "var=%%a %%b %%c"

IF %set_hour_start% LEQ 9 (
	SET set_hour_start=0%set_hour_start%
)
IF %set_hour_end% LEQ 9 (
	SET set_hour_end=0%set_hour_end%
)

IF %ERRORLEVEL% EQU 0 (
	ECHO Active Hours are successfully changed..
	SET "balloon_text=Active Hours are successfully changed..                                            Start Hour: %set_hour_start%                                            End Hour: %set_hour_end%"
) ELSE (
	ECHO Active Hours couldn't be successfully changed..
	SET "balloon_text=Active Hours couldn't be successfully changed.."
)

::Displaying update message as balloon in Action Center
powershell.exe -noprofile -executionpolicy bypass -Command "& {$Text='%balloon_text%'; $Title='%balloon_title%'; $IconType='%balloon_icon_type%'; $Timeout=%balloon_timeout%; $Icon='%balloon_icon_location%'; Add-Type -AssemblyName System.Windows.Forms; if ($script:balloon -eq $null){ $script:balloon=New-Object System.Windows.Forms.NotifyIcon; } if ([string]::IsNullOrEmpty($Icon)) { $path=Get-Process -id $pid | Select-Object -ExpandProperty Path; $balloon.Icon=[System.Drawing.Icon]::ExtractAssociatedIcon($path); } else { $balloon.Icon=[System.Drawing.Icon]::ExtractAssociatedIcon($Icon) } $balloon.BalloonTipIcon=$IconType; $balloon.BalloonTipText=$Text; $balloon.BalloonTipTitle=$Title; $balloon.Visible=$true; $balloon.ShowBalloonTip($Timeout); Start-Sleep -s ($Timeout / 1000); $balloon.Dispose();}"

::DEBUG Purpose
::ECHO powershell.exe -noprofile -executionpolicy bypass -Command "& {%MYFILES%\%balloon_script_name% -Text '%balloon_text%' -Title '%balloon_title%' -Icon '%balloon_icon_type%' -Timeout %balloon_timeout%}"

TIMEOUT 3 > NUL
::PAUSE

EXIT

::Based on https://gist.githubusercontent.com/ijprest/1207832/raw/77fd886c1b89a41566910dcf0a05f09cf5edb09c/tohex.bat
::Start of :ConvertDecToHex subroutine
:ConvertDecToHex 
SET LOOKUP=0123456789abcdef
SET HEXSTR=
SET PREFIX=

IF "%1" EQU "" (
SET "%2=0"
GOTO :EOF
)
set /A A=%1 || exit /b 1
IF !A! LSS 0 SET /a A=0xfffffff + !A! + 1 & SET PREFIX=f
:LOOP
SET /A B=!A! %% 16 & SET /A A=!A! / 16
SET HEXSTR=!LOOKUP:~%B%,1!%HEXSTR%
IF %A% GTR 0 GOTO :LOOP
SET "%2=%PREFIX%%HEXSTR%"
GOTO :EOF
::End of :ConvertDecToHex subroutine

::Based on https://ss64.com/nt/syntax-strlen.html
::Start of :StrLen subroutine
:StrLen
SET "S=#%1"
SET /A LEN=0

FOR %%N IN (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) DO (
	IF "!S:~%%N,1!" neq "" (
		SET /A LEN+=%%N
		SET "S=!S:~%%N!"
    )
)

IF "%2" neq "" (SET /A %2=%LEN%) ELSE SET /A %2=%LEN%
GOTO :EOF
::End of :StrLen subroutine
