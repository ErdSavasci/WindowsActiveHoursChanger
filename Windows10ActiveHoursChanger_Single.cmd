@ECHO OFF
SETLOCAL EnableExtensions  EnableDelayedExpansion 

SET "architecture=64 bit"
SET "balloon_script_name=Show-BalloonTip.ps1"
SET "balloon_icon=Windows10ActiveHoursChanger.ico"
SET "balloon_title=Active Hours Changer for Windows"
SET "balloon_icon_type=Info"
SET /A balloon_timeout=3000
SET /A balloon_icon_exists_in_curr_dir=0
SET "balloon_icon_location="
SET "current_path=%~dp0"

reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE | find "ARCH" | FINDSTR /L "86" > NUL
IF %ERRORLEVEL% EQU 0 (
	SET "architecture=32 bit"
) ELSE (
	SET "architecture=64 bit"
)

ECHO Architecture: %architecture%
ECHO Current Path: %current_path%

ECHO Initializing the script.. Please wait..

For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set current_hour=%%a)
ECHO Current Hour: %current_hour%

::Check registry keys existence
reg query "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" 
::/e >nul 2>nul

IF EXIST "%current_path%%balloon_icon%" (
	SET /A balloon_icon_exists_in_curr_dir=1
	CALL SET "current_path=%current_path: =` %"
	SET "balloon_icon_location=%current_path%%balloon_icon%"
) ELSE (
	SET /A balloon_icon_exists_in_curr_dir=0
)

ECHO Balloon Icon Location: %balloon_icon_location%

IF %ERRORLEVEL% EQU 1 (
	SET "exception_message=No Folder Found (Path: HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings).. Quitting.."
	ECHO %exception_message%
	::Displaying exception as balloon in Action Center
	powershell.exe -noprofile -executionpolicy bypass -Command "& {$Text='%exception_message%'; $Title='%balloon_title%'; $IconType='%balloon_icon_type%'; $Timeout=%balloon_timeout%; $Icon='%balloon_icon_location%'; Add-Type -AssemblyName System.Windows.Forms; if ($script:balloon -eq $null){ $script:balloon=New-Object System.Windows.Forms.NotifyIcon; } if ([string]::IsNullOrEmpty($Icon)) { $path=Get-Process -id $pid | Select-Object -ExpandProperty Path; $balloon.Icon=[System.Drawing.Icon]::ExtractAssociatedIcon($path); } else { $balloon.Icon=[System.Drawing.Icon]::ExtractAssociatedIcon($Icon) } $balloon.BalloonTipIcon=$IconType; $balloon.BalloonTipText=$Text; $balloon.BalloonTipTitle=$Title; $balloon.Visible=$true; $balloon.ShowBalloonTip($Timeout); Start-Sleep -s ($Timeout / 1000); $balloon.Dispose();}"
	TIMEOUT 2 > NUL
)

SET /A set_hour_start=%current_hour%
SET /A set_hour_start_hex=!set_hour_start!
SET /A set_hour_end=%set_hour_start% + 18
SET /A set_hour_end_hex=!set_hour_end!

IF %set_hour_start% GTR 9 (
	call :ConvertDecToHex %set_hour_start% set_hour_start_hex
	REM SET /A set_hour_end=%set_hour_start% + 18
)

IF %set_hour_end% GTR 24 (
	SET /A set_hour_end=%set_hour_end% - 24
	SET /A set_hour_end_hex=!set_hour_end!
)

IF %set_hour_end% GTR 9 (
	call :ConvertDecToHex %set_hour_end% set_hour_end_hex
)

SET set_hour_start_hex=0x%set_hour_start_hex%
SET set_hour_end_hex=0x%set_hour_end_hex%

echo START HOUR: %set_hour_start_hex%
echo END HOUR: %set_hour_end_hex%

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