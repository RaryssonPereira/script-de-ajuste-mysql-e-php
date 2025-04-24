#!/bin/bash

# Script: ajustemysql.sh
# Descricao: Ajusta automaticamente parametros de performance do MySQL com base na memoria RAM disponivel.
# Autor: ServerDo.in (versao aprimorada)
# Data: $(date +"%Y-%m-%d")

CONFIG_FILE="/etc/mysql/conf.d/mysql.cnf"
DATE=$(date "+%Y-%m-%d %H:%M")
BACKUP_FILE="$CONFIG_FILE.bkp_$(date +%Y%m%d_%H%M)"

# Verifica se o arquivo de configuracao existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Arquivo de configuracao $CONFIG_FILE nao encontrado. Criando novo arquivo."
    touch "$CONFIG_FILE"
fi

# Realiza backup
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Backup criado em $BACKUP_FILE"

# Obtem memoria total
get_memory_info() {
    TOTAL_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_MEM_MB=$((TOTAL_MEM_KB / 1024))
    echo "Memoria detectada: ${TOTAL_MEM_MB}MB"
}

# Aplica alteracoes no arquivo
adjust_variable() {
    local var_name="$1"
    local new_value="$2"

    # Se ja existe, comenta a linha anterior com formato seguro
    if grep -qE "^$var_name" "$CONFIG_FILE"; then
        old_value=$(grep -E "^$var_name" "$CONFIG_FILE" | cut -d= -f2 | xargs)
        sed -i "s/^$var_name.*/# $var_name (ajustado pelo script em $DATE): antigo valor era $old_value/" "$CONFIG_FILE"
    fi

    echo "$var_name=$new_value" >> "$CONFIG_FILE"
    echo "Ajustado: $var_name=$new_value"
}

# Define parametros com base na memoria
get_memory_info

if [ "$TOTAL_MEM_MB" -le 4096 ]; then
    PARAMS=(
        "innodb_buffer_pool_size=2G"
        "innodb_buffer_pool_instances=1"
        "tmp_table_size=128M"
        "max_heap_table_size=128M"
        "join_buffer_size=128M"
        "sort_buffer_size=128M"
        "key_buffer_size=32M"
        "read_rnd_buffer_size=64M"
        "query_cache_limit=64M"
        "query_cache_size=256M"
    )
elif [ "$TOTAL_MEM_MB" -le 8192 ]; then
    PARAMS=(
        "innodb_buffer_pool_size=4G"
        "innodb_buffer_pool_instances=2"
        "tmp_table_size=256M"
        "max_heap_table_size=256M"
        "join_buffer_size=256M"
        "sort_buffer_size=256M"
        "key_buffer_size=64M"
        "read_rnd_buffer_size=128M"
        "query_cache_limit=128M"
        "query_cache_size=512M"
    )
else
    PARAMS=(
        "innodb_buffer_pool_size=8G"
        "innodb_buffer_pool_instances=4"
        "tmp_table_size=512M"
        "max_heap_table_size=512M"
        "join_buffer_size=512M"
        "sort_buffer_size=512M"
        "key_buffer_size=128M"
        "read_rnd_buffer_size=256M"
        "query_cache_limit=256M"
        "query_cache_size=1024M"
    )
fi

# Aplica todas as variaveis
for param in "${PARAMS[@]}"; do
    var_name=$(echo "$param" | cut -d= -f1)
    new_value=$(echo "$param" | cut -d= -f2)
    adjust_variable "$var_name" "$new_value"
    sleep 0.1
done

# Reinicio opcional
read -rp $'\nDeseja reiniciar o MySQL para aplicar as alteracoes? [s/N]: ' resposta
if [[ "$resposta" =~ ^[sS](im)?$ ]]; then
    systemctl restart mysql && echo "✅ MySQL reiniciado com sucesso."
else
    echo "⚠️  Lembre-se de reiniciar o MySQL manualmente para aplicar as configuracoes."
fi
