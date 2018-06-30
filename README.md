# Getting started with MongoDB Enterprise on Kubernetes

## Introduction

The MongoDB Enterprise Operator is now a public beta program to deploy MongoDB on Kubernetes v1.9+. This article is a quickstart beginners guide to help you get started with MongoDB Enterprise on Kubernetes.

## Install the dependencies on your machine

The `install.sh` is a helper script to install all the required dependencies on Mac OS. Please tweak it accordingly or manually install the below dependencies on your system.

- virtualbox
- minikube
- kubernetes-helm
- bash-completion

```bash
# install and configure the dependencies for Mac OS
sh install.sh
```

If you happened to manually install the dependencies, you must also install the `mongodb-enterprise-kubernetes` operator. Please refer to the `install.sh` for further information

## Configure the Ops Manager

The `mongodb-enterprise-kubernetes` operator is supported for MongoDB Enterprise Ops Manager v4.0+. So please have the Ops Manager v4.0 or above ready.

> Note: _The instructions for installing the Ops Manager v4.0 or higher is out of scope for this article. You may also use the [MongoDB Cloud Manager](https://www.mongodb.com/cloud/cloud-manager) as an interim solution._

Once the Ops Manager is up and running, please follow the below instructions and have the information ready / configured

- Make a note of the Ops Manager Uri
- Create a Project in Ops Manager
- Make a note of the Project ID
  Settings > Project Settings > General > Project ID
- Create Public API Keys
  Account > Public API Access > API Keys
- Find your [public IP address](https://www.whatismyip.com/)
- Whitelist your IP Address
  Account > Public API Access > API Whitelist

## Configuring your environment

Please edit the `templates/environment.sh` file with appropriate values. You must update the values for the properites before you start creating a replica set. The required set of properies are as shown below

```bash
OM_PROJECT_ID="<opsmanager_project_id>"
OM_USER_BASE64=$(echo "<opsmanager_userid>" | base64)
OM_API_KEY_BASE64=$(echo "<opsmanager_public_apikey>" | base64)
OM_URL="<opsmanager_uri>"
K8_NAMESPACE="<kubernetes_namespace>"
MONGODB_VERSION="<mongodb_version>"
```

For example, If you want to use MongoDB Cloud Manager and create a MonogDB v3.6.5 replica set then you must update the properies in the file `templates/environment.sh` as shown below.

```bash
OM_URL="https://cloud.mongodb.com/"
MONGODB_VERSION="3.6.5"
```

> Note: _Please ensure that the MongoDB version is selected in the Version Manager of your Ops Manager._

## Create a simple replica set

I have provided a sample template file for your convenience. Using the values defined in the `templates/environment.sh` file and the template file, `templates/simple-replicaset.sh`, you could easily generate custom yaml file, `samples/<kubernetes_namespace>-replicaset.yaml`, and create the simple replica set using the below commands.

```bash
# create the yaml file using the template
sh templates/simple-replicaset.sh

# create the replica set based on the generated yaml output
source templates/environment.sh
kubectl apply -f samples/${K8_NAMESPACE}-replicaset.yaml
```

Based on your internet download speed, the resources associated are created for you within a few seconds to a few minutes.

```bash
# display all the resources in the namespace
kubectl -n $K8_NAMESPACE get all
```

## Troubleshooting

### Check Enterprise Operator logs for errors

Sometimes you may notice that _MongoDbReplicaSet_ creation did not succeed. To figure out what went wrong, you would have to check the logs on the `mongodb-enterprise-operator` pod.

```bash
# find the pod name for mongodb-enterprise-operator  using selectors
K8_OPERATOR_POD_NAME=$(kubectl -n mongodb get pods --selector=app=mongodb-enterprise-operator --output=jsonpath='{.items[0].metadata.name}')

# display the mongodb-enterprise-operator logs from mongodb namespace
kubectl -n mongodb logs $K8_OPERATOR_POD_NAME
```

The typical errors some of you may incur are related to

- Current IP Address is not added to Whitelist
- MongoDB Version not checked/binaries not available on Ops Manager

If you find the errors in your logs, then have to fix them and may have to recreate the operator pod before creating the replica set again.

```bash
# delete the existing pod after fixing the issue
kubectl -n mongodb delete pod $K8_OPERATOR_POD_NAME

sleep 5
# rerun the kubectl apply -f <samples/replicaset.yaml> script again
source templates/environment.sh
kubectl apply -f samples/${K8_NAMESPACE}-replicaset.yaml

sleep 5
# display all the resources in the namespace
kubectl -n ${K8_NAMESPACE} get all
```

## Delete MongoDB replica set

Issue the below command to delete the _MongoDbReplicaSet_. The Ops Manager deployment in the given project should have been removed as well. If for any reason this project still exists, you have to go to Deployment > ... > _Remove from Ops Manager_ to remove it completely.

```bash
kubectl delete -f samples/${K8_NAMESPACE}-replicaset.yaml
```
