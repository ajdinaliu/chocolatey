# ¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨
#
#    Author: © AJAL
#    Date  : 30.06.2015
#    Goal  : Get Choco Package Install Wizard
#
# ¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨
<#
.SYNOPSIS
	<A brief description of the script>
.DESCRIPTION
	<A detailed description of the script>
.PARAMETER <paramName>
	<Description of script parameter>
.NOTES 		
	<Notes of script  / requirements>
.EXAMPLE
	<An example of using the script>
.INPUTS
	Hard work
.OUTPUTS
	Satisfaction
.LINK
	See http://www.matho.ch
#>

#region Params
	[CmdletBinding(DefaultParameterSetName="None")]
Param(
    [parameter(Mandatory=$false)]																#A semicolon delimited list of Nuget Feed URLs this script will search for packages
	[Alias("Source")]
	[ValidateNotNullOrEmpty()]
	#[string[]]$NuGetSourceFeeds = "http://chocolatey.org/api/v2;http://www.myget.org/F/boxstarter/api/v2",
	[string]$NuGetSourceFeeds = "https://www.myget.org/F/ajal_pub/api/v2",    	

	[Alias("InstallWith")]
	[string]
	[ValidateNotNullOrEmpty()]
	[ValidateSet("Boxstarter", "Chocolatey","Choco",IgnoreCase=$true)]
	$Installer        = "Boxstarter",
		
	[Alias("WorkDir")]
	[string]
	[ValidateNotNullOrEmpty()]
	[ValidateScript({ Test-Path $_ })]
	$WorkingDirectory = $pwd,
	
	[Parameter(ParameterSetName="LOC")]	# use local Repository with NuGet Packages ?
	[switch]
	$UseLocalRepo,
	
	[Parameter(ParameterSetName="LOC")]															# RootFolder of local Repository where NuGet packages are saved?
	[string]
	[ValidateNotNullOrEmpty()]
	[ValidateScript({ Test-Path $(Resolve-Path $_) })]
	$LocalRepoPath	
		

)
#endregion Params
# Hard Coded Variables
#[string]$NuGetSourceFeeds="https://www.myget.org/F/ajal_pub/api/v2"		#Todo: not hardcoded

#################
# CONFIGURATION #
#################


#################
# ARGUMENTS		#
#################



#################
# VARIABLES     #
#################
$DebugLevel = 0 														#Debud mode
$scriptName				= "Get-ChocoWizard.powershell"								# Name of this script, obviously.
$scriptVersion			= "0.0.0.1"										# ScriptVersion
$scriptQual				= "Beta"										# Release to Web
$sessionKey				= [Guid]::NewGuid().ToString()					# Session key, used for keeping records unique between multiple runs.
$logFolder				= "$($env:Temp)\$($scriptName)\$($sessionKey)"	# Log folder path.
$transcripting			= $false


# Banner text displayed during each run.
$scriptHeader = @"

AJAL $scriptName - Released under the Apache 2.0 License
Version $scriptVersion $scriptQual

"@
# Text used as the banner in the UI.
$ScriptUIHeader  = @"
Use the fields below to configure Package, Version, Source, PackageParameters for the packages that you want to install!
"@
# Text used for flag
$ScriptflagText = @"
This $VHDFormat was installed by $scriptName $scriptVersion $scriptQual
on $([DateTime]::Now).
"@

###################
# CHOCO VARIABLES #
###################
# chocolatey variables - https://github.com/chocolatey/choco/wiki/HelpersReference
#$packageName=$env:packageName 							# PackgageName of this package. The package name, which is equivalent to the <id> tag in the nuspec 
$packageName=$scriptName 								# PackgageName of this package. The package name, which is equivalent to the <id> tag in the nuspec 
#$packageVersion=$env:packageVersion					# The package version, which is equivalent to the <version> tag in the nuspec



#fix_ if choco variable "packageName" empty
	If (!$packageName){
		#SayWarn "Chocolatey variable PackgageName not evaluated!" 					#<id> tag in the nuspec
		$packageName=$sessionKey
	}
# temp path
$chocTempDir = Join-Path $env:TEMP "chocolatey"
$tempDir = Join-Path $chocTempDir "chocInstall"
if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
$ZIPfile = Join-Path $tempDir "$packageName.zip"

