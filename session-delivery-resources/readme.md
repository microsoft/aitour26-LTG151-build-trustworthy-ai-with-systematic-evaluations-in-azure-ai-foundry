# Delivering this theater session

This repository contains the materials for a 15-minute theater session on building trustworthy AI with systematic evaluations. The time is just enough to set the stage with an explanation - then do two quick demos. This document provides the guidance you need, to deliver this session.


---

## 1. File Summary 🗂️

The links below provide access to the presentation, speaker notes, demo setup instructions - and a walkthrough video with speaker guidance. We recommend setting up the demo **at least 30 minutes ahead of the presentation time** so you can optimize the time to talk through the code & evaluation results.

| Resources          | Links                            | Description |
|-------------------|----------------------------------|-------------------|
| Session Delivery Deck     |  [PPT](https://aka.ms/AAxs6f7) | Powerpoint presentation |
| Speaker Prep | [Notes](#2-speaker-prep-️) | Suggested flow for talk  |
| Demo Prep | [Notes](#3-demo-prep-) |  Setup guidance for demo |
| Walkthrough| | Recorded walkthrough of talk |
|||

<br/>

##  2. Speaker Prep 🎙️

The figure shows the slides in the presentation organized into sections (one per row) corresponding to the table below - with a suggestion time allocation per section. If you are time constrained - just define observability (row 2) and jump into demos. Leave 1 minute to wrap - and use that to share the final slide with QR codes that point to learning resources.


| Row | Time | Notes |
|:---|:---|:---|
| 1 | 1 min | Introduce yourself · Introduce topic briefly |
| 2 | 1 min | Define Observability · Describe E2E Workflow |
| 3 | 5 min | Demo 1: Model Evals · Quality & Safety Evaluations  |
| 4 | 5 min | Demo 2: Agent Evals · Intent & Tool Evaluations |
| 5 | 3 min | E2E Observability · Red Teaming, Monitoring, Tracing|
| | |


 **Takeaway Message**: We want learners to know:

1. Observability is the foundation for trustworthy AI Agents
1. Azure AI Foundry is a unified platform for E2E Observability


![FLow](./LTG151-flow.png)

<br/>

## 3. Demo Prep 🚀

The repository is instrumented with GitHub Codespaces for convenience. Follow instructions below and set up the demo well ahead of your presentation time - you will have no time for setup at the podium.

The Codespaces session may get paused when idle. That's okay. It will be faster to resume it from this state than to start a new instance from scratch and complete all the steps in time.

Follow steps 1-4 **before** your session to get setup. Follow step 4 **after your presentation** to clean up and reclaim resources.

| Step   | Instructions | Comments
--------------|-------------|-------
Setup    | [1. Setup Infrastructure](#31-setup-infrastructure) | Create Standard Agent Project |
Validate | [2. Validate Setup](#32-validate-setup) | Configure Local Environment |
Demo 1   | [3. Run Model Evaluations](#33-run-model-evals) | Run Notebook 1 |
Demo 2   | [4. Run Agent Evaluations ](#34-run-agent-evals) | Run Notebook 2 |
Teardown | [5. Teardown Infrastructure](#35-teardown-infrastructure) | Delete Provisioned Project  |
| | |


### Tips For Troubleshooting

Before you get started on setup, here are some optional (but useful) steps you can take to make it easier to troubleshoot or understand setup later.

**Tip 1: Use GitHub Copilot**

1. The GitHub Codespaces environment should have GitHub Copilot chat available (see the icon to the right of the search bar in navigation). Verify that your account has access by clicking the icon and logging in.
1. Switch it to [Agent Mode](https://code.visualstudio.com/docs/copilot/chat/chat-agent-mode) and set your preferred model, noting the quota available. The default is fine - I used `Claude Sonnet 4` in my setup.
1. Use this to ask for explainers or troubleshoot issues if you have any. _Where possible, we'll identify useful prompts you can use to gain more insights into a specific step._

**Tip 2: Use MCP Servers**

1. In Agent Mode, the model gets access to _tools_ that it can use to be more effective at taking actions or answering questions.
1. To explore available MCP servers, visit the [MCP Registry](https://github.com/mcp) in the browser, or click the _Extensions_ icon in VS Code sidebar and look for the **MCP SERVERS** dropdown section.
1. For this project, we recommend using these two:
    - **Azure MCP Server** - The GitHub Codespaces is already configured to have this installed via an extension. See [its supported tools](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azure-mcp-server#complete-list-of-supported-azure-services).

    - **Microsoft Docs MCP Server** - Just run the command below to get it setup locally using `.vscode/mcp.json`. See [its supported tools](https://github.com/mcp/microsoftdocs/mcp#%EF%B8%8F-currently-supported-tools). 
        ```sh
        mkdir -p .vscode && cp src/assets/mcp.json .vscode
        ```

You are now ready to get to work on demo setup! 🎊


---

### 3.1 Setup Infrastructure

For this demo, we'll use the [Azure AI Foundry Agent Service: Standard Agent Setup](https://github.com/azure-ai-foundry/foundry-samples/tree/main/samples/microsoft/infrastructure-setup/41-standard-agent-setup) infrastructure template from the Azure AI Foundry samples repo.

1. First, switch to the directory with the infrastructure
    ```
    cd src/infra
    ```

1. Then, authenticate using the Azure CLI

    ```
    az login --tenant <tenant-id>
    ```

1. Create the resource group - pick the resource group name and location that suits you (default location is `westus`). **Make sure that you have quota for the selected model in that location**. _The default model in `main.bicep` is gpt-5_.

    ```
    az group create --name rg-aitour-ltg151 --location eastus2
    ```
1. Now deploy the template.
    ```
    az deployment group create --resource-group rg-aitour-ltg151 --template-file main.bicep
    ```
1. This can take 5-10 minutes to complete so make sure you run this well ahead of your presentation time slot. Also, you may get failures if you have insufficient quota for that model - so verify that the quota requested in `main.bicep` is available.

    ![Arch](./../src/assets/standard-agent-setup.png)

### 3.2 Validate Setup

Once deployment is completed, we can validate the setup and configure local environment variables to use it effectively.

1. **Visit [https://portal.azure.com](https://portal.azure.com)** - verify resource group was created
1. Look for the _Azure AI Foundry_ resource in the list of resources.
1. Click to view the details page - then click on **Go To AI Foundry Portal**
1. You should set the _https://ai.azure.com_ portal with your project page

Now we can configure our local environment.

```
cp src/scripts/.env.sample .env
```

Open the `.env` file - it should look like this. Go ahead and fill in all the values for env variables using the Azure AI Foundry project page.

Then visit the Azure Portal to update the values for the Azure AI Search endpoint and the resource names for the foundry and project resources.

```bash
# .... Azure 
AZURE_SUBSCRIPTION_ID=
AZURE_RESOURCE_GROUP=

# .... Azure AI Foundry
AZURE_OPENAI_API_KEY=
AZURE_OPENAI_ENDPOINT=
AZURE_OPENAI_API_VERSION="2025-02-01-preview" 
AZURE_AI_FOUNDRY_NAME=
AZURE_AI_PROJECT_NAME=

# .... Azure AI Foundry Deployment
AZURE_OPENAI_DEPLOYMENT="gpt-4.1"
AZURE_OPENAI_MODEL_VERSION="2025-04-14"

# .... Azure AI Search
AZURE_AISEARCH_DATAFILE="data/products.csv"
AZURE_AISEARCH_ENDPOINT=
AZURE_AISEARCH_INDEX="zava-products"
```

We can now populate the Zava data in the search index in 2 steps:

1. Open a terminal at the root of the repo and run this command. This updates your user profile to give you read/write access to the search resource.

    ```
    ./src/scripts/update-roles.sh 
    ```
1. Then run this command to upload the products to the search index. 
    ```
    cd src/scripts && python setup_aisearch.py  --data-file ../data/products.csv
    ```
1. When done you should see:
    ```
    ✅ Setup completed successfully!
    Uploaded 50 products to the search index
    The Zava product catalog is now ready for semantic search.
    ```

Finally, you can visit the Azure AI Foundry Portal in the browser .
- Click on the `Agents` tab. You will be asked to select a model.
- Pick a deployed model (I used `gpt-4.1`) - confirm.
- You will now see a created Agent - select it.
- You are now on the Agent details page - leave the tab open.

**Your infrastructure setup is done!** 

We can now explore [Azure AI Evaluation Samples](https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/evaluation/azure-ai-evaluation) for Python. The GitHub Codespaces environment is setup with the required dependencies - lets go!

### 3.3 Run Model Evals



### 3.4 Run Agent Evals

### 3.5 Teardown Infrastructure


<br/>

## Thank you! 🏆

You just completed your AI Tour Presentation! 🎊

Thank you so much for your hard work! If you have comments or feedback, please reach out to the Content Owners and help us improve the experience for future tour attendees!