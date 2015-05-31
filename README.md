# Easy Deploying CoreOS with Kubernetes to GCE

With one simple script on your Mac OS X or Linux computer, you can deploy an elastic Kubernetes cluster on top of CoreOS using [Fleet](https://github.com/coreos/fleet) and [flannel](https://github.com/coreos/flannel) to GCE.
By default it is set to a master + two nodes.



### Install dependencies if you do not have them on your Mac OS/Linux:

* You need Google Cloud account and GC SDK installed
* git
* The rest like `etcdctl, fleetctl and kubectl` will be installed by `bootstrap_k8s_cluster.sh` script


### Clone this project and get it running!

* git clone https://github.com/rimusz/coreos-multi-node-k8s-gce
* cd coreos-multi-node-k8s-gce
* edit `bootstrap_k8s_cluster.sh` and set
````
ETCD_RELEASE, FLEET_RELEASE, k8s_version, project and zone
````
* then run bootstrap_k8s_cluster.sh 
* And that's it, in a few minutes you will have Kubernetes cluster with master + 2 nodes on GCE running and required OS X/Linux clients `etcdctl, fleetctl and kubectl` installed


### What exactly `bootstrap_k8s_cluster.sh` does

* Bootstraps Kubernetes cluster with `gcloud` utility to GCE

* Downloads `etcdctl, fleetctl and kubectl` and puts them to `~/k8s-bin` folder

* Deploys Kubernetes fleet units to Kubernetes cluster on GCE:
````
kube-apiserver.service          
kube-scheduler.service            
kube-register.service
kube-controller-manager.service 
kube-proxy.service 
kube-kubelet.service             
````

## Usage

When you are done the bootstraping Kubernetes cluster, from the same folder run `set_k8s_access.sh` to get shell preset to work with etcd, fleet and Kubernetes master.

Script will do the following:
````
# fleet
export FLEETCTL_TUNNEL="master_external_ip"
# etcd
ssh -f -nNT -L 4001:127.0.0.1:4001 core@master_external_ip
# kubernetes master
ssh -f -nNT -L 8080:127.0.0.1:8080 core@master_external_ip

````

List the running machines:
````
$ fleetctl list-machines
MACHINE     IP              METADATA
9c1aa398... 10.240.82.10    role=control
a6681f2c... 10.240.168.12   role=node
fe36d443... 10.240.120.228  role=node
````
List the running units:
````
$ fleetctl list-units
UNIT                            MACHINE                     ACTIVE  SUB

kube-register.service           a6681f2c.../10.240.82.10    active  running
kube-controller-manager.service a6681f2c.../10.240.82.10    active  running
kube-kubelet.service            a6681f2c.../10.240.168.12   active  running
kube-kubelet.service            fe36d443.../10.240.120.228  active  running
kube-proxy.service              a6681f2c.../10.240.168.12   active  running
kube-proxy.service              fe36d443.../10.240.120.228  active  running
kube-scheduler.service          a6681f2c.../10.240.81.10    active  running
kube-apiserver.service          a6681f2c.../10.240.82.10    active  running
````

List the registered Kubernetes Kubelets:
````
$ kubecfg list /minions
Minion identifier
----------
10.240.168.12
10.240.120.228
````
At this point you are ready to launch pods using the kubecfg command tool, or the Kubernetes API.

* When you are done with `set_k8s_access.sh` just type exit or ctrl+d and on exit script will close all ssh connections to Kubernetes master.
 
##### You can manually run `get_k8s_fleet_etcd_osx.sh` script to update OS X `etcdctl, fleetctl and kubectl` clients.

### Adding and removing machines

Adding more node machines is as easy as starting up more nodes using the `node.yml` cloud-config file. The same is true for removing machines, simply destroy them and Fleet will reschedule the units.

## If you are a Mac user, you can try my `CoreOS Vagrant Kubernetes cluster GUI App for Mac OS X`
[It will allow you very easily to provison Kubenetes Cluster on your Mac](https://github.com/rimusz/coreos-osx-gui-kubernetes-cluster)

