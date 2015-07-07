$arguments = @{}

# Let's assume that the input string is something like this, and we will use a Regular Expression to parse the values
# /Port:81 /Edition:LicenseKey /AdditionalTools

# Now we can use the $env:chocolateyPackageParameters inside the Chocolatey package
$packageParameters = $env:chocolateyPackageParameters

# Default the values

#$port = "81"
#$edition = "LicenseKey"
#$additionalTools = $false
#$installationPath = "c:\temp"

# Now parse the packageParameters using good old regular expression
if ($packageParameters) {

	if ($arguments.ContainsKey("Port")) {
		Write-Host "Port Argument Found"
		$port = $arguments["Port"]
	}

}else {
	Write-Debug "No Package Parameters Passed in"
}
  
#$silentArgs = "/S /Port:" + $port + " /Edition:" + $edition + " /InstallationPath:" + $installationPath
#if ($additionalTools) { $silentArgs += " /Additionaltools" }

#Write-Debug "This would be the Chocolatey Silent Arguments: $silentArgs"


$psFile = Join-Path "$(Split-Path -parent $MyInvocation.MyCommand.Definition)" 'Get-ChocoWizard.powershell.ps1'
#$psArgs = $env:computername
If ($packageParameters){
	Write-Debug $packageParameters
}

#Start-ChocolateyProcessAsAdmin "& `'$psFile`'" #ToDo: not here
Install-ChocolateyPowershellCommand 'Get-ChocoWizard.powershell' $psFile

#Get-ChocoWizard.powershell

