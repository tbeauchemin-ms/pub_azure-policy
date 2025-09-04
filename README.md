# Azure Policy Repository

This repository contains a comprehensive collection of custom Azure Policies and Policy Initiatives designed to help organizations implement governance, compliance, and security controls across their Azure environments.

## Repository Overview

This collection provides production-ready Azure Policy definitions and initiatives that address common governance scenarios including:

- **Network Security**: Policies for Network Security Groups, subnet requirements, and private DNS zones
- **Tag Governance**: Comprehensive tag management policies for resources and resource groups
- **Monitoring & Compliance**: Diagnostic settings and logging policies for various Azure resources

All policies are designed following Azure Policy best practices with comprehensive documentation, deployment examples, and real-world use cases.

## Repository Structure

```
├── policies/             # Individual Azure Policy definitions
│   ├── net/              # Network-related policies
│   ├── mon/              # Monitoring and diagnostic policies
│   └── tags/             # Tag governance policies
├── initiatives/          # Policy Initiative definitions (policy sets)
│   └── mon/              # Monitoring policy initiatives
└── README.md             # This file
```

## Quick Start

1. **Browse Policies**: Navigate to the appropriate category folder
2. **Review Documentation**: Each policy includes detailed documentation
3. **Deploy**: Use provided Azure CLI, PowerShell, or ARM template examples
4. **Customize**: Modify parameters and scope as needed for your environment

## Policy Catalog

### Network Policies (`/policies/net/`)

| Policy | File | Description | Effects | State |
|--------|------|-------------|---------|-------|
| **Require NSG on Subnets** | `vnetSubnet-RequireNetworkSecurityGroup.json` | Ensures all subnets have a Network Security Group assigned | Deny, Audit, Disabled | Working |
| **Audit Required NSG Rules** | `networkSecurityGroup-AuditRequiredSecurityRule.json` | Audits NSGs to ensure they contain specific security rules | Audit, AuditIfNotExists, Disabled | In Progress |
| **Deploy Required NSG Rules** | `networkSecurityGroup-DeployRequiredSecurityRule.json` | Automatically deploys missing security rules to NSGs | DeployIfNotExists, AuditIfNotExists, Disabled | In Progress |
| **Prevent Specific NSG Rules** | `networkSecurityGroup-DenySecurityRule.json` | Prevents creation of NSG rules matching specified criteria | Deny, Audit, Disabled | In Progress |
| **Enable Private DNS Internet Fallback** | `privateDnsZones-EnableInternetFailback.json` | Configures private DNS zones to enable internet fallback | DeployIfNotExists, Disabled | In Progress |

### Tag Governance Policies (`/policies/tags/`)

| Policy | File | Description | Effects | State |
|--------|------|-------------|---------|-------|
| **Require Tag on Resources** | `tags-RequireATagFromASetofValuesOnResources.json` | Enforces required tags with specific values on resources | Audit, Deny, Disabled | Working |
| **Require Tag on Resource Groups** | `tags-RequireATagFromASetofValuesOnResourceGroups.json` | Enforces required tags with specific values on resource groups | Audit, Deny, Disabled | Working |
| **Require Tag on Resource Types** | `tags-RequireATagFromASetofValuesOnResourceType.json` | Enforces required tags with specific values on specific resource types | Audit, Deny, Disabled | Working |
| **Append Tag to Resource Types** | `tags-AppendATagOnResourceType.json` | Automatically adds tags to specific resource types during creation | Append, Disabled | Working |
| **Inherit Tag from Resource Group** | `tags-InheritATagFromResourceGroupOnResourceType.json` | Inherits tags from parent resource group to specific resource types | Append, Disabled | Working |

### Monitoring Policies (`/policies/mon/`)

| Policy | File | Description | Effects | State |
|--------|------|-------------|---------|-------|
| **Azure Firewall Diagnostic Settings** | `diagnosticSettings-AzureFirewall-LogAnaltyics.json` | Enables diagnostic logging for Azure Firewalls to Log Analytics | DeployIfNotExists, AuditIfNotExists, Disabled | In Progress |

## Policy Initiatives (`/initiatives/`)

### Monitoring Initiatives (`/initiatives/mon/`)

| Initiative | File | Description |
|------------|------|-------------|
| **Standard Diagnostic Settings** | `diagnosticSettings-Standard-LogAnalytics.bicep` | Comprehensive initiative deploying diagnostic settings policies for multiple Azure resource types to Log Analytics |

## Documentation

Each policy category includes comprehensive documentation:

- **Network Policies**: See `/policies/net/README.md` and individual policy documentation
- **Tag Governance**: See `/policies/tags/README.md` with complete implementation strategy
- **NSG Security Rules**: See `/policies/net/networkSecurityGroup-SecurityRules.md` for detailed NSG policy guidance

## Support and Resources

### Azure Policy Documentation
- [Azure Policy Overview](https://docs.microsoft.com/en-us/azure/governance/policy/overview)
- [Policy Definition Structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure)
- [Policy Effects](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects)
