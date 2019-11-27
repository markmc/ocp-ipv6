#!/bin/bash

## Generic configuration

# A namespace where builds will be executed
IPV6_NAMESPACE=ipv6

# Image stream where the release will be published to
IPV6_RELEASE_STREAM=release

# A kubeconfig for api.ci.openshift.org
IPV6_KUBECONFIG=ipv6-kubeconfig

# Need access to wherever the payload image - and the
# images referenced by the payload - are hosted
IPV6_PULLSECRET=ipv6-pullsecret

## Specific modules

# cluster-dns-operator build config
DNS_STREAM=cluster-dns-operator
DNS_GIT_URI=https://github.com/openshift-kni/cluster-dns-operator.git
DNS_GIT_REF=4.3-ipv6
DNS_DOCKERFILE=Dockerfile

# cluster-authentication-operator build config
CAO_STREAM=cluster-authentication-operator
CAO_GIT_URI=https://github.com/openshift-kni/cluster-authentication-operator.git
CAO_GIT_REF=4.3-ipv6
CAO_DOCKERFILE=Dockerfile

# cluster-kube-apiserver-operator build config
CKAO_STREAM=cluster-kube-apiserver-operator
CKAO_GIT_URI=https://github.com/openshift-kni/cluster-kube-apiserver-operator.git
CKAO_GIT_REF=4.3-ipv6
CKAO_DOCKERFILE=Dockerfile.rhel7

# cluster-kube-controller-manager-operator build config
CKCMO_STREAM=cluster-kube-controller-manager-operator
CKCMO_GIT_URI=https://github.com/openshift-kni/cluster-kube-controller-manager-operator.git
CKCMO_GIT_REF=4.3-ipv6
CKCMO_DOCKERFILE=Dockerfile.rhel7

# cluster-openshift-apiserver-operator build config
COAO_STREAM=cluster-openshift-apiserver-operator
COAO_GIT_URI=https://github.com/openshift-kni/cluster-openshift-apiserver-operator.git
COAO_GIT_REF=4.3-ipv6
COAO_DOCKERFILE=Dockerfile

# cluster-network-operator build config
CNO_STREAM=cluster-network-operator
CNO_GIT_URI=https://github.com/openshift-kni/cluster-network-operator.git
CNO_GIT_REF=4.3-ipv6
CNO_DOCKERFILE=Dockerfile

# hyperkube build config
HYPERKUBE_STREAM=hyperkube
HYPERKUBE_GIT_URI=https://github.com/danwinship/origin.git
HYPERKUBE_GIT_REF=ipv6
HYPERKUBE_DOCKERFILE=images/hyperkube/Dockerfile.rhel

# machine-api-operator build config
MAO_STREAM=machine-api-operator
MAO_GIT_URI=https://github.com/openshift-kni/machine-api-operator.git
MAO_GIT_REF=4.3-ipv6
MAO_DOCKERFILE=Dockerfile

# machine-config-operator build config
MCO_STREAM=machine-config-operator
MCO_GIT_URI=https://github.com/russellb/machine-config-operator.git
MCO_GIT_REF=ipv6
MCO_DOCKERFILE=Dockerfile

# machine-os-content build config
MOC_STREAM=machine-os-content

# ovn-kubernetes build config
OVNKUBE_STREAM=ovn-kubernetes
OVNKUBE_GIT_URI=https://github.com/markmc/ovn-kubernetes.git
OVNKUBE_GIT_REF=ipv6-hack
OVNKUBE_DOCKERFILE=Dockerfile
