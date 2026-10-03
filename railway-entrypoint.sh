#!/bin/bash
set -e

SOURCE="/crafty-image"
TARGET="/crafty"

echo "======================================"
echo " Crafty Controller - Railway"
echo "======================================"

# O Railway monta o volume vazio em /crafty.
mkdir -p "$TARGET"

# ------------------------------------------------
# PRIMEIRO BOOT
# ------------------------------------------------

if [ ! -f "$TARGET/.railway-initialized" ]; then
    echo "[Railway] Primeiro boot."
    echo "[Railway] Copiando Crafty para o volume..."

    cp -a "$SOURCE/." "$TARGET/"

    touch "$TARGET/.railway-initialized"

    echo "[Railway] Inicialização concluída."

else

    # ------------------------------------------------
    # DEPLOYS/ATUALIZAÇÕES
    # ------------------------------------------------

    echo "[Railway] Volume existente encontrado."
    echo "[Railway] Atualizando aplicação..."

    # Salva os dados persistentes temporariamente.
    mkdir -p /tmp/crafty-persist

    for dir in \
        app/config \
        servers \
        backups \
        logs \
        import
    do
        if [ -e "$TARGET/$dir" ]; then
            mkdir -p "/tmp/crafty-persist/$(dirname "$dir")"
            mv "$TARGET/$dir" "/tmp/crafty-persist/$dir"
        fi
    done

    # Atualiza os arquivos da aplicação com os da nova imagem.
    cp -a "$SOURCE/." "$TARGET/"

    # Restaura os dados persistentes.
    for dir in \
        app/config \
        servers \
        backups \
        logs \
        import
    do
        if [ -e "/tmp/crafty-persist/$dir" ]; then

            rm -rf "$TARGET/$dir"

            mkdir -p "$(dirname "$TARGET/$dir")"

            mv "/tmp/crafty-persist/$dir" "$TARGET/$dir"
        fi
    done

    touch "$TARGET/.railway-initialized"

    echo "[Railway] Atualização concluída."
fi

# ------------------------------------------------
# GARANTE DIRETÓRIOS
# ------------------------------------------------

mkdir -p \
    "$TARGET/servers" \
    "$TARGET/backups" \
    "$TARGET/logs" \
    "$TARGET/import"

chmod +x "$TARGET/docker_launcher.sh"

echo "[Railway] Iniciando Crafty..."

cd "$TARGET"

exec "$TARGET/docker_launcher.sh"
