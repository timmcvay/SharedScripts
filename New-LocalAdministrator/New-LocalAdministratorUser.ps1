function New-LocalAdministratorUser {
<#
.SYNOPSIS   
Script to create a local administrative user
    
.DESCRIPTION 
This script creates a local administrative user on the local or a remote system.
	
.PARAMETER ComputerName
This parameter can be used instead of the InputFile parameter to specify a single computer or a series of
computers using a comma-separated format
	
.PARAMETER Trustee
The user name of the account to be created. If the account already exists the script will add the existing account to the Administrators group

.NOTES   
Name       : New-LocalAdministratorUser
Author     : Jaap Brasser
Version    : 1.0.0
DateCreated: 2016-05-08
DateCreated: 2016-05-08
Blog       : http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
. .\New-LocalAdministratorUser.ps1

Description
-----------
This command dot sources the script to ensure the New-LocalAdministratorUser function is available in your current PowerShell session

.EXAMPLE   
New-LocalAdministratorUser -ComputerName Server01 -Trustee JaapBrasser -Password $SecureString

Description
-----------
Will create the JaapBrasser account as a Local Administrator on Server01

.EXAMPLE   
New-LocalAdministratorUser -ComputerName Server01 -Trustee JaapBrasser

Description
-----------
Will create the JaapBrasser account as a Local Administrator on Server01, the script will securely prompt for the password
#>
    [cmdletbinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]       $ComputerName,
        
        [Parameter(Mandatory = $true)]
        [Alias('UserName')]
        [string]       $Trustee,

        [Parameter(Mandatory = $true)]
        [SecureString] $Password
    )

    process {
        if ($PSCmdlet.ShouldProcess($Computer,"Creating user $Trustee")) {
            try {
                $ComputerObject = [adsi]"WinNT://$Computer"
                $User = $ComputerObject.Create('User',$Trustee)
                $User.SetPassword((New-Object -TypeName PSCredential 1,$Password).GetNetworkCredential().Password)
                $User
                $User.SetInfo()
            } catch {
                Write-Warning $_.Exception.Message
            }
        }

        if ($PSCmdlet.ShouldProcess($Computer,"Adding user '$Trustee' to Administrators")) {
            try {
                ([adsi]"WinNT://$Computer/Administrators,group").add($User.Path)
            } catch {
                Write-Warning $_.Exception.Message
            }
        }

        Write-Verbose -Message "Successfully created account '$Trustee' on $Computer"
    }
}