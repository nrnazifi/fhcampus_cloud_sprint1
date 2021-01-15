import os
import exoscale
import time
from flask import Flask, make_response

app = Flask(__name__)

exo_key = os.environ['EXOSCALE_KEY']
exo_secret = os.environ['EXOSCALE_SECRET']
listen_port = os.environ['LISTEN_PORT']
exo_zone = os.environ['EXOSCALE_ZONE']
exo_instance_pool = os.environ['EXOSCALE_INSTANCEPOOL_ID']
exo = exoscale.Exoscale(api_key=exo_key, api_secret=exo_secret)
zone=exo.compute.get_zone(exo_zone)
instancePool = exo.compute.get_instance_pool(zone=zone, id=exo_instance_pool)

MAX_POOL_SIZE = 20
MIN_POOL_SIZE = 1

@app.route('/up', methods=['POST','GET'])
def up():
	if instancePool is None :
		return make_response('not found', 404)
	if instancePool.size < MAX_POOL_SIZE:
		ip_size = instancePool.size + 1
		instancePool.scale(ip_size)
		
    return make_response('up', 200)

@app.route('/down', methods=['POST','GET'])
def down():
	if instancePool is None :
		return make_response('not found', 404)
	if instancePool.size > MIN_POOL_SIZE:
		ip_size = instancePool.size - 1
		instancePool.scale(ip_size)
		
    return make_response('down', 200)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=listen_port)