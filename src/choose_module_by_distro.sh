#!/bin/bash

RED='\033[1;31m'

choose_module(){
    if command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
        rhel_kernel_check
    elif command -v apt >/dev/null 2>&1; then
        deb_kernel_check
    else
        printf "${RED}ERROR: Distribuição não identificada${NC}"
    fi
}

run_choose(){
    choose_module
}