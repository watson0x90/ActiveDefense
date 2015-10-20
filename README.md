# CanaryBadger
Collection of useful PowerShell scripts that will create HoneyCreds, HoneyDocs, and other active defense and detection scripts

Unlike Honey Badger, Canary Badger cares!! 

##ImplantCreds.ps1
This script utilizes CreateProcessWithLogonW to seed credentials as HoneyCreds onto windows workstations. To get the most value out of seeding credentials, create a privileged account on the domain that is never used for administrative purposes. Use that username in the `-username` field and then alert on any failed login attempts. Taking this a step further create a scheduled task on a "secure" host to login to create a login event so the "Last Logon" field in Active Directory is updated periodically. 

####ImplantCreds.ps1 Example Usage

#####Local Host
`PS C:\> Implant-Cred -username FakeAdministrator -password EB8{RdPpT)!75V)g -Domain Acme`

#####Remote Host
`PS C:\> Invoke-Command {Implant-Cred -username FakeAdministrator -password EB8{RdPpT)!75V)g -Domain Acme} -computername AcmeComputer1`
