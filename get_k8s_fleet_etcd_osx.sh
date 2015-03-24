#!/bin/bash

mkdir ~/k8s-bin
# download etcd and fleet clients for OS X
ETCD_RELEASE=$(cat bootstrap_k8s_cluster.sh | grep ETCD_RELEASE= | head -1 | cut -f2 -d"=")
echo "Downloading etcdctl $ETCD_RELEASE for OS X"
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/$ETCD_RELEASE/etcd-$ETCD_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-$ETCD_RELEASE-darwin-amd64/etcdctl"
mv -f etcdctl ~/k8s-bin
# clean up
rm -f etcd.zip
echo "etcdctl was copied to ~/k8s-bin"
echo " "

#
FLEET_RELEASE=$(cat bootstrap_k8s_cluster.sh | grep FLEET_RELEASE= | head -1 | cut -f2 -d"=")
echo "Downloading fleetctl $FLEET_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/$FLEET_RELEASE/fleet-$FLEET_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-$FLEET_RELEASE-darwin-amd64/fleetctl"
mv -f fleetctl ~/k8s-bin
# clean up
rm -f fleet.zip
echo "fleetctl was copied to ~/k8s-bin "
echo " "

# download kubernetes binaries for OS X
# k8s version
k8s_version=$(cat bootstrap_k8s_cluster.sh | grep k8s_version= | head -1 | cut -f2 -d"=")
echo "Downloading kubernetes $k8s_version for OS X"
curl -L -o kubernetes.tar.gz https://github.com/GoogleCloudPlatform/kubernetes/releases/download/$k8s_version/kubernetes.tar.gz
tar -xzvf kubernetes.tar.gz kubernetes/platforms/darwin/amd64
mv -f ./kubernetes/platforms/darwin/amd64/kubectl ~/k8s-bin
mv -f ./kubernetes/platforms/darwin/amd64/kubecfg ~/k8s-bin
# clean up
rm -fr ./kubernetes
rm -fr ./kubernetes.tar.gz

echo "kubecfg and kubectl were copied to ~/k8s-bin"
echo " "

