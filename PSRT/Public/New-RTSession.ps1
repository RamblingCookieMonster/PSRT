function New-RTSession {
    <#
    .Synopsis
        Connects to RT Server and returns a Session.
    .DESCRIPTION
        Connects to RT Server and returns a Session So that other PSRT commands can be authenticated when using the -Session paramenter
        Session is automatically added to PSRTConfig
    .PARAMETER Credential
        A credential to use for RT.  Defaults to PSRTConfig.Credential
    .PARAMETER BaseUri
        Base URI for RT.  Defaults to PSRTConfig.BaseUri
    .PARAMETER DontUpdateConfig
        If specified, we don't update PSRT.Session
    .EXAMPLE
        New-RTSession

        # Creates an RT session from the BaseUri and Credential in your PSRTConfig,
        # previously set via Set-RTConig
        # Updates the PSRTConfig.Session with the session we get back
    .EXAMPLE
        $MyRTSession = New-RTSession -Credential (Get-Credential) -BaseUri "https://rt.mydomain.com" 
    .OUTPUTS
        Microsoft.PowerShell.Commands.WebRequestSession
    .FUNCTIONALITY
        Request Tracker
    #>
    [cmdletbinding()]
    Param ( 
        [Parameter( ValueFromPipeLine = $true, 
                    ValueFromPipelineByPropertyName = $true )] 
        [ValidateNotNull()] 
        [System.Management.Automation.PSCredential] 
        [System.Management.Automation.Credential()] 
        $Credential = $PSRTConfig.Credential,

        [ValidateNotNull()] 
        [string]$BaseUri = $PSRTConfig.BaseUri,

        [switch]$DontUpdateConfig
    )
    Add-Type -AssemblyName System.Web
    Write-Verbose "Creating RT Session"
    $EncodedUserName = [System.Web.HttpUtility]::UrlEncode($Credential.UserName)
    $EncodedPassword = [System.Web.HttpUtility]::UrlEncode($Credential.GetNetworkCredential().Password)
    Write-Verbose -Message "Sending RT Session credentials for $($Credential.UserName)"
    $r = Invoke-WebRequest -Uri $BaseUri -SessionVariable RTSession -Method Post -UseBasicParsing -Body "user=$EncodedUserName&pass=$EncodedPassword"
    if ($r.Content -notmatch "<li>Your username or password is incorrect</li>") {
        Write-Verbose -Message "Authentication Successful"
        if(-not $DontUpdateConfig)
        {
            Set-RTConfig -Session $RTSession
        }
        $RTSession
    }
    else {
        Write-Error $r.Content
        Write-Error "Server $($http + $Server): Your username or password is incorrect"
    }

}
