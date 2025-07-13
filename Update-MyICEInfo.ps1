# Update-MyICEInfo.ps1
# Script to create or update myICE.html file with important personal information
# Run this script whenever you need to update your emergency information

# Configuration - Change the path as needed
$iceFilePath = "$env:USERPROFILE\Documents\myICE.html"

# Function to get input with optional default value
function Get-UserInput {
    param (
        [string]$prompt,
        [string]$default = ""
    )
    
    if ($default -ne "") {
        $promptWithDefault = "$prompt [$default]: "
        $input = Read-Host -Prompt $promptWithDefault
        if ([string]::IsNullOrWhiteSpace($input)) {
            return $default
        }
        return $input
    } else {
        return Read-Host -Prompt $prompt
    }
}

# Check if the file exists and load existing data
$existingData = @{}
if (Test-Path $iceFilePath) {
    Write-Host "Existing myICE.html file found. Loading data for updating..." -ForegroundColor Cyan
    
    # Read the HTML file
    $htmlContent = Get-Content -Path $iceFilePath -Raw
    
    # Extract personal info
    if ($htmlContent -match '<h2>Personal Information</h2>([\s\S]*?)<h2>') {
        $personalSection = $matches[1]
        if ($personalSection -match '<p><strong>Full Name:</strong> (.*?)</p>') { $existingData.FullName = $matches[1] }
        if ($personalSection -match '<p><strong>Date of Birth:</strong> (.*?)</p>') { $existingData.DOB = $matches[1] }
        if ($personalSection -match '<p><strong>Address:</strong> (.*?)</p>') { $existingData.Address = $matches[1] }
        if ($personalSection -match '<p><strong>Phone:</strong> (.*?)</p>') { $existingData.Phone = $matches[1] }
    }
    
    # Extract emergency contacts
    if ($htmlContent -match '<h2>Emergency Contacts</h2>([\s\S]*?)<h2>') {
        $contactsSection = $matches[1]
        if ($contactsSection -match '<p><strong>Primary Contact:</strong> (.*?)</p>') { $existingData.PrimaryContact = $matches[1] }
        if ($contactsSection -match '<p><strong>Relationship:</strong> (.*?)</p>') { $existingData.Relationship = $matches[1] }
        if ($contactsSection -match '<p><strong>Contact Phone:</strong> (.*?)</p>') { $existingData.ContactPhone = $matches[1] }
        if ($contactsSection -match '<p><strong>Secondary Contact:</strong> (.*?)</p>') { $existingData.SecondaryContact = $matches[1] }
    }
    
    # Extract medical info
    if ($htmlContent -match '<h2>Medical Information</h2>([\s\S]*?)<h2>') {
        $medicalSection = $matches[1]
        if ($medicalSection -match '<p><strong>Blood Type:</strong> (.*?)</p>') { $existingData.BloodType = $matches[1] }
        if ($medicalSection -match '<p><strong>Allergies:</strong> (.*?)</p>') { $existingData.Allergies = $matches[1] }
        if ($medicalSection -match '<p><strong>Medications:</strong> (.*?)</p>') { $existingData.Medications = $matches[1] }
        if ($medicalSection -match '<p><strong>Medical Conditions:</strong> (.*?)</p>') { $existingData.MedicalConditions = $matches[1] }
    }
    
    # Extract passwords/accounts
    if ($htmlContent -match '<h2>Important Accounts</h2>([\s\S]*?)<h2>|<h2>Important Accounts</h2>([\s\S]*?)$') {
        $accountsSection = if ($matches[1]) { $matches[1] } else { $matches[2] }
        
        # Extract each account as a separate item
        $accountMatches = [regex]::Matches($accountsSection, '<li><strong>(.*?):</strong> (.*?)</li>')
        $existingData.Accounts = @{}
        
        foreach ($match in $accountMatches) {
            $accountName = $match.Groups[1].Value
            $accountDetails = $match.Groups[2].Value
            $existingData.Accounts[$accountName] = $accountDetails
        }
    }
}

# Collect user information with defaults from existing data
Write-Host "`n=== Personal Information ===" -ForegroundColor Green
$fullName = Get-UserInput -prompt "Full Name" -default $existingData.FullName
$dob = Get-UserInput -prompt "Date of Birth" -default $existingData.DOB
$address = Get-UserInput -prompt "Address" -default $existingData.Address
$phone = Get-UserInput -prompt "Phone Number" -default $existingData.Phone

Write-Host "`n=== Emergency Contacts ===" -ForegroundColor Green
$primaryContact = Get-UserInput -prompt "Primary Emergency Contact" -default $existingData.PrimaryContact
$relationship = Get-UserInput -prompt "Relationship" -default $existingData.Relationship
$contactPhone = Get-UserInput -prompt "Contact Phone" -default $existingData.ContactPhone
$secondaryContact = Get-UserInput -prompt "Secondary Contact" -default $existingData.SecondaryContact

Write-Host "`n=== Medical Information ===" -ForegroundColor Green
$bloodType = Get-UserInput -prompt "Blood Type" -default $existingData.BloodType
$allergies = Get-UserInput -prompt "Allergies" -default $existingData.Allergies
$medications = Get-UserInput -prompt "Medications" -default $existingData.Medications
$medicalConditions = Get-UserInput -prompt "Medical Conditions" -default $existingData.MedicalConditions

# Handle accounts and passwords
Write-Host "`n=== Important Accounts & Passwords ===" -ForegroundColor Green
$accounts = @{}

