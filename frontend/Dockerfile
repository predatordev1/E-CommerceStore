FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
ARG REACT_APP_USER_SERVICE_URL=http://localhost:3001
ARG REACT_APP_PRODUCT_SERVICE_URL=http://localhost:3002
ARG REACT_APP_CART_SERVICE_URL=http://localhost:3003
ARG REACT_APP_ORDER_SERVICE_URL=http://localhost:3004
RUN npm run build

FROM nginx:1.27-alpine AS production
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
