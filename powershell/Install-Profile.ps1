#  ____             _             ___  
# |  _ \ _   _  ___| | ___   _   / \ \ 
# | | | | | | |/ __| |/ | | | | / / \ \
# | |_| | |_| | (__|   <| |_| |/ /  / /
# |____/ \__,_|\___|_|\_\\__, /_/  /_/ 
# ====================== |___/ ========         
# Ducky's PowerShell Profile, v19.7.9

function Get-ProfileVersion {
    return "19.7.9"
}

if($MyInvocation.MyCommand.Name.ToLower() -eq "install-profile.ps1")
{
    New-Item $profile -ItemType file -ErrorAction SilentlyContinue -Force | Out-Null
    Copy-Item $MyInvocation.MyCommand.Path $profile

    $profileVersion = Get-ProfileVersion

    Write-Host "Installed " -f Gray -n
    Write-Host "Ducky's PowerShell Profile " -f Cyan -n
    Write-Host $profileVersion -f White -n
    Write-Host ". Enjoy!" -f Gray
    Write-Host "================================================================================"  -f DarkGray
    Write-Host "Remember to stay up-to-date; use " -f Gray -n
    Write-Host "Update-Profile " -f Yellow -n
    Write-Host "to automagically download and" -f Gray
    Write-Host "install. If you regret your current life decisions, turn back the clock with " -f Gray
    Write-Host "Uninstall-Profile" -f Yellow -n
    Write-Host "." -f Gray
    Write-Host "================================================================================"  -f DarkGray
    Write-Host "Restart your shell to use!" -f White

    Exit 0
}

Clear-Host

$extraCommandsLocation = $profile.ToString().Replace(".ps1", ".extra.ps1")
$gaaaay = $false
$opSys = ([Environment]::OSVersion.Platform.ToString()).Replace("Win32NT", "Windows")
$opSysHost = ([net.dns]::GetHostName())
$opSysKernel = ""
$powershellVersion = ""
$powershellVersionShort = ""
$user = ([Environment]::UserName)

$powershellVersion = $PSVersionTable.PSVersion
$powershellVersionShort = $powershellVersion.Major.ToString() + "." + $powershellVersion.Minor.ToString()

Set-Alias -Name clear -Value Reload-Shell -Option AllScope

function Get-OSKernel {
    $opSys = ([Environment]::OSVersion.Platform.ToString()).Replace("Win32NT", "Windows")

    if($opSys -eq 'Unix') {
        $unameCommand = "uname -s"

        $unixKernel = Invoke-Expression $unameCommand

        return $unixKernel
    } elseif($opSys -eq 'Windows') {
        return 'Windows'
    }
}

function Get-OSRelease {
    # TODO: Refactor this

    $opSysKernel = Get-OSKernel
    $opSysVersion = [Environment]::OSVersion.Version

    if($opSysKernel -eq 'Darwin') {
        switch ($opSysVersion.Major)
            {
                14 { "OSX Yosemite" }
                15 { "OSX El Capitan" }
                16 { "macOS Sierra" }
                17 { "macOS High Sierra" }
                18 { "macOS Mojave" }
                default { "Darwin" + " " + $opSysVersion.Major.ToString() + "." + $opSysVersion.Minor.ToString() }
            }
    } elseif($opSys -eq 'Windows') {
        #Get-ItemPropertyValue HKLM:\SOFTWARE\Microsoft\"Windows NT"\CurrentVersion "ProductName"
        #return (get-ciminstance Win32_OperatingSystem).Caption.Replace("Microsoft ", "")
        switch($opSysVersion.Build) {
            7600 { "Windows 7" }
            7601 { "Windows 7 SP1" }
            9200 { "Windows 8" }
            9600 { "Windows 8.1" }
            10240 { "Windows 10" }
            10586 { "Windows 10 November Update" }
            14393 { "Windows 10 Anniversary Update" }
            15063 { "Windows 10 Creators Update" }
            16299 { "Windows 10 Fall Creators Update" }
            17134 { "Windows 10 April 2018 Update" }
            17763 { "Windows 10 October 2018 Update" }
            default {
                if($opSysVersion.Build -gt 9841)
                {
                    "Windows 10 Insider (Build " + $opSysVersion.Build.ToString() + ")"
                }
                else
                {
                    "Windows" + " " + $opSysVersion.Major.ToString() + "." + $opSysVersion.Minor.ToString() + "." + $opSysVersion.Build.ToString()
                }
            }
        }
    } elseif($opSysKernel -eq 'Linux') {
        $linuxKernelVersion = $opSysVersion.Major.ToString() + "." + $opSysVersion.Minor.ToString()

        if (!(Get-Command "lsb_release" -errorAction SilentlyContinue))
        {
            "Linux" + " " + $linuxKernelVersion
        }
        else
        {
            $linuxOSDescription = lsb_release -d -s
            $linuxOSDescription.ToString().Replace("elementary OS", "elementaryOS")
        }
    }
}

