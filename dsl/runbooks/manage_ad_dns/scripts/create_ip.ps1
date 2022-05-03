Add-DnsServerResourceRecordA -Name @@{dns_name}@@ -ZoneName @@{domain_name}@@ -IPv4Address @@{dns_ip_address}@@ -ComputerName @@{dns_server}@@

Add-DnsServerResourceRecordPtr -Name '@@{ip_number}@@' -ZoneName '@@{reversed_ip}@@.in-addr.arpa' -PtrDomainName '@@{dns_name}@@.@@{domain_name}@@' -ComputerName @@{dns_server}@@
