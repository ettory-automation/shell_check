#!/bin/bash
set -eou pipefail

RED='\033[1;31m'
MAGENTA='\033[1;35m'
NC='\033[0m'

select_dir(){
	read -p "[*] Select directory or path: " dir_sel

	if [ ! -e "$dir_sel" ]; then
   		printf "\n${RED}Path inválido ou inexistente.${NC}\n"
    		return 1
	fi
}

get_dir_analyzis(){
	printf "\n"
	printf "${MAGENTA}=== Directory Analyzed: ["$dir_sel"] ===${NC}"
	printf "\n\n"
	df -h "$dir_sel"
}

get_mountpoint_details(){
	printf "\n${MAGENTA}=== Mountpoint's System Data ["$dir_sel"] ===\n${NC}"
	printf "\n"
	local typefs=$(findmnt -n -o FSTYPE --target "$dir_sel")
	mountpoint "$dir_sel" || true
	printf "Type: %s\n" "$typefs" # Corrigido para exibir o tipo do filesystem
}

get_dir_details(){
	printf "\n${MAGENTA}=== TOP 15: Fully Directories ["$dir_sel"] ===\n${NC}"
	printf "\n"
	du "$dir_sel" -h --max-depth=5 2>/dev/null | sort -hr | head -n 15
}

storage_check(){
	clear
	select_dir || return
	get_dir_analyzis
	get_mountpoint_details
	get_dir_details

	printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
	read -r
}
