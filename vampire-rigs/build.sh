#!/bin/bash
#==================================================
# VAMPIRE RIGS - BUNDLER
# Concatena todos os modulos em um unico arquivo
# Uso: bash build.sh
#==================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
OUT_FILE="$SCRIPT_DIR/dist/VampireRigScript.luau"

# Tambem copia pro root do repo (para o gist/loadstring)
ROOT_OUT="$SCRIPT_DIR/../VampireRigScript.luau"

echo "🦇 Vampire Rigs Bundler"
echo "========================"

# Limpa output
> "$OUT_FILE"

# Header
cat >> "$OUT_FILE" << 'HEADER'
--==================================================
-- VAMPIRE RIG SCANNER v10 - GENERATE RIG PREVIEW
-- Create By VampireSonata
-- Gera o rig no preview ao inves de clonar!
-- ⚡ Bundled automaticamente — NÃO edite este arquivo!
-- ⚡ Edite os modulos em vampire-rigs/src/
--==================================================

HEADER

# Conta modulos
count=0

# Concatena cada modulo em ordem
for file in "$SRC_DIR"/*.luau; do
    if [ -f "$file" ]; then
        name=$(basename "$file")
        echo "  + $name"
        echo "" >> "$OUT_FILE"
        echo "--[[ ═══════ MODULE: $name ═══════ ]]" >> "$OUT_FILE"
        echo "" >> "$OUT_FILE"
        cat "$file" >> "$OUT_FILE"
        echo "" >> "$OUT_FILE"
        count=$((count + 1))
    fi
done

# Copia pro root
cp "$OUT_FILE" "$ROOT_OUT"

echo "========================"
echo "✅ $count modulos → $OUT_FILE"
echo "✅ Copiado → $ROOT_OUT"
echo "🦇 Done!"
