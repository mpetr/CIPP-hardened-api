function Invoke-CippGraphWebhookProcessing {
    [CmdletBinding()]
    param (
        $Data,
        $CIPPID,
        $WebhookInfo    
    )

    $Table = Get-CIPPTable -TableName Extensionsconfig

    $Configuration = ((Get-AzDataTableEntity @Table).config | ConvertFrom-Json)

        Switch ($WebhookInfo.Resource) {
            'devices' {
                # CIPP-hardened: NinjaOne is an unsupported optional extension.
                if ($Configuration.NinjaOne.Enabled -eq $True) {
                    Write-Warning 'CIPP-hardened does not support the NinjaOne extension. Device webhook processing is disabled.'
                }
            }
        }
        

    }
