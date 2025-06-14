#!/bin/bash
set -euo pipefail

RED='\033[1;31m'
MAGENTA='\033[1;35m'
NC='\033[0m'

sel_interface(){
	local input_inet
	local choice


	while true; do
		ip -c a | awk '
			/^[0-9]+: / {
				iface=$2; sub(":", "", iface);\
			}
			
			/link\/ether/ {
				mac=$2;
			}
			
			/inet / && !/inet6/ {
			split($2, ip, "/");
			broadcast=$4;
			printf "%-12s %-15s %-17s %-15s\n", iface, ip[1], mac, broadcast;
			}
		' | column -t -s ' ' && printf "${NC}"

		printf "\n"
		read -rp "[*] Type Network Interface: " input_inet

		local inet_is_valid=true
		local error_message=""

		set +e
		ip link show "$input_inet" > /dev/null 2>&1
		local ip_status=$?
		set -e

		if [[ $ip_status -ne 0 ]]; then
			error_message="${RED}Interface selecionada '$input_inet' não existe!${NC}\n"
			inet_is_valid=false
		else
			local operstate
			set +e
			operstate=$(cat "/sys/class/net/$input_inet/operstate" 2>/dev/null)
			set -e

			if [[ "$operstate" != "up" ]]; then
				error_message="${RED}Interface '$input_inet' existe, mas está DOWN. Status: ${operstate^^}${NC}\n"
				inet_is_valid=false
			fi
		fi

		if ! $inet_is_valid; then
			printf "\n${error_message}"

			while true; do
				printf "\n${MAGENTA}Voltar ao menu? (S/n): ${NC}" 
                read -r choice

				choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

				if [[ "$choice" == "s" ]]; then
					clear
					return 1
				elif [[ "$choice" == "n" ]]; then
					clear
					break 1
				else
					printf "\n${RED}Opção inválida. Tentando novamente...\n${NC}"
					sleep 1
					break
				fi
			done
		else
			break
		fi
	done
	
	inet=$input_inet
}

set_interval(){
	printf "\n"
	read -rp "[*] Sampling Interval (s): " interval

	if ! [[ "$interval" =~ ^[1-9][0-9]*$ ]]; then
		printf "\n${RED}Intervalo inválido. Use apenas números inteiros (excessão ao zero "0"!).${NC}\n"
		printf "\n"
		printf "${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
		read -r
		return 1
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
	printf "\n${MAGENTA}=== Delta Diff Value [inet: "$inet", Sampling Interval: "$interval"s] ===${NC}\n"
	rx_bytes=$((second_rx - first_rx))
	tx_bytes=$((second_tx - first_tx))

	rx_delta_mbps=$(echo "scale=2; ($rx_bytes * 8) / ($interval * 1000000)" | bc)
	tx_delta_mbps=$(echo "scale=2; ($tx_bytes * 8) / ($interval * 1000000)" | bc)

	printf "${RED}RX (Traffic IN)  ~> %.2f Mbps${NC}\n" "$rx_delta_mbps"
	printf "${RED}TX (Traffic OUT) ~> %.2f Mbps${NC}\n" "$tx_delta_mbps"
}

network_check(){
	clear
	sel_interface || return 1
	set_interval || return 1
	get_data_traffic
	get_delta_diff_traffic

	printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
	read -r
}
