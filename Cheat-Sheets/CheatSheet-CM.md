# PowerShell Cheat Sheet - Configuration Manager

## **Initial Setup**

- **Import the SCCM PowerShell Module**

  ```powershell
  Import-Module "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
  ```

- **Set the SCCM Site Code** – Replace `XYZ` with your specific site code.

  ```powershell
  $SiteCode = "XYZ"
  cd "$SiteCode:"
  ```

## **Collections Management**

- **List All Collections** (Device & User)

  ```powershell
  Get-CMCollection
  ```

- **Get Detailed Information About a Collection**

  ```powershell
  Get-CMDeviceCollection -Name "CollectionName" | Select-Object *
  ```

- **Create a Device Collection with Query Membership Rule**

  ```powershell
  $Query = "select SMS_R_SYSTEM.ResourceID from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation%'"
  New-CMDeviceCollection -Name "Windows Workstations" -LimitingCollectionName "All Systems" -QueryMembershipRule $Query
  ```

- **Remove a Device Collection**

  ```powershell
  Remove-CMDeviceCollection -Name "CollectionName"
  ```

- **List All Devices in a Collection**

  ```powershell
  Get-CMDeviceCollectionMember -CollectionName "CollectionName"
  ```

## **Device Management**

- **List All Devices with Extended Properties**

  ```powershell
  Get-CMDevice | Select-Object Name, DeviceID, ResourceID, SMSAssignedSites, AgentEdition, ClientVersion
  ```

- **Get Device by MAC Address**

  ```powershell
  Get-CMDevice -MACAddress "00-1A-2B-3C-4D-5E"
  ```

- **Rename a Device**

  ```powershell
  Rename-CMDevice -Name "OldDeviceName" -NewName "NewDeviceName"
  ```

## **Application Management**

- **List All Applications with Additional Details**

  ```powershell
  Get-CMApplication | Select-Object LocalizedDisplayName, SoftwareVersion, Manufacturer, DeploymentType
  ```

- **Get Detailed Information About an Application**

  ```powershell
  Get-CMApplication -Name "AppName" | Select-Object *
  ```

- **Modify Application Deployment Type**

  ```powershell
  Set-CMDeploymentType -ApplicationName "AppName" -DeploymentTypeName "AppDeploymentType" -InstallCommand "NewInstallCommand"
  ```

- **Delete an Application**

  ```powershell
  Remove-CMApplication -Name "AppName"
  ```

## **Package & Program Management**

- **Create a Package**

  ```powershell
  New-CMPackage -Name "PackageName" -Path "\\Server\Share\Source" -Description "Package for testing"
  ```

- **Create a Program for a Package**

  ```powershell
  New-CMProgram -PackageName "PackageName" -StandardProgramName "ProgramName" -CommandLine "setup.exe /silent" -Description "Silent Install Program"
  ```

- **Deploy a Package to a Collection**

  ```powershell
  Start-CMPackageDeployment -PackageName "PackageName" -CollectionName "CollectionName" -DeploymentType Required
  ```

## **Deployment Management**

- **List All Application Deployments**

  ```powershell
  Get-CMApplicationDeployment
  ```

- **Get Deployment Details for a Specific Application**

  ```powershell
  Get-CMApplicationDeployment -Name "AppName"
  ```

- **Update Deployment Properties**

  ```powershell
  Set-CMDeployment -DeploymentID <DeploymentID> -NewDeadline $((Get-Date).AddDays(7))
  ```

- **Monitor Deployment Status**

  ```powershell
  Get-CMDeploymentStatus -Name "AppName" -CollectionName "CollectionName"
  ```

- **Delete an Application Deployment**

  ```powershell
  Remove-CMDeployment -DeploymentID <DeploymentID>
  ```

## **Software Update Management**

- **List All Software Updates with Details**

  ```powershell
  Get-CMSoftwareUpdate | Select-Object ArticleID, Title, DatePosted, IsDeployed
  ```

- **Synchronize Software Updates**

  ```powershell
  Sync-CMSoftwareUpdate
  ```

- **Create a Software Update Group**

  ```powershell
  New-CMSoftwareUpdateGroup -Name "UpdateGroupName"
  ```

- **Add Updates to Software Update Group**

  ```powershell
  Add-CMSoftwareUpdateToGroup -SoftwareUpdateGroupName "UpdateGroupName" -SoftwareUpdateIDs <UpdateID1>, <UpdateID2>
  ```

- **Deploy Software Update Group to Collection**

  ```powershell
  Start-CMSoftwareUpdateDeployment -DeploymentName "UpdateDeployment" -SoftwareUpdateGroupName "UpdateGroupName" -CollectionName "CollectionName" -Deadline ((Get-Date).AddDays(3))
  ```

## **Compliance & Baseline Management**

- **Get All Compliance Settings**

  ```powershell
  Get-CMComplianceSetting
  ```

- **Create Compliance Setting**

  ```powershell
  New-CMComplianceSettingFile -Name "FileComplianceSetting" -Description "Check file compliance" -FileName "C:\Path\File.txt"
  ```

- **Create and Deploy a Baseline**

  ```powershell
  $Baseline = New-CMBaseline -Name "ComplianceBaseline" -Description "Baseline Description"
  Start-CMBaselineDeployment -Name "ComplianceBaseline" -CollectionName "CollectionName"
  ```

## **Task Sequence Management**

- **List All Task Sequences with Details**

  ```powershell
  Get-CMTaskSequence | Select-Object Name, PackageID, LastModified
  ```

