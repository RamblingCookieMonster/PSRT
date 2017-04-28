function New-RTSession {
    <#
    .Synopsis
        Connects to RT Server and returns a Session.
    .DESCRIPTION
        Connects to RT Server and returns a Session So that other PSRT commands can be authenticated when using the -Session paramenter.
    .EXAMPLE
        $MyRTSession = New-RTSession -Credential (Get-Credential) -BaseUri "https://rt.mydomain.com" 
    .INPUTS
    .OUTPUTS
        Microsoft.PowerShell.Commands.WebRequestSession
    .NOTES
        It gets you authenticated onto RT Server
    #>
    [cmdletbinding()]
    Param ( 
        [Parameter( 
            Mandatory = $true, 
            ValueFromPipeLine = $true, 
            ValueFromPipelineByPropertyName = $true 
        )] 
        [ValidateNotNull()] 
        [System.Management.Automation.PSCredential] 
        [System.Management.Automation.Credential()] 
        $Credential,
        [ValidateNotNull()] 
        [string]$BaseUri
    )
    $r = Invoke-WebRequest -Uri $BaseUri -SessionVariable RTSession -Credential $Credential
    $form = $r.Forms[0]
    $form.fields['user'] = $Credential.UserName
    $form.fields['pass'] = $Credential.GetNetworkCredential().Password
 
    $r = Invoke-WebRequest -Uri "$BaseUri$($Form.Action)" -WebSession $RTSession -Method POST -Body $form.Fields
    if ($r.Content -notmatch "<li>Your username or password is incorrect</li>"){
        return $RTSession
    }
    else{
        Write-Error $r.Content
        Write-Error "Server $($http + $Server): Your username or password is incorrect"
    }
}