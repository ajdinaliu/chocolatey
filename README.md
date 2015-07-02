# Description
This is my first Chocolatey Dev folder with some helper scripts to help creating NuGet / Chocolatey Packages.

# Requirements

Useful Links:
* https://github.com/chocolatey/chocolatey/wiki/CreatePackagesQuickStart

# Requirements

## Platform:

## Packages:

* Package1
* Package2


# Notes

As of Chocolatey version
[0.9.8.24](https://github.com/chocolatey/chocolatey/blob/master/CHANGELOG.md#09824-july-3-2014)
the install directory for Chocolatey has changed from `C:\Chocolatey` to
`C:\ProgramData\Chocolatey`.


More information can be gotten from the [Chocolateywiki](https://github.com/chocolatey/chocolatey/wiki/DefaultChocolateyInstallReasoning).

# Attributes

* `node['chocolatey']['Uri']` -  Defaults to `"https://chocolatey.org/install.ps1"`.
* `node['chocolatey']['upgrade']` -  Defaults to `"true"`.

# Recipes

* chocolatey::default

# Resources

* [chocolatey](#chocolatey)

## chocolatey

### Actions

- install: Install a chocolatey package (default)
- remove: Uninstall a chocolatey package
- upgrade: Update a chocolatey package

### Attribute Parameters

- package: package to manage (default name)
- source:
- version: The version of the package to use.
- args: arguments to the installation.

# Examples

``` powershell
include_recipe 'chocolatey'

chocolatey 'DotNet4.5'

chocolatey 'PowerShell'
```

# License and Maintainer
Maintainer:: Name (<email@domain.com>)
License:: Apache 2.0

