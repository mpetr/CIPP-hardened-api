function Start-ExtensionOrchestrator {
    <#
    .SYNOPSIS
        Start the Extension Orchestrator
    .FUNCTIONALITY
        Entrypoint
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    $Table = Get-CIPPTable -TableName Extensionsconfig
    $ExtensionConfig = (Get-AzDataTableEntity @Table).config
    if ($ExtensionConfig -and (Test-Json -Json $ExtensionConfig)) {
        $Configuration = ($ExtensionConfig | ConvertFrom-Json)
    } else {
        $Configuration = @{}
    }

    Write-Host 'Started Scheduler for Extensions'

    # CIPP-hardened: NinjaOne is an unsupported optional extension.
    if ($Configuration.NinjaOne.Enabled -eq $true) {
        Write-Warning 'CIPP-hardened does not support the NinjaOne extension. Scheduler execution is disabled.'
    }
}
