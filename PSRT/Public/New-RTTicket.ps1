Function New-RTTicket {
    <#
    .SYNOPSIS
        Create a new ticket in RT
    .DESCRIPTION
        Create a new ticket in RT
    .PARAMETER Requestor
        Ticket requestor
    .PARAMETER Owner
        Ticket Owner
    .PARAMETER Priority
        Ticket Priority.  Defaults to 0
    .PARAMETER Subject
        Ticket Subject
    .PARAMETER Text
        Ticket Text.  For multiline, add a single space to the start of every line after the first line
    .PARAMETER Queue
        Ticket Queue.  Defaults to General
    .PARAMETER Cc
        Ticket Cc
    .PARAMETER AdminCc
        Ticket AdminCc
    .PARAMETER Status
        Ticket Status
    .PARAMETER InputHash
        Add additional ticket properties to this hashtable.

        These values are overridden if an explicit parameter is also specified.  e.g.
            -Owner wframe -InputObject @{Owner = 'Nope'}
            Result: Owner: wframe
    .PARAMETER Referer
        Referer to use for whitelisting purposes.  Defaults to PSRTConfig.Referer (Created by New-RTSession)
        
        See @ReferrerWhitelist RT configuration if you run into CSRF errors
        If you specify  'https://<hostname>', RT (and its whitelist) use <hostname>:443
    .PARAMETER Session
        RT session to use.  Defaults to PSRTConfig.Session (Created by New-RTSession)
    .PARAMETER BaseUri
        Base URI for RT.  Defaults to PSRTConfig.BaseUri (Created by New-RTSession)
    .PARAMETER Raw
        If specified, do not parse output
    .EXAMPLE
        New-RTTicket -Requestor wframe -Owner wframe -Subject 'TEST' -Text 'This is a ticket!'
    .EXAMPLE
        $Text = @"
        This is
         a
         multiline
         ticket!
        "@ # note the single space before each line after the first.

        New-RTTicket -Queue SomeOtherQueue -InputHash @{
            Requestor = 'wframe'
            Subject = 'Test'
            Text = $Text
            'CF-CustomField' = 'Custom!'
        }

    .FUNCTIONALITY
        Request Tracker
    #>
    [cmdletbinding()]
    Param(
        [string]$Requestor,
        [string]$Owner,
        [int]$Priority = 0,
        [string]$Subject,
        [string]$Text,
        [string]$Queue = 'General',
        [hashtable]$InputHash,
        [string]$Cc,
        [string]$AdminCc,
        [string]$Status,
        [string]$Referer = $PSRTConfig.Referer,

        [Parameter( ValueFromPipeLine = $true, 
            ValueFromPipelineByPropertyName = $true )] 
        [ValidateNotNull()] 
        [Microsoft.PowerShell.Commands.WebRequestSession] 
        $Session = $PSRTConfig.Session,
        [ValidateNotNull()] 
        [string]$BaseUri = $PSRTConfig.BaseUri,
        [switch]$Raw
    )
    $InvokeParams = @{ WebSession = $Session }
    if($Referer)
    {
        $headers = @{}
        $headers.Add('Referer', $Referer)
        $InvokeParams.Add('Headers', $headers)
    }
    $uri = Join-Parts -Separator '/' -Parts $BaseUri, "/REST/1.0/ticket/new"
    
    # Merge explicit parameters into InputHash, with explicit param values taking precedent
    $Parameters = . Get-ParameterValues
    if(-not $PSBoundParameters.ContainsKey('InputHash'))
    {
        $InputHash = @{}
    }
    Write-Output Requestor,
                 Owner,
                 Priority,
                 Subject,
                 Text,
                 Queue,
                 Cc,
                 AdminCc,
                 Status |
        Foreach-Object {
            $Property = $_
            if($Parameters.containskey($Property))
            {
                $InputHash.Set_Item($Property, $Parameters[$Property])
            }
        }
    
    # Build up content for ticket
    # Queue must come last.  wtf RT. https://stackoverflow.com/a/29540271
    $Content = ''
    foreach($Key in $InputHash.Keys)
    {
        if($Key -ne 'Queue')
        {
            $Content += "$Key`: $($InputHash[$Key])`n"
        }
        #Later: Handle odd custom fields
    }
    $Content += "Queue: $($InputHash['Queue'])`n"

    $InvokeParams.Add('Body', @{content=$Content})
    Write-Verbose "$($InvokeParams | Out-String)`n$($Content | Out-String)"
    $Response = ( Invoke-WebRequest @InvokeParams -Uri $uri -Method Post).Content
    if ($Raw) {
        $Response
    }
    else {
        ConvertFrom-RTResponse -Content $Response
    }
}
