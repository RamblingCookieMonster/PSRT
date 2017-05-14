# PSRT

This is a quick and dirty PowerShell module for working with the Request Tracker (RT) API

This is quite early, and can only read information at the moment.  Issues and pull requests welcome!

A huge thanks to [aricade](https://www.reddit.com/user/aricade) for [getting this started](https://www.reddit.com/r/PowerShell/comments/614dey/request_tracker_rt_and_rest_api/)

## Instructions

```powershell
# One time setup
    # Download the repository
    # Unblock the zip
    # Extract the PSRT folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

    #Simple alternative, if you have PowerShell 5, or the PowerShellGet module:
        Install-Module PSRT

# Import the module.
    Import-Module PSRT

# Get commands in the module
    Get-Command -Module PSRT

# Get help
    Get-Help Set-RTConfig -Full
```

## Examples

### Set default values and create a session

```powershell
Set-RTConfig -BaseUri 'https://rt.fqdn' -Credential (Get-Credential)
New-RTSession
```

### Query for a ticket

```powershell
# After creating a session...
Get-RTTicket -Ticket 1234

<#
    ResponseOverview    : RT/REDACTED 200 Ok
    id                  : ticket/1234
    Queue               : General
    Owner               : wframe
    Creator             : someone
    Subject             : Some subject line
    Status              : open
    Priority            : 0
    InitialPriority     : 0
    FinalPriority       : 0
    Requestors          : someone@somewhere.com
    Cc                  : 
    AdminCc             : 
    Created             : Thu May 11 12:45:34 2017
    Starts              : Not set
    Started             : Thu May 11 12:52:13 2017
    Due                 : Not set
    Resolved            : Not set
    Told                : Fri May 12 11:15:16 2017
    LastUpdated         : Fri May 12 11:21:12 2017
    TimeEstimated       : 0
    TimeWorked          : 0
    TimeLeft            : 0
    CF.{CustomCat}      : Some custom field detail
#>
```

### Query ticket history

```powershell
# After creating a session...
# List all entries
Get-RTTicketEntry -Ticket 1234

<#
    ResponseOverview : RT/redacted 200 Ok
    HistoryOverview  : # 42/42 (id/total)
    2058745          : Ticket created by requestorx
    2058746          : Outgoing email recorded by some_system
    2058747          : Outgoing email recorded by some_system
    2058767          : Given to wframe (Warren Frame) by teammatex
    2058768          : Outgoing email recorded by some_system
    2058769          : Owner set to wframe (Warren Frame) by teammatex
    2058862          : Correspondence added by wframe
    2058863          : Outgoing email recorded by some_system
    2058864          : Status changed from 'new' to 'open' by some_system
    2058865          : Field FieldValue added by wframe
    ...
#>

# Check a particular entry
Get-RTTicketEntry -Ticket 1234 -Entry 2058862

<#
    ResponseOverview          : RT/redacted 200 Ok
    HistoryOverview           : # 42/42 (id/2058862/total)
    id                        : 2058862
    Ticket                    : 1234
    TimeTaken                 : 0
    Type                      : Correspond
    Field                     : 
    OldValue                  : 
    NewValue                  : 
    Data                      : No Subject
    Description               : Correspondence added by wframe
    Content                   : Some multiline correspondence content
                                         
                                         Don't ask why the indentation is like this
                       
    Creator                   : wframe
    Created                   : 2017-03-07 19:14:09
    Attachments               : 
                 1347592      : untitled (1.5k)
#>
```
