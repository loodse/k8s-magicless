#!/bin/bash

set -euxo pipefail

. ./func.sh

public=$( public_ip )

# arguments: kubeconfig filename (kc), user, keyfile
mkkubecfg() {
  kc="$1";shift ; user="$1";shift ; keyfile="$1";shift

  kubectl config set-cluster magicless-cluster --kubeconfig=$kc \
    --certificate-authority=ca.pem --embed-certs=true \
    --server=https://$public:6443 \

    kubectl config set-credentials $user --kubeconfig=$kc \
    --client-certificate=$keyfile.pem \
    --client-key=$keyfile-key.pem \
    --embed-certs=true

    kubectl config set-context default --kubeconfig=$kc \
      --cluster=magicless-cluster --user=$user

    kubectl config use-context default --kubeconfig=$kc
}


# worker kubeconfs:
mkkubecfg worker-0.kubeconfig system:node:worker-0 worker-0
mkkubecfg worker-1.kubeconfig system:node:worker-1 worker-1
mkkubecfg worker-2.kubeconfig system:node:worker-2 worker-2

# kube-proxy, kube-controller-manager, kube-scheduler
mkkubecfg kube-proxy.kubeconfig system:kube-proxy kube-proxy
mkkubecfg kube-controller-manager.kubeconfig system:kube-controller-manager kube-controller-manager
mkkubecfg kube-scheduler.kubeconfig system:kube-scheduler kube-scheduler

# admin
mkkubecfg admin.kubeconfig admin admin
