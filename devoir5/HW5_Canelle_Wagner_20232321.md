# HW5 Réponses courtes


**Name:** Canelle Wagner

**Matricule \#:** 20232321

**Veuillez écrire vos réponses courtes ci-dessous et les inclure dans votre soumission de gradescope.**

**Le titre du rapport doit être HW5_{Votre_Nom}\_{Matricule_\#}**


## Question 2
À chaque soumission de build, deux images Docker sont construites :

- L'image de base.
- L'image cible (backend_v1 ou autres composants, selon le fichier YAML).

Ce n'est pas obligatoire de procéder de cette façon parce que par exemple lorsqu'on crée backend_v2, on réutilise la même image de base, ce qui rajoute une étape supplémentaire inutile qui prend un peu de temps. 

Pour éviter de reconstruire à chaque fois l'image de base, on peut rajouter une étape pull pour récupérer l'image de base si elle existe déjà et qu'elle n'a pas changée, au début du code de chaque fichier .yaml.

 ```
# Pour les ficheir backend_v1 et pour backend_v2
  - name: 'gcr.io/cloud-builders/docker'
    id: 'pull-backend-base-image'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        docker pull northamerica-northeast1-docker.pkg.dev/my-project-canelle/my-artifacts/backend-base:latest || exit 0

## --> Rajouter cette ligne de code dans build-backend-base-image
- --cache-from=northamerica-northeast1-docker.pkg.dev/my-project-canelle/my-artifacts/backend-base:latest
      



# Pour les ficheir frontend_v1 et pour frontend_v2
  - name: 'gcr.io/cloud-builders/docker'
    id: 'pull-frontend-base-image'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        docker pull northamerica-northeast1-docker.pkg.dev/my-project-canelle/my-artifacts/frontend-base:latest || exit 0

## --> Rajouter cette ligne de code dans build-frontend-base-image
- --cache-from=northamerica-northeast1-docker.pkg.dev/my-project-canelle/my-artifacts/frontend-base:latest
      
```

## Question 4
Pour contourner le téléchargement du modèle ResNet depuis le PyTorch Hub lors du déploiement de backend_v1, nous pouvons pré-télécharger le modèle lors de la construction de l'image Docker. 

Nous pouvons modifier le Dockerfile pour inclure une étape qui télécharge le modèle ResNet et l'intègre directement dans l'image. Cela augmentera la taille de l'image mais réduira le temps de démarrage de l'application, car le modèle n'aura pas besoin d'être téléchargé à chaque déploiement.

L'intégration du modèle dans l'image Docker prolongera le temps de build, car le modèle doit être téléchargé et stocké dans l'image (une image plus grande).

## Question 5

**Avantages :**

- Maintenance et Mises à jour : Les mises à jour peuvent être effectuées sur un service sans perturber l'autre, ce qui facilite la maintenance et le déploiement continu.
- Séparation des "tâches"" : Dans un cadre professionnel, c'est généralement des équipes différentes qui gère le frontend et backend. Le principe de séparation des "tâches"", permet aux équipes de se concentrer sur leurs domaines spécifiques (frontend ou backend) sans interférence.

**Inconvénients :**
- Complexité de Gestion : Gérer deux déploiements distincts est un peu plus complexe en termes de configuration, de surveillance et de débogage.
- Latence de Communication : Le fait de séparer les deux oblige  les équipes de frontend et backend de bien communiquer, ce qui peut prendre plus de temps. Mais le problème ne se pose pas si c'est la même équipe que implémente des deux. 

## Question 7

**backend_v1**

Ici, l'utilisation d'une variable globale model pour charger ResNet152 ne pose pas vraiment de problème. C'est parce qu'on a un seul modèle qui ne change pas. Donc, le charger une fois au démarrage est efficace et simplifie les choses. Chaque requête de prédiction utilise ce même modèle déjà en mémoire, ce qui est super pour la performance et la simplicité du code.

**backend_v2**

Par contre, dans backend_v2, la situation est différente. On a la possibilité de changer de modèle en cours de route. Si deux personnes utilisent l'app en même temps et que l'une d'elles change le modèle, ça pourrait affecter la prédiction de l'autre, car ils partagent la même variable globale model. Cela peut créer des conflits et des incohérences dans les résultats, surtout si les modèles sont changés fréquemment. Cela pose des défis en termes de gestion des ressources et de maintien de la précision des prédictions.

### Solutions

**Dans le Frontend**

Gérer les sessions utilisateur dans le frontend avec Flask :
Utiliser les sessions Flask pour stocker des informations spécifiques à chaque utilisateur, comme l'ID du modèle actuellement utilisé. Cela permet de maintenir un état cohérent pour chaque utilisateur tout au long de leur interaction avec l'application.


Sécurisation des Sessions :
Nous nouvons aussi réglé le problème en assurant la sécurité des sessions en configurant correctement la clé secrète et en utilisant des cookies sécurisés. 


**Dans le Backend**

Pour le backend_v2, qui permet de changer de modèle dynamiquement :
Au lieu de stocker le modèle dans une variable globale, nous pouvons charger le modèle à chaque requête. Cela peut augmenter la latence, mais garantit que la bonne version du modèle est utilisée pour chaque prédiction.

Mais il faut aussi tenir compte du fait que charger des modèles différents pour chaque requête peut être coûteux en termes de performance. Une meilleure approche pourrait être de limiter les options de modèle ou de conserver plusieurs modèles chargés simultanément, mais il faut garder en tête que cela consomme des ressources. Avoir plusieurs modèles lourds en mémoire dans le même conteneur peut ne pas être idéal.

## Question 8

**Objectif de v3**


- Backend Flexible : La version v3 du backend est conçue pour être plus flexible. Elle utilise une variable d'environnement MODEL_NAME pour choisir quel modèle de machine learning charger. C'est une amélioration par rapport aux versions précédentes, car ça permet de changer le modèle plus facilement.
- Frontend Interactif avec Streamlit :
Pour le frontend, v3 utilise Streamlit, qui est un super outil pour créer des applications web interactives. Le frontend communique avec le backend en envoyant des requêtes pour obtenir des prédictions sur des images.
- API Gateway pour la Simplicité :
v3 semble utiliser un API Gateway, indiqué par la variable API_GATEWAY. C'est comme un guichet unique qui gère toutes les requêtes envoyées au backend. Ça simplifie les choses, notamment la gestion des différentes requêtes et la sécurisation de l'accès aux services (Il peut offrir des fonctionnalités telles que la sécurisation des requêtes, la gestion du trafic, l'authentification, etc.).


**Différences avec les versions précédentes**

- Changement de Modèle en Temps Réel :
Contrairement aux versions précédentes, backend_v3 permet de changer le modèle en temps réel via une variable d'environnement, ce qui donne plus de contrôle sur le modèle utilisé pour les prédictions.
- Utilisation d'API Gateway dans le Frontend :
Le frontend_v3 semble préparé pour intégrer un API Gateway, ce qui est différent des versions précédentes où le frontend communiquait directement avec le backend. Cela peut améliorer la gestion des requêtes et la sécurité.
- Architecture Plus Évolutive et Sécurisée :
L'intégration d'un API Gateway suggère une orientation vers une architecture plus évolutive et sécurisée, permettant de mieux gérer les différentes requêtes et de répartir la charge entre plusieurs services backend si nécessaire.
L'introduction d'un API Gateway dans v3 c'est un peu comme avoir une tour de contrôle pour toutes les requêtes entre le frontend et le backend. 