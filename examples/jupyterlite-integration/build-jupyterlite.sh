#!/bin/bash
set -e

# Build JupyterLite with jupyterlite-ai pre-installed
# This creates a static site you can serve locally or deploy

echo "🚀 Building JupyterLite with jupyterlite-ai..."
echo ""

# Create build directory
BUILD_DIR="jupyterlite-build"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR/content

# Create requirements file with jupyterlite-ai
cat > $BUILD_DIR/content/requirements.txt << EOF
jupyterlite-ai
ipywidgets
EOF

# Create a sample notebook explaining how to configure
cat > $BUILD_DIR/content/configure-ai.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Configure jupyterlite-ai with any-llm-gateway\n",
    "\n",
    "Follow these steps to connect to your any-llm-gateway:\n",
    "\n",
    "## Step 1: Open Settings\n",
    "\n",
    "Go to **Settings** → **Settings Editor** in the top menu\n",
    "\n",
    "## Step 2: Find Jupyter AI Settings\n",
    "\n",
    "Search for \"Jupyter AI\" in the settings search box\n",
    "\n",
    "## Step 3: Add Generic Provider\n",
    "\n",
    "Under \"Model Providers\", add a new provider with:\n",
    "\n",
    "```json\n",
    "{\n",
    "  \"baseURL\": \"http://localhost:3000/v1\",\n",
    "  \"apiKey\": \"Bearer YOUR_API_KEY_HERE\",\n",
    "  \"model\": \"openai:gpt-4\"\n",
    "}\n",
    "```\n",
    "\n",
    "Replace `YOUR_API_KEY_HERE` with your actual API key from any-llm-gateway.\n",
    "\n",
    "## Step 4: Test\n",
    "\n",
    "Try typing code in a new notebook - AI suggestions should appear!\n",
    "\n",
    "Or use the AI chat icon in the left sidebar."
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
EOF

# Install JupyterLite and dependencies if not already installed
echo "📦 Installing JupyterLite..."
pip install -q jupyterlite-core jupyterlite-pyodide-kernel jupyter-server 2>/dev/null || {
    echo "Installing JupyterLite locally..."
    python -m pip install jupyterlite-core jupyterlite-pyodide-kernel jupyter-server
}

# Build JupyterLite
echo "🔨 Building JupyterLite site..."
cd $BUILD_DIR
jupyter lite build --contents content --output-dir dist

echo ""
echo "✅ Build complete!"
echo ""
echo "📂 JupyterLite site built in: $BUILD_DIR/dist"
echo ""
echo "To serve locally:"
echo "  cd $BUILD_DIR/dist"
echo "  python -m http.server 8080"
echo ""
echo "Then open: http://localhost:8080"
echo ""
echo "jupyterlite-ai will be pre-installed and ready to configure!"