# If there are existing accounts, show them and allow updates
if ($existingData.Accounts -and $existingData.Accounts.Count -gt 0) {
    Write-Host "Current accounts found:"
    $i = 1
    foreach ($account in $existingData.Accounts.GetEnumerator()) {
        Write-Host "$i. $($account.Key): $($account.Value)"
        $i++
    }
    
    # Copy existing accounts
    $accounts = $existingData.Accounts.Clone()
    
    # Ask for updates
    do {
        $updateChoice = Read-Host "`nWould you like to [A]dd a new account, [U]pdate an existing one, [D]elete an account, or [C]ontinue? (A/U/D/C)"
        
        switch ($updateChoice.ToUpper()) {
            "A" {
                $newAccount = Read-Host "Enter new account name"
                $accountDetails = Read-Host "Enter account details"
                $accounts[$newAccount] = $accountDetails
                Write-Host "Account added." -ForegroundColor Green
            }
            "U" {
                $updateAccount = Read-Host "Enter name of account to update"
                if ($accounts.ContainsKey($updateAccount)) {
                    $accountDetails = Read-Host "Enter new details for $updateAccount"
                    $accounts[$updateAccount] = $accountDetails
                    Write-Host "Account updated." -ForegroundColor Green
                } else {
                    Write-Host "Account not found." -ForegroundColor Red
                }
            }
            "D" {
                $deleteAccount = Read-Host "Enter name of account to delete"
                if ($accounts.ContainsKey($deleteAccount)) {
                    $accounts.Remove($deleteAccount)
                    Write-Host "Account deleted." -ForegroundColor Green
                } else {
                    Write-Host "Account not found." -ForegroundColor Red
                }
            }
            "C" {
                # Do nothing, continue to next step
            }
            default {
                Write-Host "Invalid option, please try again." -ForegroundColor Yellow
            }
        }
    } while ($updateChoice.ToUpper() -ne "C")
} else {
    # No existing accounts, collect new ones
    Write-Host "No existing accounts found. Let's add some important accounts."
    do {
        $accountName = Read-Host "`nEnter account name (or leave empty to finish)"
        if (![string]::IsNullOrWhiteSpace($accountName)) {
            $accountDetails = Read-Host "Enter account details for $accountName"
            $accounts[$accountName] = $accountDetails
        }
    } while (![string]::IsNullOrWhiteSpace($accountName))
}

# Generate last updated date
$lastUpdated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Generate HTML content
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My ICE (In Case of Emergency) Information</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        h1 {
            color: #d33;
            text-align: center;
            border-bottom: 2px solid #d33;
            padding-bottom: 10px;
        }
        h2 {
            color: #333;
            border-bottom: 1px solid #ccc;
            padding-bottom: 5px;
        }
        .section {
            margin-bottom: 30px;
        }
        .updated {
            text-align: right;
            font-style: italic;
            color: #666;
            font-size: 0.9em;
        }
        .important {
            font-weight: bold;
            color: #d33;
        }
        ul {
            list-style-type: none;
            padding-left: 20px;
        }
        li {
            margin-bottom: 5px;
        }
        @media print {
            body {
                font-size: 12pt;
            }
            h1 {
                font-size: 18pt;
            }
            h2 {
                font-size: 16pt;
            }
        }
    </style>
</head>
<body>
    <h1>My ICE (In Case of Emergency) Information</h1>
    <p class="updated">Last Updated: $lastUpdated</p>
    
    <div class="section">
        <h2>Personal Information</h2>
        <p><strong>Full Name:</strong> $fullName</p>
        <p><strong>Date of Birth:</strong> $dob</p>
        <p><strong>Address:</strong> $address</p>
        <p><strong>Phone:</strong> $phone</p>
    </div>
    
    <div class="section">
        <h2>Emergency Contacts</h2>
        <p><strong>Primary Contact:</strong> $primaryContact</p>
        <p><strong>Relationship:</strong> $relationship</p>
        <p><strong>Contact Phone:</strong> $contactPhone</p>
        <p><strong>Secondary Contact:</strong> $secondaryContact</p>
    </div>
    
    <div class="section">
        <h2>Medical Information</h2>
        <p><strong>Blood Type:</strong> $bloodType</p>
        <p><strong>Allergies:</strong> $allergies</p>
        <p><strong>Medications:</strong> $medications</p>
        <p><strong>Medical Conditions:</strong> $medicalConditions</p>
    </div>
    
    <div class="section">
        <h2>Important Accounts</h2>
        <p class="important">CONFIDENTIAL - Keep Secure</p>
        <ul>
"@

# Add accounts to HTML
foreach ($account in $accounts.GetEnumerator()) {
    $htmlContent += "            <li><strong>$($account.Key):</strong> $($account.Value)</li>`n"
}

# Complete HTML content
$htmlContent += @"
        </ul>
    </div>
    
    <div class="section">
        <h2>Important Notes</h2>
        <p>This document contains sensitive personal information. Keep it secure and only share with trusted individuals in case of emergency.</p>
    </div>
</body>
</html>
"@

# Save the HTML file
try {
    $htmlContent | Out-File -FilePath $iceFilePath -Force -Encoding UTF8
    Write-Host "`nSuccess! Your myICE.html file has been updated at: $iceFilePath" -ForegroundColor Green
    Write-Host "This file contains sensitive information. Please ensure it's stored securely." -ForegroundColor Yellow
} catch {
    Write-Host "Error saving file: $_" -ForegroundColor Red
}

# Option to open the file
$openFile = Read-Host "Would you like to open the file now? (Y/N)"
if ($openFile.ToUpper() -eq "Y") {
    Start-Process $iceFilePath
}
