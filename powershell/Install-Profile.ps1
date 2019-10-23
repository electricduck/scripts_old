#  ____             _             ___  
# |  _ \ _   _  ___| | ___   _   / \ \ 
# | | | | | | |/ __| |/ | | | | / / \ \
# | |_| | |_| | (__|   <| |_| |/ /  / /
# |____/ \__,_|\___|_|\_\\__, /_/  /_/ 
# ====================== |___/ ========
# Ducky's PowerShell Profile, v19.7.25
################################################################################
# #[Hostname\Username:Me]##################################################[x]#
# #                                                                           #
# #        ###############                                                    #
# #       ##   ##########  $ PowerShell 6.1.0                                 #
# #      ####   ########   # ConsoleHost                                      #
# #     ######   ######    ~ Windows 10 October 2018 Update                   #
# #    ####   ########     @ Hostname\Username                                #
# #   ##   ###     ##      + 2 hours                                          #
# #  ###############                                                          #
# #                                                                           #
# # Hostname\Username:(C)/Users/Me                                            #
# # posh-6.1$ _                                                               #
# #                                                                           #
# #############################################################################
#
# HOW TO INSTALL
#  1) Download this file (and save it as 'install-profile.ps1')
#  2) Run `./install-profile.ps1`
#  3) Restart your shell
#
# SUPPORTED ENVIRONMENTS
#  - PowerShell 5.1
#   - Previous versions may work, but they have not been tested.
#  - PowerShell Core 6.0 (and above)
#  - Any OS that supports PowerShell (or PowerShell Core)
#   - I am no longer in posession of a macOS install, however, there
#     is no reason for things to not work.
#
# INJECTING ADDITIONAL COMMANDS
#  If you need to inject anything extra (like a custom PATH, or aliases),
#  you will find them in the same directory as this profile. To reveal the
#  location, run:
#   `$extraCommandsLocation`
#  This file is not create by default, but you can create it with:
#   `New-Item -Type File $extraCommandsLocation`
#  You can then edit it using your favourite text editor, like:
#   `nano $extraCommandsLocation`;
#   `notepad $extraCommandsLocation`;
#   `code $extraCommandsLocation`
#  Add commands on each line (no empty lines!), and these will be ran on
#  startup. For example, to add extra things to the PATH, add:
#   `$Env:PATH += ":/opt/myapp/:/home/me/bin/"`
#
# ADDITIONAL CONFIGURATION
#  This script is built to be minimal and out-of-the-box, so no additional
#  configuration is available (other than injecting custom commands, as above).
#  There's plenty of other resources out there if you need such a thing.
#
# UPDATING
#  This profile is updated often, so make sure to run `Update-Profile` every
#  once-in-a-while. This will download the script and replace your old $profile.
#
# UNINSTALLING
#  To remove, run `Uninstall-Profile`. This will leave behind the
#  $extraCommandsLocation file, and will not affect anything else.
#
# OTHER COMMANDS
#  `Get-ProfileVersion`: [String] Get version of Ducky's PowerShell Profile you
#                        are using.
#
# CONTRIBUTING
#  This is part of Ducky's scripts repository, found at
#  https://github.com/electricduck/scripts. You may submit PRs and issues there.
#
# ENJOY! :)
################################################################################

