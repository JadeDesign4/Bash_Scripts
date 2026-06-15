#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        scaffold-backend-app.sh
# TARGET:      Backend Developers, Sysadmins, & Power Users
# DESCRIPTION: Instantly scaffolds a standardized backend directory structure 
#              with placeholder files, templates, and sample configs.
# PROBLEM:     Manually setting up directory trees, configs, and dummy files for 
#              new microservices or local testing boilerplate is slow and repetitive.
# USAGE:       ./scaffold-backend-app.sh [ProjectName]
# ==============================================================================

# Default project name if none provided
PROJECT_NAME="${1:-backend-boilerplate}"

echo "🚀 Initiating Backend Scaffolding for: $PROJECT_NAME"
echo "--------------------------------------------------"

# 1. Create the base and nested directories
directories=(
    "$PROJECT_NAME/config"
    "$PROJECT_NAME/src/controllers"
    "$PROJECT_NAME/src/models"
    "$PROJECT_NAME/src/routes"
    "$PROJECT_NAME/src/middleware"
    "$PROJECT_NAME/tests"
    "$PROJECT_NAME/logs"
)

echo "📁 Creating directory structure..."
for dir in "${directories[@]}"; do
    mkdir -p "$dir"
    echo "   Created: $dir"
done

# 2. Populate template/placeholder files
echo "📝 Populating template and configuration files..."

# Create a sample config JSON
cat <<EOF > "$PROJECT_NAME/config/default.json"
{
  "app": {
    "name": "$PROJECT_NAME",
    "port": 5000,
    "environment": "development"
  },
  "database": {
    "host": "127.0.0.1",
    "port": 5432,
    "name": "dev_db"
  }
}
EOF

# Create a standard .env.example
cat <<EOF > "$PROJECT_NAME/.env.example"
# Application Configuration
PORT=5000
NODE_ENV=development

# Database Settings
DB_HOST=127.0.0.1
DB_PORT=5432
DB_NAME=dev_db
DB_USER=root
DB_PASSWORD=secret_password
EOF

# Create an entry point boilerplate
cat <<EOF > "$PROJECT_NAME/src/app.js"
// Auto-generated backend application entry point
const express = require('express');
const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());

app.get('/health', (req, res) => {
    res.status(200).json({ status: "UP", timestamp: new Date() });
});

app.listen(PORT, () => {
    console.log(\`🚀 Server running smoothly on port \${PORT}\`);
});
EOF

# Create a basic gitignore
cat <<EOF > "$PROJECT_NAME/.gitignore"
.env
logs/
*.log
node_modules/
.DS_Store
EOF

echo "--------------------------------------------------"
echo "✅ Success! Project '$PROJECT_NAME' scaffolded beautifully."
echo "💡 Next steps: 'cd $PROJECT_NAME', edit '.env.example', and start coding!"