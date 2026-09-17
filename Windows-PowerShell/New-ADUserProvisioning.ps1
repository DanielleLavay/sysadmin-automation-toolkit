<#
.SYNOPSIS
    Automated Active Directory User Onboarding Script
.DESCRIPTION
    Reads user details from a CSV file, generates a secure password, creates 
    the Active Directory account, adds specified security groups, and initializes a user directory.
.PARAMETER CsvPath
    Path to the CSV file containing new user details (FirstName, LastName, Department, Group).
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$CsvPath
)

# Import Active Directory Module
Import-Module ActiveDirectory

# Check if CSV exists
if (-not (Test-Path $CsvPath)) {
    Write-Error "[ERROR] CSV file not found at $CsvPath"
    exit
}

# Import User Data
$NewUsers = Import-Csv -Path $CsvPath

foreach ($User in $NewUsers) {
    try {
        $SamAccountName = "$($User.FirstName.ToLower()).$($User.LastName.ToLower())"
        $UserPrincipalName = "$SamAccountName@yourdomain.com"
        $DisplayName = "$($User.FirstName) $($User.LastName)"
        
        # Generate temporary random password
        $Password = ConvertTo-SecureString "P@ssword$(Get-Random -Minimum 1000 -Maximum 9999)!" -AsPlainText -Force

        # Create AD User
        New-ADUser `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $UserPrincipalName `
            -Name $DisplayName `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -Department $User.Department `
            -AccountPassword $Password `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "[SUCCESS] Created user account: $SamAccountName" -ForegroundColor Green

        # Assign Security Group
        if ($User.Group) {
            Add-ADGroupMember -Identity $User.Group -Members $SamAccountName
            Write-Host "[SUCCESS] Added $SamAccountName to group: $($User.Group)" -ForegroundColor Green
        }

    } catch {
        Write-Host "[ERROR] Failed to process user $($User.FirstName) $($User.LastName): $_" -ForegroundColor Red
    }
}
