<#
.SYNOPSIS
    Exports NTFS and SMB share-level permissions for selected file shares to CSV format.

.DESCRIPTION
    This script retrieves all non-admin SMB shares on a Windows file server, presents a numbered list to the user,
    and allows selection of one or more shares to process. For each selected share:
        - Recursively collects NTFS folder-level permissions using Get-Acl
        - Collects share-level permissions using Get-SmbShareAccess
        - Outputs both sets of results to well-structured CSV files

.OUTPUT
    CSV files are saved under C:\Reports\NTFSPermissions with one pair of reports per selected share:
        - <ShareName>_NTFS_Permissions.csv
        - <ShareName>_Share_Permissions.csv

.NOTES
    Author      : Yates Enterprise Solutions (https://yatessbs.com)
    Created     : 2025-04-15
    Last Updated: 2025-04-15
    Version     : 1.0

.CHANGELOG
    1.0 - Initial release with interactive console-based selection and structured CSV output

.REQUIREMENTS
    - Run as Administrator
    - PowerShell 5.1 or higher
    - Outbound access to local file system for report generation

.EXAMPLE
    Run the script and enter: 1,3,4 to export permissions from shares 1, 3, and 4

#>

# Set output directory for reports
$reportFolder = "C:\Reports\NTFSPermissions"
New-Item -ItemType Directory -Force -Path $reportFolder | Out-Null

# Retrieve all non-admin SMB shares
$shares = Get-SmbShare | Where-Object { $_.Name -notmatch '^\w\$' } | Select-Object Name, Path

# Display a numbered list of shares
Write-Host "`nAvailable Shared Folders:`n"
for ($i = 0; $i -lt $shares.Count; $i++) {
    Write-Host "$($i + 1). $($shares[$i].Name) - $($shares[$i].Path)"
}

# Prompt for user input
$selection = Read-Host "`nEnter the numbers of the folders to process (comma-separated, e.g., 1,3,5)"

# Convert input into valid indexes
$indexes = $selection -split ',' | ForEach-Object {
    ($_ -as [int]) - 1
} | Where-Object { $_ -ge 0 -and $_ -lt $shares.Count }

if (-not $indexes) {
    Write-Host "`nNo valid selections made. Exiting script."
    exit
}

# Process each selected share
foreach ($index in $indexes) {
    $share = $shares[$index]
    $shareName = $share.Name
    $sharePath = $share.Path
    $safeName = $shareName -replace '[^\w]', '_'

    Write-Host "`nProcessing $shareName ($sharePath)..."

    # --- Export NTFS Permissions ---
    $ntfsCsv = Join-Path $reportFolder "$safeName`_NTFS_Permissions.csv"
    $ntfsPermissions = @()

    Get-ChildItem -Path $sharePath -Recurse -Directory -Force -ErrorAction SilentlyContinue |
    ForEach-Object {
        try {
            $acl = Get-Acl $_.FullName
            foreach ($entry in $acl.Access) {
                $ntfsPermissions += [PSCustomObject]@{
                    Share        = $shareName
                    FolderPath   = $_.FullName
                    Identity     = $entry.IdentityReference
                    Rights       = $entry.FileSystemRights
                    Inherited    = $entry.IsInherited
                    Propagation  = $entry.PropagationFlags
                    Type         = $entry.AccessControlType
                }
            }
        } catch {
            Write-Warning "ACL retrieval failed for $($_.FullName): $_"
        }
    }

    $ntfsPermissions | Export-Csv -Path $ntfsCsv -NoTypeInformation -Encoding UTF8
    Write-Host "✅ NTFS permissions saved to: $ntfsCsv"

    # --- Export Share-Level Permissions ---
    $shareCsv = Join-Path $reportFolder "$safeName`_Share_Permissions.csv"
    $sharePermissions = Get-SmbShareAccess -Name $shareName | ForEach-Object {
        [PSCustomObject]@{
            Share       = $shareName
            FolderPath  = $sharePath
            Identity    = $_.AccountName
            AccessRight = $_.AccessControlType
        }
    }

    $sharePermissions | Export-Csv -Path $shareCsv -NoTypeInformation -Encoding UTF8
    Write-Host "✅ Share-level permissions saved to: $shareCsv"
}

Write-Host "`n🎉 All selected shares processed. CSV reports saved in: $reportFolder"
