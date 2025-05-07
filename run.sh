#!/bin/bash

# Vérifier si nvidia-smi fonctionne sur l'hôte
if nvidia-smi &> /dev/null; then
    echo "GPU détecté sur l'hôte"
    GPU_OPTIONS="--gpus all"
else
    echo "ATTENTION: GPU non détecté. L'application fonctionnera en mode CPU."
    GPU_OPTIONS=""
fi

# Créer un volume pour stocker les données persistantes
docker volume create marker-data

# Construire l'image Docker
docker build -t marker-pdf .

# Exécuter le conteneur
docker run -d \
    $GPU_OPTIONS \
    -p 8000:8000 \
    -v marker-data:/app/data \
    -v $(pwd)/shared:/app/shared \
    --restart unless-stopped \
    --name marker-pdf \
    marker-pdf

echo "Marker PDF API est en cours d'exécution sur http://localhost:8000"
echo "Documentation API: http://localhost:8000/docs"