$conf = @{
    Address = "172.86.123.205"
    Username = "root"
    Password = "6f227684d439D$"
    SshHostKeyFingerprint = "ssh-rsa 3072 PqAcZt5RQU1FTMZIwhBdXe4ylqNflWOtGfNQ2ByWmyQ"
    DirectoryList = @(
        "d:\sftp\uploads_1",
        "d:\sftp\uploads_2",
        "d:\sftp\uploads_3"
    )
    throttlelimit = 9
}

function Get-Files {
    param(
        $Dirs
    )

    $files = @{}

    foreach ($dir in $Dirs){
        foreach ($file in Get-ChildItem $dir -Recurse -file){
            $files.Add($file.Fullname, [System.IO.Path]::GetDirectoryName($file.Fullname).Substring(([System.IO.DirectoryInfo]$dir).Parent.FullName.Length + 1).Replace("\", "/"))
        }
    }
    return $files
}


Add-Type -Path .\lib\WinSCP-5.21.5-Automation\WinSCPnet.dll

$ErrorActionPreference = 'stop'
$DebugPreference = 'continue'

$PSNativeCommandUseErrorActionPreference

$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol              = [WinSCP.Protocol]::Sftp
    HostName              = $conf.Address
    UserName              = $conf.Username
    Password              = $conf.Password
    SshHostKeyFingerprint = $conf.SshHostKeyFingerprint
}

$session = New-Object WinSCP.Session
$session.Open($sessionOptions)
$transferOptions = New-Object WinSCP.TransferOptions
$transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

workflow wf {

    param(
        $Files,
        $Session
    )

    foreach -parallel -throttlelimit $conf.throttlelimit ($key in $Files.Keys) {
        $subdirs = ($Files.$key).Split('/')
        for ($i = 0; $i -lt $subdirs.Count; $i++){
            $d = '{0}' -f ($subdirs[0..$i] -join '/')
            $exist = $session.FileExists($d)
            if (!$exist){
                $null = $Session.CreateDirectory($d)
            }
        }
        $transferResult = $Session.PutFileToDirectory($key, $Files.$key, $false, $transferOptions)
    }
}

$files = Get-Files -Dirs $conf.DirectoryList

wf $files $session

$session.Dispose()