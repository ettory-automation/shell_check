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

source ../src/memory_analyzer.sh
source ../src/cpu_analyzer.sh
source ../src/storage_analyzer.sh
source ../src/network_analyzer.sh
source ../src/rhel_kernel_analyzer.sh
source ../src/deb_kernel_analyzer.sh

check_and_run() {
    local script_file="$1"
    local func_name="$2"

    if [[ -f "$script_file" ]]; then
        "$func_name"
    else
        printf "${RED}Erro: '${script_file##*/}' não encontrado ou sem permissão de leitura.${NC}\n"
        sleep 2
    fi
}

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
                1) check_and_run "$MEMORY_ANALYZER_SCRIPT" memory_check ;;
		2) check_and_run "$CPU_ANALYZER_SCRIPT" cpu_check ;;
		3) check_and_run "$STORAGE_ANALYZER_SCRIPT" storage_check ;;
		4) check_and_run "$NETWORK_ANALYZER_SCRIPT" network_check ;; 
		5) check_and_run "$RHEL_KERNEL_ANALYZER_SCRIPT" rhel_kernel_check ;;
		6) check_and_run "$DEB_KERNEL_ANALYZER_SCRIPT" deb_kernel_check ;;
                0) exit ;;
                *) printf "${RED}Opção inválida. Por favor, selecione uma opção válida.${NC}" ; sleep 2 ;;
        esac
done
