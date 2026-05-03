# Kubernetes App Deployment

This repository contains Kubernetes workload sources imported from DeathStarBench for AKS deployment and CI/CD demonstrations.

## Included workloads
- socialNetwork
- mediaMicroservices
- hotelReservation

## Source attribution
- Upstream project: https://github.com/delimitrou/DeathStarBench
- License copied to UPSTREAM_LICENSE

## Notes
- This repo is intended for Terraform + AKS + Azure DevOps deployment portfolio work.

## Azure DevOps AKS Deployment

This repo includes [azure-pipelines-deploy-hotel-aks.yml](azure-pipelines-deploy-hotel-aks.yml) to deploy HotelReservation to AKS.

How to use:
1. Create a new Azure DevOps pipeline using the YAML file [azure-pipelines-deploy-hotel-aks.yml](azure-pipelines-deploy-hotel-aks.yml).
2. Run it manually with these parameters:
	- serviceConnection: `sc-azure-terraform`
	- clusterResourceGroup: `rg-microservices-dev-cin-1jd9`
	- clusterName: `aks-microservices-dev-cin-1jd9`
	- namespace: `hotel-res`
	- domainName: `hotelreservationweb.me` (default; override if needed)
3. The pipeline deploys manifests under `hotelReservation/kubernetes`, creates a dedicated `frontend-public` `LoadBalancer` service on port 80, then prints the public endpoint.
4. If `domainName` is provided, the pipeline prints DNS mapping guidance (A record for IP endpoint, CNAME for hostname endpoint).
