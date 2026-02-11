## Terraform EKS Setup Overview

This setup provisions a production-ready EKS cluster with the following features:

### VPC
- Created using the official AWS VPC module (version 5.1.0)
- 2 Availability Zones, private and public subnets
- NAT gateway for outbound internet from private subnets
- Subnet tagging for Kubernetes load balancers
- Environment tag: `production`

### EKS Cluster
- Created using the official AWS EKS module (version 20.8.5)
- Kubernetes version: 1.29
- Private endpoint only (no public API access)
- IRSA enabled for secure IAM integration
- Secrets encryption enabled
- Control plane logging enabled (all types)
- Managed node group (m5.large, min 2, max 4)
- Addons: CoreDNS, kube-proxy, VPC CNI

### Bastion Host
- Amazon Linux 2023 EC2 instance in public subnet
- SSH access restricted to your public IP (update in main.tf)
- Key pair managed via `aws_key_pair` resource

### ArgoCD & Monitoring
- ArgoCD deployed via Helm in its own namespace
- Prometheus/Grafana stack deployed via Helm in `monitoring` namespace
- All services are internal (ClusterIP)

### Remote State
- S3 backend with DynamoDB state locking (see backend.tf)

### Providers
- AWS, Kubernetes, Helm, Random, TLS

### Outputs
- EKS cluster name and endpoint
- Bastion public IP

---

## Usage

1. Update variables in `variables.tf` and your SSH public key path in `main.tf`.
2. Update the allowed SSH CIDR in the bastion security group.
3. Initialize and apply:

```sh
cd terraform-eks
terraform init
terraform apply
```

---

## Security Notes
- EKS API is private (no public endpoint)
- Bastion host is the only SSH entry point; restrict access to your IP
- Secrets are encrypted at rest
- Use IRSA for workload IAM permissions

---

## Architecture Diagram

![EKS Production Architecture](https://raw.githubusercontent.com/aws-samples/eks-workshop/main/static/img/eks.png)

<details>
<summary>Click to view logical design (Mermaid)</summary>

```mermaid
...existing code...
```
</details>

---

## Accessing ArgoCD, Prometheus, and Grafana

All services are deployed as internal (ClusterIP) for security. To access their dashboards, use `kubectl port-forward` from your bastion host or a machine with cluster access:

### ArgoCD UI
1. Port-forward the ArgoCD server service:
   ```sh
   kubectl port-forward svc/argocd-server -n argocd 8080:80
   ```
2. Open [http://localhost:8080](http://localhost:8080) in your browser.
3. Get the initial admin password:
   ```sh
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

### Grafana (Monitoring)
1. Port-forward the Grafana service:
   ```sh
   kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
   ```
2. Open [http://localhost:3000](http://localhost:3000) in your browser.
3. Default login: `admin/prom-operator` (change after first login).

### Prometheus
1. Port-forward the Prometheus service:
   ```sh
   kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
   ```
2. Open [http://localhost:9090](http://localhost:9090) in your browser.