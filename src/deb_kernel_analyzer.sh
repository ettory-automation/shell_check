#!/bin/bash
set -euo pipefail

GREEN='\033[1;32m'
RED='\033[1;31m'
MAGENTA='\033[1;35m'
NC='\033[0m'
clear

function get_kernel_ver_installed(){
	echo "=== Kernel Versions Installed ==="
	dpkg --list | grep linux-image | awk '{print $2}' | sort -V | tail -n 3 || true
}

function get_kernel_run(){
	echo -e "\n=== Running Kernel ==="
	uname -r
}

function get_kernel_update_logs(){
	echo -e "\n=== Kernel Update Logs ==="
	awk '/Start-Date:|Commandline:|Requested-By:|linux-image/ {print}' /var/log/apt/history.log* 2>/dev/null | tail -n 22 || true
}

function get_status_autoupgrades(){
	echo -e "\n=== Unattended Upgrades Status ==="

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

get_kernel_ver_installed
get_kernel_run
get_kernel_update_logs
get_status_autoupgrades

printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
read -r
