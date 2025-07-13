# 🖥️ Shell Check

O `Shell Check` é uma ferramenta de diagnóstico e auditoria desenvolvida em Shell Script, voltada para sistemas Linux-based. Seu objetivo é automatizar a coleta de dados do sistema operacional e apresentar outputs formatados e organizados, facilitando:

- Análises de consumo de recursos computacionais
- Verificações de configuração de serviços
- Visualização de logs para auditorias técnicas
- Identificação de gargalos em ambientes produtivos

Com foco em praticidade e compatibilidade, o `Shell Check` pode ser executado em ambientes bare metal, virtuais ou containers leves, sem depender de dependências externas complexas.

### ⚙️ Funcionalidades disponíveis

Até o momento, o Shell Check oferece as seguintes funcionalidades:

#### 📊 Análise de CPU:

- Verificação detalhada do uso atual da(s) CPU(s)
- Identificação de picos e gargalos de processamento

#### 🧠 Análise de Memória RAM e Swap:

- Exibição do uso total, livre e cache
- Avaliação do uso de swap e memória real disponível

#### 💽 Análise de I/O de disco:

- Identificação de dispositivos com maior tempo de leitura/gravação
- Monitoramento de operações por segundo (IOPS)

#### 🌐 Análise de rede:

- Tráfego de entrada (inbound) e saída (outbound) por interface
- Dados úteis para identificar sobrecarga de banda ou uso anormal

#### 📦 Análise de uso de armazenamento:

- Uso percentual por mountpoint
- Destaca partições próximas da capacidade máxima
- Também utiliza verificação percentual por inodes

#### 🔍 Verificação de atualizações de kernel:

- Checagem da versão atual do kernel
- Notificação sobre versões mais recentes disponíveis
- Compatível com ambientes Debian-like (ex.: Debian, Ubuntu Server) e RHEL-like (ex.: RedHat Enterprise Linux, Oracle Linux, CentOS Linux)

## 📦 Download e Utilização

### 🔁 Clonando com o Git

Se o servidor possuir `git` instalado, basta executar:

```bash
git clone https://github.com/ettory-automation/shell_check.git
```

### 📥 Alternativa sem `git` (via `curl` ou `wget`):

Se o `git` não estiver disponível, use `curl` ou `wget` para baixar o projeto em formato `.zip`:

```bash
curl -L -o shell_check.zip https://github.com/ettory-automation/shell_check/archive/refs/heads/main.zip || \
wget -O shell_check.zip https://github.com/ettory-automation/shell_check/archive/refs/heads/main.zip 
```

#### 📂 Descompactando:

➤ Com `unzip`:

```bash
unzip shell_check.zip && rm -rf shell_check.zip && mv shell_check-main shell_check
```

> ⚠️ Nota: Se o servidor não possuir `unzip`, utilize o `Python` nativo para descompactar.

➤ Com `Python` 3.x:

```bash
python3 -m zipfile -e shell_check.zip .
```

➤ Com `Python` 2.x:

```bash
python -c "import zipfile; zipfile.ZipFile('shell_check.zip', 'r').extractall('.')"
```

### 🔐 Permissões e Execução

➤ Torne o script principal executável:

```bash
chmod +x shell_check/view/menu.sh
```

➤ Execute o script com permissões elevadas para resultados mais precisos:

```bash
sudo bash ./menu.sh
```
