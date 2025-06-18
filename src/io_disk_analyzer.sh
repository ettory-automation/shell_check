#!/bin/bash
set -eou pipefail

RED='\033[1;31m'
GREEN='\033[1;32m'
MAGENTA='\033[1;35m'
NC='\033[0m'
disk_sel=""
limit=0

select_disk(){
	local input_disk_sel
	local choice
 
	while true; do
        clear
        printf "${MAGENTA}=== Discos Detectados ===${NC}\n"

        lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | awk '
        BEGIN {
            printf "\n%-12s %-10s %-8s %-20s\n", "NAME", "SIZE", "TYPE", "MOUNTPOINT";
            print "-------------------------------------------------------------";
        }
        NR > 1 {
            printf "%-12s %-10s %-8s %-20s\n", $1, $2, $3, ($4 == "" ? "-" : $4);
        }'

        printf "\n"
        printf "\n"

		read -rp "[*] Select disk: " input_disk_sel
		
		if [ ! -e /dev/"$input_disk_sel" ]; then
			printf "\n${RED}Disco inválido ou inexistente.${NC}\n"
            sleep 2

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
					sleep 2
					break
				fi
			done
		else
			disk_sel="/dev/"$input_disk_sel""
			return 0
		fi
	done
}

get_io_details(){
    printf "\n"
	printf "${MAGENTA}=== I/O per Blocks: ["$disk_sel"] ===${NC}"
	printf "\n\n"

    vmstat 1 5 | awk -v red="$RED" -v green="$GREEN" -v nc="$NC" '
        NR==2 { printf "%sin%s %sout%s\n", green, nc, red, nc }
        NR>2 { print $9 "\t" $10 }
    ' | column -t
    
    printf "\n"
}

set_interval_bits(){
	printf "\n${MAGENTA}=== Results ===${NC}\n"
 	printf "\n"
    read -rp "[*] Limite de I/O (ex: 1G, 1M, 1K ou bytes): " input

    # Expressão regex para extrair número e unidade (case insensitive)
    if [[ "$input" =~ ^([0-9]+)([KMG]?)$ ]]; then
        num=${BASH_REMATCH[1]}
        unit=${BASH_REMATCH[2],,}  # para minúsculo
    else
        printf "${RED}Valor inválido. Use formato numérico com opcional K, M ou G.${NC}\n"
	sleep 2
        printf "\n"
        return 1
    fi

    case "$unit" in
        k) limit=$(( num * 1024 )) ;;
        m) limit=$(( num * 1024 * 1024 )) ;;
        g) limit=$(( num * 1024 * 1024 * 1024 )) ;;
        "") limit=$num ;;
        *) 
            printf "${RED}Unidade inválida.${NC}\n"
            return 1
            ;;
    esac

    return 0
}

get_io_results(){
    local limit=$1
    local block_size
    block_size=$(blockdev --getbsz "$disk_sel")

    local limit_blocks=$(( limit / block_size ))
    local alert=0

    vmstat 1 5 | awk -v lim="$limit_blocks" '
        NR>2 {
            if ($9 > lim || $10 > lim) {
                exit 1
            }
        }
    '
    
    if [[ $? -eq 1 ]]; then
        alert=1
    fi

    if [[ $alert -eq 1 ]]; then
        printf "\n${RED}ALERTA: I/O alto detectado no disco!${NC}\n"
    else
        printf "\n${GREEN}I/O dentro dos parâmetros normais.${NC}\n"
    fi
}

io_disk_check(){
    select_disk || return
    get_io_details

    set_interval_bits || return 1
    get_io_results "$limit" || return
    
    printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
	read -r
}
