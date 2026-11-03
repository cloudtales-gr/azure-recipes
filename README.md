# CloudTales Azure Recipes

Short, tested, step-by-step Azure recipes from [cloudtales.gr](https://cloudtales.gr/recipes/): every article on the site has its code here, in PowerShell (Az), Bash (Azure CLI) and Bicep.

- **Zero keys.** Managed identities, RBAC and OIDC; no account keys, connection strings with secrets, or client secrets.
- **One resource group per recipe**, tagged `recipe` and `expires`, with a cleanup script. `tools/Remove-ExpiredLabs.ps1` removes what you forgot.
- **Tested** in Sweden Central; each article says when.

## Start here

1. Install the tools: [GOV-02](https://cloudtales.gr/recipes/governance/gov-02-azure-cli-az-powershell-bicep-windows-linux/).
2. Pick a recipe, open its folder, run `deploy.ps1` (or `deploy.sh`), read the article alongside.
3. Clean up with `cleanup.ps1` when you are done.

## Repository layout

```text
catalog.json              every planned recipe: id, category, title, slug (the single source for site and backlog)
recipes/<slug>/           one folder per recipe: README, main.bicep, deploy and cleanup scripts
templates/recipe/         the folder every new recipe starts from
tools/New-Recipe.ps1      copies the template for a recipe id
tools/New-RecipeIssues.ps1  creates the backlog (issues + project board) from the catalog
tools/Remove-ExpiredLabs.ps1  deletes expired lab resource groups
tools/catalog.py          catalog checks (CI) and this README's list
```

## Recipes

<!-- recipes:begin -->

### Foundations and governance (2/12)

- ✅ **GOV-01** [Secure a new Azure tenant in the first hour: MFA, break-glass accounts, security defaults](recipes/gov-01-secure-new-azure-tenant-first-hour/) · [article](https://cloudtales.gr/recipes/governance/gov-01-secure-new-azure-tenant-first-hour/)
- ✅ **GOV-02** [Azure CLI, Az PowerShell and Bicep on Windows and Linux: the toolkit every recipe uses](recipes/gov-02-azure-cli-az-powershell-bicep-windows-linux/) · [article](https://cloudtales.gr/recipes/governance/gov-02-azure-cli-az-powershell-bicep-windows-linux/)
- ⬜ **GOV-03** Management groups and subscriptions for a small organisation
- ⬜ **GOV-04** Naming and tagging standard, enforced with Azure Policy
- ⬜ **GOV-05** Azure Policy: allowed regions and VM sizes
- ⬜ **GOV-06** Resource locks: stop the accidental delete
- ⬜ **GOV-07** Least privilege with a custom "VM Operator" role
- ⬜ **GOV-08** Privileged Identity Management for Azure roles: just-in-time Owner
- ⬜ **GOV-09** Azure Resource Graph: 15 queries every admin needs
- ⬜ **GOV-10** A self-cleaning sandbox: expiry tags and a nightly cleanup Function
- ⬜ **GOV-11** Azure Landing Zone with the Bicep accelerator, sized for a small tenant
- ⬜ **GOV-12** Activity Log in Log Analytics: who deleted what, and when

### Identity with Microsoft Entra ID (1/14)

- ✅ **ID-01** [Users and groups with Microsoft Graph PowerShell](recipes/id-01-users-groups-microsoft-graph-powershell/) · [article](https://cloudtales.gr/recipes/identity/id-01-users-groups-microsoft-graph-powershell/)
- ⬜ **ID-02** Dynamic groups by department and device
- ⬜ **ID-03** Conditional Access baseline: MFA for admins, block legacy authentication
- ⬜ **ID-04** Passwordless with passkeys (FIDO2 and Microsoft Authenticator)
- ⬜ **ID-05** Self-service password reset with on-premises writeback
- ⬜ **ID-06** Entra Cloud Sync from an on-premises AD (lab with a Windows Server 2025 DC)
- ⬜ **ID-07** App registration with certificate credentials instead of client secrets
- ⬜ **ID-08** Managed identities: system-assigned vs user-assigned, hands-on
- ⬜ **ID-09** Workload identity federation: GitHub Actions to Azure without secrets
- ⬜ **ID-10** B2B guest access with cross-tenant access settings
- ⬜ **ID-11** Access reviews for guests and privileged groups
- ⬜ **ID-12** Entitlement management: an access package for a project team
- ⬜ **ID-13** Sign-in logs in Log Analytics: KQL for suspicious sign-ins
- ⬜ **ID-14** Alert when a break-glass account signs in

### Networking (0/15)

- ⬜ **NET-01** VNet, subnets and NSGs: the first network
- ⬜ **NET-02** Hub and spoke with VNet peering in Bicep
- ⬜ **NET-03** Private Endpoint for a Storage account with Private DNS
- ⬜ **NET-04** Azure Bastion: RDP and SSH without public IPs
- ⬜ **NET-05** NAT Gateway: one predictable outbound IP
- ⬜ **NET-06** Azure Firewall Basic: spokes forced through the hub
- ⬜ **NET-07** Private DNS Resolver: hybrid DNS between on-premises and Azure
- ⬜ **NET-08** Site-to-site VPN to an on-premises lab (strongSwan on Linux)
- ⬜ **NET-09** Point-to-site VPN with Entra ID authentication
- ⬜ **NET-10** Standard Load Balancer for two web VMs
- ⬜ **NET-11** Application Gateway with WAF in front of App Service
- ⬜ **NET-12** Azure Front Door with a custom domain and WAF
- ⬜ **NET-13** Azure DNS: host a public zone and move a domain to it
- ⬜ **NET-14** VNet flow logs and Traffic Analytics
- ⬜ **NET-15** Network Watcher: troubleshooting "it doesn't connect"

### Virtual Machines (0/12)

- ⬜ **VM-01** Windows Server 2025 VM with PowerShell and az CLI
- ⬜ **VM-02** Ubuntu 24.04 VM with SSH keys and cloud-init
- ⬜ **VM-03** Auto-shutdown, resize and deallocate: stop paying for idle VMs
- ⬜ **VM-04** Managed disks: add, expand, snapshot, restore
- ⬜ **VM-05** Trusted Launch and Secure Boot
- ⬜ **VM-06** Run Command and Custom Script Extension
- ⬜ **VM-07** Azure Update Manager: patch Windows and Linux on a schedule
- ⬜ **VM-08** Machine Configuration (guest configuration) baselines
- ⬜ **VM-09** A custom image with Azure Image Builder and Compute Gallery
- ⬜ **VM-10** VM Scale Set with autoscale
- ⬜ **VM-11** Spot VMs for batch jobs
- ⬜ **VM-12** Serial console and boot diagnostics: rescue a VM that won't boot

### Windows Server on Azure (0/8)

- ⬜ **WIN-01** An Active Directory domain controller on an Azure VM
- ⬜ **WIN-02** Join Azure VMs to the domain, with DNS done right
- ⬜ **WIN-03** Windows Admin Center in the Azure portal
- ⬜ **WIN-04** Hotpatching with Windows Server 2025 Datacenter: Azure Edition
- ⬜ **WIN-05** SMB over QUIC: a file server without a VPN
- ⬜ **WIN-06** Azure File Sync: a cloud-tiered file server
- ⬜ **WIN-07** IIS with a TLS certificate from Key Vault
- ⬜ **WIN-08** Universal Print instead of a print server

### Linux on Azure (0/7)

- ⬜ **LNX-01** Sign in to Linux VMs with Entra ID: SSH without keys to manage
- ⬜ **LNX-02** Nginx reverse proxy with Let's Encrypt
- ⬜ **LNX-03** Azure Monitor Agent and syslog to Log Analytics
- ⬜ **LNX-04** Mount Azure Files over NFS and SMB
- ⬜ **LNX-05** A Docker host on Ubuntu that pulls from ACR with managed identity
- ⬜ **LNX-06** A WireGuard gateway VM
- ⬜ **LNX-07** Unattended upgrades vs Azure Update Manager

### Azure Virtual Desktop (0/5)

- ⬜ **AVD-01** A pooled host pool with Entra-joined session hosts
- ⬜ **AVD-02** FSLogix profiles on Azure Files with Entra Kerberos
- ⬜ **AVD-03** RemoteApp: publish a single application
- ⬜ **AVD-04** Scaling plans: session hosts off when nobody works
- ⬜ **AVD-05** Windows 365 vs AVD: the same desktop, priced both ways

### Storage (0/10)

- ⬜ **STO-01** Storage account secure baseline: no shared keys, TLS 1.2, private only
- ⬜ **STO-02** User delegation SAS: the only SAS worth issuing
- ⬜ **STO-03** Blob lifecycle rules: hot to cool to cold to archive, automatically
- ⬜ **STO-04** Immutable storage (WORM) for compliance records
- ⬜ **STO-05** Azure Files with identity-based access (Entra Kerberos)
- ⬜ **STO-06** AzCopy recipes: copy, sync, and move from AWS S3
- ⬜ **STO-07** Static website: Storage account vs Static Web Apps
- ⬜ **STO-08** Customer-managed keys with Key Vault
- ⬜ **STO-09** Data Lake Storage Gen2: folders and ACLs
- ⬜ **STO-10** A geo-redundant storage failover drill

### Databases (0/8)

- ⬜ **DB-01** Azure SQL Database with Entra-only authentication
- ⬜ **DB-02** Azure SQL behind a private endpoint, with auditing
- ⬜ **DB-03** Azure SQL failover group across two regions
- ⬜ **DB-04** PostgreSQL Flexible Server with Entra authentication and private access
- ⬜ **DB-05** MySQL Flexible Server for a WordPress site
- ⬜ **DB-06** Cosmos DB with RBAC and no keys
- ⬜ **DB-07** SQL Server on an Azure VM: automated backup and patching
- ⬜ **DB-08** Azure SQL serverless: pause when idle

### Containers and AKS (0/9)

- ⬜ **CTR-01** Azure Container Registry with Entra authentication and ACR Tasks
- ⬜ **CTR-02** Azure Container Apps: a web app with managed identity
- ⬜ **CTR-03** Container Apps jobs: a scheduled job instead of a VM cron
- ⬜ **CTR-04** AKS Automatic: the first cluster
- ⬜ **CTR-05** AKS with Entra ID and Kubernetes RBAC
- ⬜ **CTR-06** AKS workload identity: pods that call Azure without secrets
- ⬜ **CTR-07** Ingress on AKS with Application Gateway for Containers
- ⬜ **CTR-08** GitOps on AKS with Flux
- ⬜ **CTR-09** AKS node auto-provisioning to cut cost

### App platform (0/11)

- ⬜ **APP-01** App Service: deploy a .NET 10 app with deployment slots
- ⬜ **APP-02** App Service: custom domain and a free managed certificate
- ⬜ **APP-03** App Service with VNet integration and a private endpoint
- ⬜ **APP-04** Key Vault references in app settings
- ⬜ **APP-05** Azure Functions Flex Consumption with managed identity
- ⬜ **APP-06** Durable Functions: a long-running workflow
- ⬜ **APP-07** Static Web Apps with Hugo and GitHub Actions
- ⬜ **APP-08** Event Grid: react to a new blob
- ⬜ **APP-09** Service Bus queues: sessions and dead-lettering
- ⬜ **APP-10** API Management (Consumption) in front of Functions
- ⬜ **APP-11** Logic Apps Standard: an approval by email

### Security (0/10)

- ⬜ **SEC-01** Key Vault with RBAC: secrets, keys and certificates
- ⬜ **SEC-02** Defender for Cloud: enable the plans and take the first secure score wins
- ⬜ **SEC-03** Just-in-time VM access
- ⬜ **SEC-04** Microsoft Sentinel: the first workspace and data connectors
- ⬜ **SEC-05** Sentinel: an analytics rule for impossible travel
- ⬜ **SEC-06** Entra ID Protection: risk-based Conditional Access
- ⬜ **SEC-07** Disable shared keys across a subscription with Azure Policy
- ⬜ **SEC-08** A CIS baseline audit with Machine Configuration
- ⬜ **SEC-09** Defender for Identity on a domain controller
- ⬜ **SEC-10** Find leaked keys in your repos and rotate them through Key Vault

### Monitoring (0/9)

- ⬜ **MON-01** One Log Analytics workspace or many: a decision recipe
- ⬜ **MON-02** Azure Monitor Agent and Data Collection Rules
- ⬜ **MON-03** Alerts and action groups: email, SMS, Teams
- ⬜ **MON-04** KQL for admins: 20 queries for VMs
- ⬜ **MON-05** Application Insights for .NET 10 with OpenTelemetry
- ⬜ **MON-06** Workbooks: a VM health dashboard
- ⬜ **MON-07** Diagnostic settings at scale with Azure Policy
- ⬜ **MON-08** Cut log cost with the Basic and Auxiliary table plans
- ⬜ **MON-09** Free uptime monitoring with GitHub Actions

### Backup and disaster recovery (0/7)

- ⬜ **BCK-01** Azure Backup for VMs with a backup policy
- ⬜ **BCK-02** Restore a single file from a VM backup
- ⬜ **BCK-03** Back up Azure Files and blobs (vaulted backup)
- ⬜ **BCK-04** Immutable vault, soft delete and multi-user authorization against ransomware
- ⬜ **BCK-05** SQL Server in a VM: workload-aware backup
- ⬜ **BCK-06** Azure Site Recovery: a VM replicated to a second region
- ⬜ **BCK-07** A DR drill you can run every quarter

### Hybrid with Azure Arc (0/5)

- ⬜ **ARC-01** Onboard an on-premises server to Azure Arc
- ⬜ **ARC-02** Azure Update Manager for on-premises servers
- ⬜ **ARC-03** Defender for Servers on-premises through Arc
- ⬜ **ARC-04** SSH to Arc servers without open ports
- ⬜ **ARC-05** Azure Policy and Machine Configuration on non-Azure servers

### Infrastructure as Code and DevOps (0/9)

- ⬜ **IAC-01** Bicep from zero: parameters, modules, outputs
- ⬜ **IAC-02** Azure Verified Modules: stop writing every module yourself
- ⬜ **IAC-03** Deployment stacks: protect what you deployed
- ⬜ **IAC-04** What-if and PSRule for Azure in CI
- ⬜ **IAC-05** GitHub Actions to Azure with OIDC, end to end
- ⬜ **IAC-06** Azure DevOps pipelines with workload identity service connections
- ⬜ **IAC-07** Terraform on Azure with remote state and Entra authentication
- ⬜ **IAC-08** Azure Developer CLI (azd): a template from scratch
- ⬜ **IAC-09** Bicep vs Terraform: the same small landing zone in both

### Cost (0/6)

- ⬜ **COST-01** Find idle and orphaned resources with Resource Graph
- ⬜ **COST-02** Azure Advisor cost recommendations, weekly by email
- ⬜ **COST-03** Tag-based cost allocation per project
- ⬜ **COST-04** Reservations vs savings plans: a decision with real numbers
- ⬜ **COST-05** Start and stop VMs on a schedule
- ⬜ **COST-06** Cost exports to a storage account and a simple Excel or Power BI view

### Azure AI (0/7)

- ⬜ **AI-01** Azure OpenAI in AI Foundry: a model deployment behind a private endpoint
- ⬜ **AI-02** Call Azure OpenAI with managed identity, no API keys
- ⬜ **AI-03** RAG over your own documents with Azure AI Search
- ⬜ **AI-04** Azure AI Speech: turn articles into audio
- ⬜ **AI-05** Document Intelligence: extract fields from invoices
- ⬜ **AI-06** Content Safety in front of a chatbot
- ⬜ **AI-07** An AI Foundry agent with tools and managed identity

### Migration (0/6)

- ⬜ **MIG-01** Azure Migrate: discovery and assessment of a small estate
- ⬜ **MIG-02** Move a Hyper-V VM to Azure
- ⬜ **MIG-03** File shares to Azure Files with Storage Mover
- ⬜ **MIG-04** SQL Server to Azure SQL Managed Instance with Database Migration Service
- ⬜ **MIG-05** WordPress to a static site on Azure
- ⬜ **MIG-06** From shared hosting to Azure: DNS, mail and certificates without downtime

<!-- recipes:end -->

## License

Code: [MIT](LICENSE). Article text and images on cloudtales.gr remain © CloudTales.
