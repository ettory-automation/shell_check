#!/bin/bash
set -eou pipefail

RED='\033[1;31m'
MAGENTA='\033[1;35m'
NC='\033[0m'

MEMORY_ANALYZER_SCRIPT='../src/memory_analyzer.sh'
CPU_ANALYZER_SCRIPT='../src/cpu_analyzer.sh'
STORAGE_ANALYZER_SCRIPT='../src/storage_analyzer.sh'
NETWORK_ANALYZER_SCRIPT='../src/network_analyzer.sh'
RHEL_KERNEL_ANALYZER_SCRIPT='../src/rhel_kernel_analyzer.sh'
DEB_KERNEL_ANALYZER_SCRIPT='../src/deb_kernel_analyzer.sh'

while true; do
        clear
        printf "%b\n" "${MAGENTA}           ###               ###     ###                ###                        ###${NC}"
        printf "%b\n" "${MAGENTA}           ##                 ##      ##                 ##                         ##${NC}"
        printf "%b\n" "${MAGENTA}   #####   ##      ####       ##      ##        ####     ##      ####     ####      ##   ##${NC}"
        printf "%b\n" "${MAGENTA}  ##       #####   ##  ##     ##      ##       ##   ##   #####   ##  ##  ##   ##    ##  ##${NC}"
        printf "%b\n" "${MAGENTA}   #####   ##  ##  ######     ##      ##       ##        ##  ##  ######  ##         ####${NC}"
        printf "%b\n" "${MAGENTA}       ##  ##  ##  ##         ##      ##       ##   ##   ##  ##  ##      ##   ##    ##  ##${NC}"
        printf "%b\n" "${MAGENTA}  ######  ###  ##   #####    ####    ####       ####    ###  ##   #####    ####     ##   ##${NC}"
        
	printf "\n"
        printf "\n"

        echo "1) Memory Check-in"
        echo "2) CPU Check-in"
        echo "3) Storage/Disk Check-in"
        echo "4) Network Interface Check-in"
        echo "5) RHEL-like: Kernel Analyzis"
        echo "6) Debian-like: Kernel Analyzis"
        echo "0) Exit"

        printf "\n"
        read -p "Select an option: " option

        case $option in
                1)
                        if [[ -f "$MEMORY_ANALYZER_SCRIPT" ]]; then
                                sudo bash "$MEMORY_ANALYZER_SCRIPT"
                        else
                                printf "${RED}Erro: 'memory_analyzer.sh' não encontrado ou sem permissão de leitura.${NC}"
                                sleep 2
                        fi
                        ;;
		2)
			if [[ -f "$CPU_ANALYZER_SCRIPT" ]]; then
				sudo bash "$CPU_ANALYZER_SCRIPT"
			else
				printf "${RED}Erro: 'cpu_analyzer.sh' não encontrado ou sem permissão de leitura.${NC}"
				sleep 2
			fi
			;;
		3)
			if [[ -f "$STORAGE_ANALYZER_SCRIPT" ]]; then
				sudo bash "$STORAGE_ANALYZER_SCRIPT"
			else
				printf "${RED}Erro: 'storage_analyzer.sh' não encontrado ou sem permissão de leitura.${NC}"
				sleep 2
			fi
			;;
		4)
			if [[ -f "$NETWORK_ANALYZER_SCRIPT" ]]; then
				sudo bash "$NETWORK_ANALYZER_SCRIPT"
			else
				printf "${RED}Erro: 'network_analyzer.sh' não encontrado ou sem permissão de leitura.${NC}"
				sleep 2
			fi
			;;
		5)
			if [[ -f "$RHEL_KERNEL_ANALYZER_SCRIPT" ]]; then
				sudo bash "$RHEL_KERNEL_ANALYZER_SCRIPT"
			else
				printf "${RED}Erro: 'rhel_kernel_analyzer.sh' não encontrado ou sem permissão de leitura.${NC}"
				sleep 2
			fi
			;;
		6)
			if [[ -f "$DEB_KERNEL_ANALYZER_SCRIPT" ]]; then
				sudo bash "$DEB_KERNEL_ANALYZER_SCRIPT"
			else
				printf "${RED}Erro: 'rhel_kernel_analyzer.sh' não encontrado ou sem permissão de leitura.${NC}"
				sleep 2
			fi
			;;
                0)
                        exit
                        ;;
                *)
                        printf "${RED}Opção inválida. Por favor, selecione uma opção válida.${NC}"
                        sleep 2
                        ;;
        esac
done
