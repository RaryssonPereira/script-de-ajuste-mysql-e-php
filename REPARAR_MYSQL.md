# Reparar MySQL Corrompido
### 👤 Autor

**Rarysson Pereira**  
Analista de Desenvolvimento de Sistemas e Infraestrutura | Brasileiro 🇧🇷  
🗓️ Criado em: 29/05/2025  
[LinkedIn](https://www.linkedin.com/in/rarysson-pereira?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app) • [Instagram](https://www.instagram.com/raryssonpereira?igsh=MXhhb3N2MW1yNzl3cA==)

---

**Vídeo de Referência**

Para um auxílio visual, o vídeo a seguir demonstra a resolução de problemas técnicos em um banco de dados MySQL, incluindo a depuração de problemas de corrupção e falhas de backup:

Link do vídeo: **indisponível**

---

## 1. Diagnóstico Inicial

Antes de assumir que o banco de dados está corrompido, é fundamental verificar se o problema não é mais simples, como um erro de autenticação.

**Verifique os logs do MySQL**: Procure por mensagens de erro relacionadas a falhas de login (access denied) ou outros problemas que não sejam de corrupção de tabelas. Abaixo estão alguns comandos úteis para essa verificação:

- Para ver os logs em tempo real (ideal para diagnosticar o erro no momento em que ele ocorre):
```bash
tail -f /var/log/mysql/error.log
```

- Para buscar por erros específicos (ex: 'access denied'):
```bash
grep -i 'access denied' /var/log/mysql/error.log
```

- Para navegar pelo arquivo de log completo com mais facilidade:
```bash
less /var/log/mysql/error.log
```
> ⚠️ Obs: O caminho do log pode variar. Em sistemas como CentOS, pode ser `/var/log/mysqld.log`. Em sistemas mais modernos, você também pode usar `journalctl -u mysql.service`.

Se os logs indicarem problemas com arquivos ou tabelas, prossiga com os passos de reparo.

---

## 2. Método 1: Reparo Rápido com mysqlcheck

Este é o primeiro método a ser tentado, pois é mais seguro e menos invasivo.

### Passo 2.1: Coletar a Senha do MySQL
```bash
history | grep mysql
```

### Passo 2.2: Verificar e Reparar Tabelas
```bash
# Substitua SUA_SENHA pela senha encontrada
mysqlcheck -u root -pSUA_SENHA --auto-repair --check --all-databases
```

### Passo 2.3: Verificação Final

Após o reparo, rode o comando novamente para garantir que os erros foram corrigidos.
```bash
mysqlcheck -u root -pSUA_SENHA --check --all-databases
```

## 3. Método 2: Recuperação Forçada (Se o Reparo Rápido Falhar)

Atenção: Prossiga com este método apenas se o mysqlcheck não resolver o problema. Este processo é mais complexo e envolve a reinicialização do banco de dados a partir de um backup.

### Passo 3.1: Parar o serviço do banco
```bash
service mysql stop
```

### Passo 3.2: Realizar uma cópia física de segurança
```bash
# Substitua dia_mes_ano pela data atual
cp -r -p /var/lib/mysql /var/lib/mysql_corrompido_dia_mes_ano
```

### Passo 3.3: Colocar o MySQL em modo de recuperação

Adicione a linha a seguir no arquivo de configuração, geralmente em `/etc/mysql/conf.d/mysql.cnf` ou `/etc/my.cnf`:
```bash
innodb_force_recovery=1
```

**Importante**: Comece sempre com o valor 1. Se o serviço não iniciar, aumente o valor sequencialmente até 6.

- **Níveis 1 a 3**: Permitem acesso aos dados sem risco de perdas.

- **Níveis 4 a 6**: Permitem forçar o início do serviço, mas podem envolver perda de dados, pois algumas operações de escrita são desativadas.

### Passo 3.4: Iniciar o serviço do banco
```bash
service mysql start
```

### Passo 3.5: Realizar um backup lógico (dump)

Com o banco em modo de recuperação, extraia os dados para um arquivo SQL.
```bash
# Substitua os placeholders pelos valores corretos
mysqldump -u USER -pPASSWORD DATABASE > /caminho/backup_db.sql
```

### Passo 3.6: Parar o serviço e desativar o modo de recuperação
```bash
service mysql stop
```
Agora, remova ou comente a linha innodb_force_recovery=1 do arquivo de configuração.

### Passo 3.7: Iniciar o serviço e recriar o banco
```bash
service mysql start
```

Acesse o MySQL e recrie o banco de dados.
```bash
-- Dropar o banco de dados corrompido
DROP DATABASE nome_do_banco;

-- Criar o banco de dados novamente
CREATE DATABASE nome_do_banco;
```

### Passo 3.8: Importar o backup

Finalmente, importe os dados do arquivo de dump que você criou.
```bash
mysql -u username -p nome_do_banco < /caminho/backup_db.sql
```

Após a importação, seu banco de dados deve estar recuperado e funcionando normalmente.
