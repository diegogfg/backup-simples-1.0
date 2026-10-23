#!/usr/bin/env bash
# backup-simples-1.0 - cria backups compactados (.tar.gz) de uma pasta
# e mantém apenas os N mais recentes.

set -euo pipefail

VERSAO="1.0.0"
ORIGEM=""
DESTINO="./backups"
MANTER=5

uso() {
  cat <<AJUDA
backup-simples v${VERSAO}

Uso: ./backup.sh -o <pasta_origem> [-d <pasta_destino>] [-k <quantidade>]

Opções:
  -o  Pasta que será copiada (obrigatório)
  -d  Pasta onde os backups serão salvos (padrão: ./backups)
  -k  Quantos backups manter (padrão: 5)
  -v  Mostra a versão
  -h  Mostra esta ajuda

Exemplo:
  ./backup.sh -o ~/Documentos -d ~/meus_backups -k 3
AJUDA
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

while getopts ":o:d:k:vh" opcao; do
  case "$opcao" in
    o) ORIGEM="$OPTARG" ;;
    d) DESTINO="$OPTARG" ;;
    k) MANTER="$OPTARG" ;;
    v) echo "backup-simples v${VERSAO}"; exit 0 ;;
    h) uso; exit 0 ;;
    :) echo "Erro: a opção -$OPTARG precisa de um valor." >&2; exit 1 ;;
    \?) echo "Erro: opção inválida -$OPTARG" >&2; uso; exit 1 ;;
  esac
done

# --- Validações ---
if [[ -z "$ORIGEM" ]]; then
  echo "Erro: informe a pasta de origem com -o" >&2
  uso
  exit 1
fi

if [[ ! -d "$ORIGEM" ]]; then
  echo "Erro: '$ORIGEM' não é uma pasta válida." >&2
  exit 1
fi

if ! [[ "$MANTER" =~ ^[1-9][0-9]*$ ]]; then
  echo "Erro: -k deve ser um número inteiro maior que zero." >&2
  exit 1
fi

# --- Criação do backup ---
mkdir -p "$DESTINO"
NOME="$(basename "$(realpath "$ORIGEM")")"
DATA="$(date '+%Y-%m-%d_%H-%M-%S')"
ARQUIVO="$DESTINO/backup_${NOME}_${DATA}.tar.gz"

log "Iniciando backup de '$ORIGEM'..."
tar -czf "$ARQUIVO" -C "$(dirname "$(realpath "$ORIGEM")")" "$NOME"
TAMANHO="$(du -h "$ARQUIVO" | cut -f1)"
log "Backup criado: $ARQUIVO ($TAMANHO)"

# --- Rotação: apaga os mais antigos ---
# Os nomes têm data no formato AAAA-MM-DD_HH-MM-SS,
# então a ordem alfabética é a ordem cronológica.
arquivos=( "$DESTINO"/backup_"${NOME}"_*.tar.gz )
total=${#arquivos[@]}

if (( total > MANTER )); then
  remover=$(( total - MANTER ))
  for (( i=0; i<remover; i++ )); do
    rm -f -- "${arquivos[$i]}"
    log "Backup antigo removido: ${arquivos[$i]}"
  done
fi

log "Concluído. Backups mantidos: $(( total > MANTER ? MANTER : total ))"
