#!/bin/sh

# Replace the below properties with the <values> appropriate for your setup
OM_PROJECT_ID="<opsmanager_project_id>"
OM_USER_BASE64=$(echo "<opsmanager_userid>" | base64)
OM_API_KEY_BASE64=$(echo "<opsmanager_public_apikey>" | base64)
OM_URL="<opsmanager_uri>"
K8_NAMESPACE="<kubernetes_namespace>"
MONGODB_VERSION="<mongodb_version>"