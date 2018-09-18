#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh \
  --apiserver-endpoint '${eks_endpoint}' \
  --b64-cluster-ca '${authority_data}' \
  '${eks_name}'
