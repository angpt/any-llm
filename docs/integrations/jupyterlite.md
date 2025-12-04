# JupyterLite Integration

Configure jupyterlite-ai to use any-llm-gateway for cost tracking and multi-provider support.

## Quick Start

### 1. Start Gateway

```bash
docker-compose -f docker/docker-compose.yml up -d
curl http://localhost:8000/health
```

### 2. Create API Key

```bash
cd examples/jupyterlite-integration
./setup.sh
# Save the API key output
```

### 3. Configure jupyterlite-ai

**Option A: Use official demo**
- Visit https://jupyterlite.github.io/ai/lab/index.html
- Note: Will have CORS issues with localhost - use ngrok or build locally

**Option B: Build locally (recommended)**
```bash
cd examples/jupyterlite-integration
./build-jupyterlite.sh
cd jupyterlite-build/dist
python -m http.server 8080
# Open http://localhost:8080
```

### 4. Add Provider

In JupyterLite:
1. Settings → Settings Editor → "JupyterLite AI Settings"
2. Providers → "+" → Add provider:

```json
{
  "baseURL": "http://localhost:8000/v1",
  "apiKey": "gw-your-key-here",
  "model": "openai:gpt-4",
  "headers": {
    "X-AnyLLM-Key": "Bearer gw-your-key-here"
  }
}
```

### 5. Test

Create a notebook and start typing - AI suggestions should appear.

Check usage:
```bash
curl http://localhost:8000/v1/users/USER_ID \
  -H "X-AnyLLM-Key: Bearer YOUR_MASTER_KEY"
```

## Configuration

### Supported Models

Use format: `provider:model-name`

```
openai:gpt-4
anthropic:claude-3-5-sonnet-20241022
gemini:gemini-1.5-pro
mistral:mistral-large-latest
```

### Multiple Providers

```json
[
  {
    "id": "gpt4",
    "baseURL": "http://localhost:8000/v1",
    "apiKey": "gw-key-1",
    "model": "openai:gpt-4",
    "headers": {"X-AnyLLM-Key": "Bearer gw-key-1"}
  },
  {
    "id": "claude",
    "baseURL": "http://localhost:8000/v1",
    "apiKey": "gw-key-2",
    "model": "anthropic:claude-3-5-sonnet-20241022",
    "headers": {"X-AnyLLM-Key": "Bearer gw-key-2"}
  }
]
```

## Troubleshooting

### 401 Unauthorized

**Cause:** Missing `X-AnyLLM-Key` header

**Fix:** Add custom header in provider config (see Step 4 above)

### CORS Errors

**Cause:** Browser blocks HTTPS→HTTP requests (online demo → localhost)

**Fix:**
- Use ngrok: `ngrok http 8000` then use the HTTPS URL
- Or build locally (both on localhost, no CORS)

### Connection Refused

Check gateway is running:
```bash
docker ps
curl http://localhost:8000/health
```

## Production Deployment

### Deploy JupyterLite

GitHub Pages:
```yaml
# .github/workflows/deploy.yml
name: Deploy JupyterLite
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - run: pip install jupyterlite-core jupyterlite-pyodide-kernel
      - run: jupyter lite build --contents content --output-dir dist
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./dist
```

### Deploy Gateway with HTTPS

Configure CORS headers in Nginx:
```nginx
server {
    listen 443 ssl http2;
    server_name gateway.yourdomain.com;

    location / {
        proxy_pass http://localhost:8000;

        add_header Access-Control-Allow-Origin "https://yourusername.github.io" always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-AnyLLM-Key" always;

        if ($request_method = 'OPTIONS') {
            return 204;
        }
    }
}
```

### Production Config

```json
{
  "baseURL": "https://gateway.yourdomain.com/v1",
  "apiKey": "gw-production-key",
  "model": "openai:gpt-4",
  "headers": {
    "X-AnyLLM-Key": "Bearer gw-production-key"
  }
}
```

## Architecture

```
Browser (JupyterLite)
    ↓ POST /v1/chat/completions
    ↓ X-AnyLLM-Key: Bearer xxx
any-llm-gateway
    ↓ Validates key
    ↓ Tracks usage/cost
    ↓ Routes request
OpenAI / Claude / Gemini
```

## Scripts

- `examples/jupyterlite-integration/setup.sh` - Create user and API key
- `examples/jupyterlite-integration/build-jupyterlite.sh` - Build local JupyterLite

## Links

- [JupyterLite AI Demo](https://jupyterlite.github.io/ai/lab/index.html)
- [jupyterlite-ai GitHub](https://github.com/jupyterlite/ai)
- [JupyterLite Docs](https://jupyterlite.readthedocs.io/)
