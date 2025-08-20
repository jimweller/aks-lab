# Migration Plan: EKS to AKS

## 1. Introduction

This document outlines the migration of a Kubernetes lab from AWS EKS to Azure AKS. The goal is a technical comparison of the services.

## 2. Summary of Decisions

| Feature | AWS EKS Equivalent | Azure AKS Choice & Rationale |
|---------|-------------------|------------------------------|
| **Networking** | VPC CNI | **Azure CNI**. Pods get direct VNet IPs, equivalent to VPC CNI. |
| **Node Autoscaling** | Karpenter / Cluster Autoscaler | **Cluster Autoscaler & Karpenter (NAP mode)**. Start with Cluster Autoscaler, then explore Karpenter for pod-centric scaling. |
| **Cluster Identity** | IAM Role for Node Group | **Managed Identity**. Simpler and more secure than Service Principals. |
| **Pod Identity** | EKS Pod Identity / IRSA | **Azure AD Workload Identity**. OIDC-based pod access to Azure resources, equivalent to EKS Pod Identity. |
| **Block Storage** | EBS | **Azure Managed Disks**. Default block storage. |
| **File Storage** | EFS | **Azure Files**. Managed NFS and SMB for shared storage. |
| **Ingress** | AWS Load Balancer Controller | **Application Gateway Ingress Controller (AGIC)**. Integrates with Application Gateway for L7 load balancing. |
| **Secrets** | Secrets Manager | **Azure Key Vault + CSI Driver**. Mounts secrets from Key Vault into pods. |
| **Certificates** | ACM | **cert-manager + Let's Encrypt**. Automated certificates stored in Azure Key Vault. |
| **Container Registry** | ECR | **Azure Container Registry (ACR)**. Integrates via cluster attach, granting pull rights to the cluster's managed identity. |

## 3. Proposed `aks-lab` Structure

```text
aks-lab/
├── 1-cluster/            # Terraform for AKS cluster
├── 2-kubernetes/         # Kubernetes provider configuration
├── 3-metrics-server/     # Metrics Server installation
├── 4-cluster-autoscaler/ # Cluster Autoscaler configuration
├── 5-crossplane/         # Crossplane installation (optional)
└── 6-workloads/          # Sample workloads
```

## 4. Technical Comparisons

### 4.1. Core Infrastructure

#### Networking

| Feature | Kubenet | Azure CNI | AWS VPC CNI |
|---------|---------|-----------|-------------|
| **IP Allocation** | Pods get IPs from a separate address space. | Pods get IPs from the VNet. | Pods get IPs from the VPC. |
| **Performance** | Extra hop adds latency. | Direct connectivity. | Direct connectivity. |
| **Network Policies** | Calico supported. | Azure Network Policies supported. | Calico supported. |

**Decision:** Use **Azure CNI**.

#### Node Autoscaling

| Feature | Cluster Autoscaler (AKS) | Karpenter (EKS/AKS) |
|---------|--------------------------|---------------------|
| **Provisioning** | Node pool-based. | Pod-spec-based. |
| **Node Diversity** | Limited to node pool instance types. | Can provision varied instance types. |
| **Speed** | Slower. | Faster. |

**Decision:** Start with **Cluster Autoscaler**, then implement **Karpenter**.

#### Storage

| Type | AWS EKS | Azure AKS |
|------|---------|-----------|
| **Block** | EBS | Azure Managed Disks |
| **File** | EFS | Azure Files |
| **Object** | S3 | Azure Blob Storage |
| **CSI Drivers** | Manual install. | Default install. |

**Decision:** Use **Azure Managed Disks** and **Azure Files**.

#### Container Registry

| Feature | ECR | ACR |
|---------|-----|-----|
| **Authentication** | IAM-based. | Managed Identity-based via cluster attach. |
| **Scanning** | Amazon Inspector. | Microsoft Defender for Cloud. |

**Decision:** Use **ACR** attached to the AKS cluster.

### 4.2. Security and Identity

#### Cluster Identity

| Feature | Service Principal | Managed Identity |
|---------|-------------------|------------------|
| **Management** | Manual secret lifecycle. | Azure-managed. |
| **Security** | Secret stored in cluster. | No manageable secrets. |

**Decision:** Use a **Managed Identity**.

#### Pod-Level Identity

| Feature | EKS Pod Identity | AWS IRSA (Legacy) | Azure AD Workload Identity | Azure AD Pod Identity (Legacy) |
|---------|------------------|-------------------|----------------------------|-------------------------------|
| **Mechanism** | EKS add-on. | OIDC + webhook. | OIDC + webhook. | Intercepts metadata calls. |
| **Management** | Managed EKS feature. | Manual OIDC setup. | Managed AKS feature. | Deprecated. |

**Decision:** Use **Azure AD Workload Identity**.

### 4.3. Application Ecosystem

#### Ingress, Certificates, and Secrets

| Feature | AWS EKS | Azure AKS |
|---------|---------|-----------|
| **Ingress** | AWS Load Balancer Controller | AGIC |
| **Certificates** | ACM | cert-manager + Let's Encrypt + Key Vault |
| **Secrets** | Secrets Manager + ASCP | Key Vault + Secrets Store CSI Driver |

**Decision:** Use **AGIC**, **cert-manager**, and the **Secrets Store CSI Driver**.
