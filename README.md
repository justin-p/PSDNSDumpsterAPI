# PSDNSDumpsterAPI

<img src="https://raw.githubusercontent.com/justin-p/PSDNSDumpsterAPI/master/src/other/powershell-project.png" height="240">

[![License](https://img.shields.io/github/license/justin-p/PSDNSDumpsterAPI?style=flat-square)](https://github.com/justin-p/PSDNSDumpsterAPI/blob/master/LICENSE.md)
[![AppveyorBuild](https://img.shields.io/appveyor/ci/justin-p/psdnsdumpsterapi?style=flat-square)](https://ci.appveyor.com/project/justin-p/psdnsdumpsterapi)
[![CodacyGrade](https://img.shields.io/codacy/grade/aeab860a75e24a3f9c40c9defc2a01d7?style=flat-square)](https://www.codacy.com/manual/justin-p/PSDNSDumpsterAPI?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=justin-p/PSDNSDumpsterAPI&amp;utm_campaign=Badge_Grade)
[![PowerShellGalleryVersion](https://img.shields.io/powershellgallery/v/PSDNSDumpsterAPI?style=flat-square)](https://www.powershellgallery.com/packages/PSDNSDumpsterAPI/)
[![PowerShellGalleryDownloads](https://img.shields.io/powershellgallery/dt/PSDNSDumpsterAPI?style=flat-square)](https://www.powershellgallery.com/packages/PSDNSDumpsterAPI/)

## Description

(Unofficial) PowerShell API for [htttps://www.dnsdumpster.com](https://dnsdumpster.com/)

## Introduction

This module enables you to query [dnsdumpster](https://dnsdumpster.com/) from the PowerShell commandline.

## Requirements

## Installation

PowerShell Gallery (PS 5.0, Preferred method)
`install-module PSDNSDumpsterAPI`

Manual Installation
`iex (New-Object Net.WebClient).DownloadString("https://github.com/justin-p/PSDNSDumpsterAPI/raw/master/Install.ps1")`

Or clone this repository to your local machine, extract, go to the .\releases\PSDNSDumpsterAPI directory
and import the module to your session to test, but not install this module.

## Features

Return the results from dnsdumpster as a PSObject.

![GetDomains](https://github.com/justin-p/PSDNSDumpsterAPI/blob/master/_img/GetDomains.gif)

Use the magic of powershell objects to comb through the data.

![ShowDomainInfo](https://github.com/justin-p/PSDNSDumpsterAPI/blob/master/_img/ShowDomainInfo.gif)

The image and the Excel file of the domain is added to the PSObject as a base64 encoded byte array. Use `[System.Convert]::FromBase64String()` and `Set-Content` to save the data to disk.

```powershell
[System.Convert]::FromBase64String($domaininfo[0].DNSDumpsterObject.Image.ContentInBytesBase64Encoded) | Set-Content -Encoding Byte -Path "out.png"
```

![SaveDomainImg](https://github.com/justin-p/PSDNSDumpsterAPI/blob/master/_img/SaveDomainImg.gif)

Saving this in bulk is really easy !

```powershell
$DomainInfo | ForEach-Object {[System.Convert]::FromBase64String($_.DNSDumpsterObject.Excel.ContentInBytesBase64Encoded) | Set-Content -Encoding Byte -Path $($_.DomainName + ".xlsx")}
```

![BulkExcel](https://github.com/justin-p/PSDNSDumpsterAPI/blob/master/_img/BulkExcel.gif)

## Versions

0.0.1 - Initial Release.  
0.0.2 - Alpha build.  
0.0.3 - Replaced parsing with html agility pack.  
0.0.4 - Added back missing functionalities. Data is now stored in encoded with Base64 instead of a 'plain' Byte Array.  
 
## Contribute

Please feel free to contribute by opening new issues or providing pull requests.
For the best development experience, open this project as a folder in Visual
Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code](https://code.visualstudio.com/)
* [PowerShell Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)

## Other Information

**Author:** Justin Perdok

**Website:** [PSDNSDumpsterAPI](https://github.com/justin-p/PSDNSDumpsterAPI)
