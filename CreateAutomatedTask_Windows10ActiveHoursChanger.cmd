@ECHO OFF

schtasks /create /sc ONLOGON /tn "UAC\Windows Active Hours Changer" /tr "%cd%\Releases\v1.0\Windows10ActiveHoursChanger.exe" /rl HIGHEST /it /f
schtasks /change /ri 60 /tn "UAC\Windows Active Hours Changer"

ECHO "Successfully added the task into the Task Scheduler.. Quitting.."
TIMEOUT 2 > NUL