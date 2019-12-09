---
external help file: PSDNSDumpsterAPI-help.xml
Module Name: PSDNSDumpsterAPI
online version: https://github.com/justin-p/PSDNSDumpsterAPI
schema: 2.0.0
---

# Invoke-PSDNSDumpsterAPI

## SYNOPSIS
Send a webrequest to DNSDumpster, parse output and return it as a PSObject.

## SYNTAX

```
Invoke-PSDNSDumpsterAPI [-Domains] <Array> [<CommonParameters>]
```

## DESCRIPTION
Send a webrequest to DNSDumpster, parse output and return it as a PSObject.

## EXAMPLES

### EXAMPLE 1
```
Invoke-PSDNSDumpsterAPI -Domains 'justin-p.me'
```

DNSDumpsterObject        DomainName
-----------------        ----------
{DNS, TXT, MX, Image...} justin-p.me

### EXAMPLE 2
```
Invoke-PSDNSDumpsterAPI -Domains 'justin-p.me','reddit.com','youtube.com'
```

DNSDumpsterObject        DomainName
-----------------        ----------
{DNS, TXT, MX, Image...} justin-p.me
{DNS, TXT, MX, Image...} reddit.com
{DNS, TXT, MX, Image...} youtube.com

### EXAMPLE 3
```
'microsoft.com','google.com' | Invoke-PSDNSDumpsterAPI
```

DNSDumpsterObject        DomainName
-----------------        ----------
{DNS, TXT, MX, Image...} microsoft.com
{DNS, TXT, MX, Image...} google.com

## PARAMETERS

### -Domains
One or more domains to get DNSDumpster results for.

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Justin Perdok, https://justin-p.me.
Project: https://github.com/justin-p/PSDNSDumpsterAPI

ContentInBytes to PNG file:
To turn the Image Byte array (ContentInBytes) to a png file run the following set of commands:
$domain = Invoke-PSDNSDumpsterAPI -Domains "justin-p.me"
$domain.DNSDumpsterOutput.Image.ContentInBytes | Set-Content -Encoding Byte -Path c:\path\to\file.png

## RELATED LINKS

[https://github.com/justin-p/PSDNSDumpsterAPI](https://github.com/justin-p/PSDNSDumpsterAPI)

