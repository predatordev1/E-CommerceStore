FROM node:24-alpine3.22

WORKDIR /app

COPY package.json package-lock.json* ./

RUN npm ci || npm install --production

COPY . .

ENV PORT=3004
ENV MONGODB_URI='mongodb://localhost:27017/ecommerce_carts'
EXPOSE 3004

CMD ["node", "app.js"]
