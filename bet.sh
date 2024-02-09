board_id='33ee2635-4a1d-496b-9a19-17e4b79a47ff'
auto_cash_out="2"

get_board_result() {
    curl -s "https://eu-server-w9.ssgportal.com/JetXNode83//api/JetXapi/Board/$board_id" \
    -H 'authority: eu-server-w9.ssgportal.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.8' \
    -H 'referer: https://eu-server-w9.ssgportal.com/JetXNode83/JetXLight/Board.aspx?Token=b063bdf3-92f2-4414-890d-173d074d9fac&ReturnUrl=https%3a%2f%2fgamelaunch.everymatrix.com%2fLoader%2fLobbyResolver%2f2314%2f285%3fcasinolobbyurlencoded%3diuANNG_Ju4flgEnwneQN8lCr2uoM1Gw2&StopUrl=&Skin=&chat=' \
    -H 'sec-ch-ua: "Brave";v="119", "Chromium";v="119", "Not?A_Brand";v="24"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Linux"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-gpc: 1' \
    -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36' \
    -H 'x-requested-with: XMLHttpRequest' \
    --compressed
}

place_bet() {
    place=$(curl "https://eu-server-w9.ssgportal.com/JetXNode83//api/JetXapi/Bet/$board_id" \
        -H 'authority: eu-server-w9.ssgportal.com' \
        -H 'accept: */*' \
        -H 'accept-language: en-US,en;q=0.8' \
        -H 'content-type: application/x-www-form-urlencoded; charset=UTF-8' \
        -H 'origin: https://eu-server-w9.ssgportal.com' \
        -H "referer: https://eu-server-w9.ssgportal.com/JetXNode83/JetXLight/Board.aspx?Token=$board_id&ReturnUrl=https%3a%2f%2fgamelaunch.everymatrix.com%2fLoader%2fLobbyResolver%2f2314%2f285%3fcasinolobbyurlencoded%3diuANNG_Ju4flgEnwneQN8lCr2uoM1Gw2&StopUrl=&Skin=&chat=" \
        -H 'sec-ch-ua: "Brave";v="119", "Chromium";v="119", "Not?A_Brand";v="24"' \
        -H 'sec-ch-ua-mobile: ?0' \
        -H 'sec-ch-ua-platform: "Linux"' \
        -H 'sec-fetch-dest: empty' \
        -H 'sec-fetch-mode: cors' \
        -H 'sec-fetch-site: same-origin' \
        -H 'sec-gpc: 1' \
        -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36' \
        -H 'x-requested-with: XMLHttpRequest' \
        --data-raw "Amount=$1&Autocashout=$auto_cash_out&Position=0" \
    --compressed)
    
    echo "... Betting $1 MGA"
}

place_bet_demo() {
    echo "... Betting $1 MGA"
}

placed_bet="false"
limit=3
initial_bet_amount=500
multiplier=1
under_two_count=0
skip_next="false"
gain_count=0
loss=0
total_gain=$((gain - loss))

# Function to initialize variables
init_all() {
    placed_bet="false"
    under_two_count=0
    multiplier=1
    gain_count=0
}

# Function to clear the terminal
clear_terminal() {
    if command -v clear > /dev/null; then
        clear
    else
        printf '\033c'
    fi
}

# Main function to execute the script logic
launch() {
    board_res=$(get_board_result)
    is_finished=$(echo "$board_res" | jq -r '.SocketInfo.IsFinnished')
    value=$(echo "$board_res" | jq -r '.SocketInfo.Value')
    
    if ((multiplier > 4)); then
        init_all
        ((initial_bet_amount *= 2))
    fi
    
    if [ "$placed_bet" == "true" ] && (( $(echo "$value > 1.99" | bc -l) )); then
        clear_terminal
        ((total_gain += initial_bet_amount))
        ((gain_count++))
        
        if ((gain_count >= 2)); then
            skip_next="true"
            echo "... skipping next signal"
        fi
        
        echo "Bet : $(($initial_bet_amount * $multiplier))MGA - Gain : $(($initial_bet_amount * $multiplier * 2))MGA"
        echo "Total gain = $total_gain MGA"
        echo "... Removing bet"
        echo "... Waiting for next signal"
        initial_bet_amount=500
        init_all
        sleep 2
    fi
    
    if [ "$is_finished" == "true" ] && (( $(echo "$value > 1.99" | bc -l) )); then
        init_all
    fi
    
    if [ "$is_finished" == "true" ] && (( $(echo "$value >= 1.00 && $value <= 1.99" | bc -l) )); then
        ((under_two_count++))
        
        if [ "$placed_bet" == "true" ]; then
            if ((multiplier < 4)); then
                ((multiplier *= 2))
            else
                init_all
            fi
            
            placed_bet="false"
        fi
        
        sleep 3
    fi
    
    if [ "$is_finished" == "true" ] && ((under_two_count >= limit)) && [ "$placed_bet" == "false" ]; then
        if [ "$skip_next" == "true" ]; then
            skip_next="false"
            init_all
        else
            place_bet "$(($initial_bet_amount * $multiplier))"
            placed_bet="true"
        fi
    fi
}

# Entry point
echo "... Script now running"
echo "... Waiting for signal"

while true; do
    launch
done