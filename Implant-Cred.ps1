function Implant-Cred {

<#
# All credit to the original author(s): Ryan Watson (Watson0x90)
#
# Implant-Cred.ps1 is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Implant-Cred.ps1 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Implant-Cred.ps1.  If not, see <http://www.gnu.org/licenses/>.

.SYNOPSIS
Using the same concept as the /netonly feature in the "runas" command, this will implant the credentials 
without any attempt to validate them. This allows you to seed fake credentials for a real account
onto a server or workstation. The real value comes in when alerting has been setup on the workstation or
the domain to alert on failed logons. If a Domain, Username, and
Password are not supplied, the account Administrator will be seeded with a randomly generated 16 character
password with the domain of whatever domain the computer is currently joined to.


Function: Implant-Credential
Author: Ryan Watson (watson0x90)
Required Dependencies: None
Optional Dependencies: None
Version: 1.0

.Description
This script utilizes CreateProcessWithLogonW to seed credentials as HoneyCreds onto windows workstations.

.EXAMPLE

Implant-Cred -username FakeAdministrator -password EB8{RdPpT)!75V)g -Domain Acme

Invoke-Command {Implant-Cred -username FakeAdministrator -password EB8{RdPpT)!75V)g -Domain Acme} -computername AcmeComputer1

#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$False)]
   [string]$username,
	
   [Parameter(Mandatory=$False)]
   [string]$password,

   [Parameter(Mandatory=$False)]
   [string]$domain
)


function Gen-Password {
    $randChar = [Char[]]"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890!@#$%*()=?"
    $newPass = ($randChar | Get-Random -Count 16) -join ""
    $newPass
}


$code = @'

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
public struct PROCESS_INFORMATION
{
    public IntPtr hProcess;
    public IntPtr hThread;
    public uint dwProcessId;
    public uint dwThreadId;
}

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct STARTUPINFO
 {
     public Int32 cb;
     public string lpReserved;
     public string lpDesktop;
     public string lpTitle;
     public Int32 dwX;
     public Int32 dwY;
     public Int32 dwXSize;
     public Int32 dwYSize;
     public Int32 dwXCountChars;
     public Int32 dwYCountChars;
     public Int32 dwFillAttribute;
     public Int32 dwFlags;
     public Int16 wShowWindow;
     public Int16 cbReserved2;
     public IntPtr lpReserved2;
     public IntPtr hStdInput;
     public IntPtr hStdOutput;
     public IntPtr hStdError;
 }

[DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
public static extern bool CreateProcessWithLogonW(
    String userName,
    String domain,
    String password,
    UInt32 logonFlags,
    String applicationName,
    String commandLine,
    UInt32 creationFlags,
    UInt32 environment,
    String currentDirectory,
    ref STARTUPINFO lpStartupInfo, 
    out PROCESS_INFORMATION lpProcessInformation);
'@

Add-Type -MemberDefinition $code -namespace AdvApi32 -name SRP -passThru

if(!$username){
    $username = "AD-Administrator"
}

if(!$password){
    $password = Gen-Password
}

if(!$domain){
    $domain = $env:USERDOMAIN
}

$pi = New-Object AdvApi32.SRP+PROCESS_INFORMATION
$si = New-Object AdvApi32.SRP+STARTUPINFO 

$logonFlag= 2
$command="c:\windows\system32\cmd.exe"
$createFlag = 0x08000000 #No window, no popup
$environment = $null
$cwd = "C:\"

[AdvApi32.SRP]::CreateProcessWithLogonW($username,$domain,$password,$logonFlag,$command,$command,$createFlag,$environment,$cwd,[ref] $si, [ref] $pi)

$pkill = $pi | Select-Object -ExpandProperty dwProcessId
Stop-Process $pkill

}
