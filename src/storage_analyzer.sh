#!/bin/bash
set -eou pipefail

RED='\033[1;31m'
GREEN='\033[1;32m'
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
	printf "${MAGENTA}=== Mountpoint Analyzed ===${NC}"
	printf "\n\n"
	df -h --output=source,size,used,pcent,target "$dir_sel"
}

get_mountpoint_details(){
	printf "\n${MAGENTA}=== Mountpoint Filesystem Data ===\n${NC}"
	printf "\n"
	local typefs=$(findmnt -n -o FSTYPE --target "$dir_sel" || true)
	mountpoint "$dir_sel" || true
	printf "Type: %s\n" "$typefs"
}

get_use_by_inodes(){
	printf "\n${MAGENTA}=== Inodes Consumption ===\n${NC}"
	printf "\n"

	df -h --output=source,iavail,ipcent,itotal "$dir_sel" | awk '
		NR==1 {
			printf "%-40s %-20s %-10s %-14s\n", "Diskpath", "Inode Available", "Inode(%)", "Inode(Total)"
			next
		}
		{
    			printf "%-40s %-20s %-10s %-14s\n", $1, $2, $3, $4
		}
	'
}

get_dir_details(){
	printf "\n${MAGENTA}=== TOP 15: Fully Directories ===\n${NC}"
	printf "\n"

	time bash -c '
		dir_sel="$0"
		find "$dir_sel" -xdev -type d -mindepth 0 -maxdepth 5 -print0 2>/dev/null \
			! -path "/proc*" ! -path "/sys*" ! -path "/dev*" ! -path "/run*" \
			! -path "/var/lib/docker*" ! -path "/snap*" ! -path "/tmp*" |
			xargs -0 -P "$(nproc)" -n 10 du -sh 2>/dev/null |
			sort -hr | head -n 15
	' "$dir_sel"
}

storage_check(){
	clear
	select_dir || return
	get_dir_analysis
	get_mountpoint_details
	get_use_by_inodes
	get_dir_details

	printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
	read -r
}
