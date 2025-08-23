FROM hugomods/hugo:debian-exts AS build
WORKDIR /site

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm ci || npm install

# Copy source files
COPY . .

# Accept BASE_URL as build argument
ARG BASE_URL=https://localhost

# Substitute environment variables in production config
RUN sed "s|\${BASE_URL}|${BASE_URL}|g" config/production/hugo.toml > config/production/hugo.toml.tmp && \
    mv config/production/hugo.toml.tmp config/production/hugo.toml

# Build the site with production environment
RUN hugo --gc --minify --environment production

FROM caddy:2.8
COPY --from=build /site/public /usr/share/caddy
