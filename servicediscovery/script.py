import os
import exoscale
import time

exo_key = os.environ['EXOSCALE_KEY']
exo_secret = os.environ['EXOSCALE_SECRET']
exo_zone = os.environ['EXOSCALE_ZONE']
exo_instance_pool = os.environ['EXOSCALE_INSTANCEPOOL_ID']
target_port = os.environ['TARGET_PORT']

exo = exoscale.Exoscale(api_key=exo_key, api_secret=exo_secret)

zone=exo.compute.get_zone(exo_zone)
instancepool = exo.compute.get_instance_pool(zone=zone, id=exo_instance_pool)

flag = 1
while flag == 1:
	json = '['
	for instance in instancepool.instances:
		ip = instance.ipv4_address
		json += '{"targets": ["' + str(ip) + ':' + target_port + '"]},'
	json = json[:-1] + ']'

	f = open("/srv/service-discovery/config.json", "w")
	f.write(json)
	f.flush()
	os.fsync(f.fileno())
	f.close()

	time.sleep(30)
