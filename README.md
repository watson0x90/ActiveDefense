# CanaryBadger
Useful PowerShell scripts that will create HoneyCreds, HoneyDocs, and other active defense and detection scripts

Unlike Honey Badger, Canary Badger cares!! 

##Implant Creds
This script utilizes CreateProcessWithLogonW to seed credentials as HoneyCreds onto windows workstations.

###Example Usage

Local Host: `Implant-Cred -username Administrator -password EB8{RdPpT)!75V)g -Domain Acme`

Remote Host: `Invoke-Command {Implant-Cred -username Administrator -password EB8{RdPpT)!75V)g -Domain Acme} -computername AcmeComputer1`
