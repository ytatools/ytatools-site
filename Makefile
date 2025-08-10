SHELL := /bin/bash

setup:
	@echo "🔧 Installing development dependencies..."
	@npm install
	@echo "🔧 Creating Traefik external network if missing..."
	@docker network inspect traefik >/dev/null 2>&1 || docker network create traefik
	@echo "✅ Done."

build:
	@echo "🏗️  Building Docker image..."
	@docker compose build

run:
	@echo "🚀 Starting with docker compose..."
	@docker compose up -d
	@docker compose ps

clean:
	@echo "🧹 Stopping and removing containers..."
	@docker compose down
	@echo "🗑️  Optionally prune dangling images with: docker image prune -f"