function Get-OSUptime {
    $totalHoursUptime = 0
    $totalHoursUptimeRounded = 0
    $totalDaysUptime = 0

    Try {
        $uptimeOutput = Get-Uptime

        $totalHoursUptime = $uptimeOutput.TotalHours
        $totalHoursUptimeRounded = [Math]::Round($totalHoursUptime)
        $totalDaysUptime = $uptimeOutput.Days
    } Catch {
        $windowsObject = Get-WmiObject win32_operatingsystem
        $uptimeOutput = (Get-Date) - ($windowsObject.ConvertToDateTime($windowsObject.lastbootuptime))
        
        $totalHoursUptime = $uptimeOutput.TotalHours
        $totalHoursUptimeRounded = [Math]::Round($totalHoursUptime)
        $totalDaysUptime = $uptimeOutput.Days
    }

    if($totalDaysUptime -eq 0) {
        return $totalHoursUptimeRounded.ToString() + " hours"
    } elseif ($totalDaysUptime -eq 1) {
        return $totalHoursUptimeRounded.ToString() + " hours (" + $totalDaysUptime + " day)"
    } else {
        return $totalHoursUptimeRounded.ToString() + " hours (" + $totalDaysUptime + " days)"
    }
}

function Get-WelcomeMessage {
    $opSysRelease = Get-OSRelease
    $uptime = Get-OSUptime

    if((get-date).ToString("MM") -eq "06")
    {
        $gaaaay = $true
    }

    if($gaaaay)
    {
        $logoColor1 = "DarkRed"
        $logoColor2 = "Red"
        $logoColor3 = "Yellow"
        $logoColor4 = "Green"
        $logoColor5 = "Cyan"
        $logoColor6 = "Magenta"
        $logoColor7 = "DarkMagenta"
    }
    else
    {
        $logoColor1 = "Cyan"
        $logoColor2 = "Cyan"
        $logoColor3 = "Cyan"
        $logoColor4 = "Cyan"
        $logoColor5 = "Cyan"
        $logoColor6 = "Cyan"
        $logoColor7 = "Cyan"
    }

    Write-Host " "
    Write-Host "       ############### " -f $logoColor1
    Write-Host "      ##   ##########  " -f $logoColor2 -n
    Write-Host "$ " -f Red -n
    Write-Host "PowerShell $powershellVersion" -f White
    Write-Host "     ####   ########   " -f $logoColor3 -n
    Write-Host "# " -f Yellow -n
    Write-Host $Host.Name -f White
    Write-Host "    ######   ######    " -f $logoColor4 -n
    Write-Host "~ " -f Green -n
    Write-Host $opSysRelease -f White
    Write-Host "   ####   ########     " -f $logoColor5 -n
    Write-Host "@ " -f Cyan -n
    Write-Host $opSysHost -f White -n
    Write-Host "\" -f Gray -n
    Write-Host $user -f White
    Write-Host "  ##   ###     ##      " -f $logoColor6 -n
    Write-Host "+ " -f Magenta -n
    Write-Host $uptime -f White
    Write-Host " ###############       " -f $logoColor7
    Write-Host " "
}

function Reload-Shell {
    Clear-Host
    Get-WelcomeMessage
}

function Set-WindowTitle {
    Param(
        [string]$newTitle
    )

    if($opSysKernel -eq 'Windows') {
        $shortLocation = Split-Path -leaf -path (Get-Location)

        if($newTitle) {
            $Host.ui.rawui.WindowTitle = $newTitle
        } else {
            $Host.ui.rawui.WindowTitle = $opSysHost + "\" + $user + ":" + $shortLocation
        }
    } else {
        if($newTitle) {
            $Host.ui.rawui.WindowTitle = $newTitle
        } else {
            $Host.ui.rawui.WindowTitle = $opSysHost + "\" + $user
        }
    }
}

function Update-Profile {
    New-Item $profile -ItemType file -ErrorAction SilentlyContinue -Force | Out-Null
    Invoke-WebRequest https://raw.githubusercontent.com/electricduck/scripts/master/powershell/Install-Profile.ps1 -out $profile | Out-Null

    Write-Host "Updated! " -f Gray -n
    Write-Host "Restart your shell to use!" -f White
}

function Uninstall-Profile {
    Remove-Item -Force $profile | Out-Null
    Stop-Process -Id $PID
}

$opSysKernel = Get-OSKernel
if($opSysKernel -eq 'Darwin') {
    Set-Item Env:PATH "/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/share/dotnet:/opt/local/bin:/opt/local/sbin:/sw/bin:/sw/sbin"
} elseif($opSysKernel -eq 'Linux') {
    Set-Item Env:PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}

if(Test-Path $extraCommandsLocation) {
    $commands = Get-Content $extraCommandsLocation
    foreach($command in $commands) {
        Invoke-Expression -Command $command
    }
}

if($Host.Name.ToString() -eq "ConsoleHost") {
    Get-WelcomeMessage
}

function prompt {
    $fullLocation = (Get-Location).ToString()

    if($opSysKernel -eq 'Windows')
    {
        $fullLocation = "(" + (Get-Location).ToString().Replace(":", ")").Replace("\", "/")
    }

    Set-WindowTitle

    Write-Host " "
    Write-Host $opSysHost -n -f Magenta
    Write-Host "\" -n
    Write-Host $user -n -f Cyan
    Write-Host ":" -n
    Write-Host $fullLocation -f Yellow
    Write-Host "posh-" -n
    Write-Host $powershellVersionShort -n
    Write-Host "$" -n -f Green
    return ' '
}