
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Redis too many masters incident
---

The Redis too many masters incident occurs when there are too many master nodes in a Redis cluster, leading to connection issues and potential data loss. This can happen due to misconfiguration, network issues, or other factors, and requires immediate attention to prevent further damage.

### Parameters
```shell
# Environment Variables

export REDIS_CLUSTER_HOST="PLACEHOLDER"

export REDIS_CLUSTER_PORT="PLACEHOLDER"

export REDIS_PORT="PLACEHOLDER"

export REDIS_CLUSTER_NAME="PLACEHOLDER"

export MAX_NUMBER_OF_MASTERS="PLACEHOLDER"

export REDIS_CLUSTER_IP="PLACEHOLDER"
```

## Debug

### Check if Redis is running on the affected instance
```shell
systemctl status redis-server.service
```

### Check the Redis configuration file
```shell
cat /etc/redis/redis.conf
```

### Check the number of master nodes in the Redis cluster
```shell
redis-cli -h ${REDIS_CLUSTER_HOST} -p ${REDIS_CLUSTER_PORT} cluster nodes | grep "master" | wc -l
```

### Check the status of the Redis cluster
```shell
redis-cli -h ${REDIS_CLUSTER_HOST} -p ${REDIS_CLUSTER_PORT} cluster info
```

### Check the number of connections to the Redis cluster
```shell
redis-cli -h ${REDIS_CLUSTER_HOST} -p ${REDIS_CLUSTER_PORT} info clients | grep "connected_clients"
```

### Check the Redis logs for any errors or warnings
```shell
tail -f /var/log/redis/redis-server.log
```

### Restart the Redis service
```shell
systemctl restart redis-server.service
```

### Network connectivity issues between Redis nodes, causing nodes to become isolated and designate themselves as master nodes.
```shell
bash

#!/bin/bash



# Define variables

REDIS_CLUSTER=${REDIS_CLUSTER_IP}

REDIS_PORT=${REDIS_PORT}



# Check network connectivity between Redis nodes

for i in {1..3}; do

  redis-cli -h $REDIS_CLUSTER -p $REDIS_PORT ping

  if [ "$?" -ne "0" ]; then

    echo "Error: Redis node $REDIS_CLUSTER is not responding"

    exit 1

  fi

done



# Check Redis cluster status

redis-cli -h $REDIS_CLUSTER -p $REDIS_PORT cluster info

if [ "$?" -ne "0" ]; then

  echo "Error: Redis cluster is not responding"

  exit 1

fi



# Check Redis cluster nodes

redis-cli -h $REDIS_CLUSTER -p $REDIS_PORT cluster nodes

if [ "$?" -ne "0" ]; then

  echo "Error: Redis cluster nodes are not responding"

  exit 1

fi



# Check Redis cluster configuration

redis-cli -h $REDIS_CLUSTER -p $REDIS_PORT config get cluster-enabled

if [ "$?" -ne "0" ]; then

  echo "Error: Redis cluster configuration is invalid"

  exit 1

fi



# Check Redis cluster node roles

redis-cli -h $REDIS_CLUSTER -p $REDIS_PORT cluster nodes | awk '{print $3}' | sort | uniq -c

if [ "$?" -ne "0" ]; then

  echo "Error: Redis cluster node roles are not consistent"

  exit 1

fi



echo "Success: Redis cluster is healthy"

exit 0


```

## Repair

### Reduce the number of master nodes in the Redis cluster to the recommended maximum, which varies based on the size and complexity of the system.
```shell


#!/bin/bash



# Set variables

REDIS_CLUSTER=${REDIS_CLUSTER_NAME}

MAX_MASTERS=${MAX_NUMBER_OF_MASTERS}



# Get current number of master nodes

current_masters=$(redis-cli -c -h $REDIS_CLUSTER cluster info | grep "masters" | awk -F: '{print $2}')



# Check if current number of masters is greater than the maximum recommended

if [ $current_masters -gt $MAX_MASTERS ]; then

    # Get a list of all master nodes

    master_nodes=$(redis-cli -c -h $REDIS_CLUSTER cluster nodes | grep "master" | awk '{print $2}')



    # Select the first $MAX_MASTERS nodes as new master nodes

    new_masters=$(echo "$master_nodes" | head -n $MAX_MASTERS)



    # Set new master nodes for the Redis cluster

    for node in $new_masters; do

        redis-cli -c -h $REDIS_CLUSTER cluster replicate $node

    done



    # Failover to the new master nodes

    redis-cli -c -h $REDIS_CLUSTER cluster failover force



    echo "Successfully reduced the number of master nodes to $MAX_MASTERS."

else

    echo "The current number of master nodes is already within the recommended limit."

fi




```