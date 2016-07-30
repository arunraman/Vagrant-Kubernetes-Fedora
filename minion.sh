#!/bin/bash

set -x

source ./common_functions.sh


checkroot

if [ -z ${MINION_IP} ]; then
    MINION_IP=$(hostname -I | awk '{print $2}')
    echo "MINION_IP is set to: ${MINION_IP}"
fi

installcommon

dnf -y install flannel kubernetes

FLANNEL_CFG="FLANNEL_ETCD=\"http://192.168.50.130:2379\"\nFLANNEL_ETCD_KEY=\"/atomic.io/network\""
echo -e ${FLANNEL_CFG}> /etc/sysconfig/flanneld

KUBE_CFG="KUBE_LOGTOSTDERR=\"--logtostderr=true\"\nKUBE_LOG_LEVEL=\"--v=0\"\nKUBE_ALLOW_PRIV=\"--allow-privileged=false\"\nKUBE_MASTER=\"--master=http://192.168.50.130:8080\""
echo -e ${KUBE_CFG} > /etc/kubernetes/config


KUBELET_CFG="KUBELET_ADDRESS=\"--address=0.0.0.0\"\nKUBELET_PORT=\"--port=10250\"\nKUBELET_HOSTNAME=\"--hostname_override=${MINION_IP}\"\nKUBELET_API_SERVER=\"--api_servers=http://192.168.50.130:8080\"\nKUBELET_ARGS=\"\""
echo -e ${KUBELET_CFG} > /etc/kubernetes/kubelet

for SERVICES in kube-proxy kubelet docker flanneld; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES
done
