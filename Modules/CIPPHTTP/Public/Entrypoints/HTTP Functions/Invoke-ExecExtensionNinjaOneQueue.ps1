function Invoke-ExecExtensionNinjaOneQueue {
    <#
    .FUNCTIONALITY
        Entrypoint
    .ROLE
        CIPP.Extension.ReadWrite
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)

    $Result = 'CIPP-hardened does not support the NinjaOne extension. Queue execution is disabled by policy.'
    return [HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::Gone
        Body       = @{ 'Results' = $Result }
    }
}
