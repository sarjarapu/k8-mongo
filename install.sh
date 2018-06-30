#!/bin/sh

# Install all the dependencies for the MacOSX
brew install brew-cask
brew cask install virtualbox minikube 
brew install kubernetes-helm bash-completion
# Start the minikube with 8 GB RAM and 2 CPUs
minikube start --memory 8192 --cpus 2



# Install the enterprise operator
# Download the mongodb-enterprise-kubernetes git source
wget -O master.zip https://goo.gl/khJzMu
unzip master.zip

# Initialize the helm and helm chart
helm init --upgrade
sleep 5
helm install mongodb-enterprise-kubernetes-master/helm_chart/ --name mongodb-enterprise

# If helm is not available
# Install the enterprise operator via yaml
# kubectl apply -f mongodb-enterprise-kubernetes-master/mongodb-enterprise.yaml

# Clean up the files and folders
rm -rf master.zip mongodb-enterprise-kubernetes-master/

# display all the resources in mongodb namespace
kubectl -n mongodb get all