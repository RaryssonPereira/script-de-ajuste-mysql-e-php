# ⚙️ Ajuste de MySQL e PHP para Cloud Servers

Este repositório contém um script interativo desenvolvido para ajustar automaticamente as configurações do MySQL e do PHP-FPM de acordo com o perfil de recursos do servidor (Cloud 2GB, 4GB, 8GB ou 16GB).

O objetivo é ajudar devs, sysadmins e times de suporte técnico a corrigirem configurações genéricas que causam lentidão, uso excessivo de swap ou consumo desbalanceado de recursos.

---

## 📜 Sobre o script

**Arquivo:** `ajuste-mysql-php.sh`  
**Criado por:** [Rarysson](https://github.com/RaryssonPereira)  
**Objetivo:** Ajustar automaticamente os parâmetros de desempenho do MySQL e do PHP-FPM com base na RAM e CPU disponíveis no servidor.

---

## 🔧 O que o script faz?

1. Detecta versões de PHP instaladas no servidor.
2. Permite ao usuário escolher qual versão deseja ajustar.
3. Aplica configurações otimizadas ao MySQL (`/etc/mysql/conf.d/mysql.cnf`).
4. Aplica configurações otimizadas ao PHP-FPM (`/etc/php/VERSAO/fpm/pool.d/www.conf`).
5. Permite selecionar se deseja ajustar apenas o MySQL, apenas o PHP ou ambos.
6. Realiza backups automáticos antes de sobrescrever os arquivos.
7. Reinicia os serviços `mysql` e `phpX.X-fpm` após a alteração.

---

## 🚨 Requisitos antes de usar

- Servidor Linux com MySQL (ou MariaDB) instalado.
- Pelo menos uma versão do PHP-FPM instalada.
- Acesso como root ou sudo.
- Scripts testados em Ubuntu Server (20.04 ou superior).

---

## ▶️ Como usar

### 1. Baixe o script

```bash
git clone https://github.com/RaryssonPereira/ajuste-mysql-php.git
cd ajuste-mysql-php
```

### 2. Torne o script executável

```bash
chmod +x ajuste-mysql-php.sh
```

### 3. Execute o script

```bash
./ajuste-mysql-php.sh
```

---

## 🔍 Perfis disponíveis no script

| Tipo de Servidor | Ajustes MySQL (buffer pool, conexões) | Ajustes PHP (FPM tuning)       |
|------------------|----------------------------------------|---------------------------------|
| Cloud 2GB        | Configuração leve e segura             | 30 children, 300 requests       |
| Cloud 4GB        | Intermediária para portais médios      | 60 children, 500 requests       |
| Cloud 8GB        | Alta capacidade para tráfego intenso   | 100 children, 500 requests      |
| Cloud 16GB       | Alta performance e concorrência        | 180 children, 500 requests      |

---

## 💬 Exemplo de fluxo interativo

```text
O que deseja ajustar?
1) Somente MySQL
2) Somente PHP
3) Ambos (MySQL e PHP)

Selecione o tipo de servidor:
1) Cloud 2GB
2) Cloud 4GB
3) Cloud 8GB
4) Cloud 16GB

Versões de PHP detectadas:
8.0
8.1
8.2
Digite a versão do PHP que deseja ajustar: 8.1
```

---

## ❤️ Contribuindo

Este projeto foi feito para acelerar o suporte técnico e provisionamento de servidores.  
Sinta-se à vontade para enviar Pull Requests com novos perfis, melhorias ou correções.

---

## 📜 Licença

Este projeto está sob a licença MIT.  
Você pode usar, modificar e distribuir como quiser.

---

## ✨ Créditos

Criado com 💻 por **Rarysson**,  
para facilitar o dia a dia de quem gerencia servidores de conteúdo, WordPress, APIs e aplicações em nuvem.
