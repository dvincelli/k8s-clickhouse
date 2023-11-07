#!/bin/bash

KIND_VERSION="v1.27.3"
SNAPSHOTTER_VERSION="v2.0.1"
NGINX_INGRESS_VERSION="v1.8.2"

kind create cluster --name=clickhouse --config=cluster.yaml --image kindest/node:${KIND_VERSION}

kubectl config use-context kind-clickhouse

# Create dynamically provisioned hostpath storage class.
# To allow statefulsets to provision templated storage.

# Apply VolumeSnapshot CRDs
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml

# Create snapshot controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml

git submodule init
git submodule update

csi-driver-host-path/deploy/kubernetes-latest/deploy.sh

kubectl apply -f csi-storageclass.yaml

# Create NGINX ingress so we can port-forward

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-${NGINX_INGRESS_VERSION}/deploy/static/provider/cloud/deploy.yaml
