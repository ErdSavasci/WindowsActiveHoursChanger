@ECHO OFF

set "current_script_path=%~dp0"

schtasks /create /sc ONLOGON /tn "UAC\Windows 10 Active Hours Changer" /tr "\"%current_script_path%\Releases\v1.2\Windows10ActiveHoursChanger.exe\"" /rl HIGHEST /it /f
schtasks /change /ri 60 /tn "UAC\Windows 10 Active Hours Changer"

ECHO "Successfully added the task into the Task Scheduler.. Quitting.."
TIMEOUT 2 > NUL