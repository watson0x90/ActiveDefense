# CanaryBadger
Collection of useful PowerShell scripts that will create HoneyCreds, HoneyDocs, and other active defense and detection scripts

Unlike Honey Badger, Canary Badger cares!! 

##ImplantCreds.ps1
This script utilizes CreateProcessWithLogonW to seed credentials as HoneyCreds onto windows workstations.

###ImplantCreds.ps1 Example Usage

Local Host: `Implant-Cred -username Administrator -password EB8{RdPpT)!75V)g -Domain Acme`

Remote Host: `Invoke-Command {Implant-Cred -username Administrator -password EB8{RdPpT)!75V)g -Domain Acme} -computername AcmeComputer1`
