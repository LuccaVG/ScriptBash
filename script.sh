#!/bin/bash

echo -e "\033[1;34m TraceHunter-Forensic Collector \033[0m"

if [[ $EUID -ne 0 ]]; then
    echo -e "\033[1;34m Este script precisa ser executado como root. \033[0m"
    exit 1
fi

COLLECTED_DIR="collected_files"
mkdir -p "$COLLECTED_DIR"

echo -e "\033[1;35mColetando arquivos do sistema...\033[0m"

echo -e "\033[1;95mListando informações sobre discos e partições...\033[0m"

lsblk > disk_info.txt

echo -e "\033[1;95mColetando informações de rede...\033[0m"

ss > active_connections.txt

netstat -tuln > open_ports.txt

echo -e "\033[1;95mColetando lista de processos...\033[0m"

ps > process_list.txt

echo -e "\033[1;95mColetando logs do sistema...\033[0m"

COLLECTED_DIR="collected_logs"
mkdir -p $COLLECTED_DIR

cp /var/log/syslog $COLLECTED_DIR/syslog.log
cp /var/log/auth.log $COLLECTED_DIR/auth.log
cp /var/log/dmesg $COLLECTED_DIR/dmesg.log

print_magenta() {
    echo -e "\033[95m$1\033[0m"
}

print_magenta "Coletando arquivos de configuração..."
cp -r /etc /tmp/etc_backup

print_magenta "Listando o diretório raiz..."
ls / > /tmp/root_dir_list.txt

hostname=$(hostname)
datetime=$(date +"%Y%m%d_%H%M%S")
output_file="TraceHunter_${hostname}_${datetime}.tar.gz"

tar -czf $output_file -C /tmp etc_backup root_dir_list.txt

rm -rf /tmp/etc_backup /tmp/root_dir_list.txt

print_magenta "Arquivo de saída criado: $output_file"
