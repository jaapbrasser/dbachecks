function Get-AllDatabaseInfo {
    # Using the unique tags gather the information required
    Param($Instance, $Tags)

    #clear out the default initialised fields
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Information], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Settings], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.LogFile], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile], $false)

    # set the default init fields for all the tags

    # Server Initial fields
    $ServerInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server])
    $ServerInitFields.Add("VersionMajor") | Out-Null # so we can check versions
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $ServerInitFields)

    # Database Initial Fields
    $DatabaseInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database])

    # Stored Procedure Initial Fields
    $StoredProcedureInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure])

    # Information Initial Fields

    # Settings Initial Fields
    $SettingsInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Settings])

    # Login Initial Fields
    $LoginInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login])

    # Log File Initial Fields
    $LogFileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.LogFile])

    # Data File Initial Fields
    $DataFileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile])

    # Configuration cannot have default init fields :-)
    $configurations = $false

    # Set up blank ConfigValues object for any config we need to use in the checks
    $ConfigValues = [PSCustomObject]@{}

    # Using there so that if the instance is not contactable, no point carrying on with gathering more information
    switch ($tags) {

        'AsymmetricKeySize' {
            $asymmetrickey = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'asymmetrickeysizeexclude' -Value (Get-DbcConfigValue policy.asymmetrickeysize.excludedb)
        }

        'AutoClose' {
            $autoclose = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoclose' -Value (Get-DbcConfigValue policy.database.autoclose)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autocloseexclude' -Value (Get-DbcConfigValue policy.autoclose.excludedb)
        }

        'AutoShrink' {
            $autoshrink = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoshrink' -Value (Get-DbcConfigValue policy.database.autoshrink) 
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoshrinkexclude' -Value (Get-DbcConfigValue policy.autoshrinke.excludedb)
        }

        'ValidDatabaseOwner' {
            $owner = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'validdbownername' -Value (Get-DbcConfigValue policy.validdbowner.name)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'validdbownerexclude' -Value (Get-DbcConfigValue policy.validdbowner.excludedb)
        }

        'InvalidDatabaseOwner' {
            $owner = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'invaliddbownername' -Value (Get-DbcConfigValue policy.invaliddbowner.name)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'invaliddbownerexclude' -Value (Get-DbcConfigValue policy.invaliddbowner.excludedb)
        }

        'DatabaseCollation' {
            $collation = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'wrongcollation' -Value (Get-DbcConfigValue policy.database.wrongcollation)
        }

        'SuspectPage' {
            $suspectPage = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'suspectpageexclude' -Value (Get-DbcConfigValue policy.suspectpage.excludedb)
        }
        'VirtualLogFile' {
            $vlf = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'maxvlf' -Value (Get-DbcConfigValue policy.database.maxvlf)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'vlfexclude' -Value (Get-DbcConfigValue policy.vlf.excludedb)
        }
        'LogFileCount' {
            $logfilecount = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'logfilecount' -Value (Get-DbcConfigValue policy.database.logfilecount)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'logfilecountexclude' -Value (Get-DbcConfigValue policy.logfilecount.excludedb)
        }
        'AutoCreateStatistics' {
            $autocreatestats = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autocreatestats' -Value (Get-DbcConfigValue policy.database.autocreatestatistics)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autocreatestatsexclude' -Value (Get-DbcConfigValue policy.autocreatestats.excludedb)
        }
        'AutoUpdateStatistics' {
            $autoupdatestats = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoupdatestats' -Value (Get-DbcConfigValue policy.database.autoupdatestatistics)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoupdatestatsexclude' -Value (Get-DbcConfigValue policy.autoupdatestats.excludedb)
        }
        'AutoUpdateStatisticsAsynchronously' {
            $autoupdatestatsasync = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoupdatestatsasync' -Value (Get-DbcConfigValue policy.database.autoupdatestatisticsasynchronously)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoupdatestatsasyncexclude' -Value (Get-DbcConfigValue policy.autoupdatestatisticsasynchronously.excludedb)
        }
        Default { }
    }

    #build the object
    $testInstanceObject = [PSCustomObject]@{
        ComputerName     = $Instance.ComputerName
        InstanceName     = $Instance.DbaInstanceName
        Name             = $Instance.Name
        ConfigValues    = $ConfigValues # can we move this out to here?
        Databases        = $Instance.Databases.Foreach{
            [PSCustomObject]@{
                Name                        = $psitem.Name
                SqlInstance                 = $Instance.Name
                Owner                       = if ($owner) { $psitem.owner }
                ServerCollation             = if ($collation) { $Instance.collation }
                Collation                   = if ($collation) { $psitem.collation }
                SuspectPage                 = if ($suspectPage) { (Get-DbaSuspectPage -SqlInstance $Instance -Database $psitem.Name | Measure-Object).Count }
                ConfigValues                = $ConfigValues # can we move this out?
                AsymmetricKeySize           = if ($asymmetrickey) { ($psitem.AsymmetricKeys | Where-Object { $_.KeyLength -lt 2048} | Measure-Object).Count }
                #AsymmetricKeySize          = if ($asymmetrickey) { $psitem.AsymmetricKeys.KeyLength }  # doing this I got $null if there wasn't a key so counting ones that are too short
                AutoClose                   = if ($autoclose) { $psitem.AutoClose}
                AutoCreateStatistics        = if ($autocreatestats) { $psitem.AutoCreateStatisticsEnabled }
                AutoUpdateStatistics        = if ($autoupdatestats) { $psitem.AutoUpdateStatisticsEnabled }
                AutoUpdateStatisticsAsync   = if ($autoupdatestatsasync) { $psitem.AutoUpdateStatisticsAsync }
                AutoShrink                  = if ($autoshrink) { $psitem.AutoShrink}
                VLF                         = if ($vlf) { ($psitem.Query("DBCC LOGINFO") | Measure-Object).Count }
                LogFileCount                = if ($logfilecount) { ($psitem.LogFiles | Measure-Object).Count }
            }
        }
    }
    return $testInstanceObject
}