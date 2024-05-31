## How-To Deploy ChatQnA Demo

### INFO:

- all the enviornment set in the qna_configmap_gaudi.yaml
    
    ```
    EMBEDDING_MODEL_ID: "BAAI/bge-base-en-v1.5"
    RERANK_MODEL_ID: "BAAI/bge-reranker-base"
    LLM_MODEL_ID: "mistralai/Mixtral-8x7B-v0.1"
    TEI_EMBEDDING_ENDPOINT: "[http://tei-embedding-svc.default.svc.cluster.local:6006](http://tei-embedding-svc.default.svc.cluster.local:6006/)"
    TEI_RERANKING_ENDPOINT: "[http://tei-reranking-svc.default.svc.cluster.local:8808](http://tei-reranking-svc.default.svc.cluster.local:8808/)"
    TGI_LLM_ENDPOINT: "[http://tgi-gaudi-svc.default.svc.cluster.local:9009](http://tgi-gaudi-svc.default.svc.cluster.local:9009/)"
    REDIS_URL: "redis://redis-vector-db.default.svc.cluster.local:6379"
    INDEX_NAME: "rag-redis"
    HUGGING_FACE_HUB_TOKEN: "HUGGINGFACEHUB_API_TOKEN"
    EMBEDDING_SERVICE_HOST_IP: embedding-svc
    RETRIEVER_SERVICE_HOST_IP: retriever-svc
    RERANK_SERVICE_HOST_IP: reranking-svc
    LLM_SERVICE_HOST_IP: llm-svc
    ```
    
- the model files locate on /mnt/models
- This version only contains deployments(no reranking)
    ```
    chaqna-xeon-backend-server-deploy   4/4     4            4           166m
    embedding-deploy                    1/1     1            1           166m
    llm-deploy                          1/1     1            1           166m
    redis-vector-db                     1/1     1            1           167m
    retriever-deploy                    1/1     1            1           166m
    tei-embedding-service-deploy        4/4     4            4           166m
    tgi-gaudi-service-deploy            29/32   32           29          112m
    ```

### Install

- ./install_all_gaudi.sh

### uninstall

- ./remove_all_gaudi.sh

### Scale

- As you scale the deployment, the pods will be evenly distributed across the nodes (1, 2, 3, and 4)
- There are 8 Gaudi cards in each node. each tgi instance will consume one Gaudi card
- there will be 32 tgi-gaudi, 4 tei-embedding, 4 chaqna-xeon-backend-server distributed evenly on 4 nodes
- scale tgi —  `kubectl scale deploy tgi-gaudi-service-deploy --replicas=32`
- scale tei —  `kubectl scale deploy tei-embedding-service-deploy --replicas=4`
- scale backend — `kubectl scale deploy chaqna-xeon-backend-server-deploy --replicas=4`

## verify

- be sure you could access the service IP
- user this command to check,
- chaqna_backend_svc_ip=`kubectl get svc|grep '^chaqna-xeon-backend-server-svc'|awk '{print $3}'` && echo ${chaqna_backend_svc_ip} && curl http://${chaqna_backend_svc_ip}:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "messages": "What is the revenue of Nike in 2023?",
     "max_tokens": 128
     }'
- or you could use http://${hostip}:30888/v1/chatqna  instead

### how to change tei-embedding from xeon to gaudi

- open the script: install_all_gaudi.sh
- just replace the “tei_embedding_service” with “tei_embedding_gaudi_service”
- if you need to config tei_embedding_gaudi, just edit the manifest file: tei_embedding_gaudi_service.yaml
