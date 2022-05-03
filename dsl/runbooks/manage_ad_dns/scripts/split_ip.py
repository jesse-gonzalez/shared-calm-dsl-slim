print "ip_number=", '@@{dns_ip_address}@@'.split('.')[3]
print "reversed_ip=", '.'.join(list(reversed('@@{dns_ip_address}@@'.split('.')[0:3])))
