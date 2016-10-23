Install-Module xPSDesiredStateConfiguration
New-SelfSignedCertificate -CertStoreLocation 'CERT:\LocalMachine\MY' -DnsName "DSCPullCert" -OutVariable DSCCert
Install-Module xPSDesiredStateConfiguration
New-SelfSignedCertificate -CertStoreLocation 'CERT:\LocalMachine\MY' -DnsName "DSCPullCert" -OutVariable DSCCert