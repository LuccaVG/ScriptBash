#!/bin/bash

echo -e "\033[1;34m TraceHunter-Forensic Collector \033[0m"

if [[ $EUID -ne 0 ]]; then
    echo -e "\033[1;31m Este script precisa ser executado como root. \033[0m"
    exit 1
fi

echo -e "\033[1;35mColetando arquivos do sistema...\033[0m"

echo -e "\033[1;35mListando informações sobre discos e partições...\033[0m"

lsblk > collected_logs/disk_info.txt

echo -e "\033[1;35mColetando informações de rede...\033[0m"

ss > collected_logs/active_connections.txt

netstat -tuln > collected_logs/open_ports.txt

echo -e "\033[1;35mColetando lista de processos...\033[0m"

ps > collected_logs/process_list.txt

echo -e "\033[1;35mColetando logs do sistema...\033[0m"

COLLECTED_DIR="collected_logs"
mkdir -p $COLLECTED_DIR

cp /var/log/syslog $COLLECTED_DIR/syslog.log
cp /var/log/auth.log $COLLECTED_DIR/auth.log
cp /var/log/dmesg $COLLECTED_DIR/dmesg.log
cp disk_info.txt $COLLECTED_DIR/disk_info.log
cp active_connections.txt $COLLECTED_DIR/active_connections.log
cp open_ports.txt $COLLECTED_DIR/open_ports.log
cp process_list.txt $COLLECTED_DIR/process_list.log

echo -e "\033[1;35mColetando arquivos de configuração...\033[0m"
cp -r /etc $COLLECTED_DIR/etc_backup

echo -e "\033[1;35mListando o diretório raiz...\033[0m"
ls / > $COLLECTED_DIR/root_dir_list.txt

hostname=$(hostname)
datetime=$(date +"%Y%m%d_%H%M%S")
output_file="TraceHunter_${hostname}_${datetime}.tar.gz"

tar -czf $output_file -C $COLLECTED_DIR etc_backup root_dir_list.txt

rm -rf $COLLECTED_DIR/etc_backup $COLLECTED_DIR/root_dir_list.txt

echo -e "\033[1;35mArquivo de saída criado: $output_file\033[0m"
