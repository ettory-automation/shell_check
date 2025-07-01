#!/bin/bash
set -euo pipefail

GREEN='\033[1;32m'
RED='\033[1;31m'
MAGENTA='\033[1;35m'
NC='\033[0m'

get_kernel_ver_installed_deb() {
	printf "\n"
    printf "\n${MAGENTA}=== Kernel Versions Installed ===\n${NC}"
    dpkg --list | grep -E 'linux-image-[0-9]+' | awk '{print $2}' | sort -V | tail -n 5 || true
}

get_kernel_run_deb() {
    printf "\n${MAGENTA}=== Running Kernel ===\n${NC}\n"
    uname -r
}

get_kernel_update_logs_deb() {
    printf "\n${MAGENTA}=== Kernel Update Logs (/var/log/apt/history.log) ===\n${NC}"
	printf "\n"
    awk '/Start-Date:|Commandline:|Requested-By:|linux-image/' /var/log/apt/history.log* 2>/dev/null | tail -n 20 || true

    printf "\n${MAGENTA}=== Kernel Update Logs (/var/log/dpkg.log) ===\n${NC}"
	printf "\n"
    zgrep -h "install linux-image" /var/log/dpkg.log* 2>/dev/null | tail -n 20 || true

    printf "\n${MAGENTA}=== Kernel Update Journal ===\n${NC}"
	printf "\n"
    journalctl --since "30 days ago" | grep -Ei 'kernel.*(upgrade|install)' | head -n 10 || true
}

get_status_autoupgrades_deb() {
    printf "\n${MAGENTA}=== Unattended Upgrades Status ===\n${NC}"

    if systemctl list-unit-files --type=service | grep -q "unattended-upgrades.service"; then
        if systemctl is-active --quiet unattended-upgrades.service; then
			printf "\n"
            printf "${GREEN}unattended-upgrades.service está ativo. Atualizações automáticas habilitadas.${NC}"
        else
			printf "\n"
            printf "${RED}unattended-upgrades.service está desativado. Atualizações são manuais.${NC}"
        fi
    else
		printf "\n"
        printf "${RED}unattended-upgrades não está instalado ou não foi encontrado como um serviço systemd.${NC}"
    fi
	printf "\n"

    printf "\n${MAGENTA}=== Últimos Logs do unattended-upgrades ===\n${NC}"
	printf "\n"
    journalctl -u unattended-upgrades.service -n 10 --no-pager || true

    printf "\n${MAGENTA}=== Última Atualização Manual ===\n${NC}"
	printf "\n"
    awk '/Requested-By:/ {print "Feita por:", $2}' /var/log/apt/history.log* 2>/dev/null | tail -n 1 || true
}

get_pending_kernel_updates_deb() {
    printf "\n${MAGENTA}=== Updates Disponíveis (Kernel) ===\n${NC}"
	printf "\n"
    apt list --upgradable 2>/dev/null | grep -i linux-image || echo -e "${GREEN}Nenhuma atualização de kernel disponível.${NC}"
}

deb_kernel_check() {
    clear
    get_kernel_ver_installed_deb
    get_kernel_run_deb
    get_kernel_update_logs_deb
    get_status_autoupgrades_deb
    get_pending_kernel_updates_deb

    printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
    read -r
}
