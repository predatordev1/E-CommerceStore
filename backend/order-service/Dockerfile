FROM node:24-alpine3.22

WORKDIR /app

COPY package.json package-lock.json* ./

RUN npm ci || npm install --production

COPY . .

ENV PORT=3004
ENV MONGODB_URI=mongodb://localhost:27017/ecommerce_orders
ENV CART_SERVICE_URL=http://localhost:3003
ENV PRODUCT_SERVICE_URL=http://localhost:3002
ENV USER_SERVICE_URL=http://localhost:3001



EXPOSE 3004

CMD ["node", "server.js"]
