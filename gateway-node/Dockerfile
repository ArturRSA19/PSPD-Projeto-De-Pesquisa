FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --production || npm install --production
COPY src ./src
COPY public ./public
COPY proto ./proto
ENV PORT=8080
RUN addgroup -S app && adduser -S app -G app
USER app
EXPOSE 8080
CMD ["npm", "start"]
