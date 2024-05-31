#!/bin/bash

# Define backend URL
BACKEND_URL="http://100.80.180.211:30888/v1/chatqna"

# Define concurrency levels
CONCURRENCY_LEVELS=(1 2 4 8 16 32 64 128)

# Log file
LOG_FILE="benchmark.log"

# Create or clear the log file
: > $LOG_FILE

# Iterate over each concurrency level
for CONCURRENCY in "${CONCURRENCY_LEVELS[@]}"
do
    echo "Running benchmark with concurrency level: $CONCURRENCY" | tee -a $LOG_FILE
    { time python3 chatqna_benchmark.py --backend_url="$BACKEND_URL" --concurrency=$CONCURRENCY; } 2>&1 | tee -a $LOG_FILE
done

