#
# Module manifest for module 'Fortytwo.IAM.GroupWritebackReconciliation'
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'Fortytwo.IAM.GroupWritebackReconciliation.psm1'

    # Version number of this module.
    ModuleVersion = '0.7.0'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = '2ef49c45-7fd8-4ea0-9d9d-b69ac9aee42e'

    # Author of this module
    Author            = 'Marius Solbakken Mellum'

    # Company or vendor of this module
    CompanyName       = 'Fortytwo Technologies AS'

    # Copyright statement for this module
    Copyright         = '(c) Fortytwo Technologies AS'

    # Description of the functionality provided by this module
    Description       = "A module for group writeback consolidation in Entra ID."

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '7.2'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules   = @("EntraIDAccessToken")

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = '*'

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @('Complete-GroupWritebackReconciliation','Connect-GroupWritebackReconciliation','Get-GroupWritebackReconciliationOperations','Show-GroupWritebackReconciliationOperation')

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = '*'

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{
        Tags       = @('PSEdition_Core', 'Microsoft365', 'EntraID')
        ProjectUri = "https://github.com/fortytwoservices/powershell-module-GroupWritebackReconciliation"
    }

}