###################
# Get-ChocoWizard #
###################
# Dialogue config
[string]$Global:GCWLocalRepository 													# used to save local Repository with NuGet Packages
[System.Collections.ArrayList]$Global:arrSelectedPackages = @()		# Create an empty Array to save seleceted packages
[System.Collections.ArrayList]$Global:arrInstalledPackages = @()	# ToDo: installed packages - save output
[System.Collections.ArrayList]$arrCheckBoxArrayList = @()					# Create an empty Array to work with
	

#################
# FUNCTIONS 	#
#################

##########################################################################################
#General output Functions 
Function SayDebug {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string]
		[ValidateNotNullOrEmpty()]
		$text
	)
	
    If ($DebugLevel -ge 1){        
		If ($text){
			Write-Host "DEBUG   : $($text)" -ForegroundColor Yellow
		} else {
			Write-Host
		}		
    }
}
Function SayInfo {    
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string]
		[ValidateNotNullOrEmpty()]
		$text
	)
	
    If ($text){
        Write-Host "INFO   : $($text)" -ForegroundColor White
    }else {
		Write-Host
	}
}
Function SayOK {	
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string]
		[ValidateNotNullOrEmpty()]
		$text
	)
	
    If ($text){
        Write-Host "==>   : $($text)" -BackgroundColor DarkGreen
    }else {
		Write-Host
	}	
}
Function SayWarn{    
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string]
		[ValidateNotNullOrEmpty()]
		$text
	)
	Write-Host "WARN   : $($text)" -ForegroundColor Yellow
}
Function SayError{    
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string]
		[ValidateNotNullOrEmpty()]
		$text
	)
	Write-Host "ERROR  : $($text)" -ForegroundColor Red
}
Function SayTrace{    
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string]
		[ValidateNotNullOrEmpty()]
		$text
	)
	Write-Verbose $text
}

##########################################################################################
#tell me, running as admin or limited
Function Test-Admin{	
	$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
	$isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
	SayTrace "isUserAdmin? $isAdmin"
	return $isAdmin
}
##########################################################################################
#ToDo - Choco Logfile?

##########################################################################################
# download the package
# Download-File $url $file
# download 7zip
# Write-Host "Download 7Zip commandline tool"
# $7zaExe = Join-Path $tempDir '7za.exe'

# unzip the package
# Write-Host "Extracting $file to $tempDir..."
# Start-Process "$7zaExe" -ArgumentList "x -o`"$tempDir`" -y `"$file`"" -Wait -NoNewWindow
function Download-File {
param (
  [string]$url,
  [string]$file
 )
  Write-Host "Downloading $url to $file"
  $downloader = new-object System.Net.WebClient
  $downloader.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;
  $downloader.DownloadFile($url, $file)
}

##########################################################################################
## Load Module
Function Get-MyModule{
	Param([string]$name)
	if(-not(Get-Module -name $name))
		{
			if(Get-Module -ListAvailable | Where-Object { $_.name -eq $name })
			{
				Import-Module -Name $name
				$true
			} #end if module available then import
			else { $false } #module not available
		} # end if not module
	else { $true } #module already loaded
} #end function get-MyModule


##########################################################################################
Function GlobalMemoryCleanup{	
	if($Global:GCWLocalRepository){	Remove-Variable -Name GCWLocalRepository -Scope Global -Force}	
	Remove-Variable -Name arrSelectedPackages -Scope Global -Force
	Remove-Variable -Name arrInstalledPackages -Scope Global -Force
}

#################
# MAIN 			#
#################
Write-Host "********************************************************************************" -ForegroundColor Gray
Write-Host $scriptHeader -ForegroundColor Gray
Write-Host "********************************************************************************" -ForegroundColor Gray
Write-Host 
#SayInfo "Feeds used : $NuGetSourceFeeds"

# Create log folder
if (Test-Path $logFolder) {
	$null = rd $logFolder -Force -Recurse
}
$null = md $logFolder -Force
# Try to start transcripting.  If it's already running, we'll get an exception and swallow it.
try {
	$null = Start-Transcript -Path (Join-Path $logFolder "$($scriptName).log") -Force -ErrorAction SilentlyContinue
	$transcripting = $true
} catch {
	SayWarn "Transcription is already running.  No $($scriptName)-specific transcript will be created."
	$transcripting = $false
}

