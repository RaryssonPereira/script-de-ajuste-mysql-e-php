#!/bin/bash

# Caminhos
MYSQL_CONF="/etc/mysql/conf.d/mysql.cnf"
PHP_BASE_DIR="/etc/php"

# Funcoes de configuracao
ajustar_mysql() {
    echo "\n👉 Aplicando configuracoes para MySQL ($1)..."
    # Backup inteligente do mysql.cnf
    if [ -f "$MYSQL_CONF" ]; then
        cp "$MYSQL_CONF" "$MYSQL_CONF"_19-04-2025
    else
        touch "$MYSQL_CONF"
    fi

    cat > "$MYSQL_CONF" <<EOF
[mysqld]
innodb_file_per_table = 1
sql_mode = ""

max_connections = $2
wait_timeout = 60
interactive_timeout = 60

key_buffer_size = $3
tmp_table_size = $4
max_heap_table_size = $4
sort_buffer_size = $5
join_buffer_size = $5
read_rnd_buffer_size = $6

table_open_cache = $7
thread_cache_size = $8

max_allowed_packet = 64M

innodb_buffer_pool_size = $9
innodb_buffer_pool_instances = ${10}
innodb_log_file_size = ${11}
innodb_log_buffer_size = ${12}
innodb_flush_method = O_DIRECT
innodb_flush_log_at_trx_commit = 1
innodb_doublewrite = 1
innodb_lru_scan_depth = ${13}

# innodb_force_recovery = 1
EOF
}

ajustar_php() {
    echo "\n👉 Ajustando PHP-FPM para versao $1..."
    PHP_CONF_PATH="$PHP_BASE_DIR/$1/fpm/pool.d/www.conf"

    if [ ! -f "$PHP_CONF_PATH" ]; then
        echo "❌ Arquivo de configuracao nao encontrado: $PHP_CONF_PATH"
        return
    fi

    # Backup inteligente do www.conf
    if [ -f "$PHP_CONF_PATH" ]; then
        cp "$PHP_CONF_PATH" "$PHP_CONF_PATH"_19-04-2025
    else
        touch "$PHP_CONF_PATH"
    fi

    sed -i "s/^pm\.max_children.*/pm.max_children = $2/" "$PHP_CONF_PATH"
    sed -i "s/^pm\.start_servers.*/pm.start_servers = $3/" "$PHP_CONF_PATH"
    sed -i "s/^pm\.min_spare_servers.*/pm.min_spare_servers = $4/" "$PHP_CONF_PATH"
    sed -i "s/^pm\.max_spare_servers.*/pm.max_spare_servers = $5/" "$PHP_CONF_PATH"
    sed -i "s/^;*pm\.max_requests.*/pm.max_requests = $6/" "$PHP_CONF_PATH"
}


# Verificações de pré-requisitos
skip_mysql=false
skip_php=false

# Verifica se o MySQL está instalado
if ! command -v mysqld >/dev/null 2>&1; then
  echo "❌ MySQL (mysqld) não está instalado no servidor."
  skip_mysql=true
fi

# Verifica se o diretório do PHP existe
if [ ! -d /etc/php ]; then
  echo "❌ Nenhuma instalação de PHP-FPM foi encontrada no caminho /etc/php."
  skip_php=true
fi


# Menu de selecao
clear
echo "O que deseja ajustar?"
echo "1) Somente MySQL"
echo "2) Somente PHP"
echo "3) Ambos (MySQL e PHP)"
read -rp "Digite a opcao (1-3): " acao

clear
echo "Selecione o tipo de servidor:"
echo "1) Cloud 2GB"
echo "2) Cloud 4GB"
echo "3) Cloud 8GB"
echo "4) Cloud 16GB"
read -rp "Digite a opcao (1-4): " tipo

case $tipo in
    1)
        mysql_vals=("Cloud 2GB" 100 16M 32M 2M 1M 256 4 512M 1 128M 32M 256)
        php_vals=(30 5 2 10 300)
        ;;
    2)
        mysql_vals=("Cloud 4GB" 150 32M 64M 2M 1M 384 6 2G 2 256M 48M 384)
        php_vals=(60 10 5 15 500)
        ;;
    3)
        mysql_vals=("Cloud 8GB" 200 64M 128M 4M 2M 512 8 4G 4 512M 64M 512)
        php_vals=(100 15 10 20 500)
        ;;
    4)
        mysql_vals=("Cloud 16GB" 300 128M 256M 8M 4M 1024 12 8G 8 1G 128M 1024)
        php_vals=(180 20 15 25 500)
        ;;
    *)
        echo "❌ Opcao invalida. Saindo."
        exit 1
        ;;
esac

# Aplicar configuracoes conforme a escolha
if [[ "$acao" == "1" || "$acao" == "3" ]]; then
    if [ "$skip_mysql" != true ]; then
    ajustar_mysql "${mysql_vals[@]}"
fi
fi

if [[ "$acao" == "2" || "$acao" == "3" ]]; then
    echo "\nVersoes de PHP detectadas:"
    ls $PHP_BASE_DIR | grep -E '^[0-9]\.[0-9]$'
    echo ""
    read -rp "Digite a versao do PHP que deseja ajustar (ex: 8.1): " php_versao
    if [ "$skip_php" != true ]; then
    ajustar_php "$php_versao" "${php_vals[@]}"
fi
    echo "\n🔄 Reiniciando PHP-FPM..."
    if [ "$skip_php" != true ]; then
    systemctl restart php$php_versao-fpm
fi
fi

if [[ "$acao" == "1" || "$acao" == "3" ]]; then
    echo "\n🔄 Reiniciando MySQL..."
    if [ "$skip_mysql" != true ]; then
    systemctl restart mysql
fi
fi

echo "\n✅ Ajustes aplicados com sucesso para o perfil ${mysql_vals[0]}!"
