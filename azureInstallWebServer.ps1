
Configuration SampleIISInstall
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    node ('localhost')
    {
        WindowsFeature IIS
        {
            Ensure = 'Present'
            Name   = 'Web-Server'
        }
    }
}


SampleIISInstall

Start-DscConfiguration -Path .\SampleIISInstall -Wait 

#WinRm ssc on the target VM
#Create cert and store cert and thumbprint in variables
$CertName = '52.236.59.127'
$Cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname $Certname
$Thumbprint = $Cert.Thumbprint

#Open firewall port on the target VM
New-NetFirewallRule -DisplayName 'WinRm (HTTPS-In)' -Name 'WinRm (HTTPS-In)' -Profile any -LocalPort 5986 -Protocol TCP

#Set winRm to listen to Https with the cert thumbprint
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Thumbprint –Force

# Remove HTTP listener (optional)
Winrm enumerate winrm/config/listener
Get-ChildItem WSMan:\Localhost\listener | Where -Property Keys -eq 'Transport=HTTP' | Remove-Item -Recurse

$Cert | Export-Certificate -FilePath "$env:temp\DscPublicKey.cer" -Force