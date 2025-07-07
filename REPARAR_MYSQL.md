# Reparar MySQL Corrompido
### 👤 Autor

**Rarysson Pereira**  
Analista de Desenvolvimento de Sistemas e Infraestrutura | Brasileiro 🇧🇷  
🗓️ Criado em: 07/07/2025  
[LinkedIn](https://www.linkedin.com/in/rarysson-pereira?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app) • [Instagram](https://www.instagram.com/raryssonpereira?igsh=MXhhb3N2MW1yNzl3cA==)

---

## ▶️ **Vídeo de Referência**

Para um auxílio visual, o vídeo a seguir demonstra a resolução de problemas técnicos em um banco de dados MySQL, incluindo a depuração de problemas de corrupção e falhas de backup:

Link do vídeo: **indisponível**

---

## 1. 🧠 Diagnóstico Inicial

Antes de assumir que o banco de dados está corrompido, é fundamental verificar se o problema não é mais simples, como um erro de autenticação.

**Verifique os logs do MySQL**: Procure por mensagens de erro relacionadas a falhas de login (access denied) ou outros problemas que não sejam de corrupção de tabelas. Abaixo estão alguns comandos úteis para essa verificação:

- Para ver os logs em tempo real (ideal para diagnosticar o erro no momento em que ele ocorre):
```bash
sudo tail -f /var/log/mysql/error.log
```

- Para buscar por erros específicos (ex: 'access denied'):
```bash
sudo grep -i 'access denied' /var/log/mysql/error.log
```

- Para navegar pelo arquivo de log completo com mais facilidade:
```bash
sudo less /var/log/mysql/error.log
```
> ⚠️ Obs: O caminho do log pode variar. Em sistemas como CentOS, pode ser `/var/log/mysqld.log`. Em sistemas mais modernos, você também pode usar `journalctl -u mysql.service`.

Se os logs indicarem problemas com arquivos ou tabelas, prossiga com os passos de reparo.

---

## 2. ⚙️ Reparo Rápido com mysqlcheck

Este é o primeiro método a ser tentado, pois é mais seguro e menos invasivo.

### Coletar a Senha do MySQL
```bash
history | grep mysql
```

### Verificar e Reparar Tabelas
```bash
# Substitua SUA_SENHA pela senha encontrada
sudo mysqlcheck -u root -pSUA_SENHA --auto-repair --check --all-databases
```

### Verificação Final

Após o reparo, rode o comando novamente para garantir que os erros foram corrigidos.
```bash
sudo mysqlcheck -u root -pSUA_SENHA --check --all-databases
```
> 🔐 **Segurança**: Colocar a senha diretamente no comando é um risco, pois ela fica salva no histórico do terminal. Após a execução, considere limpar o histórico com o comando `history -c` ou use apenas `-p` e digite/cole a senha quando for solicitado.

---

## 3. 🛠️ Recuperação Forçada (Se o Reparo Rápido Falhar)

Prossiga com este método apenas se o mysqlcheck não resolver o problema. Este processo é mais complexo e envolve a reinicialização do banco de dados a partir de um backup. 

> **Atenção**: A maioria dos comandos a seguir precisa de privilégios de superusuário. Use `sudo` no início dos comandos.

### Parar o serviço do banco
```bash
sudo service mysql stop
```

### Realizar uma cópia física de segurança
```bash
# Substitua dia_mes_ano pela data atual
sudo cp -r -p /var/lib/mysql /var/lib/mysql_corrompido_dia_mes_ano
```

### Colocar o MySQL em modo de recuperação

Adicione a linha a seguir no arquivo de configuração, geralmente em `/etc/mysql/conf.d/mysql.cnf` ou `/etc/my.cnf`:
```bash
innodb_force_recovery=1
```
- **Níveis 1 a 3**: Permitem acesso aos dados sem risco de perdas.
- **Níveis 4 a 6**: Permitem forçar o início do serviço, mas podem envolver perda de dados, pois algumas operações de escrita são desativadas.

> ⚠️ **Importante**: Comece sempre com o valor 1. Se o serviço não iniciar, aumente o valor sequencialmente até 6.

### Iniciar o serviço do banco
```bash
sudo service mysql start
```

### Realizar um backup lógico (dump)

Com o banco em modo de recuperação, extraia os dados para um arquivo SQL.
```bash
# Substitua os placeholders pelos valores corretos
sudo mysqldump -u root -pSUA_SENHA DATABASE > /caminho/backup_db.sql
``` 

### Parar o serviço e desativar o modo de recuperação
```bash
sudo service mysql stop
```
Agora, remova ou comente a linha innodb_force_recovery=1 do arquivo de configuração.

### Iniciar o serviço e recriar o banco
```bash
sudo service mysql start
```

### Acesse o MySQL

```bash
# Acesse o MySQL com o seguinte comando:
sudo mysql -u root -pSUA_SENHA
```

### Recrie o banco de dados
```sql
-- Dropar o banco de dados corrompido
DROP DATABASE nome_do_banco;

-- Criar o banco de dados novamente
CREATE DATABASE nome_do_banco;

-- Encerra a sessão do MySQL. O atalho Ctrl + D tem o mesmo efeito.
EXIT;
```

### Importar o backup

Finalmente, importe os dados do arquivo de dump que você criou.
```bash
sudo mysql -u root -pSUA_SENHA nome_do_banco < /caminho/backup_db.sql
```
> 🔐 **Segurança**: Colocar a senha diretamente no comando é um risco, pois ela fica salva no histórico do terminal. Após a execução, considere limpar o histórico com o comando `history -c` ou use apenas `-p` e digite/cole a senha quando for solicitado.

Após a importação, seu banco de dados deve estar recuperado e funcionando normalmente.

---

## 4. ☢️ Reinstalação Completa (Último Recurso)

Este procedimento é extremamente destrutivo e deve ser usado apenas se os métodos anteriores falharem, especialmente se houver suspeita de corrupção nas bases de dados nativas do próprio MySQL.

> ⚠️ **Importante**: Garanta que você possui um backup lógico (arquivo .sql) do seu banco de dados, como o realizado no passo 3, antes de prosseguir.

### Verificar o pacote MySQL instalado

Este comando ajuda a identificar o nome exato do pacote para a desinstalação.

- Em sistemas Debian/Ubuntu:
```bash
dpkg -l | grep mysql
```

- Em sistemas CentOS/RHEL:
```bash
rpm -qa | grep mysql
```

### Desinstalar completamente o MySQL

- Em sistemas Debian/Ubuntu:

O comando purge remove os pacotes, arquivos de configuração e dados.
  
```bash
# Substitua <nome_do_pacote> pelo nome identificado no passo anterior
sudo apt-get purge --auto-remove <nome_do_pacote>

# Exemplo comum:
sudo apt-get purge --auto-remove percona-server-common-5.7
```

- Em sistemas CentOS/RHEL:
```bash
# Substitua <nome_do_pacote> pelo nome identificado no passo anterior
sudo yum remove <nome_do_pacote>

# Ou em sistemas mais novos com DNF
sudo dnf remove <nome_do_pacote>

# Exemplo comum:
sudo dnf remove percona-server-common-5.7
```

### Limpeza Manual (Opcional, mas recomendado)

Após a desinstalação, verifique se os diretórios a seguir foram removidos. Se não, remova-os manualmente para garantir uma instalação limpa:

```bash
sudo rm -rf /etc/mysql
sudo rm -rf /var/lib/mysql
```
> ⚠️ **CUIDADO**: Use os comandos acima apenas se tiver certeza absoluta e o backup dos seus dados estiver seguro. Esta ação não pode ser desfeita.

### Instalar o MySQL novamente

**Nota do Autor**: O guia a seguir demonstra a instalação do percona-server-server-5.7, que é a minha preferência. Se você utiliza outra versão do MySQL, MariaDB ou outro tipo de banco de dados, os passos de instalação serão diferentes e você precisará seguir a documentação específica do software escolhido, incluindo suas extensões, bibliotecas e outros serviços.

Os comandos a seguir instalam o Percona Server 5.7 em sistemas baseados em Debian:
```bash
sudo wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
sudo apt-get update -qq
percona-release setup ps57
# Pré-configura a senha do root para evitar prompts interativos
echo "percona-server-server-5.7 percona-server-server-5.7/root-pass password ahq.iuo_8h43r" | sudo debconf-set-selections
echo "percona-server-server-5.7 percona-server-server-5.7/re-root-pass password ahq.iuo_8h43r" | sudo debconf-set-selections
# Instala o servidor
sudo apt-get install -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" percona-server-server-5.7
```

### Configurar o mysql.cnf

Ajuste o arquivo `/etc/mysql/conf.d/mysql.cnf` com as configurações otimizadas. Você pode usar o padrão da sua organização ou um modelo de referência.

Referência Serverdo: https://bitbucket.org/serverdoin/scriptbase/src/master/mysql.cnf

### Reiniciar o serviço
```bash
sudo service mysql restart
```

### Criar a base de dados e importar o backup

Acesse o MySQL com a nova senha e recrie o banco de dados antes de importar os dados.

### Use a senha definida durante a instalação
```bash
sudo mysql -u root -pSUA_SENHA
```

### Dentro do MySQL:
```sql
CREATE DATABASE nome_do_banco;
EXIT;
```

### Finalmente, importe o backup:
```bash
sudo mysql -u root -pSUA_SENHA nome_do_banco < /caminho/backup_db.sql
```

Seu ambiente MySQL estará completamente novo e com os dados restaurados.
