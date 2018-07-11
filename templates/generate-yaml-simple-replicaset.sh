#!/bin/sh

source templates/environment.sh
TARGET_FILE=${K8_NAMESPACE}-replicaset.yaml
tee samples/$TARGET_FILE <<EOF
---
apiVersion: v1
kind: Namespace
metadata:
  name: "${K8_NAMESPACE}"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: "${K8_NAMESPACE}-project"
  namespace: "$K8_NAMESPACE"
data:
  projectId: "$OM_PROJECT_ID"
  baseUrl: "$OM_URL"

---
apiVersion: v1
kind: Secret
metadata:
  name: "${K8_NAMESPACE}-credentials"
  namespace: "$K8_NAMESPACE"
type: Opaque
data:
  user: "$OM_USER_BASE64"
  publicApiKey: "$OM_API_KEY_BASE64"

---
apiVersion: mongodb.com/v1
kind: MongoDbReplicaSet``
metadata:
  name: "${K8_NAMESPACE}-replicaset"
  namespace: "$K8_NAMESPACE"
spec:
  members: 3
  version: "$MONGODB_VERSION"
  project: "${K8_NAMESPACE}-project"
  credentials: "${K8_NAMESPACE}-credentials"
  persistent: false  # For testing only
  podSpec:
    cpu: '0.25'
    memory: 128M
    storage: 2G
EOF

echo "Dynamically generated an yaml file based on the settings. Now execute below command to create a replica set."
echo "kubectl apply -f samples/${TARGET_FILE}"
