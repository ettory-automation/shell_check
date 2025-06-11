#!/bin/bash
set -euo pipefail

RED='\033[1;31m'
MAGENTA='\033[1;35m'
NC='\033[0m'

sel_interface(){
	read -rp "Type Interface: " inet
	printf "\n"
	
	ip link show "$inet" || { 
		printf "${RED}Interface selecionada não existe!${NC}\n"
  		exit 1
	}
	
	
	state=$(cat /sys/class/net/$inet/operstate)
	if [[ "$state" != "up" ]]; then
		printf "\n"
		printf "${RED}Interface existe, mas está DOWN.${NC}\n"
		exit 1
	fi
}

set_interval(){
	printf "\n"
	read -rp "Interval (per sec): " interval

	if ! [[ "$interval" =~ ^[0-9]+$ ]]; then
    		printf "${RED}Intervalo inválido. Use apenas números inteiros.${NC}\n"
    		exit 1
	fi
}

get_data_traffic(){
	printf "\n${MAGENTA}=== First Collect [${inet}] ===${NC}\n"
	first_rx=$(ip -s link show "$inet" | awk '/RX:/{getline; print $1}')
	first_tx=$(ip -s link show "$inet" | awk '/TX:/{getline; print $1}')
	printf "${RED}RX (Traffic IN)  ~> $first_rx bytes${NC}\n"
	printf "${RED}TX (Traffic OUT) ~> $first_tx bytes${NC}\n"

	sleep "$interval"

	printf "\n${MAGENTA}=== Second Collect [${inet}] ===${NC}\n"
	second_rx=$(ip -s link show "$inet" | awk '/RX:/{getline; print $1}')
	second_tx=$(ip -s link show "$inet" | awk '/TX:/{getline; print $1}')
	printf "${RED}RX (Traffic IN)  ~> $second_rx bytes${NC}\n"
	printf "${RED}TX (Traffic OUT) ~> $second_tx bytes${NC}\n"
}

get_delta_diff_traffic(){
	printf "\n${MAGENTA}=== Delta Diff Value ===${NC}\n"
	rx_bytes=$((second_rx - first_rx))
	tx_bytes=$((second_tx - first_tx))

	rx_delta_mbps=$(echo "scale=2; ($rx_bytes * 8) / ($interval * 1000000)" | bc)
	tx_delta_mbps=$(echo "scale=2; ($tx_bytes * 8) / ($interval * 1000000)" | bc)

	printf "${RED}RX (Traffic IN)  ~> %.2f Mbps${NC}\n" "$rx_delta_mbps"
	printf "${RED}TX (Traffic OUT) ~> %.2f Mbps${NC}\n" "$tx_delta_mbps"
}

network_check(){
	clear
	sel_interface
	set_interval
	get_data_traffic
	get_delta_diff_traffic

	printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
	read -r
}
