# Marker PDF API avec Docker

Ce projet permet de déployer l'API Marker PDF dans un conteneur Docker pour traiter des documents PDF à distance à l'aide d'OCR et de parsing automatisé, optimisé pour fonctionner sur une VM Ubuntu avec GPU H100.

## Prérequis

- Ubuntu (testé avec Ubuntu 22.04)
- Docker
- Docker Compose (optionnel)
- NVIDIA Container Toolkit (pour utiliser le GPU)

## Installation des prérequis

### Docker

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
```

### Docker Compose

```bash
sudo apt-get install -y docker-compose-plugin
```

### NVIDIA Container Toolkit (pour GPU)

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

## Structure du projet

```
.
├── Dockerfile           # Configuration pour construire l'image Docker
├── api.py               # Code de l'API FastAPI pour Marker PDF
├── docker-compose.yml   # Configuration Docker Compose
├── run.sh               # Script pour construire et lancer le conteneur
└── shared/              # Dossier partagé entre l'hôte et le conteneur
```

## Déploiement

1. Clonez ce dépôt sur votre VM Ubuntu:

```bash
git clone https://votre-depot/marker-pdf-docker.git
cd marker-pdf-docker
```

2. Créez le dossier partagé:

```bash
mkdir -p shared
```

3. Rendez le script d'exécution exécutable:

```bash
chmod +x run.sh
```

4. Déployez avec Docker Compose:

```bash
docker compose up -d
```

Ou utilisez le script run.sh:

```bash
./run.sh
```

5. Vérifiez que le service est en cours d'exécution:

```bash
docker ps
```

L'API est maintenant accessible à l'adresse `http://IP-DE-VOTRE-VM:8000`.

## Utilisation de l'API

### Interface interactive

Accédez à `http://IP-DE-VOTRE-VM:8000/docs` pour utiliser l'interface Swagger interactive de l'API.

### Conversion d'un PDF via téléchargement

Vous pouvez télécharger un fichier PDF via l'endpoint `/marker/upload`:

```bash
curl -X 'POST' \
  'http://IP-DE-VOTRE-VM:8000/marker/upload' \
  -H 'accept: application/json' \
  -H 'Content-Type: multipart/form-data' \
  -F 'file=@votre-fichier.pdf' \
  -F 'output_format=markdown' \
  -F 'force_ocr=true'
```

### Conversion d'un PDF depuis le dossier partagé

1. Placez votre fichier PDF dans le dossier `shared/` sur la machine hôte
2. Appelez l'endpoint `/marker` avec le chemin relatif:

```bash
curl -X 'POST' \
  'http://IP-DE-VOTRE-VM:8000/marker' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
    "filepath": "/app/shared/votre-fichier.pdf",
    "output_format": "markdown",
    "force_ocr": true
  }'
```

## Options de conversion

Voici les principales options disponibles lors de la conversion:

- `filepath`: Chemin du fichier à convertir (obligatoire pour l'endpoint `/marker`)
- `page_range`: Plage de pages à convertir (ex: "0,5-10,20")
- `languages`: Liste des langues pour l'OCR séparées par des virgules (ex: "fr,en")
- `force_ocr`: Force l'OCR sur toutes les pages (booléen)
- `paginate_output`: Pagine la sortie (booléen)
- `output_format`: Format de sortie ("markdown", "json", ou "html")
- `use_llm`: Utilise un LLM pour améliorer la précision (booléen, nécessite une clé API)

## Exemple d'application cliente Python

Voici un exemple simple d'application cliente Python pour interagir avec l'API:

```python
import requests
import json
import os

API_URL = "http://IP-DE-VOTRE-VM:8000"

def upload_and_convert_pdf(pdf_path, output_format="markdown", force_ocr=True):
    """Télécharger et convertir un fichier PDF"""
    with open(pdf_path, 'rb') as file:
        files = {'file': (os.path.basename(pdf_path), file, 'application/pdf')}
        data = {
            'output_format': output_format,
            'force_ocr': str(force_ocr).lower(),
        }
        response = requests.post(f"{API_URL}/marker/upload", files=files, data=data)
    
    if response.status_code == 200:
        result = response.json()
        if result.get('success', False):
            return result
        else:
            print(f"Erreur: {result.get('error')}")
            return None
    else:
        print(f"Erreur HTTP: {response.status_code}")
        return None

# Exemple d'utilisation
result = upload_and_convert_pdf("votre-document.pdf")
if result:
    print(result['output'])
    # Enregistrer le résultat dans un fichier
    with open("resultat.md", "w") as f:
        f.write(result['output'])
```

## Configuration supplémentaire

### Utiliser un LLM pour améliorer la qualité

Pour utiliser un LLM (comme Gemini, Claude, etc.) afin d'améliorer la qualité du parsing:

1. Ajoutez la clé API appropriée comme variable d'environnement dans docker-compose.yml:

```yaml
environment:
  - TORCH_DEVICE=cuda
  - GOOGLE_API_KEY=votre-cle-api  # Pour Gemini
  # OU
  - CLAUDE_API_KEY=votre-cle-api  # Pour Claude
```

2. Activez l'option `use_llm` lors de l'appel API.

### Optimisation des performances

Pour les fichiers volumineux ou pour traiter plusieurs documents simultanément, vous pouvez ajuster les paramètres suivants:

1. Modifiez le nombre de workers dans api.py:

```python
config_dict["pdftext_workers"] = 4  # Augmentez selon votre CPU
```

2. Ajustez les ressources allouées au conteneur dans docker-compose.yml:

```yaml
deploy:
  resources:
    limits:
      cpus: '4'
      memory: 16G
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

## Dépannage

### Problèmes de GPU

Vérifiez que le GPU est correctement détecté dans le conteneur:

```bash
docker exec -it marker-pdf nvidia-smi
```

### Logs du conteneur

Pour voir les logs:

```bash
docker logs marker-pdf
```

### Redémarrage du service

```bash
docker compose down
docker compose up -d
```

ou

```bash
docker restart marker-pdf
```

## Références

- [Documentation de Marker PDF](https://github.com/VikParuchuri/marker)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)