function Get-ProfileVersion {
    return "19.7.25"
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

enum OS {
    Windows
    MacOS
    Linux
}

enum Themes {
    Normal
    Gay
}

$extraCommandsLocation = $profile.ToString().Replace(".ps1", ".extra.ps1")
$hostname = ([net.dns]::GetHostName())
[OS]$global:opSys = [OS]::Windows
$powershellVersion = ""
$powershellVersionShort = ""
$user = ([Environment]::UserName)

$powershellVersion = $PSVersionTable.PSVersion
$powershellVersionShort = $powershellVersion.Major.ToString() + "." + $powershellVersion.Minor.ToString()

Set-Alias -Name clear -Value Reload-Shell -Option AllScope

[Themes]$global:currentTheme = [Themes]::Normal

function Get-OSRelease {
    if($powershellVersion.Major -lt 6)
    {
        $global:opSys = [OS]::Windows
    }
    else
    {
        if($IsWindows) { $global:opSys = [OS]::Windows }
        if($IsMacOS) { $global:opSys = [OS]::MacOS }
        if($IsLinux) { $global:opSys = [OS]::Linux }
    }

    $opSysVersion = [Environment]::OSVersion.Version

    switch($global:opSys)
    {
        Windows
        {
            #Get-ItemPropertyValue HKLM:\SOFTWARE\Microsoft\"Windows NT"\CurrentVersion "ProductName"
            $productType = (Get-WmiObject -Class Win32_OperatingSystem).ProductType # TODO: Handle permission error when calling Get-CimInstance on non-Admin account
            $isServer = $false

            if($productType -eq 3)
            {
                $isServer = $true
            }

            if($isServer -eq $true)
            {
                switch($opsysVersion.Build)
                {
                    7600 { "Windows Server 2008 R2" }
                    7601 { "Windows Server 2008 R2 SP1"}
                    9200 { "Windows Server 2012" }
                    9600 { "Windows Server 2012 R2"}
                    14393 { "Windows Server 2016" }
                    16299 { "Windows Server SARC 1709" }
                    17134 { "Windows Server SARC 1803" }
                    #17763 { "Windows Server SARC 1809" }
                    17763 { "Windows Server 2019" }
                    18362 { "Windows Server SARC 1903" }
                    default {
                        if($opSysVersion.Build -gt 9841)
                        {
                            "Windows Server vNext (Build " + $opSysVersion.Build.ToString() + ")"
                        }
                        else
                        {
                            "Windows Server " + " " + $opSysVersion.Major.ToString() + "." + $opSysVersion.Minor.ToString() + "." + $opSysVersion.Build.ToString()
                        }  
                    }
                }
            }
            else
            {
                switch($opSysVersion.Build)
                {
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
                    18362 { "Windows 10 May 2019 Update" }
                    18363 { "Windows 10 November 2019 Update" }
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
            }
        }
        MacOS
        {
            switch ($opSysVersion.Major)
            {
                14 { "OSX Yosemite" }
                15 { "OSX El Capitan" }
                16 { "macOS Sierra" }
                17 { "macOS High Sierra" }
                18 { "macOS Mojave" }
                19 { "macOS Catalina" }
                default { "macOS" + " " + $opSysVersion.Major.ToString() + "." + $opSysVersion.Minor.ToString() }
            }
        }
        Linux
        {
            $linuxKernelVersion = $opSysVersion.Major.ToString() + "." + $opSysVersion.Minor.ToString()

            if (!(Get-Command "lsb_release" -errorAction SilentlyContinue))
            {
                "Linux" + " " + $linuxKernelVersion
            }
            else
            {
                $linuxOSDescription = lsb_release -d -s
                $linuxOSDescription.ToString().Replace("elementary OS", "elementaryOS").Replace("Debian GNU/Linux", "Debian")
            }
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

function Set-Theme {
    $currentDate = (get-date)
    $currentMonth = (get-date).ToString("MM")
    $currentDay = (get-date).ToString("dd")

    switch($currentMonth)
    {
        "06"
        {
            $global:currentTheme = [Themes]::Gay
        }
    }
}

function Set-WelcomeMessageColors {
    switch($global:currentTheme)
    {
        Gay
        {
            $global:logoColor1 = "DarkRed"
            $global:logoColor2 = "Red"
            $global:logoColor3 = "Yellow"
            $global:logoColor4 = "Green"
            $global:logoColor5 = "Cyan"
            $global:logoColor6 = "Magenta"
            $global:logoColor7 = "DarkMagenta"
        }
        default
        {
            $global:logoColor1 = "Cyan"
            $global:logoColor2 = "Cyan"
            $global:logoColor3 = "Cyan"
            $global:logoColor4 = "Cyan"
            $global:logoColor5 = "Cyan"
            $global:logoColor6 = "Cyan"
            $global:logoColor7 = "Cyan"
        }
    }
}

function Get-WelcomeMessage {
    $opSysRelease = Get-OSRelease
    $uptime = Get-OSUptime

    Set-WelcomeMessageColors

    Write-Host " "
    Write-Host "       ############### " -f $global:logoColor1
    Write-Host "      ##   ##########  " -f $global:logoColor2 -n
    Write-Host "$ " -f Red -n
    Write-Host "PowerShell $powershellVersion" -f White
    Write-Host "     ####   ########   " -f $global:logoColor3 -n
    Write-Host "# " -f Yellow -n
    Write-Host $Host.Name -f White
    Write-Host "    ######   ######    " -f $global:logoColor4 -n
    Write-Host "~ " -f Green -n
    Write-Host $opSysRelease -f White
    Write-Host "   ####   ########     " -f $global:logoColor5 -n
    Write-Host "@ " -f Cyan -n
    Write-Host $hostname -f White -n
    Write-Host "\" -f Gray -n
    Write-Host $user -f White
    Write-Host "  ##   ###     ##      " -f $global:logoColor6 -n
    Write-Host "+ " -f Magenta -n
    Write-Host $uptime -f White
    Write-Host " ###############       " -f $global:logoColor7
    Write-Host " "
}

function Reload-Shell {
    Clear-Host
    Set-Theme
    Get-WelcomeMessage
}

function Set-WindowTitle {
    Param(
        [string]$newTitle
    )

    if($global:opSys -eq [OS]::Windows) {
        $shortLocation = Split-Path -leaf -path (Get-Location)

        if($newTitle) {
            $Host.ui.rawui.WindowTitle = $newTitle
        } else {
            $Host.ui.rawui.WindowTitle = $hostname + "\" + $user + ":" + $shortLocation
        }
    } else {
        if($newTitle) {
            $Host.ui.rawui.WindowTitle = $newTitle
        } else {
            $Host.ui.rawui.WindowTitle = $hostname + "\" + $user
        }
    }
}

function Update-Profile {
    New-Item $profile -ItemType file -ErrorAction SilentlyContinue -Force | Out-Null
    Invoke-WebRequest https://raw.githubusercontent.com/electricduck/scripts/master/powershell/Install-Profile.ps1 -out $profile | Out-Null

    Write-Host "Updated. " -f Gray -n
    Write-Host "Restart your shell to use!" -f White
}

function Uninstall-Profile {
    Remove-Item -Force $profile | Out-Null
    Stop-Process -Id $PID
}

function Set-DefaultPath {
    switch($opSys)
    {
        MacOS
        {
            Set-Item Env:PATH "/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/share/dotnet:/opt/local/bin:/opt/local/sbin:/sw/bin:/sw/sbin"
        }
        Linux
        {
            Set-Item Env:PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        }
    }
}

function Invoke-ExtraCommands {
    if(Test-Path $extraCommandsLocation) {
        $commands = Get-Content $extraCommandsLocation
        foreach($command in $commands) {
            Invoke-Expression -Command $command
        }
    }
}

if($Host.Name.ToString() -eq "ConsoleHost") {
    Set-DefaultPath
    Invoke-ExtraCommands
    Reload-Shell

    function prompt {
        $fullLocation = (Get-Location).ToString()

        if($global:opSys -eq [OS]::Windows)
        {
            $fullLocation = "(" + (Get-Location).ToString().Replace(":", ")").Replace("\", "/")
        }

        Set-WindowTitle

        Write-Host " "
        Write-Host $hostname -n -f Magenta
        Write-Host "\" -n
        Write-Host $user -n -f Cyan
        Write-Host ":" -n
        Write-Host $fullLocation -f Yellow
        Write-Host "posh-" -n
        Write-Host $powershellVersionShort -n
        Write-Host "$" -n -f Green
        return ' '
    }
}
