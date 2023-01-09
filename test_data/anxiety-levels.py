#!/usr/bin/env python3

import random
from datetime import datetime, timedelta
import sys

def scrape_data():
    '''Returns random label values and metric value, but without timestamp.
    
    Use to simulate a cardinality explosion that can be loaded into Prometheus.

    Let's pretend we have some system we're monitoring, and it is a sharded
    datastore of some kind, like Kafka. Within this system we have some type
    of client activity. Naturally, clients have very different levels of
    activity, so let's model the client with a key that is non-uniform, and
    the shard can be uniform.

    One of the goals is to ensure that a lot of the clients end up being stale.
    '''

    shard = random.randint(0, 99)
    client = random.randbytes(16).hex()[:random.randrange(1,6)]
    value = random.randint(0,1000)

    return shard, client, value

# How long (seconds) do we want to generate data for?
#
simulation_duration = timedelta(days = 7)

# How often we want our simulated data to be scraped.
# 15 seconds is too low really, but a useful default for our needs
# because that's the Prometheus default config.
#
scrape_interval = timedelta(seconds = 15)

# The documentation around 'promtool tsdb create-blocks-from-openmetrics'
# says to avoid the most recent three hours.
#
simulation_end_time = datetime.now() - timedelta(hours = 3)

# Calculate the number of scrape intervals to simulate, and the earliest scrape time
#
total_scrapes = simulation_duration // scrape_interval
simulation_start_time = simulation_end_time - timedelta(seconds = total_scrapes * scrape_interval.total_seconds())
simulation_start_time = simulation_start_time.replace(microsecond=0)

print(f"Simulation starts: {simulation_start_time}", file=sys.stderr)
print(f"Simulation ends: {simulation_end_time}", file=sys.stderr)
print(f"Scrape interval: {scrape_interval}", file=sys.stderr)
print(f"Total scrapes: {total_scrapes}", file=sys.stderr)

print("# HELP anxiety_level A gauge that should illustrate a churn problem")
print("# TYPE anxiety_level gauge")

sim_time = simulation_start_time
while sim_time < simulation_end_time:
    sim_time += scrape_interval
    timestamp = sim_time.timestamp()

    sample_count = random.randint(10,100)
    samples = {}

    for i in range(sample_count):
        shard, client, value = scrape_data()
        # We need to avoid duplicates, hence using a dictionary
        samples[shard,client] = value

    for (shard, client) in samples:
        print(f'anxiety_level{{shard="{shard}",client="{client}"}} {value} {timestamp}')

print("# EOF")
