# Reparar MySQL Corrompido

Este guia descreve os passos para diagnosticar e reparar um banco de dados MySQL que apresenta erros de corrupção.

## 1. Diagnóstico Inicial

Erro de banco de dados ao acessar o site

Antes de assumir que o banco de dados está corrompido, é fundamental verificar se o problema não é mais simples, como um erro de autenticação.

- Verifique os logs do MySQL: Procure por mensagens de erro relacionadas a falhas de login (access denied) ou outros problemas que não sejam de corrupção de tabelas.

Se os logs indicarem problemas com arquivos ou tabelas, prossiga com os passos de reparo.

### Vídeo de Referência

Para um auxílio visual, o vídeo a seguir demonstra a resolução de problemas técnicos em um banco de dados MySQL, incluindo a depuração de problemas de corrupção e falhas de backup:

- Vídeo do YouTube para ajudar: https://youtu.be/JSOqaauIczA

---

## 2. Passos para Reparo

Siga os passos abaixo para verificar e reparar as tabelas do seu banco de dados.

### Passo 2.1: Coletar a Senha do MySQL
Para executar os comandos de verificação e reparo, você precisará da senha de root do MySQL. Se você não a sabe de cor, pode tentar encontrá-la no histórico de comandos do seu terminal.

Atenção: Não é necessário logar no MySQL, apenas obter a senha.

Execute o seguinte comando para pesquisar no seu histórico:
```bash
history | grep mysql
```
Procure por uma linha de comando como mysql -u root -pSENHA ou similar, onde a senha pode estar visível.

### Passo 2.2: Verificar Arquivos Corrompidos

Este comando irá analisar todas as tabelas de todos os bancos de dados, procurar por erros e tentar um reparo automático.

Substitua SUA_SENHA pela senha encontrada no passo anterior. Se a senha não estiver diretamente no comando, o terminal irá solicitá-la.
```bash
# Comando para checar e reparar automaticamente
mysqlcheck -u root -pSUA_SENHA --auto-repair --check --all-databases
```

### Passo 2.3: Forçar o Reparo (Comando Alternativo)

Se o comando anterior não resolver todos os problemas, você pode rodar um comando de reparo mais geral. O sistema pedirá a senha após a execução.
```bash
# Comando para reparar todos os bancos de dados
mysqlcheck -A --auto-repair -u root -p
```

### 3. Verificação Final
Após executar os comandos de reparo, é altamente recomendável rodar o comando de verificação do Passo 2.2 novamente para confirmar que todos os erros foram corrigidos.
```bash
mysqlcheck -u root -pSUA_SENHA --check --all-databases
```

Se o comando não retornar mais erros, seu banco de dados foi reparado com sucesso.
