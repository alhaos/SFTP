$cred = Get-Credential -Credential manticore\richard

function ppdemo5 {
  param ($credential)
  $computers = Get-VM -Name W19* | Where-Object Name -ne 'W19ND01' | 
  Sort-Object -Property Name |
  Select-Object -ExpandProperty Name

foreach -parallel ($computer in $computers){

<#
 Invoke-Command isn't activity so has to 
  be inside an inlinescript block
#>

  inlinescript {
      $count = Invoke-Command -ScriptBlock {
        Get-WinEvent -FilterHashtable @{LogName='Application'; Id=2809} -ErrorAction SilentlyContinue  |
        Measure-Object 
      } -VMName $using:computer -Credential $using:credential

      $props = [ordered]@{
        Server = $count.PSComputerName
        ErrorCount = $count.Count
      }
  
      New-Object -TypeName PSObject -Property $props
  }  
}
}

ppdemo5 -credential $cred | Select-Object Server, ErrorCount 