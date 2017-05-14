param (
    [bool]$DebugModule = $false
)

# Get public and private function definition files
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
    $Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
    $FilesToLoad = @([object[]]$Public + [object[]]$Private) | Where-Object {$_}
    $ModuleRoot = $PSScriptRoot

# Dot source the files
# Thanks to Bartek, Constatine 
# https://becomelotr.wordpress.com/2017/02/13/expensive-dot-sourcing/
    Foreach($File in $FilesToLoad)
    {
        Write-Verbose "Importing [$File]"
        Try
        {
            if ($DebugModule)
            {
                . $File.FullName
            }
            else {
                . (
                    [scriptblock]::Create(
                        [io.file]::ReadAllText($File.FullName, [Text.Encoding]::UTF8)
                    )
                )
            }
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($File.fullname)"
            Write-Error $_
        }
    }

#Initialize the config variable.  I know, I know...
    Try
    {
        #Import the config
        $PSRTConfig = $null
        $PSRTConfig = Get-RTConfig -Source Config -ErrorAction Stop

    }
    Catch
    {
        Write-Warning "Error importing PSRT config"
        Write-Warning $_
    }

Export-ModuleMember -Function $Public.BaseName