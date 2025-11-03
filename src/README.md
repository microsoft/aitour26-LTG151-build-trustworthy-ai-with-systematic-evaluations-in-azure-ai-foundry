# Build trustworthy AI with systematic evaluations in Azure AI Foundry

Welcome to the train-the-trainer materials for LTG151. This is a 15-min theater session that teaches AI developers to build trustworthy AI with systematic evaluations in Azure AI Foundry.

## Pre-Requisites

To run the demos for this session you will need:

1. A personal GitHub account (to run GitHub Codespaces)
1. An Azure subscription (to host the Azure AI Foundry project)
1. An Azure AI Search service resource ([see supported regions](https://learn.microsoft.com/en-us/azure/search/search-region-support#azure-public-regions))
1. An LLM to serve as a "judge" for evaluations (e.g., gpt-4o)
1. All the [pre-requisities here](https://learn.microsoft.com/en-us/azure/ai-foundry/agents/environment-setup#prerequisites) for deploying the Bicep template.

<br/>

## Run Of Show

The Session is only 15 minutes long. Based on your familiarity with the topic you may want to do just a subset of the demos. The currently available demos are:

1. Leaderboard - Model Selection
1. Simulator - Dataset Generation
1. Evaluation - AI-Assisted Flow
1. Evaluators - Quality & Safety
1. Evaluators - Agent & More

The run of show below provides a high level view of slides with blue tiles indicating "demo stops". Each row has a core focus:

1. (Row 1) Introduce yourself and topic
1. (Row 2) What is Observability, why should you care, how to get started
1. (Row 3) What's Known: Leaderboards, Simulators & Quality/Safety evals
1. (Row 4) What's New: Agent Evalutors, Graders & Red Teaming Agent
1. (Row 5) Summary: Build trustworthy AI with observability on Foundry!

![Run Of Show](./../session-delivery-resources/LTG151-flow.png)

<br/>

## Step 1: Setup Infrastructure

We'll use [this setup guidance](https://learn.microsoft.com/en-us/azure/ai-foundry/agents/environment-setup) with the [Azure AI Foundry Agent Service Standard Setup](https://github.com/azure-ai-foundry/foundry-samples/tree/main/samples/microsoft/infrastructure-setup/41-standard-agent-setup) template to provision an Azure AI Foundry project and resource for this demo. The code can be found under the `infra/` folder.

![Setup](./assets/standard-agent-setup.png)

1. First, update `infra/azuredeploy.parameters.json` to customize any parameters. I set:
    - _modelName_ to `gpt-4.1`
    - _modelVersion_ to `2025-04-14` to match
    - _location_ to `westus` 

1. Next, deploy the template by following these steps:

    ```bash
    # 1. Switch to the right folder
    cd infra

    # 2. Authenticate with Azure from VS Code
    az login

    # 3. Create resoure group with desired name and location
    az group create --name <new-rg-name> --location westus

    # 4. Deploy the template to that location.
     az deployment group create --resource-group <new-rg-name> --template-file main.bicep --parameters @azuredeploy.parameters.json

    # 5. Wait till completed
    # This can take 10-15 mins
    ```
   
1. Check if the resources were provisioned correctly:

    ```bash
    az resource list --resource-group <new-rg-name>
    ``````
1. Run script to create or update `.env`

    ```bash
    # Start from root folder of repo
     ./src/scripts/update-env.sh <new-rg-name>
    ```
1. Create an Application Insights resource (manually)
    - Visit [Azure AI Foundry portal](https://ai.azure.com)
    - Locate your Azure AI Project resource > Tracing tab
    - Click _Create new_ and complete flow to get new App Insights resource
    - Visit [Azure Portal](https://portal.azure.com) - visit resource group
    - Verify you have _7_ resource items in your resource group!

1. **CONGRATULATIONS** - Your AI project is ready!

<br/>

## Step 2: Populate Search Index

**>> THIS IS REQUIRED ONLY IF YOU ARE DOING THE SIMULATOR DEMO <<**

1. Run script to update access roles. This takes just a minute.
    ```bash
    ./infra/scripts/update-roles.sh 
    ```
1. Manually add an `embedding model` to your AI Foundry Project
    - Visit [Azure AI Foundry portal](https://ai.azure.com)
    - Locate your Azure AI Project resource > Models & Endpoints tab
    - Deploy a `text-embedding-ada-002` model (manually for now)

1. To create a search index, we need an embedding model. 
    - Open the Azure AI Foundry project created earlier
    - Deploy a `text-embedding-ada-002` model for use manually 
    - This takes just a minute (We will automate this in future)

1. You can now populate the search index. 
    ```bash
    python src/scripts/setup_aisearch.py 
    ```
1. You can validate this works by visiting the [Azure Portal](https://portal.azure.com) 
    - Open your search resource page - click "Search Explorer"
    - You should see a `zava products` index.
    - Try a query like `eggshell paint`
    - You should see relevant products like `Interior Eggshell Paint`

**YOU ARE READY TO RUN NOTEBOOKS**

<br/>

## 3. Show Demos

Let's walk through each demo first. Then we'll talk through the run of show and you can decide which subset to show based on time and familiarity.

### Demo 1: Leaderboards

### Demo 2: Simulator

### Demo 3: Evaluation Flow

### Demo 4: Evaluators

<br/>

## 4. Teardown Infrastructure

1. Once your demos are done, don't forget to tear down the resource group!

    ```bash
    az group delete --name <new-rg-name>  --yes --no-wait
    ```

1. You will need to purge soft-deleted resources to reclaim resource names or model quota. You can do this via the portal, or using the following commands.

    1. First, locate the Azure Congitive Search resource

        ```bash
        az search service list --resource-group <new-rg-name> --query "[].name" --output table
        ```

    1. Next, purge the Azure Cognitive Search by name

        ```bash
        az resource delete --ids /subscriptions/$subscriptionId/providers/Microsoft.CognitiveServices/locations/$location/resourceGroups=$resourceGroup/deletedAccounts/$resourceName
        ```

## Congratulations!

Thank you for delivering this session