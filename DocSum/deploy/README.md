<h1 align="center" id="title">Deploy in Kubernetes Cluster</h1>

## Build UI image
```
$ cd ${RepoPath}/DocSum/ui
$ cp ../deploy/docker/Dockerfile.ui .
$ docker build . -f Dockerfile.ui -t ${docker_registry}/gen-ai-examples/ui:v1.0
```
## Prebuilt images
You could also use prebuilt images
- TGI: ghcr.io/huggingface/text-generation-inference:1.4
- Doc_Summary: intel/gen-ai-examples:document-summarize
- UI: ${docker_registry}/gen-ai-examples/ui:v1.0

## Deploy Services by Yaml files(Option 1)

> [NOTE]  
> Be sure to modify the image name in each yaml files by your own value
> Be sure to modify the ${HUGGINGFACEHUB_API_TOKEN} in doc_sum_deploy.yaml


### 1. Deploy TGI Service
```
$ cd ${RepoPath}/DocSum/deploy/kubernetes
```
Due to the lack of Habana hardware, we used TGI instead to simulate the demo.
```
# deloy tgi
$ kubectl apply -f tgi_deploy.yaml

# verify tgi
$ tgi_svc_ip=`k get svc|grep tgi-deploy|awk '{print $3}'`
$ curl ${tgi_svc_ip}:8180/generate_stream -X POST -d '{"inputs":"What is Deep Learning?","parameters":{"max_new_tokens":20}}' -H 'Content-Type: application/json' --noproxy "*"
# the output should be like:
data:{"index":1,"token":{"id":89554,"text":" Deep","logprob":-0.9719473,"special":false},"generated_text":null,"details":null}

data:{"index":2,"token":{"id":89950,"text":" Learning","logprob":-0.39028463,"special":false},"generated_text":null,"details":null}

data:{"index":3,"token":{"id":632,"text":" is","logprob":-0.56862223,"special":false},"generated_text":null,"details":null}

data:{"index":4,"token":{"id":267,"text":" a","logprob":-0.7765873,"special":false},"generated_text":null,"details":null}
```

### 2. Deploy Document Summary Service

```
# deloy doc summary backend service
$ kubectl apply -f doc_sum_deploy.yaml

# verify doc summary backend service
$ docsum_svc_ip=`k get svc|grep doc-sum|awk '{print $3}'`
$ curl ${docsum_svc_ip}:8080/v1/text_summarize     -X POST     -H 'Content-Type: application/json'     -d '{"text":"Text Embeddings Inference (TEI) is a toolkit for deploying and serving open source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE and E5."}' --noproxy "*"
# the output should be like:
data: {"ops":[{"op":"replace","path":"","value":{"id":"3ec5836a-6715-4289-961e-4a0bcb5f5937","streamed_output":[],"final_output":null,"logs":{},"name":"MapReduceDocumentsChain","type":"chain"}}]}

data: {"ops":[{"op":"add","path":"/logs/LLMChain","value":{"id":"7c4116cd-00a1-4958-919f-b43ecb3ad515","name":"LLMChain","type":"chain","tags":[],"metadata":{},"start_time":"2024-04-15T08:11:25.573+00:00","streamed_output":[],"streamed_output_str":[],"final_output":null,"end_time":null}}]}

data: {"ops":[{"op":"add","path":"/logs/HuggingFaceEndpoint","value":{"id":"a1032421-ee98-422d-83c5-6f8377640cc3","name":"HuggingFaceEndpoint","type":"llm","tags":[],"metadata":{},"start_time":"2024-04-15T08:11:25.576+00:00","streamed_output":[],"streamed_output_str":[],"final_output":null,"end_time":null}}]}

data: {"ops":[{"op":"add","path":"/logs/HuggingFaceEndpoint/streamed_output_str/-","value":"\n\n"},{"op":"add","path":"/logs/HuggingFaceEndpoint/streamed_output/-","value":"\n\n"}]}

data: {"ops":[{"op":"add","path":"/logs/HuggingFaceEndpoint/streamed_output_str/-","value":"The"},{"op":"add","path":"/logs/HuggingFaceEndpoint/streamed_output/-","value":"The"}]}

```

### 3. Deploy UI Service
```
# deloy ui service
$ kubectl apply -f ui_deploy.yaml

# verify ui service
$ ui_svc_ip=`k get svc|grep ui-deploy|awk '{print $3}'`
$ curl ${ui_svc_ip}:5176 --noproxy "*"
```

### 4. Access the UI
1. Be sure you could access the ui service by nodeport from your local pc
http://${nodeip}:30176
2. Be sure you could access the doc summary service by nodeport from your local pc
http://${nodeip}:30123



## Deploy Services by helm chart(Option 2)
> [NOTE]  
> 1. Be sure to modify the image name in each yaml files by your own value
> 2. Be sure to modify the ${HUGGINGFACEHUB_API_TOKEN} in doc_sum_deploy.yaml

```
# deploy
$ cd ${RepoPath}/DocSum/deploy/

helm install doc-sum-deploy helmchart/

# verify
# the same as kubernetes deploy
```
