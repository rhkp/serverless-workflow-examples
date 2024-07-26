#!/bin/bash

oc create ns openshift-mta

if [ -z "$MTA_OPERATOR_VERSION" ]; then
    MTA_OPERATOR_VERSION=v7.0.3 # Note: The resources in installmta.yaml should match this version
    echo "Using the MTA Operator version: $MTA_OPERATOR_VERSION"
fi

MTA_OPERATOR_NAME=mta-operator."$MTA_OPERATOR_VERSION"
echo "Using the MTA Operator: $MTA_OPERATOR_NAME"

# Install MTA Operator
oc apply -f installmta.yaml

oc project openshift-mta
echo "Installing: MTA operator - please be patient, takes a few minutes"
sleep 15
oc delete clusterserviceversion "$MTA_OPERATOR_NAME" -n openshift-mta
sleep 30
while true; do
    OPERATOR_INSTALLED=$(oc get clusterserviceversions/"$MTA_OPERATOR_NAME" | grep Succeeded)
    if [ -n "$OPERATOR_INSTALLED" ]; then
        echo "Installed: MTA operator "
        break
    else
        echo "Installing: MTA operator "
        sleep 30
    fi
done

# Create Tackle
oc apply -f tackle.yaml

# Ensure MTA UI Route is available
echo "Waiting for: MTA UI Route - please be patient, takes a few minutes"
sleep 30
while true; do
    ROUTE=$(oc get route | grep mta-ui)
    if [ -n "$ROUTE" ]; then
        echo "MTA Route Available "
        break
    else
        echo "Waiting for: MTA UI Route"
        sleep 30
    fi
done

oc get route
