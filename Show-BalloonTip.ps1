# Based on https://gallery.technet.microsoft.com/scriptcenter/Show-BalloonTip-Show-a-1a932c95

[CmdletBinding(SupportsShouldProcess = $true)]
param
(
  [Parameter(Mandatory=$true)]
  $Text,
   
  [Parameter(Mandatory=$true)]
  $Title,
   
  [ValidateSet('None', 'Info', 'Warning', 'Error')]
  $IconType = 'Info',
  
  $Icon = '',
  
  $Timeout = 3000
)

function Show-BalloonTip($Text, $Title, $IconType, $Icon, $Timeout) 
{
  Add-Type -AssemblyName System.Windows.Forms

  if ($script:balloon -eq $null)
  {
    $script:balloon = New-Object System.Windows.Forms.NotifyIcon
  }
  
  if ([string]::IsNullOrEmpty($Icon))
  {
	$path                    = Get-Process -id $pid | Select-Object -ExpandProperty Path
	$balloon.Icon            = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
  } 
  else{
	$balloon.Icon			 = [System.Drawing.Icon]::ExtractAssociatedIcon($Icon)
  }

  $balloon.BalloonTipIcon  = $IconType
  $balloon.BalloonTipText  = $Text
  $balloon.BalloonTipTitle = $Title
  $balloon.Visible         = $true

  $balloon.ShowBalloonTip($Timeout)
  
  Start-Sleep -s ($Timeout / 1000)
  $balloon.Dispose()
} 

$(Show-BalloonTip $Text $Title $IconType $Icon $Timeout)