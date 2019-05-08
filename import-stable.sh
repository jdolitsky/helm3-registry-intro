#!/bin/bash -e

# This script assumes that Helm 3 can be invoked with the "h3" command
# and that a registry is running at localhost:5000

mkdir -p stable/
cd stable/

# Add stable repo (in case it aint there)
helm repo add stable https://kubernetes-charts.storage.googleapis.com

# download all charts latest versions (stable) then save and push them to local registry
for chart in $(helm search stable | tail -n +2 | awk '{print $1}'); do
    name="$(echo $chart | cut -d '/' -f2)"
    ref="localhost:5000/stable/$name:latest"
    if [ ! -d $name ]; then
        echo "------------------------------------------------------"
        echo "+ helm fetch $chart --untar"
        helm fetch $chart --untar || echo "Issue fetching $chart"
    fi
    echo "------------------------------------------------------"
    echo "+ h3 chart save $name $chart"
    h3 chart save $name $ref || echo "Issue saving $ref"
    echo "------------------------------------------------------"
    echo "+ h3 chart push $ref"
    h3 chart push $ref || echo "Issue pushing $ref"
done

echo "------------------------------------------------------"
echo "+ h3 chart list"
h3 chart list

