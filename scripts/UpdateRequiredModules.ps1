$data = Import-PowerShellDataFile -Path "./src/AzOps.psd1"
$modules = @()
$existingmodule = @()
$newmodule = @()
$updated = $false
$data.RequiredModules | ForEach-Object {
    $moduleVersion = $_.RequiredVersion
    $galleryVersion = (Find-Module -Name $_.ModuleName).Version
    if ($moduleVersion -lt $galleryVersion) {
        $newmodule = @{
            "ModuleName" = $_.ModuleName
            "RequiredVersion" = $galleryVersion
        }
        $updated = $true
        $modules += $newmodule
    } else {
        $existingmodule = @{
            "ModuleName" = $_.ModuleName
            "RequiredVersion" = $moduleVersion
        }
        $modules += $existingmodule
    }
}
if ($updated -eq $true) {
    Update-ModuleManifest -Path "./src/AzOps.psd1" -RequiredModules $modules
    $filePath = Join-Path -Path "/tmp" -ChildPath "updates.json"
    ConvertTo-Json $modules | Out-File -FilePath $filePath
}