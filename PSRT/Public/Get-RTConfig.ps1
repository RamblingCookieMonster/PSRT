Function Get-RTConfig {
    <#
    .SYNOPSIS
        Get PSRT module configuration.

    .DESCRIPTION
        Get PSRT module configuration

    .PARAMETER Source
        Get the config data from either...
        
            PSRT:     the live module variable used for command defaults
            PSRT.xml: the serialized PSRT.xml that loads when importing the module

        Defaults to PSSlack

    .PARAMETER Path
        If specified, read config from this XML file.
        
        Defaults to PSRT.xml in the module root

    .FUNCTIONALITY
        Slack
    #>
    [cmdletbinding(DefaultParameterSetName = 'source')]
    param(
        [parameter(ParameterSetName='source')]
        [ValidateSet("PSRT","PSRT.xml")]
        $Source = "PSRT",

        [parameter(ParameterSetName='path')]
        [parameter(ParameterSetName='source')]
        $Path = "$ModuleRoot\$env:USERNAME-$env:COMPUTERNAME-PSRT.xml"
    )
    
    if($PSCmdlet.ParameterSetName -eq 'source' -and $Source -eq "PSRT" -and -not $PSBoundParameters.ContainsKey('Path'))
    {
        $Script:PSRT
    }
    else
    {
        Import-Clixml -Path $Path |
            Select -Property BaseUri,
                             Credential
    }

}