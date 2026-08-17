Function Invoke-ListAppsRepository {
    <#
    .FUNCTIONALITY
        Entrypoint,AnyTenant
    .ROLE
        Endpoint.Application.Read
    .DESCRIPTION
        Chocolatey repository search is disabled in CIPP-hardened.
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)

    $Result = 'CIPP-hardened does not support Chocolatey repository search. This optional package-manager path is disabled by policy.'
    return ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::Gone
            Body       = @{ 'Results' = $Result }
        })

}
