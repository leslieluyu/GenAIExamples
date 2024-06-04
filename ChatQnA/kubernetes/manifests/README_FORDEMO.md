# How-To Deploy ChatQnA Demo in Kubernetes with Gaudi

### INFO:
> [NOTE]  
> In node0, we can't use Kubectl get API endpoint. you need to copy to script to master node or a node which could access the API endpoint \
> PATH: the script will be located in node0(ng-kbz66woipi-ig-617ed-0) ~/Demo_ChatQnA/ \
> HF_TOKEN : Be sure to input your HUGGINGFACEHUB_API_TOKEN in the "qna_configmap_gaudi.yaml"

- all the enviornment set in the qna_configmap_gaudi.yaml
    
    ```
    EMBEDDING_MODEL_ID: "BAAI/bge-base-en-v1.5"
    RERANK_MODEL_ID: "BAAI/bge-reranker-base"
    LLM_MODEL_ID: "mistralai/Mixtral-8x7B-v0.1"
    TEI_EMBEDDING_ENDPOINT: http://tei-embedding-svc.default.svc.cluster.local:6006
    TEI_RERANKING_ENDPOINT: http://tei-reranking-svc.default.svc.cluster.local:8808
    TGI_LLM_ENDPOINT: http://tgi-gaudi-svc.default.svc.cluster.local:9009
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
## For Deploy 1 Node
### 1. Node Label
We use nodeSelector  to let all the pods choose correct nodes in kubernetes
> [NOTE]  
> Make sure the only one node has this label "demo=chatqna"

```
kubectl label nodes ng-kbz66woipi-ig-617ed-0 demo=chatqna
kubectl label --overwrite nodes ng-kbz66woipi-ig-617ed-1 demo-
kubectl label --overwrite nodes ng-kbz66woipi-ig-617ed-2 demo-
kubectl label --overwrite nodes ng-kbz66woipi-ig-617ed-3 demo-
```

### 2. Install

- ./install_all_gaudi.sh


### 3. Scale tgi to 8 pods in 1 node
- scale tgi —  `kubectl scale deploy tgi-gaudi-service-deploy --replicas=8`

### 4. Verify

- Be sure you could access the service IP
- user this command to check:
- chaqna_backend_svc_ip=`kubectl get svc|grep '^chaqna-xeon-backend-server-svc'|awk '{print $3}'` && echo "\$\{chaqna_backend_svc_ip\}" && curl http://${chaqna_backend_svc_ip}:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "messages": "What is the revenue of Nike in 2023?",
     "max_tokens": 128
     }'
- or you could use "http://${hostip}:30888/v1/chatqna" instead

### 5. Warmup
- Due to using the fp8 model, before get benchmark data, you need to warmup each tgi instance first
- `{ time python3 chatqna_benchmark.py --backend_url="http://${hostip}:30888/v1/chatqna" --concurrency=16;}`
- wait for the command finish.

### 6. Benchmark
- edit test_benchmark.sh, replace the BACKEND_URL with http://${hostip}:30888/v1/chatqna
- `./test_benchmark.sh`
- then you could see the result in benchmark.log


### 7. Uninstall

- ./remove_all_gaudi.sh



## For Deploy 4 Nodes
### 1. Node Label
We use nodeSelector to let all the pods choose correct nodes in kubernetes
> [NOTE]  
> Make sure all the 4 nodes has this label "demo=chatqna"

```
kubectl label nodes ng-kbz66woipi-ig-617ed-0 demo=chatqna
kubectl label nodes ng-kbz66woipi-ig-617ed-1 demo=chatqna
kubectl label nodes ng-kbz66woipi-ig-617ed-2 demo=chatqna
kubectl label nodes ng-kbz66woipi-ig-617ed-3 demo=chatqna
```

### 2. Install

- ./install_all_gaudi.sh


### 3. Scale tgi,tei,backend
- As you scale the deployment, the pods will be evenly distributed across the nodes (1, 2, 3, and 4)
- There are 8 Gaudi cards in each node. each tgi instance will consume one Gaudi card
- there will be 32 tgi-gaudi, 4 tei-embedding, 4 chaqna-xeon-backend-server distributed evenly on 4 nodes
- scale tgi —  `kubectl scale deploy tgi-gaudi-service-deploy --replicas=32`
- scale tei —  `kubectl scale deploy tei-embedding-service-deploy --replicas=4`
- scale backend — `kubectl scale deploy chaqna-xeon-backend-server-deploy --replicas=4`

### 4. Verify(same as 1 node)

- be sure you could access the service IP
- user this command to check:
- chaqna_backend_svc_ip=`kubectl get svc|grep '^chaqna-xeon-backend-server-svc'|awk '{print $3}'` && echo "\$\{chaqna_backend_svc_ip\}" && curl http://${chaqna_backend_svc_ip}:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "messages": "What is the revenue of Nike in 2023?",
     "max_tokens": 128
     }'
- or you could use "http://${hostip}:30888/v1/chatqna" instead

### 5. Warmup
- Due to using the fp8 model, before get benchmark data, you need to warmup each tgi instance first
- There will be 32 tgi we need to warmup, and because k8s service can't loadbalance exactly. so we will have to use more concurrency to warmup
- `{ time python3 chatqna_benchmark.py --backend_url="http://${hostip}:30888/v1/chatqna" --concurrency=64;}`
- wait for the command finish.

### 6. Benchmark(same as 1 node)
- edit test_benchmark.sh, replace the BACKEND_URL with http://${hostip}:30888/v1/chatqna
- `./test_benchmark.sh`
- then you could see the result in benchmark.log


### 7. Uninstall

- ./remove_all_gaudi.sh


## How to change tei-embedding from xeon to gaudi

- open the script: install_all_gaudi.sh
- just replace the “tei_embedding_service” with “tei_embedding_gaudi_service”
- if you need to config tei_embedding_gaudi, just edit the manifest file: tei_embedding_gaudi_service.yaml

## How to modify parameters of tgi
- open the tgi_gaudi_service.yaml
- add or modify the parameters
- we have already prepared a copy yaml of new params : "tgi_gaudi_service_new_params.yaml"



## How to upload images from Docker into K8s
> [NOTE] 

> Before the "opea" docker hub repository was created, you need to prepare the images by yourself.\
> You could use "load_save_images.sh" as example to batchly import images to kubernetes cluster.\
> Make sure to import the images on each node of kubernetes.

### Prerequisites:
Docker images built already:
- "opea/chatqna-ui:latest"
- "opea/chatqna:latest"
- "opea/tei-gaudi:latest"
- "opea/llm-tgi:latest"
- "opea/reranking-tei:latest"
- "opea/retriever-redis:latest"
- "opea/embedding-tei:latest"

```
# 1. Save docker images to tar
docker save -o "$tar_file" "$image"

# 2. upload images into k8s
sudo nerdctl -n k8s.io load -i "$tar_file"

```
