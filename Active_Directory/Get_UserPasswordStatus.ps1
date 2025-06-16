<#
.SYNOPSIS
    Retrieves password status details for one or more Active Directory users.

.DESCRIPTION
    This script prompts the user for an optional username filter (supports wildcards),
    then queries Active Directory for matching users. It displays the `PasswordLastSet`
    and `PasswordNeverExpires` properties, and optionally exports the result to CSV.

.PARAMETER Username
    Optional. A username filter to search for AD users (e.g., "jdoe", "adm*", "*smith").

.OUTPUTS
    A list of user password status details displayed on-screen and optionally saved to a CSV.

.EXAMPLE
    PS> .\Get-UserPasswordStatus.ps1
    (Prompts for username, then shows results)

.NOTES
    Author: Your Name
    Date:   2025-06-15
    Version: 1.1

#>

[CmdletBinding()]
param ()

# Prompt for an optional username filter
$usernameFilter = Read-Host "Enter username filter (use * as wildcard, leave blank for all users)"

# Prepare the filter
if ([string]::IsNullOrWhiteSpace($usernameFilter)) {
    $ldapFilter = "*"
} else {
    $ldapFilter = $usernameFilter
}

try {
    # Get the users
    $users = Get-ADUser -Filter "Name -like '$ldapFilter'" -Properties PasswordLastSet, PasswordNeverExpires

    if ($users.Count -eq 0) {
        Write-Host "No users found matching filter: $ldapFilter" -ForegroundColor Yellow
        return
    }

    # Create a simplified result object
    $results = $users | Select-Object Name, SamAccountName, PasswordLastSet, PasswordNeverExpires

    # Output to screen
    $results | Format-Table -AutoSize

    # Prompt to export
    $export = Read-Host "Do you want to export the results to CSV? (Y/N)"
    if ($export -match '^(Y|y)$') {
        $defaultPath = "$env:USERPROFILE\Documents\AD_UserPasswordStatus.csv"
        $results | Export-Csv -Path $defaultPath -NoTypeInformation
        Write-Host "Results exported to: $defaultPath" -ForegroundColor Green
    }

} catch {
    Write-Error "An error occurred: $_"
}
