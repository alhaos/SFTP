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
    RemotePath = "/"
}

Add-Type -Path .\lib\WinSCP-5.21.5-Automation\WinSCPnet.dll
$ErrorActionPreference = 'stop'

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
    foreach -parallel ($dir in $conf.DirectoryList) {
        $transferResult = $session.PutFiles($dir, "/", $false, $transferOptions)
    }
}

$session.Dispose()