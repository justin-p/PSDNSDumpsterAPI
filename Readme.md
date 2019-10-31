# PSDNSDumpsterAPI

## Description

(Unofficial) PowerShell API for [htttps://www.dnsdumpster.com](https://dnsdumpster.com/)

## Introduction

This module enables you to query [dnsdumpster](https://dnsdumpster.com/) from the PowerShell commandline.

## Requirements

## Installation

PowerShell Gallery (PS 5.0, Preferred method)
`install-module PSDNSDumpster`

Manual Installation
`iex (New-Object Net.WebClient).DownloadString("https://github.com/justin-p/PSDNSDumpster/raw/master/Install.ps1")`

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