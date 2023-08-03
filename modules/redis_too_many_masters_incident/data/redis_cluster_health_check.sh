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