- **Copy an Existing Task Sequence**

  ```powershell
  Copy-CMTaskSequence -TaskSequenceName "OriginalTaskSequence" -NewTaskSequenceName "CopiedTaskSequence"
  ```

- **Edit Task Sequence Variable**

  ```powershell
  Set-CMTaskSequenceVariable -TaskSequenceName "TaskSequenceName" -VariableName "TSVar" -Value "NewValue"
  ```

- **Delete a Task Sequence**

  ```powershell
  Remove-CMTaskSequence -Name "TaskSequenceName"
  ```

## **Client Actions**

- **Trigger a Software Update Scan**

  ```powershell
  Invoke-CMClientAction -DeviceName "DeviceName" -Action "SoftwareUpdatesScanCycle"
  ```

- **Initiate User Policy Retrieval**

  ```powershell
  Invoke-CMClientAction -DeviceName "DeviceName" -Action "RequestUserPolicy"
  ```

- **Force Application Deployment Evaluation**

  ```powershell
  Invoke-CMClientAction -DeviceName "DeviceName" -Action "ApplicationDeploymentEvaluationCycle"
  ```

## **Monitoring & Reporting**

- **Get All Status Messages for a Deployment**

  ```powershell
  Get-CMStatusMessage -DeploymentID <DeploymentID> | Select-Object MessageID, Component, MessageType, SiteCode
  ```

- **View Compliance Summary for a Collection**

  ```powershell
  Get-CMComplianceSummaryReport -CollectionName "CollectionName"
  ```

- **Get Deployment Success Rate for a Collection**

  ```powershell
  Get-CMDeploymentStatus -Name "AppName" -CollectionName "CollectionName" | Select-Object Name, EnforcementState, LastComplianceMessage
  ```

- **Export Report to CSV**

  ```powershell
  Get-CMStatusMessage -CollectionName "CollectionName" | Export-Csv -Path "C:\StatusMessages.csv" -NoTypeInformation
  ```

## **Queries**

Queries in SCCM help identify and organize resources based on criteria. Below are some PowerShell commands to create, retrieve, and work with queries.

- **List All Queries**

  ```powershell
  Get-CMQuery
  ```

- **Get Query Details by Name**

  ```powershell
  Get-CMQuery -Name "QueryName" | Select-Object *
  ```

- **Create a New Query** – Creates a device query based on a simple attribute.

  ```powershell
  New-CMQuery -Name "Windows 10 Devices" -CollectionName "All Systems" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.Name from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT Workstation 10.0%'"
  ```

- **Modify an Existing Query**

  ```powershell
  Set-CMQuery -Name "QueryName" -NewQueryExpression "select * from SMS_R_System where SMS_R_System.LastLogonTimestamp >= (Get-Date).AddDays(-30)"
  ```

- **Delete a Query**

  ```powershell
  Remove-CMQuery -Name "QueryName"
  ```

## **Reports**

Reports in SCCM provide data-driven insights into your environment. Here’s how to manage and run SCCM reports with PowerShell.

- **List All Reports**

  ```powershell
  Get-CMReport
  ```

- **Get Report Details**

  ```powershell
  Get-CMReport -Name "ReportName" | Select-Object *
  ```

- **Run a Report and Export Results to CSV** – Running reports directly via PowerShell typically returns metadata, but you can use SQL queries to extract data if direct data output is needed.

  ```powershell
  Invoke-Sqlcmd -Query "SELECT * FROM v_ReportViewName" -ServerInstance "SQLServerInstance" | Export-Csv -Path "C:\ReportResults.csv" -NoTypeInformation
  ```

- **Create a Report Folder**

  ```powershell
  New-CMReportFolder -Name "CustomReports" -ParentFolderID 5000  # Replace with appropriate ParentFolderID
  ```

- **Create a New Report** – Requires SQL query; adjust parameters as necessary.

  ```powershell
  New-CMReport -Name "Custom Report" -CategoryID 1 -SQLQuery "SELECT * FROM v_R_System"
  ```

- **Delete a Report**

  ```powershell
  Remove-CMReport -Name "ReportName"
  ```

## **User-Device Affinity**

User-device affinity (UDA) in SCCM establishes relationships between users and devices, helping target deployments or configurations to primary devices associated with specific users.

- **View User Affinity for a Device**

  ```powershell
  Get-CMUserAffinity -DeviceName "DeviceName"
  ```

- **View Device Affinity for a User**

  ```powershell
  Get-CMUserAffinity -UserName "UserName"
  ```

- **Add User-Device Affinity** – Creates a direct user-device affinity.

  ```powershell
  New-CMUserAffinity -UserName "UserName" -DeviceName "DeviceName" -PrimaryUsage $true
  ```

- **Remove User-Device Affinity** – Removes an established user-device relationship.

  ```powershell
  Remove-CMUserAffinity -UserName "UserName" -DeviceName "DeviceName"
  ```

- **List All Devices with Affinity for a User** – Lists devices where the user is marked as primary.

  ```powershell
  Get-CMUserAffinity -UserName "UserName" | Where-Object { $_.PrimaryUsage -eq $true }
  ```

- **Automatically Create User-Device Affinity Based on Usage** – Configure settings in SCCM to allow automatic UDA creation based on user login history.

  ```powershell
  # This setting needs to be configured within the SCCM console under Administration -> Client Settings -> Default Client Settings -> User and Device Affinity
  ```
