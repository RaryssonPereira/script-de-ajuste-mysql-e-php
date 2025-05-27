#!/bin/bash

# Script: mysql-tune-auto.sh
# Descrição: Ajusta automaticamente as configurações do MySQL (5.7 ou 8.0) com base na RAM do servidor e perfil (Cloud 2GB, 4GB, 8GB, 16GB)
# Autor: Rarysson Pereira
# Data: 2025-05-21

# Caminho do arquivo de configuração principal do MySQL
CONFIG_FILE="/etc/mysql/conf.d/mysql.cnf"

# Caminho do arquivo de backup, com data e hora no nome
BACKUP_FILE="/etc/mysql/conf.d/mysql.cnf.backup.$(date +%F-%H%M%S)"

# 🔍 Verifica se o MySQL está instalado e obtém sua versão
MYSQL_VERSION=$(mysql -V 2>/dev/null)

# Verifica se o comando mysql foi executado com sucesso (MySQL está instalado?)
if [ $? -ne 0 ]; then
  echo "MySQL não está instalado neste servidor."
  exit 1
fi

# Exibe a versão do MySQL encontrada
echo "Versão do MySQL detectada: $MYSQL_VERSION"

# 🛡️ Verifica se o arquivo de configuração existe
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Arquivo de configuração $CONFIG_FILE não encontrado."
  exit 1
fi

# 💾 Faz backup do arquivo atual
cp "$CONFIG_FILE" "$BACKUP_FILE"

# Exibe o caminho do backup criado
echo "Backup criado em: $BACKUP_FILE"

# 🧠 Obtém informações de memória total e disponível
get_memory_info() {
  # Lê a memória total do sistema em KB
  TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')

  # Converte a memória total para MB
  TOTAL_MEM_MB=$((TOTAL_MEM / 1024))

  # Lê a memória disponível (estimada pelo kernel) em KB
  FREE_MEM=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

  # Converte a memória disponível para MB
  FREE_MEM_MB=$((FREE_MEM / 1024))
}

# 📊 Define o perfil de Cloud com base na memória total (em MB)
get_memory_profile() {
  # Define o perfil de acordo com faixas aproximadas de RAM
  if [ "$TOTAL_MEM_MB" -lt 3000 ]; then # Até ~2.9 GB → Cloud 2GB
    PROFILE="cloud-2gb"
  elif [ "$TOTAL_MEM_MB" -lt 6000 ]; then # Até ~5.9 GB → Cloud 4GB
    PROFILE="cloud-4gb"
  elif [ "$TOTAL_MEM_MB" -lt 12000 ]; then # Até ~11.9 GB → Cloud 8GB
    PROFILE="cloud-8gb"
  elif [ "$TOTAL_MEM_MB" -lt 24000 ]; then # Até ~23.9 GB → Cloud 16GB
    PROFILE="cloud-16gb"
  else # Acima disso → personalizado
    PROFILE="custom"
  fi
}

# 🌐 Verifica se o servidor atua como web server (porta 80/443 ou PHP-FPM ativo)
is_web_server() {
  # Retorna 0 (verdadeiro) se PHP-FPM estiver ativo ou se a porta 80 ou 443 estiver escutando
  if systemctl is-active --quiet 'php*-fpm' ||
    netstat -tuln | grep -qE ':(80|443)\s+.*LISTEN'; then
    return 0
  else
    return 1
  fi
}
