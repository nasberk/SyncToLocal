<#
.SYNOPSIS
	This Script is for sync files to an local path 

.DESCRIPTION
	This Script is for sync files to an local path 

.PARAMETER <SourcePath>
	Specify the path to download

.LINK
	http://social.technet.microsoft.com/Forums/de-DE/bd084de8-4008-4cd2-bec5-ba1aeef9b581/powershelskript-aus-dem-kontextmen-starten?forum=powershell_de

.NOTES
	Version: 		<1.0.0>
	Author: 		<HpotsirhcH>
	Creation Date:	<2014-04-11>
	
.EXAMPLE
	<Example goes here. Repeat this attribute for more than one example>
#>

#---[ Parameters ]---------------------------------------------------------------------------------

Param (
    [Parameter(Mandatory=$true,Position=0)][string]$SourcePath = "NOPATH"
)

#---[ Initialisations ]----------------------------------------------------------------------------

#ErrorAction and clear of error variable
$Error.clear()

# Local Copy dir
$LocalCopyDir = "D:\LocalCopy\"

# MSG BOX init
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

#---[ Execution ]----------------------------------------------------------------------------------

# check $SourcePath
If ($SourcePath -eq "NOPATH")
{ 
	[void][System.Windows.Forms.MessageBox]::Show("Fehler - Kein Pfad wurde gesetzt. $([System.Environment]::NewLine)Error - No Path was set.","Fehler - Error",[System.Windows.Forms.MessageBoxButtons]::OK,16)
	exit
}

# Create Path if not exist
If (!(Test-Path -Path $LocalCopyDir)){ New-Item -Path $LocalCopyDir -Force -Type directory }

# check local drives c:\ d:\
If ($SourcePath.substring(0,3) -eq "c:\")
{
	[void][System.Windows.Forms.MessageBox]::Show("Fehler - Keine Kopie von Lokalen Daten moeglich. $([System.Environment]::NewLine)Error - No Copy from local data possible.","Fehler - Error",[System.Windows.Forms.MessageBoxButtons]::OK,16) 
}
Elseif ($SourcePath.substring(0,3) -eq "D:\")
{
	[void][System.Windows.Forms.MessageBox]::Show("Fehler - Keine Kopie von Lokalen Daten moeglich. $([System.Environment]::NewLine)Error - No Copy from local data possible.","Fehler - Error",[System.Windows.Forms.MessageBoxButtons]::OK,16) 
}
else
{
	# check SubFolder name
	If ($SourcePath.substring(1,2) -eq ":\") { $subfolder = $SourcePath.substring(3) }
	ElseIf ($SourcePath.substring(0,2) -eq "\\") 
	{ 
		$pieces = $SourcePath.split("\")
		$i = $pieces[3].length + 2
		$subfolder = $SourcePath.substring($i) 
	}
	$SubLocalCopyDir = $LocalCopyDir + $subfolder
	
	# check folder Size
	If (!(Test-Path -Path $SubLocalCopyDir))
	{
		Write-Host ""
		Write-Host "Check laeuft. Bitte Warten."
		Write-Host "Check runs. Please Wait."
		Write-Host "........."
		$Sum_Folder_Size = (Get-ChildItem $SourcePath -recurse | Measure-Object -property length -sum)
		$FolderSize = "{0:0}" -f ($Sum_Folder_Size.sum / 1GB)
		If ($FolderSize -ge 1)
		{
			$return = [System.Windows.Forms.MessageBox]::Show("Achtung - Gesamt Groesse ueber $FolderSize GB, sind Sie sich sicher das zu kopieren? $([System.Environment]::NewLine)Warning - Total size is greater than $FolderSize GB, are you sure to copy that?","Achtung - Warning",[System.Windows.Forms.MessageBoxButtons]::YesNo,48) 
			If ($return -eq "No") { exit }	# User Canceld program -- exit
		}
		# create SubFolder
		New-Item -Path $SubLocalCopyDir -Force -Type directory
	}
	# start copy
	robocopy $SourcePath $SubLocalCopyDir /E /Z /Purge /DCOPY:T /IPG:250 /R:3 /w:5
}

# Program end
Exit
