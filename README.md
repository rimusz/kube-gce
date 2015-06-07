# Easy Deploying CoreOS with Kubernetes to GCE

With a few simple scripts on your Mac OS X or Linux computer, you can deploy an elastic Kubernetes cluster on top of CoreOS using [fleet](https://github.com/coreos/fleet) to GCE.
By default it is set to one master + three nodes.



### Install dependencies if you do not have them on your OS X/Linux:

* You need Google Cloud account and [GC SDK](https://cloud.google.com/sdk/) installed
* git


### Clone this project and set settings:
````
git clone https://github.com/rimusz/coreos-multi-node-k8s-gce
cd coreos-multi-node-k8s-gce
````
* edit `settings` and set `project and zone`, the rest of settings you can adjust by your requirements if you need to.

### Bootstrap Kubernetes Cluster and install local clients

* To bootstrap CoreOS cluster in GCE run:

````
1-bootstrap_cluster.sh
````

* To install local etcdctl, fleetctl and kubectl clients run:

````
2-get_k8s_fleet_etcd.sh
````

* Setup Kubernetes on CoreOS cluster run:

````
3-install_k8s_fleet_units.sh
````
##### And that's it, you now have Kubernetes cluster with one master + 3 nodes running in GCE and required OS X/Linux clients `etcdctl, fleetctl and kubectl` installed on your computer.


## Usage

When you are done the bootstraping Kubernetes cluster, from the same folder run `set_k8s_access.sh` to get shell preset to work with etcd, fleet and Kubernetes master.

Script output will show the following:

````
/registry
/coreos.com

UNIT								MACHINE					ACTIVE		SUB
kube-apiserver.service			cc124065.../10.240.64.180	active	running
kube-controller-manager.service	cc124065.../10.240.64.180	active	running
kube-kubelet.service			21ed373b.../10.240.189.83	active	running
kube-kubelet.service			770ff9fd.../10.240.8.219	active	running
kube-kubelet.service			a9b4be28.../10.240.252.226	active	running
kube-proxy.service				21ed373b.../10.240.189.83	active	running
kube-proxy.service				770ff9fd.../10.240.8.219	active	running
kube-proxy.service				a9b4be28.../10.240.252.226	active	running
kube-register.service			cc124065.../10.240.64.180	active	running
kube-scheduler.service			cc124065.../10.240.64.180	active	running

NAME             LABELS                                  STATUS
10.240.189.83    kubernetes.io/hostname=10.240.189.83    Ready
10.240.252.226   kubernetes.io/hostname=10.240.252.226   Ready
10.240.8.219     kubernetes.io/hostname=10.240.8.219     Ready

Type exit when you are finished ...
````

At this point you are ready to start playing with Kubernetes using the `kubectl` command tool.

* When you are done with `set_k8s_access.sh` just type exit or ctrl+d and on exit script will close all ssh connections to remote `etcd control` and `Kubernetes master`.
 
##### You can manually run `2-get_k8s_fleet_etcd.sh` script to update OS X/Linux `etcdctl, fleetctl and kubectl` clients.

### Adding and removing machines

To add more nodes, just update `settings` `node_count` and run `1-bootstrap_k8s_cluster.sh` again. For removing nodes, simply destroy them via `GCE developer console` and `fleet` will reschedule the `kube-kubelet` and `kube-proxy` units.

### If you are OS X user:
* A standalone Kubernetes CoreOS VM App can be found here [CoreOS-Vagrant Kubernetes Solo GUI](https://github.com/rimusz/coreos-osx-gui-kubernetes-solo).
* Cluster one with Kubernetes CoreOS VM App can be found here [CoreOS-Vagrant Kubernetes Cluster GUI for OS X](https://github.com/rimusz/coreos-osx-gui-kubernetes-cluster).


