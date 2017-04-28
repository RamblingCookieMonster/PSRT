function Parse-RTResponse {
    [cmdletbinding()]
    param(
    [string]$Content
    )
    $ContentArray = $Content -split "`n"
    $Count = $ContentArray.Count    
    $Output = @{}
    $Name = $null
    $Value = $null
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

        if($thisline -match '^[a-zA-Z0-9]+:')
        {
            $SplitData = $thisline.split(':')
            $SplitCount = $SplitData.count
            $Name = $SplitData[0]
            $Value = ($SplitData[1..($SplitCount-1)] -join ':').Trim()
        }
        elseif($line)
        {
            
            $Value = $thisline
        }
        else
        {
            continue
        }

        if($Name -and $Output.ContainsKey($Name))
        {
            Write-Verbose "Appending to $Name"
            $Output[$Name] = $Output[$Name] + "`n$Value"
        }
        elseif($Name)
        {
            $Output.add($Name, $Value)
        }
    }
    [pscustomobject]$Output
}