# Étape de build
FROM node:20-alpine3.19 as build-stage

# Définition du répertoire de travail
WORKDIR /app

# Copie des fichiers source
COPY . .

# Définition des variables d'environnement
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# Installation des dépendances
RUN npm install

# Build de l'application
RUN npm run build

# Étape de production avec Nginx
FROM nginx:stable-alpine as production-stage

# Copie des fichiers de build depuis l'étape précédente
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Exposition du port 80
EXPOSE 80

# Démarrage de Nginx
CMD ["nginx", "-g", "daemon off;"]