#!/bin/bash
REGION="northamerica-northeast1"
#PROJECT_ID="ift6758-asn-development"
PROJECT_ID="my-project-canelle"

# Voici le service que vous allez déployer.
SERVICE_NAME="backend-v2"
# Mettez ici votre URI d'image correspondant au service ci-dessus.
IMAGE_URI="northamerica-northeast1-docker.pkg.dev/my-project-canelle/my-artifacts/backend_v2:b790be0c-31c4-4691-9834-076e95bcff23"

# REMARQUE : Des valeurs par défaut sont définies pour la mémoire et le CPU
# mais vous devrez peut-être les changer.

gcloud run deploy $SERVICE_NAME\
    --region=${REGION} \
    --image=${IMAGE_URI} \
    --min-instances=1 \
    --max-instances=1 \
    --memory=4Gi \
    --cpu=2 \
    --allow-unauthenticated \
    --set-env-vars="SERVING_PORT=8080" 

# REMARQUE : Dans un environnement de production, nous ne souhaiterons peut-être pas
# permettre à n'importe qui d'accéder à nos service(s). Pour les
# besoins de cet exercice, il est acceptable qu'il
# soit accessible publiquement.
