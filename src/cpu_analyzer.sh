#!/bin/bash
set -eo pipefail 

GREEN='\033[1;32m'
RED='\033[1;31m'
MAGENTA='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m'

get_cpu_consumption(){
    pids=$(ps -eo pid,%cpu --sort=-%cpu | awk 'NR>1 && $2 >= 70 {print $1}')

    if [[ -n "$pids" ]]; then
        printf "%b\n" "${MAGENTA}=== Processos Consumindo CPU Acima de 70% ===${NC}"
        printf "\n"
        ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | awk -v pids="$pids" 'NR==1 || index(" "pids" ", " "$1" ")'
    else
        printf "%b\n" "${MAGENTA}=== Processos Consumindo CPU Acima de 70% ===${NC}"
        printf "\n"
        printf "%b\n" "${GREEN}Nenhum processo está consumindo mais de 70% de CPU.${NC}"
    fi
}

read_cpu_stats(){
    grep '^cpu' /proc/stat
}

get_consumption_per_core(){
    printf "\n"
    printf "%b\n" "${MAGENTA}=== Consumo de CPU por Núcleo ===${NC}"
	printf "\n"
    
    printf "%-10s %-10s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s\n" \
           "timestamp" "core" "%usr" "%nice" "%sys" "%idle" "%iowait" "%irq" "%soft" "%total"
    
    echo "-------------------------------------------------------------------------------------------"

    local prev_stats=$(read_cpu_stats)

    for i in {1..4}; do
        sleep 5
		printf "\n"
        local current_stats=$(read_cpu_stats)
        local timestamp=$(date +%H:%M:%S)
        
        echo "$prev_stats"$'\n'"$current_stats" | awk -v ts="$timestamp" '
            /^cpu/ && NR > 1 {
                cpu_id = $1

                user_jif = $2
                nice_jif = $3
                system_jif = $4
                idle_jif = $5
                iowait_jif = $6
                irq_jif = $7
                softirq_jif = $8
                current_total_jif = user_jif + nice_jif + system_jif + idle_jif + iowait_jif + irq_jif + softirq_jif

                if (! (cpu_id in total_prev)) {
                    total_prev[cpu_id] = current_total_jif
                    idle_prev[cpu_id] = idle_jif
                    user_prev[cpu_id] = user_jif
                    system_prev[cpu_id] = system_jif
                    iowait_prev[cpu_id] = iowait_jif
                    irq_prev[cpu_id] = irq_jif
                    softirq_prev[cpu_id] = softirq_jif
                    nice_prev[cpu_id] = nice_jif
                } else {
                    delta_total = current_total_jif - total_prev[cpu_id]

                    if (delta_total > 0) {
                        delta_user = user_jif - user_prev[cpu_id]
                        delta_nice = nice_jif - nice_prev[cpu_id]
                        delta_system = system_jif - system_prev[cpu_id]
                        delta_idle = idle_jif - idle_prev[cpu_id]
                        delta_iowait = iowait_jif - iowait_prev[cpu_id]
                        delta_irq = irq_jif - irq_prev[cpu_id]
                        delta_softirq = softirq_jif - softirq_prev[cpu_id]

                        perc_user = (delta_user * 100.0) / delta_total
                        perc_nice = (delta_nice * 100.0) / delta_total
                        perc_system = (delta_system * 100.0) / delta_total
                        perc_idle = (delta_idle * 100.0) / delta_total
                        perc_iowait = (delta_iowait * 100.0) / delta_total
                        perc_irq = (delta_irq * 100.0) / delta_total
                        perc_softirq = (delta_softirq * 100.0) / delta_total

                        perc_total_active = 100.0 - perc_idle

                        printf "%-10s %-10s %-8.2f %-8.2f %-8.2f %-8.2f %-8.2f %-8.2f %-8.2f %-8.2f \n",
                               ts, cpu_id, perc_user, perc_nice, perc_system, perc_idle, perc_iowait, perc_irq, perc_softirq, perc_total_active
                    } else {
                        printf "%-10s %-10s %-8.2f %-8.2f %-8.2f %-8.2f %-8.2f %-8.2f %-8.2f %-8.2f \n",
                               ts, cpu_id, 0.00, 0.00, 0.00, 100.00, 0.00, 0.00, 0.00, 0.00
                    }

                    delete total_prev[cpu_id]
                    delete idle_prev[cpu_id]
                    delete user_prev[cpu_id]
                    delete system_prev[cpu_id]
                    delete iowait_prev[cpu_id]
                    delete irq_prev[cpu_id]
                    delete softirq_prev[cpu_id]
                    delete nice_prev[cpu_id]
                }
            }
        '
        prev_stats=$current_stats
    done
    printf "\n"
}

format_process_line(){
	local pid="$1"
    local user="$2"
    local comm="$3"
    printf "%-8s %-10s %s\n" "$pid" "$user" "$comm"
}

print_process_block(){
    local title="$1"
    local array_name="$2"

    if [[ -z "$array_name" ]]; then
        echo -e "${RED}Erro: Nome do array não fornecido para '$title'.${NC}" >&2
        return 1
    fi

    # Verifica se o array existe
    if ! eval "[[ \${#$array_name[@]} -gt 0 ]]" 2>/dev/null; then
        return 0
    fi

    printf "\n%b%s%b\n" "${MAGENTA}" "$title" "${NC}"

    # Imprime os valores ordenados pelas chaves (PID)
    local key
    eval "for key in \"\${!$array_name[@]}\"; do
        printf '%s\n' \"\${$array_name[\$key]}\"
    done" | sort
}