# Check to make sure we're running as Admin.
if (!(Test-Admin)) {
	throw "Packages can only be installed by an administrator. Please launch PowerShell elevated and run this script again."
}


	SayInfo "Launching UI..."
	#region UI
	Add-Type -AssemblyName System.Drawing,System.Windows.Forms	
	# Import the Assemblies
	#[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
	#[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

	#prepare environment for System.Windows.Forms and show PackageRepositoryLocation
	#[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null	

	#region FormObjects
	$openFolderDialog 				= New-Object Windows.Forms.FolderBrowserDialog
	$InitialFormWindowState 		= New-Object System.Windows.Forms.FormWindowState
	$formMain 						= New-Object System.Windows.Forms.Form
	$InstallPacakgesbutton 			= New-Object System.Windows.Forms.Button
	$Cancelbutton 					= New-Object System.Windows.Forms.Button
	$Addbutton 						= New-Object System.Windows.Forms.Button
	$Removebutton 					= New-Object System.Windows.Forms.Button
	$MoveUpbutton 					= New-Object System.Windows.Forms.Button
	$MoveDownbutton 				= New-Object System.Windows.Forms.Button
	$listBoxPackages1 				= New-Object System.Windows.Forms.ListBox
	$listBoxPackages2 				= New-Object System.Windows.Forms.ListBox
    $labelAvailablePackages			= New-Object System.Windows.Forms.Label
    $labelSelectedPackages			= New-Object System.Windows.Forms.Label
    $labelLocalRepo					= New-Object System.Windows.Forms.Label

	#endregion FormObjects
	
	#region Event
	$OnLoadForm_StateCorrection={# Correct the initial state of the form to prevent the .Net maximized form issue
		$formMain.WindowState = $InitialFormWindowState
	}
	
	$Cancelbutton_OnClick={
		#LogWrite ">> Updates selection canceled!"		
		$formMain.Close()
	}	
	
	$Addbutton_OnClick={
		if ($listBoxPackages1.SelectedItem){
			$listBoxPackages2.Items.Add($listBoxPackages1.SelectedItem)
			$listBoxPackages1.Items.Remove($listBoxPackages1.SelectedItem)
		}		 
	}	
	
	$Removebutton_OnClick={
		if ($listBoxPackages2.SelectedItem){
			$listBoxPackages1.Items.Add($listBoxPackages2.SelectedItem)
			$listBoxPackages2.Items.Remove($listBoxPackages2.SelectedItem)
		}		 
	}	
		
	$InstallPacakgesbutton_OnClick={				
		if ($listBoxPackages2.Items.Count -eq 0) 											# Check if anything is selected
		{
			[System.Windows.Forms.MessageBox]::Show("Nothing Selected. Click cancel to close dialogue or select package(s) for processing!")			
		}
		else{
					
			$formMain.hide()																# hide LocallRepository Form			
			$AmountSelected = $listBoxPackages2.Items.Count
			foreach ($itemChecked in $listBoxPackages2.Items){
				$Global:arrSelectedPackages.Add($itemChecked)
				#Todo! write-host ">> Selected packages Folder: $UpdateFolderItem"
			}
			#Todo: change this_ SayOK "$AmountSelected package folder(s) selected."
			$formMain.Close() |Out-Null

		}
	}
	
	$MoveUpbutton_OnClick={
		if ($listBoxPackages2.SelectedIndex -gt 0){
			$listidx = $listBoxPackages2.SelectedIndex -1
			$listBoxPackages2.Items.Insert($listidx,$listBoxPackages2.SelectedItem)
			$listBoxPackages2.Items.RemoveAt($listBoxPackages2.SelectedIndex)
			$listBoxPackages2.SelectedIndex = $listidx
		}			
	}	
	
	$MoveDownbutton_OnClick={
		if ($listBoxPackages2.SelectedIndex -lt $listBoxPackages2.Items.Count -1){
			$listidx = $listBoxPackages2.SelectedIndex +2
			$listBoxPackages2.Items.Insert($listidx,$listBoxPackages2.SelectedItem)
			$listBoxPackages2.Items.RemoveAt($listBoxPackages2.SelectedIndex)
			$listBoxPackages2.SelectedIndex = $listidx -1
		}			
	}

	
	# endregion Event	

	#region FormCode	
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 560
	$System_Drawing_Size.Width = 630
	$formMain.ClientSize = $System_Drawing_Size
	$formMain.DataBindings.DefaultDataSourceUpdateMode = 0
	$formMain.Name = "formMain"
	$formMain.Text = "$scriptName - AJAL "
	$openFolderDialog.Description = "Choose the Root of your local Package Repository"
	$openFolderDialog.ShowNewFolderButton = $false

	#region Cancel button
	$Cancelbutton.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 360
	$System_Drawing_Point.Y = 511
	$Cancelbutton.Location = $System_Drawing_Point
	$Cancelbutton.Name = "Cancelbutton"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 23
	$System_Drawing_Size.Width = 75
	$Cancelbutton.Size = $System_Drawing_Size
	#$Cancelbutton.TabIndex = 6
	$Cancelbutton.Text = "Cancel"
	$Cancelbutton.UseVisualStyleBackColor = $True
	$Cancelbutton.add_Click($Cancelbutton_OnClick)
	
	$formMain.Controls.Add($Cancelbutton)
	#endregion Cancel button
	
	#region listbox
	$listBoxPackages1.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 12
	$System_Drawing_Point.Y = 45
	$listBoxPackages1.Location = $System_Drawing_Point
	$listBoxPackages1.Name = "listBoxPackages1"	
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 450
	$System_Drawing_Size.Width = 250	
	$listBoxPackages1.Size = $System_Drawing_Size
	#$listBoxPackages1.TabIndex = 0
	#$listBoxPackages1.SelectionMode =  "One"	
	$listBoxPackages1.FormattingEnabled = $True
	#endregion listbox

	#region listbox2
	$listBoxPackages2.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 320
	$System_Drawing_Point.Y = 45
	$listBoxPackages2.Location = $System_Drawing_Point
	$listBoxPackages2.Name = "listBoxPackages2"	
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 450
	$System_Drawing_Size.Width = 250	
	$listBoxPackages2.Size = $System_Drawing_Size
	#$listBoxPackages2.TabIndex = 1
	#$listBoxPackages1.SelectionMode =  "One"	
	$listBoxPackages2.FormattingEnabled = $True
	#endregion listbox2

	#region labelAvailablePackages
	$labelAvailablePackages.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point							= New-Object System.Drawing.Point
	$System_Drawing_Point.X							= 12
	$System_Drawing_Point.Y							= 21
	$labelAvailablePackages.Location				= $System_Drawing_Point
	$labelAvailablePackages.Name					= "labelAvailablePackages"
	$System_Drawing_Size							= New-Object System.Drawing.Size
	$System_Drawing_Size.Height						= 20
	$System_Drawing_Size.Width						= 120
	$labelAvailablePackages.Size					= $System_Drawing_Size
	#$labelAvailablePackages.TabIndex				= 888888
	$labelAvailablePackages.Text					= "Packages found..."

	$formMain.Controls.Add($labelAvailablePackages)
	#endregion labelAvailablePackages

	#region labelSelectedPackages
	$labelSelectedPackages.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point							= New-Object System.Drawing.Point
	$System_Drawing_Point.X							= 320
	$System_Drawing_Point.Y							= 21
	$labelSelectedPackages.Location				= $System_Drawing_Point
	$labelSelectedPackages.Name					= "labelSelectedPackages"
	$System_Drawing_Size							= New-Object System.Drawing.Size
	$System_Drawing_Size.Height						= 20
	$System_Drawing_Size.Width						= 120
	$labelSelectedPackages.Size					= $System_Drawing_Size
	#$labelSelectedPackages.TabIndex				= 888888
	$labelSelectedPackages.Text					= "Packages to install..."

	$formMain.Controls.Add($labelSelectedPackages)
	#endregion labelSelectedPackages

	#region labelLocalRepo
	$labelLocalRepo.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point							= New-Object System.Drawing.Point
	$System_Drawing_Point.X							= 12
	$System_Drawing_Point.Y							= 511
	$labelLocalRepo.Location						= $System_Drawing_Point
	$labelLocalRepo.Name							= "labelLocalRepo"
	$System_Drawing_Size							= New-Object System.Drawing.Size
	$System_Drawing_Size.Height						= 40
	$System_Drawing_Size.Width						= 300
	$labelLocalRepo.Size							= $System_Drawing_Size
	#$labelLocalRepo.TabIndex						= 888888
	$labelLocalRepo.Text							= "-No Local Repository-"

	$formMain.Controls.Add($labelLocalRepo)
	#endregion labelLocalRepo

	#region Add button
	$Addbutton.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 265
	$System_Drawing_Point.Y = 200
	$Addbutton.Location = $System_Drawing_Point
	$Addbutton.Name = "Addbutton"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 25
	$System_Drawing_Size.Width = 50
	$Addbutton.Size = $System_Drawing_Size
	#$Addbutton.TabIndex = 2
	$Addbutton.Text = ">"
	$Addbutton.UseVisualStyleBackColor = $True
	$Addbutton.add_Click($Addbutton_OnClick)
	
	$formMain.Controls.Add($Addbutton)
	#endregion Add button

	#region Remove button
	$Removebutton.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 265
	$System_Drawing_Point.Y = 250
	$Removebutton.Location = $System_Drawing_Point
	$Removebutton.Name = "Removebutton"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 25
	$System_Drawing_Size.Width = 50
	$Removebutton.Size = $System_Drawing_Size
	#$Removebutton.TabIndex = 3
	$Removebutton.Text = "<"
	$Removebutton.UseVisualStyleBackColor = $True
	$Removebutton.add_Click($Removebutton_OnClick)
	
	$formMain.Controls.Add($Removebutton)
	#endregion Remove button

	#region MoveUpbutton button
	$MoveUpbutton.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 575
	$System_Drawing_Point.Y = 200
	$MoveUpbutton.Location = $System_Drawing_Point
	$MoveUpbutton.Name = "MoveUpbutton"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 25
	$System_Drawing_Size.Width = 50
	$MoveUpbutton.Size = $System_Drawing_Size
	#$MoveUpbutton.TabIndex = 4
	$MoveUpbutton.Text = "UP"
	$MoveUpbutton.UseVisualStyleBackColor = $True
	$MoveUpbutton.add_Click($MoveUpbutton_OnClick)
	
	$formMain.Controls.Add($MoveUpbutton)
	#endregion MoveUpbutton button

	#region MoveDownbutton button
	$MoveDownbutton.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 575
	$System_Drawing_Point.Y = 250
	$MoveDownbutton.Location = $System_Drawing_Point
	$MoveDownbutton.Name = "MoveDownbutton"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 25
	$System_Drawing_Size.Width = 50
	$MoveDownbutton.Size = $System_Drawing_Size
	#$MoveDownbutton.TabIndex = 5
	$MoveDownbutton.Text = "Down"
	$MoveDownbutton.UseVisualStyleBackColor = $True
	$MoveDownbutton.add_Click($MoveDownbutton_OnClick)
	
	$formMain.Controls.Add($MoveDownbutton)
	#endregion MoveDownbutton button
		
	#region InstallPacakges button
	$InstallPacakgesbutton.DataBindings.DefaultDataSourceUpdateMode = 0
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 442
	$System_Drawing_Point.Y = 511
	$InstallPacakgesbutton.Location = $System_Drawing_Point
	$InstallPacakgesbutton.Name = "InstallPackages"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 23
	$System_Drawing_Size.Width = 100
	$InstallPacakgesbutton.Size = $System_Drawing_Size
	#$InstallPacakgesbutton.TabIndex = 7
	$InstallPacakgesbutton.DialogResult = "OK"
	$InstallPacakgesbutton.Text = "Install Packages"
	$InstallPacakgesbutton.UseVisualStyleBackColor = $True
	$InstallPacakgesbutton.add_Click($InstallPacakgesbutton_OnClick)
	
	$formMain.Controls.Add($InstallPacakgesbutton)
	#endregion InstallPacakges button
	
	#region ListBoxCode
	#SayDebug "Listing Packages..."	
	#LogWrite ">> Listing Packages..."
	
	#Get choco packages	
	$itemPackages = choco list -source $NuGetSourceFeeds
	# $Global:arrSelectedPackages
	# $PkgItems = @(get-childitem $PIMDTUpdRoot -Recurse | ? { $_.NodeType -eq "Package" }).Count	
	# Write-Host "Total of packages found:" $PkgItems
	
		#region FilterPackages
		#Add "packages" to array
		foreach ($itemPackage in $itemPackages) { 						
				#Filter out this package
				If ($itemPackage -notmatch $packageName){
					$arrCheckBoxArrayList.Add($itemPackage) | Out-Null
				}
				#Todo: Package Parameters
			<# 			if($itemPackage.nodetype -eq 'PackageFolder') 
							{
								#Write-Host $itemPackage.Name
								#$SplitVariable = $itemPackage.Name 
								$SplitVariable = ($itemPackage.PSParentPath).SubString(52)+"\"+$itemPackage.Name 
								$arrCheckBoxArrayList += $SplitVariable
							}
			 #>	
		}		
		
		$arrCheckBoxArrayList.Remove($arrCheckBoxArrayList[0])					# Remove "chocolatey vx.x.x.x" - ToDo: check listheader; "choco list -source" - 1st item='Chocolatey v x.x.x.x' ?		
		$arrCheckBoxArrayList.Remove($arrCheckBoxArrayList[-1])				# Remove "n packages found" - check listfooter		
		#$arrCheckBoxArrayList = $arrCheckBoxArrayList | sort -Unique			# Only select unique packages in array - ku ta dish?:)
	
	
		foreach($itemPckg in $arrCheckBoxArrayList) {
			$listBoxPackages1.Items.Add($itemPckg)|Out-Null				# Add checkboxes to CheckedListBox object
		}
		#endregion FilterPackages
	
	$formMain.Controls.Add($listBoxPackages1)
	$formMain.Controls.Add($listBoxPackages2)
	#endregion ListBoxCode
		
	#region Dailog init Form
	# Save the initial state of the form
	$InitialFormWindowState = $formMain.WindowState

	# Init the OnLoad event to correct the initial state of the form
	$formMain.add_Load($OnLoadForm_StateCorrection)
	#endregion Dailog init Form
		
	#endregion FormCode
	
	#region LocalRepo
	If ($UseLocalRepo){		
		If(!$LocalRepoPath){
			#show openFolderDialog
			#$openFolderDialog.ShowDialog( )| Out-Null
			$ret = $openFolderDialog.ShowDialog( )					
			if ($ret -ilike "OK"){				
				$Global:GCWLocalRepository = $openFolderDialog.SelectedPath				
				$labelLocalRepo.Text = "Local Repository: " +$openFolderDialog.SelectedPath
                $Message = "Local Repository used: " + $Global:GCWLocalRepository
				SayInfo $Message			
			}			
		}else{
			#Get Param Value
			$Global:GCWLocalRepository = $LocalRepoPath
			$labelLocalRepo.Text = "Local Repository: " + $LocalRepoPath
            $Message = "Local Repository used: " + $Global:GCWLocalRepository
			SayInfo $Message			
		}
	}
	#endregion LocalRepo
	
	#region InstallPackages Dialog
	$ret = $formMain.ShowDialog()
	$formMain.Dispose()
	#endregion InstallPackages Dialog
	
	#endregion UI


