#写出几个shell函数，分别名字是scale_tgi1 scale_tgi8 scale_tgi16 scale_tgi32
#每个函数的功能是使用kubectl对特定的service 进行scale，并且可以接受namespace参数
# 再写一个main函数，可以接受命令行参数，调用不同的scale函数，或者全部顺序调用

# kubectl scale deployment --all --replicas=1 -n benchmarking

#!/bin/bash

reset_label() {
    echo "  Begin: reset all the nodes label"
    kubectl label --overwrite nodes satg-opea-4node-0 demo-
    kubectl label --overwrite nodes satg-opea-4node-1 demo-
    kubectl label --overwrite nodes satg-opea-4node-2 demo-
    kubectl label --overwrite nodes satg-opea-4node-3 demo-
    echo "  End: reset all the nodes label"
}
reset_deploy() {
    local namespace=$1
    echo "  Begin: reset all the deploy to replica 0"
    kubectl -n "$namespace" scale deploy/tgi-gaudi-service-deploy --replicas=0
    kubectl -n "$namespace" scale deploy/tei-embedding-service-deploy --replicas=0
    kubectl -n "$namespace" scale deploy/chaqna-xeon-backend-server-deploy --replicas=0
    kubectl -n "$namespace" scale deploy/tei-reranking-service-deploy --replicas=0
    echo "  End: reset all the deploy to replica 0"
}
get_pods(){
    local namespace=$1
    
    local duration=40  # Duration in seconds
    echo -e "Wait ${duration}s to get the pod status \n\n"
    # Start sleep in the background
    sleep $duration &
    local sleep_pid=$!
    
    # Show progress bar
    show_progress $duration $sleep_pid
    
    # Wait for sleep to finish
    wait $sleep_pid
    
    echo -e "Wait time completed\n\n"

    kubectl -n "$namespace" get pods -o wide
}
scale_tgi1() {
    echo "Begin: scale_tgi1"
    echo "-----------------------"
    local namespace=$1
    reset_label
    reset_deploy "$namespace"

    echo "  label nodes satg-opea-4node-0" 
    kubectl label nodes satg-opea-4node-0 demo=chatqna

    echo "  scale the 4 service to replicas 1/1/1/1" 
    kubectl -n "$namespace" scale deploy/tgi-gaudi-service-deploy --replicas=1
    kubectl -n "$namespace" scale deploy/tei-embedding-service-deploy --replicas=1
    kubectl -n "$namespace" scale deploy/chaqna-xeon-backend-server-deploy --replicas=1
    kubectl -n "$namespace" scale deploy/tei-reranking-service-deploy --replicas=1
    #调用reset_label函数
    echo -e "End: scale_tgi1"
    echo
    echo
    get_pods "$namespace"
    
}

scale_tgi8() {
    echo "Begin: scale_tgi8"
    echo "-----------------------"
    local namespace=$1
    reset_label
    reset_deploy "$namespace"

    echo "  label nodes satg-opea-4node-0" 
    kubectl label nodes satg-opea-4node-0 demo=chatqna


    echo "  scale the 4 service to replicas 8/1/1/1" 
    kubectl -n "$namespace" scale deploy/tgi-gaudi-service-deploy --replicas=8
    kubectl -n "$namespace" scale deploy/tei-embedding-service-deploy --replicas=1
    kubectl -n "$namespace" scale deploy/chaqna-xeon-backend-server-deploy --replicas=1
    kubectl -n "$namespace" scale deploy/tei-reranking-service-deploy --replicas=1
    #调用reset_label函数
    echo -e "End: scale_tgi8"
    echo
    echo
    get_pods "$namespace"

}

scale_tgi7_1() {
    echo "Begin: scale_tgi7_1"
    echo "-----------------------"
    local namespace=$1
    reset_label
    reset_deploy "$namespace"

    echo "  label nodes satg-opea-4node-0" 
    kubectl label nodes satg-opea-4node-0 demo=chatqna


    echo "  scale the 4 service to replicas 7/1/1/1" 
    kubectl -n "$namespace" scale deploy/tgi-gaudi-service-deploy --replicas=7
    kubectl -n "$namespace" scale deploy/tei-embedding-service-deploy --replicas=1
    kubectl -n "$namespace" scale deploy/chaqna-xeon-backend-server-deploy --replicas=1
    kubectl -n "$namespace" scale deploy/tei-reranking-service-deploy --replicas=1
    #调用reset_label函数
    echo -e "End: scale_tgi7_1"
    echo
    echo
    get_pods "$namespace"

}


scale_tgi16() {
    echo "Begin: scale_tgi16"
    echo "-----------------------"
    local namespace=$1
    reset_label
    reset_deploy "$namespace"

    echo "  label nodes satg-opea-4node-0/1" 
    kubectl label nodes satg-opea-4node-0 demo=chatqna
    kubectl label nodes satg-opea-4node-1 demo=chatqna

    echo "  scale the 4 service to replicas 16/2/2/2" 
    kubectl -n "$namespace" scale deploy/tgi-gaudi-service-deploy --replicas=16
    kubectl -n "$namespace" scale deploy/tei-embedding-service-deploy --replicas=2
    kubectl -n "$namespace" scale deploy/chaqna-xeon-backend-server-deploy --replicas=2
    kubectl -n "$namespace" scale deploy/tei-reranking-service-deploy --replicas=2
    #调用reset_label函数
    echo -e "End: scale_tgi16"
    echo
    echo
    get_pods "$namespace"
}