get_status_processes(){
	printf "\n"
    printf "%b\n" "${MAGENTA}=== Status dos Processos ===${NC}"

	local OLD_LC_ALL="${LC_ALL:-}"
	export LC_ALL=C

	local ps_output=$(ps -eo stat,pid,user,comm --no-headers --width 200)

	declare -A running_procs
    declare -A sleeping_procs
    declare -A disksleep_procs
    declare -A zombie_procs
    declare -A stopped_procs
    declare -A dead_procs

	declare -A tracing_procs
    declare -A high_priority_procs
    declare -A low_priority_procs
    declare -A locked_memory_procs
    declare -A session_leader_procs
    declare -A multi_threaded_procs
    declare -A foreground_group_procs

 	declare -A other_procs

	while IFS= read -r line; do
		read -r stat pid user comm <<< "$(awk '{print $1, $2, $3, substr($0, index($0,$4))}' <<< "$line")" || true

		local main_status="${stat:0:1}"
		local formatted_line=$(format_process_line "$pid" "$user" "$comm")

		case "$main_status" in
            R) running_procs[$pid]="$formatted_line" ;;
            S) sleeping_procs[$pid]="$formatted_line" ;;
            D) disksleep_procs[$pid]="$formatted_line" ;;
            Z) zombie_procs[$pid]="$formatted_line" ;;
            T) stopped_procs[$pid]="$formatted_line" ;;
            X) dead_procs[$pid]="$formatted_line" ;;
            *)
               if [[ -z "${other_procs[$main_status]+x}" ]]; then
                   other_procs[$main_status]="$formatted_line"
               else
                   other_procs[$main_status]="${other_procs[$main_status]}$'\n'$formatted_line"
               fi
               ;;
        esac

		if [[ "${#stat}" -gt 1 ]]; then
            if [[ "$stat" == *t* ]]; then tracing_procs[$pid]="$formatted_line"; fi
            if [[ "$stat" == *'<'* ]]; then high_priority_procs[$pid]="$formatted_line"; fi
            if [[ "$stat" == *N* ]]; then low_priority_procs[$pid]="$formatted_line"; fi
            if [[ "$stat" == *L* ]]; then locked_memory_procs[$pid]="$formatted_line"; fi
            if [[ "$stat" == *s* ]]; then session_leader_procs[$pid]="$formatted_line"; fi
            if [[ "$stat" == *l* ]]; then multi_threaded_procs[$pid]="$formatted_line"; fi
            if [[ "$stat" == *'+'* ]]; then foreground_group_procs[$pid]="$formatted_line"; fi
        fi

    done <<< "$ps_output"

	# Status principais
	print_process_block "Running (R):" running_procs
    print_process_block "Sleeping Interruptible (S):" sleeping_procs
    print_process_block "Disk Sleep / Uninterruptible Sleep (D):" disksleep_procs
    print_process_block "Zombie (Z):" zombie_procs
    print_process_block "Stopped (T):" stopped_procs
    print_process_block "Dead (X):" dead_procs

	# Modificadores de status
    printf "\n%b--- Modificadores de Status (Podem ser combinados) ---%b\n" "${MAGENTA}" "${NC}"
    print_process_block "Tracing Stop (t):" tracing_procs
    print_process_block "High Priority (<):" high_priority_procs
    print_process_block "Low Priority (N):" low_priority_procs
    print_process_block "Locked in Memory (L):" locked_memory_procs
    print_process_block "Session Leader (s):" session_leader_procs
    print_process_block "Multi-threaded (l):" multi_threaded_procs
    print_process_block "Foreground Process Group (+):" foreground_group_procs

    # Outros status não categorizados explicitamente (se houver)
	if [[ ${#other_procs[@]} -gt 0 ]]; then
        printf "\n%b--- Outros Status ---%b\n" "${MAGENTA}" "${NC}"
        for stat_key in "${!other_procs[@]}"; do
            printf "\nOutro Status (%s):\n" "$stat_key"
            printf "%s" "${other_procs[$stat_key]}" | sort
        done
    fi

    printf "\n"

	export LC_ALL="$OLD_LC_ALL"
}

get_load_average(){
    cores=$(nproc)
    
    read load1 load5 load15 < <(cut -d ' ' -f1-3 /proc/loadavg | sed 's/,/./g')
    
    printf "\n%b\n" "${MAGENTA}=== Load Average (1, 5, 15 min) ===${NC}"
    printf "\n"
    printf "%b\n" "CPUs disponíveis: $cores"
    printf "\n"
    LC_NUMERIC=C printf "1min:  %.2f\n5min:  %.2f\n15min: %.2f\n" "$load1" "$load5" "$load15"
    
    alert=$(awk -v l="$load1" -v c="$cores" '
    BEGIN {
        if (l > c) {
            print "critical"
        } else if (l > (c * 0.7)) {
            print "warning"
        } else {
            print "ok"
        }
    }'
    )
    
    case "$alert" in
    critical)
        printf "%b\n" "${RED}\nCRITICAL: Load de 1 minuto acima do número de núcleos!\n${NC}"
        ;;
    warning)
        printf "%b\n" "${YELLOW}\nWARNING: Load de 1 minuto está acima de 70% da capacidade total.\n${NC}"
        ;;
    ok)
        printf "\n"
        printf "%b\n" "${GREEN}OK: Load Average dentro do normal.${NC}"
        ;;
    esac
}

cpu_check(){
    clear
    get_cpu_consumption
    get_consumption_per_core
	get_status_processes
    get_load_average

    printf "\n${MAGENTA}Pressione ENTER para retornar ao menu...${NC}"
    read -r
}