#fix no packageName
If ($packageName -eq $sessionKey){
	SayWarn "could not resolve Chocolatey variable PackgageName!"
}

If($Installer.ToLower() -eq "boxstarter"){
	#Boxstarter
	#Import-Module Boxstarter.Chocolatey
	If(-not(Get-MyModule -name "Boxstarter.Chocolatey")){ 
		SayError "Could not load Boxstarter.Chocolatey Module!"	
		#Read-Host "Press any key to close console!" | Out-Null
		#Exit 10
	}else{
		If($uselocalRepo){
			Set-BoxstarterConfig -LocalRepo $Global:GCWLocalRepository
		}
		Set-BoxstarterConfig -NugetSources $NuGetSourceFeeds	
	}	
}

If ($Global:arrSelectedPackages){
	#Install all selected packages
	foreach($itemPackage in $Global:arrSelectedPackages) {						

		$MyPackageDetails = $itemPackage.Split()
		$MyPackageName = $MyPackageDetails[0]
		$MyPackageVer = $MyPackageDetails[1]
		$MyPackageArgs = ""
		
		SayInfo ">> Installing package : $MyPackageName"
		
		switch ($Installer){			
			{($_ -eq "chocolatey") -or ($_ -eq "choco")}{
				choco install $MyPackageName --version $MyPackageVer --y --r #--package-parameters=$MyPackageArgs #--package-parameters=VALUE --user=VALUE --password=VALUE -pre Prereleases - Include Prereleases?		
			}
			"boxstarter"{
				Install-BoxstarterPackage -PackageName $MyPackageName -DisableReboots -Force #-KeepWindowOpen		
			}			
		}
	}	
}else{
	SayWarn "Cancelled... No packages installed!"
}
#Write-ChocolateySuccess $packageName finished!
#Write-Host Done! -ForegroundColor Green

GlobalMemoryCleanup

# Close out the transcript and tell the user we're done.
SayInfo "Done."
if ($transcripting) {
	$null = Stop-Transcript
}