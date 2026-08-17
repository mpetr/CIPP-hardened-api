Function Invoke-ExecExtensionSync {
    <#
    .FUNCTIONALITY
        Entrypoint
    .ROLE
        CIPP.Extension.ReadWrite
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)
    switch ($Request.Query.Extension) {
        'Gradient' {
            try {
                Write-LogMessage -API 'Scheduler_Billing' -tenant 'none' -message 'Starting billing processing.' -sev Info
                $Table = Get-CIPPTable -TableName Extensionsconfig
                $Configuration = (Get-CIPPAzDataTableEntity @Table).config | ConvertFrom-Json -Depth 10

                foreach ($ConfigItem in $Configuration.psobject.properties.name) {
                    switch ($ConfigItem) {
                        'Gradient' {
                            If ($Configuration.Gradient.enabled -and $Configuration.Gradient.BillingEnabled) {
                                # Queue the sync function for immediate execution
                                Add-CippQueueMessage -Cmdlet 'New-GradientServiceSyncRun' -Parameters @{}
                                $Results = [pscustomobject]@{'Results' = 'Successfully queued Gradient Sync' }
                            }
                        }
                    }
                }
            } catch {
                $Results = [pscustomobject]@{'Results' = "Could not start Gradient Sync: $($_.Exception.Message)" }

                Write-LogMessage -API 'Scheduler_Billing' -tenant 'none' -message "Could not start billing processing $($_.Exception.Message)" -sev Error
            }
        }

        'NinjaOne' {
            $Results = [pscustomobject]@{'Results' = 'CIPP-hardened does not support the NinjaOne extension. Synchronization is disabled by policy.' }
        }
        'Hudu' {
            Register-CIPPExtensionScheduledTasks -Reschedule -Extensions 'Hudu'
            $Results = [pscustomobject]@{'Results' = 'Extension sync tasks have been rescheduled and will start within 15 minutes' }
        }

    }


    return ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $Results
        })

}
