#!/bin/bash
set -eou pipefail

RED='\033[1;31m'
MAGENTA='\033[1;35m'
NC='\033[0m'
dir_sel=""

select_dir(){
	local input_dir_sel
	local choice
 
	while true; do
		clear
		read -rp "[*] Select directory or path: " input_dir_sel
		
		if [ ! -e "$input_dir_sel" ]; then
			printf "\n${RED}Path inválido ou inexistente.${NC}\n"

			while true; do
				clear
				printf "\n${MAGENTA}Voltar ao menu? (S/n): ${NC}" 
				read -r choice

				choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

				if [[ "$choice" == "s" ]]; then
					return 1
				elif [[ "$choice" == "n" ]]; then
					break 1
				else
					printf "\n${RED}Opção inválida. Tentando novamente...\n${NC}"
					sleep 1
					break
				fi
			done
		else
			dir_sel="$input_dir_sel"
			return 0
		fi
	done
}

get_dir_analysis(){
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
	printf "Type: %s\n" "$typefs"
}

get_dir_details(){
	printf "\n${MAGENTA}=== TOP 15: Fully Directories ["$dir_sel"] ===\n${NC}"
	printf "\n"
	# Pode falhar por permissões em alguns subdiretórios, não é erro fatal
	set +e
	du "$dir_sel" -h --max-depth=5 2>/dev/null | sort -hr | head -n 15
	set -e
}

storage_check(){
	clear
	select_dir || return
	get_dir_analysis
	get_mountpoint_details
	get_dir_details

	printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
	read -r
}