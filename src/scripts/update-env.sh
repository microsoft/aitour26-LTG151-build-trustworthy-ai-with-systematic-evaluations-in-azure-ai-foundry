#!/bin/bash

# Usage: ./update-env.sh <resource-group-name>
# This script fetches Azure resource values and populates a .env file.

RESOURCE_GROUP="$1"
# Get the script directory and set ENV_FILE to root of repo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../../.env"
ENV_SAMPLE="$SCRIPT_DIR/../../.env.sample"

if [ -z "$RESOURCE_GROUP" ]; then
  echo "Usage: $0 <resource-group-name>"
  exit 1
fi

# Copy .env.sample to .env if .env doesn't exist
if [ ! -f "$ENV_FILE" ]; then
  if [ -f "$ENV_SAMPLE" ]; then
    echo "Copying .env.sample to .env..."
    cp "$ENV_SAMPLE" "$ENV_FILE"
  else
    echo "Warning: .env.sample not found. Creating new .env file..."
  fi
fi

echo "Fetching Azure resource values for resource group: $RESOURCE_GROUP"

# Get Subscription ID
SUBSCRIPTION_ID=$(az group show --name "$RESOURCE_GROUP" --query "id" -o tsv | cut -d'/' -f3)

# Get AI Foundry Hub resource name (the CognitiveServices account that hosts projects)
AI_FOUNDRY_NAME=$(az cognitiveservices account list --resource-group "$RESOURCE_GROUP" --query "[?kind=='AIServices' || kind=='OpenAI'].name | [0]" -o tsv)

# Get AI Project name (the project nested under the AI Foundry hub)
AI_PROJECT_FULL=$(az resource list --resource-group "$RESOURCE_GROUP" --resource-type "Microsoft.CognitiveServices/accounts/projects" --query "[0].name" -o tsv)
# Extract just the project name (after the /)
AI_PROJECT_NAME="${AI_PROJECT_FULL##*/}"

# Get OpenAI endpoint, API version, and API key
# Look for Azure AI Services or OpenAI service
OPENAI_RESOURCE=$(az cognitiveservices account list --resource-group "$RESOURCE_GROUP" --query "[?kind=='AIServices' || kind=='OpenAI'].name | [0]" -o tsv)
if [ -z "$OPENAI_RESOURCE" ]; then
  echo "Warning: No Azure OpenAI resource found. Trying alternate query..."
  OPENAI_RESOURCE=$(az cognitiveservices account list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv)
fi

# Get the endpoint in format: https://<resource-name>.openai.azure.com/
OPENAI_ENDPOINT=$(az cognitiveservices account show --name "$OPENAI_RESOURCE" --resource-group "$RESOURCE_GROUP" --query "properties.endpoint" -o tsv)

# Ensure endpoint has proper format (https:// and trailing /)
if [ -n "$OPENAI_ENDPOINT" ]; then
  # Add https:// if not present
  if [[ ! "$OPENAI_ENDPOINT" =~ ^https?:// ]]; then
    OPENAI_ENDPOINT="https://${OPENAI_ENDPOINT}"
  fi
  # Add trailing slash if not present
  if [[ ! "$OPENAI_ENDPOINT" =~ /$ ]]; then
    OPENAI_ENDPOINT="${OPENAI_ENDPOINT}/"
  fi
fi

# Try to get API key - if it fails, leave it empty
OPENAI_API_KEY=$(az cognitiveservices account keys list --name "$OPENAI_RESOURCE" --resource-group "$RESOURCE_GROUP" --query "key1" -o tsv 2>/dev/null)
if [ -z "$OPENAI_API_KEY" ]; then
  echo "Warning: Could not retrieve API key automatically. You may need to retrieve it manually from the Azure Portal."
  OPENAI_API_KEY="<retrieve-from-portal>"
fi

OPENAI_API_VERSION="2025-02-01-preview"

# Get AI Search endpoint and index name
AISEARCH_RESOURCE=$(az resource list --resource-group "$RESOURCE_GROUP" --resource-type "Microsoft.Search/searchServices" --query "[0].name" -o tsv)
AISEARCH_ENDPOINT="https://${AISEARCH_RESOURCE}.search.windows.net/"
AISEARCH_INDEX="zava-products"

# Model deployment info (from README)
OPENAI_DEPLOYMENT="gpt-4.1"
OPENAI_MODEL_VERSION="2025-04-14"

# Data file path
AISEARCH_DATAFILE="data/products.csv"

# Function to update or add env variable
update_env_var() {
  local key="$1"
  local value="$2"
  
  if grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
    # Update existing variable (works on both macOS and Linux)
    sed -i.bak "s|^${key}=.*|${key}=\"${value}\"|" "$ENV_FILE" && rm -f "${ENV_FILE}.bak"
  else
    # Add new variable
    echo "${key}=\"${value}\"" >> "$ENV_FILE"
  fi
}

# Update all environment variables
update_env_var "AZURE_SUBSCRIPTION_ID" "$SUBSCRIPTION_ID"
update_env_var "AZURE_RESOURCE_GROUP" "$RESOURCE_GROUP"
update_env_var "AZURE_OPENAI_API_KEY" "$OPENAI_API_KEY"
update_env_var "AZURE_OPENAI_ENDPOINT" "$OPENAI_ENDPOINT"
update_env_var "AZURE_OPENAI_API_VERSION" "$OPENAI_API_VERSION"
update_env_var "AZURE_AI_FOUNDRY_NAME" "$AI_FOUNDRY_NAME"
update_env_var "AZURE_AI_PROJECT_NAME" "$AI_PROJECT_NAME"
update_env_var "AZURE_OPENAI_DEPLOYMENT" "$OPENAI_DEPLOYMENT"
update_env_var "AZURE_OPENAI_MODEL_VERSION" "$OPENAI_MODEL_VERSION"
update_env_var "AZURE_AISEARCH_DATAFILE" "$AISEARCH_DATAFILE"
update_env_var "AZURE_AISEARCH_ENDPOINT" "$AISEARCH_ENDPOINT"
update_env_var "AZURE_AISEARCH_INDEX" "$AISEARCH_INDEX"

echo ".env file updated at: $ENV_FILE"
echo "Successfully populated values from resource group: $RESOURCE_GROUP"
