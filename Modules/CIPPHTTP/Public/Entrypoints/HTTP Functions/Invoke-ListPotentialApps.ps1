Function Invoke-ListPotentialApps {
    <#
    .FUNCTIONALITY
        Entrypoint
    .ROLE
        Endpoint.Application.Read
    .DESCRIPTION
        Searches supported application repositories for available applications matching a search string. Chocolatey search is disabled in CIPP-hardened.
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)

    if ($Request.Body.type -eq 'Choco') {
        return [HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::Gone
            Body       = @{'Results' = 'CIPP-hardened does not support Chocolatey package search. This optional package-manager path is disabled by policy.' }
        }
    }

    if ($request.body.type -eq 'WinGet') {
        $body = @"
{"MaximumResults":50,"Filters":[{"PackageMatchField":"Market","RequestMatch":{"KeyWord":"US","MatchType":"CaseInsensitive"}}],"Query":{"KeyWord":"$($Request.Body.SearchString)","MatchType":"Substring"}}
"@
        $DataRequest = (Invoke-RestMethod -Uri 'https://storeedgefd.dsx.mp.microsoft.com/v9.0/manifestSearch' -Method POST -Body $body -ContentType 'Application/json').data | Select-Object @{l = 'applicationName'; e = { $_.packagename } }, @{l = 'packagename'; e = { $_.packageIdentifier } } | Sort-Object -Property applicationName
    }

    return [HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = @($DataRequest)
        }

}
