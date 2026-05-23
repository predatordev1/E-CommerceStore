FROM node:24-alpine3.22

WORKDIR /app

COPY package.json package-lock.json* ./

RUN npm ci || npm install --production

COPY . .

ENV PORT=3003
ENV MONGODB_URI=mongodb://localhost:27017/ecommerce_carts
ENV PRODUCT_SERVICE_URL=http://localhost:3002
EXPOSE 3003

CMD ["node", "server.js"]
