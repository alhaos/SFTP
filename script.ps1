$conf = Import-PowerShellDataFile .\conf.psd1
Add-Type -Path .\lib\WinSCP-5.21.5-Automation\WinSCPnet.dll

$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol              = [WinSCP.Protocol]::Sftp
    HostName              = $conf.Address
    UserName              = $conf.Username
    Password              = $conf.Password
    SshHostKeyFingerprint = "ssh-ed25519 255 d7Te2DHmvBNSWJNBWik2KbDTjmWtYHe2bvXTMM9lVg4"
}

$session = New-Object WinSCP.Session

foreach ($dir in $conf.DirectoryList) {
    $session.Open($sessionOptions)
    $transferOptions = New-Object WinSCP.TransferOptions
    $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
    $transferResult =
    $session.GetFiles((Join-Path $dir "*"), $conf.LocalDirecory, $False, $transferOptions)
    $transferResult.Check()
}

$session.Dispose()

