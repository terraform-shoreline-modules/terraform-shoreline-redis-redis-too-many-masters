

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