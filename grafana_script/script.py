import os
import sys
import argparse
import exoscale
import time


parser=argparse.ArgumentParser()
parser.add_argument('--exo_key')
parser.add_argument('--exo_secret')
parser.add_argument('--exo_zone')
parser.add_argument('--exo_instance')
args=parser.parse_args()

exo_key = args.exo_key
exo_secret = args.exo_secret
exo_zone = args.exo_zone
exo_instance = args.exo_instance

exo = exoscale.Exoscale(api_key=exo_key, api_secret=exo_secret)

zone=exo.compute.get_zone(exo_zone)
instance = exo.compute.get_instance(zone=zone, id=exo_instance)

os.environ['instance_ip'] = instance.ipv4_address
print(instance.ipv4_address)