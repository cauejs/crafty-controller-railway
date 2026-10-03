#!/bin/bash
set -e

# Estrutura persistente dentro do único volume Railway
mkdir -p \
  /data/backups \
  /data/logs \
  /data/servers \
  /data/config \
  /data/import

# Na primeira inicialização, copia a configuração padrão da imagem
if [ -z "$(ls -A /data/config 2>/dev/null)" ]; then
    echo "Inicializando configuração do Crafty..."
    cp -a /crafty/app/config_original/. /data/config/
fi

# Remove os diretórios não persistentes
rm -rf \
  /crafty/backups \
  /crafty/logs \
  /crafty/servers \
  /crafty/app/config \
  /crafty/import

# Faz o Crafty enxergar o volume do Railway
ln -s /data/backups /crafty/backups
ln -s /data/logs /crafty/logs
ln -s /data/servers /crafty/servers
ln -s /data/config /crafty/app/config
ln -s /data/import /crafty/import

# Ajusta permissões
chown -R 1000:0 /data

echo "Iniciando Crafty..."

exec /crafty/docker_launcher.sh "$@"