scale_tgi15_1() {
    echo "Begin: scale_tgi15_1"
    echo "-----------------------"
    local namespace=$1
    reset_label
    reset_deploy "$namespace"

    echo "  label nodes satg-opea-4node-0/1" 
    kubectl label nodes satg-opea-4node-0 demo=chatqna
    kubectl label nodes satg-opea-4node-1 demo=chatqna

    echo "  scale the 4 service to replicas 15/2/2/1" 
    kubectl -n "$namespace" scale deploy/tgi-gaudi-service-deploy --replicas=15
    kubectl -n "$namespace" scale deploy/tei-embedding-service-deploy --replicas=2
    kubectl -n "$namespace" scale deploy/chaqna-xeon-backend-server-deploy --replicas=2
    kubectl -n "$namespace" scale deploy/tei-reranking-service-deploy --replicas=1
    #调用reset_label函数
    echo -e "End: scale_tgi15_1"
    echo
    echo
    get_pods "$namespace"
}

scale_tgi32() {
    echo "Begin: scale_tgi32"
    echo "-----------------------"
    local namespace=$1
    reset_label
    reset_deploy "$namespace"

    echo "  label nodes satg-opea-4node-0/1/2/3" 
    kubectl label nodes satg-opea-4node-0 demo=chatqna
    kubectl label nodes satg-opea-4node-1 demo=chatqna
    kubectl label nodes satg-opea-4node-2 demo=chatqna
    kubectl label nodes satg-opea-4node-3 demo=chatqna

    echo "  scale the 4 service to replicas 32/4/4/4" 
    kubectl -n "$namespace" scale deploy/tgi-gaudi-service-deploy --replicas=32
    kubectl -n "$namespace" scale deploy/tei-embedding-service-deploy --replicas=4
    kubectl -n "$namespace" scale deploy/chaqna-xeon-backend-server-deploy --replicas=4
    kubectl -n "$namespace" scale deploy/tei-reranking-service-deploy --replicas=4
    #调用reset_label函数
    echo -e "End: scale_tgi32"
    echo
    echo
    get_pods "$namespace"
}

scale_tgi31_1() {
    echo "Begin: scale_tgi31_1"
    echo "-----------------------"
    local namespace=$1
    reset_label
    reset_deploy "$namespace"

    echo "  label nodes satg-opea-4node-0/1/2/3" 
    kubectl label nodes satg-opea-4node-0 demo=chatqna
    kubectl label nodes satg-opea-4node-1 demo=chatqna
    kubectl label nodes satg-opea-4node-2 demo=chatqna
    kubectl label nodes satg-opea-4node-3 demo=chatqna

    echo "  scale the 4 service to replicas 31/4/4/1" 
    kubectl -n "$namespace" scale deploy/tgi-gaudi-service-deploy --replicas=31
    kubectl -n "$namespace" scale deploy/tei-embedding-service-deploy --replicas=4
    kubectl -n "$namespace" scale deploy/chaqna-xeon-backend-server-deploy --replicas=4
    kubectl -n "$namespace" scale deploy/tei-reranking-service-deploy --replicas=1
    #调用reset_label函数
    echo -e "End: scale_tgi31_1"
    echo
    echo
    get_pods "$namespace"
}

main() {
    local namespace=""
    local scale_type=""

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --namespace)
                namespace="$2"
                shift 2
                ;;
            --scale)
                scale_type="$2"
                shift 2
                ;;
            *)
                echo "Unknown parameter: $1"
                exit 1
                ;;
        esac
    done

    # 检查必要参数
    if [[ -z "$namespace" ]]; then
        echo "Error: Namespace is required. Use --namespace to specify."
        exit 1
    fi

    # 根据scale_type调用相应的函数
    case $scale_type in
        tgi1)
            scale_tgi1 "$namespace"
            ;;
        tgi8)
            scale_tgi8 "$namespace"
            ;;
        tgi16)
            scale_tgi16 "$namespace"
            ;;
        tgi32)
            scale_tgi32 "$namespace"
            ;;
        tgi7_1)
            scale_tgi7_1 "$namespace"
            ;;
        tgi15_1)
            scale_tgi15_1 "$namespace"
            ;;
        tgi31_1)
            scale_tgi31_1 "$namespace"
            ;;
        all)
            scale_tgi1 "$namespace"
            scale_tgi8 "$namespace"
            scale_tgi16 "$namespace"
            scale_tgi32 "$namespace"
            ;;
        *)
            echo "Error: Invalid scale type. Use tgi1, tgi8, tgi16, tgi32, or all."
            exit 1
            ;;
    esac
}

show_progress() {
    local duration=$1
    local sleep_pid=$2
    local width=50
    local fill_char="#"
    local empty_char="-"

    for ((i=0; i<=duration; i++)); do
        local percent=$((i * 100 / duration))
        local filled_width=$((i * width / duration))
        local empty_width=$((width - filled_width))
        
        # Clear the entire line and move cursor to the beginning
        printf "\r%-$((width + 20))s" " "
        printf "\r[%s%s] %3d%%" "$(printf "%${filled_width}s" | tr ' ' "$fill_char")" "$(printf "%${empty_width}s" | tr ' ' "$empty_char")" $percent
        
        if [ $i -lt $duration ]; then
            sleep 1
        fi
    done
    echo
}




main "$@"

