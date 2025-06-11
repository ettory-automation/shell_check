#!/bin/bash
set -eou pipefail

RED='\033[1;31m'
MAGENTA='\033[1;35m'
NC='\033[0m'

get_memory_primary_data(){
	printf "${MAGENTA}=== Memória Total e Utilizada ===\n${NC}"
	printf "\n"
	free -h
}

top_process_consumption(){
	printf "${MAGENTA}\n=== TOP 10 Processos com Maior Consumo ===\n${NC}"
	printf "\n"
	ps -eo pid,ppid,comm,%mem --sort=-%mem | head -n 11
}

get_memory_details(){
	printf "${MAGENTA}\n=== Detalhes da memória (TOP) ===\n${NC}"
	printf "\n"
	top -b -n 1 | grep -Ei "mem|swap" | head -n 2
}

memory_check(){
	clear
	get_memory_primary_data
	top_process_consumption
	get_memory_details

	printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
	read -r
}
