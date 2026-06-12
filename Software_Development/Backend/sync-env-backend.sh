#!/usr/bin/env bash

# Description: Compares .env.example with .env and appends missing keys.
# Target: Backend Developers / Power Users

EXAMPLE_FILE=".env.example"
ENV_FILE=".env"

# 1. Check if .env.example exists
if [ ! -f "$EXAMPLE_FILE" ]; then
    echo "❌ Error: $EXAMPLE_FILE not found in the current directory."
    exit 1
fi

# 2. If .env doesn't exist at all, create it from the example
if [ ! -f "$ENV_FILE" ]; then
    echo "⚠️  $ENV_FILE missing. Creating it from $EXAMPLE_FILE..."
    cp "$EXAMPLE_FILE" "$ENV_FILE"
    echo "✅ Created $ENV_FILE successfully."
    exit 0
fi

echo "🔄 Comparing environment files..."
MISSING_KEYS=0

# 3. Read .env.example line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Strip carriage returns (Windows compatibility)
    line=$(echo "$line" | tr -d '\r')

    # Skip empty lines and comments
    if [[ -z "$line" || "$line" =~ ^# ]]; then
        continue
    fi

    # Extract the key name (everything before the first '=')
    key=$(echo "$line" | cut -d'=' -f1)

    # Check if the key exists in the current .env file
    if ! grep -q "^${key}=" "$ENV_FILE"; then
        echo "➕ Appending missing key: $key"
        echo "$line" >> "$ENV_FILE"
        ((MISSING_KEYS++))
    fi
done < "$EXAMPLE_FILE"

# 4. Final summary
if [ "$MISSING_KEYS" -eq 0 ]; then
    echo "🎉 Your $ENV_FILE is fully up to date with $EXAMPLE_FILE!"
else
    echo "✅ Successfully added $MISSING_KEYS missing variable(s) to $ENV_FILE."
fi
