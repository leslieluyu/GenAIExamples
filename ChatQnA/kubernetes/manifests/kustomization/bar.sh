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

main() {
    local duration=40  # Duration in seconds
    
    echo "Starting sleep for $duration seconds..."
    
    # Start sleep in the background
    sleep $duration &
    local sleep_pid=$!
    
    # Show progress bar
    show_progress $duration $sleep_pid
    
    # Wait for sleep to finish
    wait $sleep_pid
    
    echo -e "Sleep completed\n"
}

main
