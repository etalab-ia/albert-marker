FROM nvidia/cuda:12.1.0-base-ubuntu22.04

# Définir les variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV TORCH_DEVICE=cuda

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    build-essential \
    git \
    wget \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Créer le répertoire pour les uploads
RUN mkdir -p /app/uploads
WORKDIR /app

# Installer les dépendances Python
RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip3 install --no-cache-dir marker-pdf[full] uvicorn fastapi python-multipart

# Copier le code de l'API
COPY api.py /app/api.py

# Exposer le port pour l'API
EXPOSE 8000

# Commande par défaut pour démarrer l'API
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"]