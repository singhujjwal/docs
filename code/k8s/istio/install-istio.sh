#!/usr/bin/env bash
set -euo pipefail

echo "Starting installation of Istio in to the K8s $(kubectl cluster-info)"

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update


kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system

helm install istiod istio/istiod -n istio-system --wait

kubectl create namespace istio-ingress
kubectl label namespace istio-ingress istio-injection=enabled
helm install istio-ingress istio/gateway -n istio-ingress --wait


helm status istiod -n istio-system


# Destroying
# helm delete istio-ingress -n istio-ingress
# kubectl delete namespace istio-ingress

# helm delete istiod -n istio-system
# helm delete istio-base -n istio-system

# kubectl delete namespace istio-system
# kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete



