## Download e Utilização

1. Para realizar o download do projeto sem `git-cli`, basta executar o comando abaixo dentro de um server utilizando a ferramenta `curl` ou `wget`:

```bash
curl -L -o shell_check.zip https://github.com/ettory-automation/shell_check/archive/refs/heads/main.zip || \
wget -O shell_check.zip https://github.com/ettory-automation/shell_check/archive/refs/heads/main.zip 
```

2. Após realizar o download, extraia o projeto com a ferramenta `unzip`:

```bash
unzip shell_check.zip
cd shell_check-main/view
```

3. Modifique as permissões do arquivo `menu.sh` dentro do diretório `../view`:

```bash
chmod +x menu.sh
```

4. Execute o arquivo nomeado como `menu.sh` para utilização (altamente recomendado utilização de `sudo` para maior precisão de informações captadas):

```bash
./menu.sh
```
