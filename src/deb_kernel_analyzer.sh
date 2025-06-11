#!/bin/bash
set -euo pipefail

GREEN='\033[1;32m'
RED='\033[1;31m'
MAGENTA='\033[1;35m'
NC='\033[0m'

get_kernel_ver_installed_deb(){
	printf "\n${MAGENTA}=== Kernel Versions Installed ===\n${NC}"
	dpkg --list | grep linux-image | awk '{print $2}' | sort -V | tail -n 3 || true
}

get_kernel_run_deb(){
	printf "\n${MAGENTA}=== Running Kernel ===\n${NC}"
	uname -r
}

get_kernel_update_logs_deb(){
	printf "\n${MAGENTA}=== Kernel Update Logs ===\n${NC}"
	awk '/Start-Date:|Commandline:|Requested-By:|linux-image/ {print}' /var/log/apt/history.log* 2>/dev/null | tail -n 22 || true
}

get_status_autoupgrades_deb(){
	printf "\n${MAGENTA}=== Unattended Upgrades Status ===\n${NC}"

	if systemctl list-units --type=service | grep -q "unattended-upgrades.service"; then
    		if systemctl is-active --quiet unattended-upgrades.service; then
        		echo -e "${GREEN}Unattended-upgrades está ativo. Atualizações serão automáticas!${NC}"
    		else
        		echo -e "${RED}Unattended-upgrades está desativado. Atualizações serão manuais!${NC}"
        		awk '/Requested-By:/ {print "Última atualização manual feita por:", $2}' /var/log/apt/history.log* 2>/dev/null | tail -n 1 || true
    		fi
	else
    		echo -e "${RED}Unattended-upgrades não encontrado no sistema.${NC}"
    		awk '/Requested-By:/ {print "Última atualização manual feita por:", $2}' /var/log/apt/history.log* 2>/dev/null | tail -n 1 || true
	fi
}

deb_kernel_check(){
	clear
	get_kernel_ver_installed_deb
	get_kernel_run_deb
	get_kernel_update_logs_deb
	get_status_autoupgrades_deb

	printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
	read -r
}
