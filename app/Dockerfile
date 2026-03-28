# --- ETAPA 1: Construcción (Builder) ---
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Copiamos solo los archivos de dependencias primero para aprovechar el caché de Docker
COPY package*.json ./
# Instalamos TODAS las dependencias (si tuvieras dependencias de desarrollo, irían aquí)
RUN npm install

# Copiamos el resto del código
COPY . .


# --- ETAPA 2: Producción (Ligera y Segura) ---
FROM node:18-alpine

# Buena práctica de seguridad: No correr la app como root
USER node
WORKDIR /usr/src/app

# Solo copiamos los módulos de node ya instalados y el código fuente desde la etapa anterior
COPY --from=builder --chown=node:node /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=node:node /usr/src/app/server.js ./
COPY --from=builder --chown=node:node /usr/src/app/public ./public

EXPOSE 3000

CMD ["node", "server.js"]