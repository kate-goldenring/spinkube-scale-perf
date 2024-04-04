#! /bin/bash

set -euox
DEPLOYMENT=${1:-"spin-in-container"}
REPLICAS=${2:-"50"}

get_current_time() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OS
        now=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)')
    else
        # Linux
        now=$(date +%s%N)
        now=$((now / 1000000))
    fi
    echo $now
}

start_time=$(get_current_time)
kubectl scale --replicas=$REPLICAS deployment $DEPLOYMENT -n default
kubectl wait --for=condition=Ready pod -l app=$DEPLOYMENT --timeout=60s 
end_time=$(get_current_time)
duration=$((end_time - start_time))
echo "Scaling deployment $DEPLOYMENT to $REPLICAS replicas took $duration ms." >> scale.log


