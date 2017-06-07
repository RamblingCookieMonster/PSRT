function Set-RTConfig {
    <#
        .SYNOPSIS
            Set Request Tracker module configuration.

        .DESCRIPTION
            Set Request Tracker module configuration, and live $PSRTConfig module variable

            This data is used as the default for most commands.

        .PARAMETER BaseUri
            Specify a Uri to use

        .PARAMETER Credential
            Specify a crdential to use for New-RTSession

        .PARAMETER Session
            Specify a websession to use

            This data is not stored in the XML

        .EXAMPLE
            Set-RTConfig -BaseUri 'https://rt.fqdn' -Credential (Get-Credential)
            New-RTSession
            
            # Set RT config base uri and default credential
            # Create a new RT session with these values (session added to RTConfig variable, used as default going forward)

        .FUNCTIONALITY
            Request Tracker
    #>
    [CmdletBinding()]
    param(
        [string]$BaseUri,
        [PSCredential]$Credential,
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session,
        [string]$Referer,
        [string]$Path = "$ModuleRoot\$env:USERNAME-$env:COMPUTERNAME-PSRT.xml"
    )

    try
    {
        $Existing = Get-RTConfig -ErrorAction stop
    }
    catch
    {
        Write-Error $_
        throw $_
    }

    foreach($Key in $PSBoundParameters.Keys)
    {
        if(Get-Variable -name $Key)
        {
            #We use add-member force to cover cases where we add props to this config...
            Add-Member -InputObject $Existing -MemberType NoteProperty -Name $Key -Value $PSBoundParameters.$Key -Force
        }
    }

    #Write the global variable and the xml
    $Script:PSRTConfig = $Existing
    $Existing | Select -Property * -ExcludeProperty Session | Export-Clixml -Path $Path -Force
}