#!/usr/bin/env bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Provisions
#   VNET via ARM template
set -e

# Edit env.sh to your preferences
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh

echo "This will take several minutes "
echo -e "${PURPLE}-----------------Log Analytics Workspace------------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_APP" \
     --template-file templates/template-log-analytics-workspace.json \
     --parameters \
     logAnalyticsWorkspaceName="$SPOKE_LOG_ANALYTICS_WS_NAME" \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \

echo -e "${PURPLE}-----------------Application Insights---------------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_APP" \
     --template-file templates/template-application-insights.json \
     --parameters \
     logAnalyticsWorkspaceName="$SPOKE_LOG_ANALYTICS_WS_NAME" \
     appInsightsName="$SPOKE_APP_INSIGHTS_NAME" \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \
