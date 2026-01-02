#!/usr/bin/env bash

# Script para pesquisa web usando fuzzel e firefox
# Compatível com River WM (sistema de tags)
# - Se Firefox já está aberto: abre nova aba na instância existente
# - Se Firefox não está aberto: abre nova instância na tag atual

# -l 0: define zero linhas de lista (apenas input)
QUERY=$(fuzzel -d -p "󰍉 Pesquisar: " -l 0 -w 60 --anchor center)

if [ -n "$QUERY" ]; then
    # Firefox automaticamente reutiliza instância existente quando
    # chamado sem flags especiais de janela
    firefox --search "$QUERY" &
fi