Remove-DnsServerResourceRecord -ZoneName @@{domain_name}@@ -Name @@{dns_name}@@ -RRType A -ComputerName @@{dns_server}@@ -Force

Remove-DnsServerResourceRecord -ZoneName '@@{reversed_ip}@@.in-addr.arpa' -Name '@@{ip_number}@@' -RRType Ptr -ComputerName @@{dns_server}@@ -Force
