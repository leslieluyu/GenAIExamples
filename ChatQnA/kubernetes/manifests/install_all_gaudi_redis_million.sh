#!/bin/bash

# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

# Array of YAML file names
yaml_files=("qna_configmap_gaudi" "redis-vector-db-million"  "tei_embedding_service"  "tgi_gaudi_service" "retriever" "embedding"  "llm" "chaqna-xeon-backend-server")
for element in ${yaml_files[@]}
do
    echo "Applying manifest from ${element}.yaml"
    kubectl apply -f "${element}.yaml"
done