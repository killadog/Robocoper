$Backups = @(
    , @("First Backup", "C:\Images", "D:\Backup\First", "0", "")
    , @("Second Backup", "C:\Documents", "D:\Backup\Second", "4", "/MT:8 /E /NDL /NP /R:1 /W:1")
    # , @("Third Backup", "C:\Bases", "D:\Backup\Third", "4", "")
    , @("Fourth Backup", "C:\Music", "D:\Backup\Fourth", "0", "")
    <# , @("Fifth Backup", "C:\PDFs", "D:\Backup\Fifth", "10", "/MT:8 /E /NDL /NP /R:1 /W:1")
    , @("Sixth Backup", "C:\XXX", "D:\Backup\Sixth", "4", "") #>
)

$DefaultParameters = "/MT:8 /E /NDL /NP /R:1 /W:1" # Default robocopy parameters
$SendEmail = $true
$SaveLog = $true
if ($SaveLog) {
    $LogDir = "D:\Backup\logs"
}
$str = "$($PSStyle.Foreground.BrightYellow)*$($PSStyle.Reset)" * 80 # Separation line for better log view

$LogTmpFile = (New-TemporaryFile).FullName | Rename-Item -NewName { $_ -replace 'tmp$', 'txt' } –PassThru

Start-Transcript -Append $LogTmpFile -UseMinimalHeader 

$TotalTime = Measure-Command {
    $BackupTable = @()
    $Backups | ForEach-Object {
        $RobocopyName = $_[0]
        $RobocopySource = $_[1]
        $RobocopyDestination = $_[2]
        $RobocopyDaysToLive = $_[3]
        $RobocopyParameters = $_[4]
        Write-Host "$str`n[$($Backups.IndexOf($_) + 1)/$($Backups.Count)] Backup: '$RobocopyName'"
        $StartTime = Get-Date -Format 'yyyy\/MM\/dd HH\:mm\:ss'
        $BackupTime = Measure-Command { 
            if ($RobocopyParameters -eq "") {
                $RobocopyParameters = $DefaultParameters
            }

            if ($RobocopyDaysToLive -ne 0) {
                $BackupFolder = $RobocopyDestination
                $RobocopyDestination = "$RobocopyDestination\$($RobocopyName.Replace(" ","_"))_$(Get-Date -Format 'ddMMyyyy_HHmmss')" 
            }

            Write-Host "robocopy $RobocopySource $RobocopyDestination $RobocopyParameters"
            robocopy $RobocopySource $RobocopyDestination $RobocopyParameters.split(' ') | Write-Host           
        }
 
        if ($LASTEXITCODE -le 3) {
            $Result = "Success"
            if ($RobocopyDaysToLive -ne 0) {
                Write-Host "`nDelete files older than $RobocopyDaysToLive days:"
                $DeleteFromDate = (Get-Date).AddDays(-$RobocopyDaysToLive)
                $WhatToDelete = Get-ChildItem -Path $BackupFolder | Where-Object { ($_.CreationTime -le $DeleteFromDate) -and ($_.LastWriteTime -le $DeleteFromDate) }
                if ($WhatToDelete.Count -ne 0) {
                    $WhatToDelete | Remove-Item -Recurse -Force -Verbose 
                }
                else {
                    Write-Host "Nothing to delete"
                }
            }
        }
        else {
            $Result = "Failed"
        }

        $number = $Backups.IndexOf($_) + 1
        $BackupTable += [PSCustomObject] @{
            'Number'      = "$(([string]$number).PadLeft(2,' '))/$($Backups.Count)"
            'Name'        = $RobocopyName
            'Result'      = "$Result ($LASTEXITCODE)"
            'Backup time' = $BackupTime.ToString("hh\:mm\:ss")
            'DaysToLive'  = $RobocopyDaysToLive
            'Source'      = $RobocopySource
            'Destination' = $RobocopyDestination
            'Start'       = $StartTime
            'End'         = Get-Date -Format 'yyyy\/MM\/dd HH\:mm\:ss'
        }
    }
}

if ($SaveLog) {
    Write-Host "$str`nCompress Log file '$LogTmpFile' to '$LogDir\log_$(Get-Date -UFormat "%Y%m%d-%H%M%S").zip'"
}

Stop-Transcript

Compress-Archive -Path $LogTmpFile -DestinationPath $LogDir\log_$(Get-Date -UFormat "%Y%m%d-%H%M%S").zip

$BackupTable = $BackupTable |  Format-Table -Property @{n = "Number"; e = { $_.Number }; a = "center" },
@{n = "Name"; e = { $_.'Name' }; a = "center" },
@{n = "Result"; e = { $_.'Result' }; a = "center" },
@{n = "Backup time"; e = { $_.'Backup time' }; a = "center" },
@{n = "DTL"; e = { $_.DaysToLive }; a = "center" },
@{n = "Source"; e = { $_.'Source' }; a = "left" },
@{n = "Destination"; e = { $_.'Destination' }; a = "left" }, 
@{n = "Start time"; e = { $_.'Start' }; a = "center" },
@{n = "End time"; e = { $_.'End' }; a = "center" } -AutoSize | Out-String -Width 512

if ($SendEmail) {
    $body = Get-Content -Path $LogTmpFile | Out-String 
    $body = "Total backup time: $($TotalTime.ToString('hh\:mm\:ss'))`n$($BackupTable)" + $body
    $email = get-content -Path $PSScriptRoot\email.json -Raw | ConvertFrom-Json
    $EmailSubject = "robocopy"
    $secpasswd = ConvertTo-SecureString $email.EmailPassword -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential ($email.EmailFrom, $secpasswd)
    $encoding = [System.Text.Encoding]::UTF8
    [System.Net.ServicePointManager]::SecurityProtocol = "Tls, TLS11, TLS12" # Uncomment this line for TLS not SSL
    Send-MailMessage `
        -To $email.EmailTo `
        -Subject $EmailSubject `
        -Body $body `
        -SmtpServer $email.EmailSmtpServer `
        -Credential $mycreds `
        -Port $email.EmailSmtpPort `
        -UseSsl `
        -from "$($env:COMPUTERNAME) <$($email.EmailFrom)>" `
        -Encoding $encoding `
        -WarningAction:SilentlyContinue 
    Write-Host "Send e-mail to $($email.EmailTo)"
}

$str
Remove-Item -Path $LogTmpFile -Force -Verbose -ErrorAction SilentlyContinue

$str
$BackupTable
Write-Host "Total backup time: $($TotalTime.ToString('hh\:mm\:ss'))"