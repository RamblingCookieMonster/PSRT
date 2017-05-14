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
    Write-Verbose "Creating RT Session"
    $r = Invoke-WebRequest -Uri $BaseUri -SessionVariable RTSession -Credential $Credential
    $form = $r.Forms[0]
    $form.fields['user'] = $Credential.UserName
    $form.fields['pass'] = $Credential.GetNetworkCredential().Password
    Write-Verbose "Sending RT Session credentials for [$($Credential.UserName)]"
    $r = Invoke-WebRequest -Uri "$BaseUri$($Form.Action)" -WebSession $RTSession -Method POST -Body $form.Fields
    if ($r.Content -notmatch "<li>Your username or password is incorrect</li>") {
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