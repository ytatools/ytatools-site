# Tiltfile for YTA-tools Hugo site local development

# Load environment variables from .env file (required)
if not os.path.exists('.env'):
    fail('.env file is required for Tilt development. Copy .env.example to .env and configure it.')

# Read .env file line by line
dotenv_content = str(read_file('.env'))
for line in dotenv_content.split('\n'):
    line = line.strip()
    if line and '=' in line and not line.startswith('#'):
        key, value = line.split('=', 1)
        os.putenv(key.strip(), value.strip())

# Build the Docker image and track file changes
docker_build(os.getenv('CONTAINER_NAME') + ':' + os.getenv('IMAGE_TAG'), '.', 
    live_update=[
        sync('./layouts', '/src/layouts'),
        sync('./assets', '/src/assets'),
        sync('./data', '/src/data'),
        sync('./static', '/src/static'),
        sync('./config.development.toml', '/src/config.development.toml'),
        run('cd /src && hugo --gc --minify --config config.development.toml -d /usr/share/nginx/html', trigger=['./layouts', './assets', './data', './static', './config.development.toml'])
    ]
)

# Load docker-compose and manage the app service
docker_compose('docker-compose.yml')
dc_resource('app')

# Install npm dependencies first
local_resource('npm-install',
    cmd='npm install',
    deps=['./package.json']
)

# Watch for changes in source files and rebuild Hugo
local_resource('hugo-build',
    cmd='npm run build:dev',
    deps=['./layouts', './assets', './data', './static', './config.development.toml'],
    ignore=['./public'],
    resource_deps=['npm-install']
)

# Run TailwindCSS in watch mode for CSS changes
local_resource('tailwind-watch',
    serve_cmd='mkdir -p ./static/css && npx tailwindcss -i ./assets/css/main.css -o ./static/css/main.css --watch',
    deps=['./assets/css', './tailwind.config.js'],
    resource_deps=['npm-install']
)