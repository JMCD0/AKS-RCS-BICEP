# AKS-RCS

This repo contains a Bicep module that deploys 2 AKS Clusters in seperate regions, Networking resources including Application Gateway. There is also a Role Assignment to manage the clusters. (Currently the Service principal will need to be created manually and given the Contributor role scoped to target RG)

An Azure Function App is also created & a Powershell script is deployed to Azure Blob via Github Actions. This script will querry the "National Grid ESO - Carbon Intensity API" and return values that will influence Cluster configuration
