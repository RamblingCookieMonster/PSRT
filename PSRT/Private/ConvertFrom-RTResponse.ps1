function ConvertFrom-RTResponse {
    [cmdletbinding()]
    param(
    [string]$Content
    )
    $ContentArray = $Content -split "`n"
    $Count = $ContentArray.Count    
    $Output = [ordered]@{}
    $Name = $null
    $Value = $null
    $DateProps = echo Created Starts Started Due Resolved Told LastUpdated


    for ($linenumber = 0; $linenumber -lt $Count; $linenumber++)
    {
        $thisline = $ContentArray[$linenumber]
        if($linenumber -gt 0)
        {
            $lastline = $ContentArray[($linenumber-1)]
        }
        else
        {
            $lastline = $null
        }

        Write-Verbose "Working on line $LineNumber with data $thisline"

        if($linenumber -eq 0 -and $thisline -match '^RT/')
        {
            $Output.add('ResponseOverview', $thisline)
            continue
        }
        if($thisline -match '# \d')
        {
            $Output.add('HistoryOverview', $thisline)
            continue
        }
        if($thisline -match '^# Ticket \d+ created')
        {
            $ticket = $thisline -replace "\D+"
            $Output.add('id', $ticket)
        }

        if($thisline -match '^[a-zA-Z0-9 .{}()]+:')
        {
            $SplitData = $thisline.split(':')
            $SplitCount = $SplitData.count
            $Name = $SplitData[0]
            # account for other colons on first line
            $Value = ($SplitData[1..($SplitCount-1)] -join ':').Trim() 
        }
        elseif($thisline)
        {
            $Value = $thisline
        }
        else
        {
            continue
        }

        if($Name -and $Output.keys -Contains $Name)
        {
            Write-Verbose "Appending to $Name"
            $Output[$Name] = $Output[$Name] + "`n$Value"
        }
        elseif($Name)
        {
            $Output.add($Name, $Value)
        }
    }
    foreach($key in $($Output.Keys))
    {
        if($Output[$key] -is [string])
        {
            $Output[$key] = $Output[$key].trim()
            if($DateProps -contains $Key -and $Output[$key] -match '\d\d:\d\d:\d\d \d\d\d\d$')
            {
                $Output[$key] = ConvertFrom-RTDate -DateString $Output[$key]
            }
        }
    }
    [pscustomobject]$Output
}