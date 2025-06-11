#!/bin/bash
set -euo pipefail

GREEN='\033[1;32m'
RED='\033[1;31m'
MAGENTA='\033[1;35m'
NC='\033[0m'

get_kernel_ver_installed(){
    printf "${MAGENTA}\n=== Kernel Versions Installed ===\n${NC}"
    rpm -q kernel | sort -V | tail -n 3 || true
}

get_run_kernel(){
    printf "${MAGENTA}\n=== Running Kernel ===\n${NC}"
    printf "\n"
    uname -r
}

get_kernel_update_logs(){
    printf "${MAGENTA}\n=== Kernel Update Logs ===\n${NC}"
    printf "\n"
    if ls /var/log/dnf.rpm.log* >/dev/null 2>&1; then
        grep -i kernel /var/log/dnf.rpm.log* 2>/dev/null | tail -n 20 || echo "Nenhum log de atualização do kernel encontrado."
    elif ls /var/log/yum.log* >/dev/null 2>&1; then
        grep -i kernel /var/log/yum.log* 2>/dev/null | tail -n 20 || echo "Nenhum log de atualização do kernel encontrado."
    else
        echo "Nenhum log de atualização do kernel encontrado."
    fi

    printf "${MAGENTA}\n=== Kernel Update Journal ===\n${NC}"
    printf "\n"
    journalctl --since "30 days ago" | grep -Ei 'kernel.*(upgrade|install)' | head -n 10 || true
}

get_status_autoupdate_and_updates(){
    printf "${MAGENTA}\n=== Automatic Updates Status ===\n${NC}"
    printf "\n"
    if command -v dnf >/dev/null 2>&1; then
        if systemctl list-units --type=service | grep -q dnf-automatic.timer; then
            if systemctl is-active --quiet dnf-automatic.timer; then
                echo -e "${GREEN}dnf-automatic.timer está ativo. Atualizações automáticas habilitadas!${NC}"
            else
                echo -e "${RED}dnf-automatic.timer está desativado. Atualizações são manuais.${NC}"
                echo -e "\nÚltimos logs de atualização manual:"
                journalctl -u dnf-automatic.timer -n 5 --no-pager || true
            fi
        else
            echo -e "${RED}Desabilitado.${NC}"
            printf "\n"
            echo -e "\nÚltimos logs de atualização manual:"
            journalctl -u dnf-automatic.timer -n 5 --no-pager || true
        fi
        
        printf "${MAGENTA}\n=== Updates Disponíveis (Kernel) ===\n${NC}"
        printf "\n"
        if dnf check-update kernel 2>/dev/null | grep -q kernel; then
            dnf check-update kernel 2>/dev/null | grep -i kernel
        else
            echo -e "${GREEN}Nenhuma atualização de kernel disponível.${NC}"
        fi
        
    elif command -v yum >/dev/null 2>&1; then
        if systemctl list-units --type=service | grep -q yum-cron.service; then
            if systemctl is-active --quiet yum-cron.service; then
                echo -e "${GREEN}yum-cron.service está ativo. Atualizações automáticas habilitadas!${NC}"
            else
                echo -e "${RED}yum-cron.service está desativado. Atualizações são manuais.${NC}"
                echo -e "\nÚltimos logs de atualização manual:"
                journalctl -u yum-cron.service -n 5 --no-pager || true
            fi
        else
            echo -e "${RED}Desabilitado.${NC}"
            echo -e "\nÚltimos logs de atualização manual:"
            journalctl -u yum-cron.service -n 5 --no-pager || true
        fi
        
        printf "\n${MAGENTA}=== Updates Disponíveis (Kernel) ===\n${NC}"
        printf "\n"
        if yum check-update kernel 2>/dev/null | grep -q kernel; then
            yum check-update kernel 2>/dev/null | grep -i kernel
        else
            echo -e "${GREEN}Nenhuma atualização de kernel disponível.${NC}"
        fi
        
    else
        echo -e "\nGerenciador de pacotes DNF ou YUM não encontrado. Não foi possível checar atualizações."
    fi
}

rhel_kernel_check(){
	clear
	get_kernel_ver_installed
	get_run_kernel
	get_kernel_update_logs
	get_status_autoupdate_and_updates

	printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
	read -r
}
