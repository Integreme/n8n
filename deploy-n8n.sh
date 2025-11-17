#!/bin/bash

set -e

echo "=========================================="
echo "Deploy do n8n em modo queue"
echo "=========================================="

# Verificar se a imagem custom existe
if ! docker image inspect n8nio/n8n:local > /dev/null 2>&1; then
    echo "ERRO: Imagem n8nio/n8n:local não encontrada!"
    echo "Execute primeiro: cd n8n && pnpm build:docker"
    exit 1
fi

# Verificar se o volume n8n_data existe, se não criar
if ! docker volume inspect n8n_data > /dev/null 2>&1; then
    echo "Criando volume n8n_data..."
    docker volume create n8n_data
fi

# Parar container antigo se estiver rodando
if docker ps -a --format '{{.Names}}' | grep -q "^n8n_prod$"; then
    echo "Parando container antigo n8n_prod..."
    docker stop n8n_prod || true
    docker rm n8n_prod || true
fi

# Parar containers do docker-compose se estiverem rodando
echo "Parando containers existentes..."
docker-compose -f docker-compose.prod.yml down || true

# Subir os serviços
echo "Subindo serviços em modo queue..."
docker-compose -f docker-compose.prod.yml up -d

# Aguardar serviços ficarem prontos
echo "Aguardando serviços ficarem prontos..."
sleep 5

# Verificar status
echo ""
echo "=========================================="
echo "Status dos containers:"
echo "=========================================="
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "=========================================="
echo "Deploy concluído!"
echo "=========================================="
echo "n8n Main: http://localhost:5678"
echo ""
echo "Para ver os logs:"
echo "  docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "Para parar os serviços:"
echo "  docker-compose -f docker-compose.prod.yml down"
echo ""

