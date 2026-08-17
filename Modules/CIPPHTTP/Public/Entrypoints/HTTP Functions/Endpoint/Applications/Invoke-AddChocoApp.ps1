function Invoke-AddChocoApp {
    <#
    .FUNCTIONALITY
        Entrypoint,AnyTenant
    .ROLE
        Endpoint.Application.ReadWrite
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)

    $APIName = $Request.Params.CIPPEndpoint
    $Headers = $Request.Headers
    $Result = 'CIPP-hardened does not support Chocolatey app deployment. This optional package-manager deployment path is disabled by policy.'
    Write-LogMessage -headers $Headers -API $APIName -message $Result -Sev 'Warning'
    return ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::Gone
            Body       = @{ 'Results' = $Result }
        })
}
