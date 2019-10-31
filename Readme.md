# PSDNSDumpsterAPI
![License](https://img.shields.io/github/license/justin-p/PSDNSDumpsterAPI?style=flat-square)
[![AppveyorBuild](https://img.shields.io/appveyor/ci/justin-p/psdnsdumpsterapi?style=flat-square)](https://ci.appveyor.com/project/justin-p/psdnsdumpsterapi)
[![CodacyGrade](https://img.shields.io/codacy/grade/aeab860a75e24a3f9c40c9defc2a01d7?style=flat-square)](https://www.codacy.com/manual/justin-p/PSDNSDumpsterAPI?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=justin-p/PSDNSDumpsterAPI&amp;utm_campaign=Badge_Grade)
[![PowerShellGalleryVersion](https://img.shields.io/powershellgallery/v/PSDNSDumpsterAPI?style=flat-square)](https://www.powershellgallery.com/)
[![PowerShellGalleryDownloads](https://img.shields.io/powershellgallery/dt/PSDNSDumpsterAPI?style=flat-square)](https://www.powershellgallery.com/)

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

## Versions

0.0.1 - Initial Release

## Contribute

Please feel free to contribute by opening new issues or providing pull requests.
For the best development experience, open this project as a folder in Visual
Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code](https://code.visualstudio.com/)
* [PowerShell Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)

## Other Information

**Author:** Justin Perdok

**Website:** [PSDNSDumpsterAPI](https://github.com/justin-p/PSDNSDumpsterAPI)