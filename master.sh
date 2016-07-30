#!/bin/bash

set -x

source ./common_functions.sh


checkroot

# Make sure master ip is set to the eth1 ip
if [ -z ${MASTER_IP} ]; then
    MASTER_IP=$(hostname -I | awk '{print $2}')
    echo "MASTER_IP is set to: ${MASTER_IP}"
fi

installcommon

dnf -y install etcd kubernetes

# set etcd config
echo '
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://localhost:2379"
'  > /etc/etcd/etcd.conf

# set up kubernetes apiserver config
echo '
KUBE_API_ADDRESS="--address=0.0.0.0"
KUBE_API_PORT="--port=8080"
KUBELET_PORT="--kubelet_port=10250"
KUBE_ETCD_SERVERS="--etcd_servers=http://127.0.0.1:2379"
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"
KUBE_ADMISSION_CONTROL="--admission_control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota"
KUBE_API_ARGS=""
' > /etc/kubernetes/apiserver

# start the services
for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES
done

#flannel network configuration
etcdctl mk /atomic.io/network/config '{"Network":"172.17.0.0/16"}'
