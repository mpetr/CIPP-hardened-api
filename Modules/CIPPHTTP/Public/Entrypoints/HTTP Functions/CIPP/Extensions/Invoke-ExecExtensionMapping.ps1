Function Invoke-ExecExtensionMapping {
  <#
    .FUNCTIONALITY
        Entrypoint,AnyTenant
    .ROLE
        CIPP.Extension.ReadWrite
    #>
  [CmdletBinding()]
  param($Request, $TriggerMetadata)

  $APIName = $Request.Params.CIPPEndpoint
  $Headers = $Request.Headers

  if ($Request.Query.List -in @('NinjaOne', 'NinjaOneFields') -or $Request.Query.AddMapping -in @('NinjaOne', 'NinjaOneFields') -or $Request.Query.AutoMapping -eq 'NinjaOne') {
    $Result = 'CIPP-hardened does not support the NinjaOne extension. Mapping and automapping are disabled by policy.'
    return ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::Gone
        Body       = $Result
      })
  }

  $Table = Get-CIPPTable -TableName CippMapping

  if ($Request.Query.List) {
    switch ($Request.Query.List) {
      'HaloPSA' { $Result = Get-HaloMapping -CIPPMapping $Table }
      'Hudu' { $Result = Get-HuduMapping -CIPPMapping $Table }
      'HuduFields' { $Result = Get-HuduFieldMapping -CIPPMapping $Table }
      'Sherweb' { $Result = Get-SherwebMapping -CIPPMapping $Table }
      'HaloPSAFields' {
        $TicketTypes = Get-HaloTicketType
        $Outcomes = Get-HaloTicketOutcome
        $Result = @{
          'TicketTypes' = $TicketTypes
          'Outcomes'    = $Outcomes
        }
      }
      'PWPushFields' {
        $Accounts = Get-PwPushAccount
        $Result = @{ 'Accounts' = $Accounts }
      }
    }
  }

  try {
    if ($Request.Query.AddMapping) {
      switch ($Request.Query.AddMapping) {
        'Sherweb' { $Result = Set-SherwebMapping -CIPPMapping $Table -APIName $APIName -Request $Request }
        'HaloPSA' { $Result = Set-HaloMapping -CIPPMapping $Table -APIName $APIName -Request $Request }
        'Hudu' {
          $Result = Set-HuduMapping -CIPPMapping $Table -APIName $APIName -Request $Request
          Register-CIPPExtensionScheduledTasks
        }
        'HuduFields' {
          $Result = Set-ExtensionFieldMapping -CIPPMapping $Table -APIName $APIName -Request $Request -Extension 'Hudu'
          Register-CIPPExtensionScheduledTasks
        }
      }
    }
    $StatusCode = [HttpStatusCode]::OK
  }
  catch {
    $ErrorMessage = Get-CippException -Exception $_
    $Result = "Mapping API failed. $($ErrorMessage.NormalizedError)"
    Write-LogMessage -API $APIName -headers $Headers -message $Result -Sev 'Error' -LogData $ErrorMessage
    $StatusCode = [HttpStatusCode]::InternalServerError
  }

  return ([HttpResponseContext]@{
      StatusCode = $StatusCode
      Body       = $Result
    })

}
