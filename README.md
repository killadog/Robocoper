# Robocoper
*Windows backup CLI tool based on [Robocopy](https://en.wikipedia.org/wiki/Robocopy)*

![Powershell](https://img.shields.io/badge/Powershell-blue.svg)

<p align="center">
<img src="img/robocoper10.png" alt="Robocoper" width="620" />
</p>

### Features

- Backup a batch of sources by one tool
- Delete backups older than *N* days
- Send email about work
- Save compressed log 

### Tested on

- [Windows Server 2019](https://en.wikipedia.org/wiki/Windows_Server_2019)
- [Powershell](https://docs.microsoft.com/ru-ru/powershell/scripting/install/installing-powershell) 7.2.7

### Requirements
- [Windows](https://en.wikipedia.org/wiki/Microsoft_Windows)
- [Robocopy](https://en.wikipedia.org/wiki/Robocopy)

### Preparation

- Change settings in `email.json`:
```
$EmailTo = 'example@example.com'
$EmailFrom = 'example@example.com'
$EmailPassword = '$eCr3tP@$sW0Rd'
$EmailSmtpServer = 'smtp.example.com'
$EmailSmtpPort = 587
```
- Uncomment this line to use TLS not SSL for e-mail

`[System.Net.ServicePointManager]::SecurityProtocol = "Tls, TLS11, TLS12"`

- Turn ON e-mail notifications

`$SendEmail = $true`

- Turn ON log saving

`$SaveLog = $true`

`$LogDir = "D:\Backup\logs"`

### Usage

In array `$Backups` insert line(s) for backup

, @('`Name`', '`Source`', '`Destination`', '`DTL`', '`Parameters`')

|Option|Explanation|Example|Default value|
|---|---|---|:---:|
|**Name**|Backup name|My code||
|**Source**|Backup from|C:\code||
|**Destination**|Backup to|D:\Backup||
|**DTL**|Days to live<sup>[1]</sup>|10|0|
|**Parameters**|Robocopy parameters|[Read Robocopy syntax](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy)|$DefaultParameters|

*Note:* disable backups by `#` at the begin of line or `<# ... #>` for multiline.

[1] - '`Days to live`' means that new backup will be in `Destination\NAME_YYMMDD_HHMMSS`. After it all folders and files older than `DTL` days will be deleted in `Destination`. If `DTL` is `"0"` backup will be in `Destination` with `default` or special parameters.

<!-- Important
To change codepage/encoding play with lines:
```
#chcp 866 | out-null
#chcp 65001 | out-null
...
$body = Get-Content -Path $LogTmpFile | Out-String 
```
-->






