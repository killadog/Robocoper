# Robocoper
*Simple backup tool based on [Robocopy](https://en.wikipedia.org/wiki/Robocopy)*

![Powershell](https://img.shields.io/badge/Powershell-blue.svg)

<p align="center">
<img src="img/robocoper10.png" alt="Robocoper" width="520" />
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

- [Robocopy](https://en.wikipedia.org/wiki/Robocopy)

### Preparation

- Change lines in `email.json` for e-mail settings:
```
$EmailTo = 'example@example.com'
$EmailFrom = 'example@example.com'
$EmailPassword = '$eCr3tP@$sW0Rd'
$EmailSmtpServer = 'smtp.example.com'
$EmailSmtpPort = 587
```
- Uncomment this line to use TLS not SSL for e-mail

`[System.Net.ServicePointManager]::SecurityProtocol = "Tls, TLS11, TLS12"`

- To turn ON e-mail notifications

`$SendEmail = $true`

- To turn ON log saving

`$SaveLog = $true`

`$LogDir = "D:\Backup\logs"`

### Usage

In array `$Backups` insert line(s) for backup

, @("`Name`", "`Source`", "`Destination`", "`DTL`", "`Parameters`")

|Option|Explanation|Example|Default value|
|---|---|---|:---:|
|**Name**|Backup name|My code||
|**Source**|Backup from|C:\code||
|**Destination**|Backup to|D:\Backup||
|**DTL**|Days to live<sup>[1]</sup>|10|0|
|**Parameters**|Robocopy syntax|[Syntax](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy)|$DefaultParameters|

*Note:* disable backups by `#` at the begin of line or `<# ... #>` for multiline.

[1] - '`Days to live`' means that new backup create folder `NAME_YYYYMMDD_HHMMSS` in `Destination`. After it all folders and files older than `N` days will be deleted in `Destination`. If `DTL` is `""` backup will
be in `Destination` with `default` or special parameters.
<!--> Important
To change codepage/encoding play with lines:
```
#chcp 866 | out-null
#chcp 65001 | out-null
...
$body = Get-Content -Path $LogTmpFile | Out-String 
```
-->






