# Shell Check

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
