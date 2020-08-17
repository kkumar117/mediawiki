#!/bin/bash

set -xe

read -p "Enter image tag:" IMAGE_TAG
read -p "Enter Namespace in EKS Cluster:" ENV
echo "Image tag-"$IMAGE_TAG
echo "NameSpace-"$ENV

#clone helm charts from repo
git clone https://github.com/kkumar117/mediawiki.git
#updating kubeconfig context
kubectl config use-context arn:aws:eks:ap-south-1:683103604691:cluster/wiki
#verify namespace exists
kubectl get namespace $ENV
#deploy on kubernetes using helm
ls mediawiki/
cd mediawiki/code/

#Building dockerfile
docker build -t 683103604691.dkr.ecr.ap-south-1.amazonaws.com/wiki:$IMAGE_TAG .

#Login ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 683103604691.dkr.ecr.ap-south-1.amazonaws.com
#Pushing Image
docker push 683103604691.dkr.ecr.ap-south-1.amazonaws.com/wiki:$IMAGE_TAG

cd ../

#######For new deployment#################
#helm install wiki wiki/

###########For upgrading helm release############
helm upgrade wiki wiki/ --set=deployment.image.tag=$IMAGE_TAG -n $ENV
