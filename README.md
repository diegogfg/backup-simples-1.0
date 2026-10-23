# backup-simples

Script em Bash que cria backups compactados (`.tar.gz`) de uma pasta, com data e hora no nome, e mantém apenas os backups mais recentes.

## Funcionalidades

- Compacta qualquer pasta em `.tar.gz`
- Nome do arquivo com data e hora (`backup_Documentos_2026-10-23_14-30-00.tar.gz`)
- Rotação automática: apaga os backups mais antigos
- Validação de parâmetros e mensagens de erro claras
- Log com horário no terminal

## Requisitos

- Linux ou macOS (ou WSL no Windows)
- Bash 4+ e `tar`

## Instalação

```bash
git clone https://github.com/diegogfg/backup-simples-1.0.git
cd backup-simples-1.0
chmod +x backup.sh
```

## Uso

```bash
./backup.sh -o <pasta_origem> [-d <pasta_destino>] [-k <quantidade>]
```

| Opção | Descrição                                  | Padrão      |
|-------|--------------------------------------------|-------------|
| `-o`  | Pasta que será copiada (obrigatório)       | —           |
| `-d`  | Pasta onde os backups serão salvos         | `./backups` |
| `-k`  | Quantidade de backups a manter             | `5`         |
| `-v`  | Mostra a versão                            | —           |
| `-h`  | Mostra a ajuda                             | —           |

### Exemplo

```bash
./backup.sh -o ~/Documentos -d ~/meus_backups -k 3
```

Saída:

```
[2026-10-23 14:30:00] Iniciando backup de '/home/user/Documentos'...
[2026-10-23 14:30:01] Backup criado: /home/user/meus_backups/backup_Documentos_2026-10-23_14-30-00.tar.gz (12M)
[2026-10-23 14:30:01] Concluído. Backups mantidos: 3
```

## Automatizando com cron

Para rodar todo dia às 2h da manhã, execute `crontab -e` e adicione:

```
0 2 * * * /caminho/completo/backup.sh -o /home/user/Documentos -d /home/user/meus_backups -k 7
```

## Como funciona

1. Lê as opções com `getopts`
2. Valida a pasta de origem e o número de backups a manter
3. Cria o `.tar.gz` com `tar -czf`
4. Lista os backups existentes (a ordem alfabética coincide com a cronológica) e remove os excedentes

## Licença

MIT — veja o arquivo [LICENSE](LICENSE).
