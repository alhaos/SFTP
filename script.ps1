    Set-Location D:\repository\SFTP 
    $conf = Import-PowerShellDataFile .\conf.psd1

    # Load WinSCP .NET assembly
    Add-Type -Path .\lib\WinSCP-5.21.5-Automation\WinSCPnet.dll
 
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = $conf.Address
        UserName = $conf.Username
        Password = $conf.Password
        SshHostKeyFingerprint = "ssh-ed25519 255 d7Te2DHmvBNSWJNBWik2KbDTjmWtYHe2bvXTMM9lVg4"
    }
 
    $session = New-Object WinSCP.Session
 

    foreach($dir in $conf.DirectoryList){

            # Connect
            $session.Open($sessionOptions)
 
            # Download files
            $transferOptions = New-Object WinSCP.TransferOptions
            $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
 
            $transferResult =
            $session.GetFiles(
                (Join-Path $dir "*"), $conf.LocalDirecory, $False, $transferOptions
            )
 
            # Throw on any error
            $transferResult.Check()
 
    }
   
    $session.Dispose()
 
    