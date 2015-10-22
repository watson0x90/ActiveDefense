function Create-Unattend {
<#
# All credit to the original author(s): Ryan Watson (Watson0x90)
#
# Create-Unattend.ps1 is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Create-Unattend.ps1 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Create-Unattend.ps1.  If not, see <http://www.gnu.org/licenses/>.

.SYNOPSIS
This script will create a fake unattend.xml file that can be seeded onto servers and workstations. 
The file can then be placed in typical paths where locate unattend.xml files are found. 
The script also has the ability generate a Unicode-Base64 version of the password as well as 
leaving the password in plaintext. Because we all know that Unicode-Base64 "encryption" is so secure!! ;) (I hope you get the sarcasm... awkward...)

To get the most value out of the script, monitor for failed logins for the supplied domain and local accounts.

Common unattend.xml locations:
C:\Windows\unattend.xml
C:\Windows\System32\Sysprep\unattend.xml
C:\Windows\Panther\Unattended.xml
C:\Windows\Panther\Unattend\Unattended.xml

Function: Create-Unattend
Author: Ryan Watson (watson0x90)
Required Dependencies: None
Optional Dependencies: None
Version: 1.0

.Description
This script utilizes CreateProcessWithLogonW to seed credentials as HoneyCreds onto windows workstations.

.EXAMPLE

Create-Unattend -domainUser DA-Admin -localUser Administrator -enc $true -domain Acme -out C:\Users\public\Desktop\unattend.xml

Create-Unattend -domainUser DA-Admin -domainPass AlphabetSoup123 -localUser Administrator -localPass ChickenNoodle123 -enc $true -domain Acme


#>

    [CmdletBinding()]
    Param(
       [Parameter(Mandatory=$True)]
       [string]$domainUser,

       [Parameter(Mandatory=$True)]
       [string]$localUser,
	
       [Parameter(Mandatory=$False)]
       [string]$domainPass,
       
       [Parameter(Mandatory=$False)]
       [string]$localPass,

       [Parameter(Mandatory=$True)]
       [string]$domain,

       [Parameter(Mandatory=$True)]
       [bool]$enc,

       [Parameter(Mandatory=$false)]
       [string]$out
    )

    $ErrorActionPreference = "SilentlyContinue"

    function Gen-Password {
    $randChar = [Char[]]"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890!@#$%*()=?"
    $length = Get-Random -minimum 16 -maximum 22
    $newPass = ($randChar | Get-Random -count $length) -join ""
    $newPass
    }

    function Enc-Password($password){
        $Bytes = [System.Text.Encoding]::Unicode.GetBytes($password)
        $EncodedText =[Convert]::ToBase64String($Bytes)
        $EncodedText
    }
 
    switch ($enc){
        $true {
                if(!$localPass){$localPass = Gen-Password}
                $localPass = Enc-Password($localPass)
                if(!$domainPass){$domainPass = Gen-Password}
                $domainPass = Enc-Password($domainPass)
                $plain = "false"
                }
        $false {
                if(!$localPass){$localPass = Gen-Password}
                if(!$domainlPass){$domainPass = Gen-Password}
                $plain = "true"
                }
    }

    if(!$out){ $out = 'unattend.xml'}


    $xmldata = '<?xml version="1.0" encoding="utf-8"?>
    <unattend xmlns="urn:schemas-microsoft-com:unattend">
		<settings pass="windowsPE"> 
			  <component name="Microsoft-Windows-Setup" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" processorArchitecture="x86"> 
					<WindowsDeploymentServices>
							  <Login>
								  <WillShowUI>OnError</WillShowUI>
							  <Credentials>
									 <Username>'+$domainUser+'</Username>
									 <Domain>'+$domain+'</Domain>
								    <Password>
										<Value>'+$domainPass+'</Value>
										<PlainText>'+$plain+'</PlainText>
									</Password>
								  </Credentials>
							  </Login>
						  <ImageSelection>
								  <InstallImage>
									 <ImageName>Install Image</ImageName>
								   <ImageGroup>defaultx86</ImageGroup>
									  <Filename>install.wim</Filename>
								  </InstallImage>
								<WillShowUI>OnError</WillShowUI>
								<InstallTo>
									  <DiskID>0</DiskID>
									  <PartitionID>1</PartitionID>
								</InstallTo>
						  </ImageSelection>
					</WindowsDeploymentServices>
			  </component> 
			  <component name="Microsoft-Windows-International-Core-WinPE" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" processorArchitecture="x86">
					<SetupUILanguage>
						  <WillShowUI>OnError</WillShowUI>
						  <UILanguage>en-US</UILanguage>
					</SetupUILanguage>
					<UILanguage>en-US</UILanguage>
			  </component>
		</settings>
		<settings pass="specialize">
			  <component name="Microsoft-Windows-TerminalServices-RDP-WinStationExtensions" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" processorArchitecture="x86">
					<SecurityLayer>2</SecurityLayer>
					<UserAuthentication>2</UserAuthentication>
			  </component>
			  <component name="Microsoft-Windows-TerminalServices-LocalSessionManager" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" processorArchitecture="x86">
					<fDenyTSConnections>false</fDenyTSConnections>
			  </component>
		</settings>
		<settings pass="oobeSystem">
			  <component name="Microsoft-Windows-Shell-Setup" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" processorArchitecture="x86">
					<UserAccounts>
						  <LocalAccounts>
								<LocalAccount wcm:action="add">
									<Password>
										<Value>'+$localPass+'</Value>
										<PlainText>'+$plain+'</PlainText>
									</Password>
									<Description>Local Administrator</Description>
									<DisplayName>'+$localUser+'</DisplayName>
									<Group>Administrators</Group>
									<Name>'+$localUser+'</Name>
								</LocalAccount>
						  </LocalAccounts>
					</UserAccounts>
			  </component>
		</settings>
	</unattend>
    '
    $xmldata | Out-File $out 

}
