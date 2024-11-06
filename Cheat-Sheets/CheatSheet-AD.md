# PowerShell Cheat Sheet - Active Directory

## **User Management**

- **Get User Information** – Retrieve user details for viewing.

  ```powershell
  Get-ADUser -Identity <username> -Properties * | Select-Object Name, EmailAddress, Title, Department
  ```

- **Unlock a User Account** – Unlocks an account after too many failed login attempts.

  ```powershell
  Unlock-ADAccount -Identity <username>
  ```

## **Group Management**

- **Get Group Information** – View details for a specific group.

  ```powershell
  Get-ADGroup -Identity "GroupName" -Properties * | Select-Object Name, Description
  ```

- **Add a User to a Specific Group** – Adds a user to an authorized group.

  ```powershell
  Add-ADGroupMember -Identity "GroupName" -Members <username>
  ```

- **List All Members of a Group** – View group membership.

  ```powershell
  Get-ADGroupMember -Identity "GroupName"
  ```

- **Check if User is a Member of a Group** – Verifies group membership.

  ```powershell
  Get-ADUser -Identity <username> -Properties MemberOf | Select-Object -ExpandProperty MemberOf
  ```

## **Computer Management**

- **Get Computer Information** – Retrieve details of a computer account.

  ```powershell
  Get-ADComputer -Identity "ComputerName" -Properties * | Select-Object Name, OperatingSystem, LastLogonDate
  ```

- **Delete a Computer Account** – Removes a computer account from AD.

  ```powershell
  Remove-ADComputer -Identity "ComputerName" -Confirm:$false
  ```

## **LAPS & BitLocker Management**

- **Retrieve LAPS Password** – Reads the Local Administrator Password Solution (LAPS) password.

  ```powershell
  Get-ADComputer -Identity "ComputerName" -Properties ms-Mcs-AdmPwd | Select-Object Name, @{Name="LAPSPassword";Expression={$_.“ms-Mcs-AdmPwd”}}
  ```

- **Retrieve BitLocker Recovery Key** – Gets the BitLocker recovery key for a specific computer.

  ```powershell
  Get-ADObject -Filter 'objectclass -eq "msFVE-RecoveryInformation"' -SearchBase "CN=ComputerName,OU=Computers,DC=domain,DC=com" -Properties msFVE-RecoveryPassword | Select-Object -ExpandProperty msFVE-RecoveryPassword
  ```

## **Searching & Filtering**

- **Search Users by Specific Criteria** – Locate users based on attributes.

  ```powershell
  Get-ADUser -Filter "Title -eq 'Manager'" -Properties DisplayName, Title, Department
  ```

- **Find Locked Out Users** – Identifies users with locked accounts.

  ```powershell
  Search-ADAccount -LockedOut | Select-Object Name, LockedOut
  ```

- **Find Disabled Accounts** – Lists accounts that are disabled.

  ```powershell
  Search-ADAccount -AccountDisabled | Select-Object Name, Enabled
  ```

## **Audit & Export Information**

- **Export User Details to CSV** – Saves user information for reporting.

  ```powershell
  Get-ADUser -Filter * -Properties Name, EmailAddress, Title | Select-Object Name, EmailAddress, Title | Export-Csv -Path "C:\ADUsers.csv" -NoTypeInformation
  ```

- **Export Group Membership to CSV** – Saves group membership list for reporting.

  ```powershell
  Get-ADGroupMember -Identity "GroupName" | Select-Object Name, SamAccountName | Export-Csv -Path "C:\GroupMembers.csv" -NoTypeInformation
  ```
