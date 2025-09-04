# Require a Tag from a Set of Values on Specific Resource Types

**File**: `tags-RequireATagFromASetofValuesOnResourceType.json`
**Display Name**: "Require a tag and value from a set of values on specific resource types"
**Category**: Tags
**Mode**: Indexed

## Overview

This policy enforces tag governance on specific Azure resource types, providing targeted enforcement for compliance and security requirements. It allows you to apply different tag requirements to different types of resources.

## Description

Enforces a tag and its value from a set of values on specific resource types. This policy enables granular governance by allowing you to target specific Azure services with tailored tag requirements.

## Target Scope

- **Resources**: Configurable resource types
- **Mode**: Indexed
- **Resource Filter**: Configurable array of resource types

## Parameters

| Parameter | Type | Description | Required | Default |
|-----------|------|-------------|----------|---------|
| `effect` | String | Policy enforcement effect | Yes | Deny |
| `resourceTypes` | Array | The resource types to target | Yes | ["*"] |
| `tagRequireType` | String | Defines the enforcement behavior | Yes | - |
| `tagName` | String | The name of the tag to enforce | Yes | - |
| `tagValues` | Array | List of allowed values for the tag | Yes | - |

### Effect Options
- **Deny**: Blocks deployment of non-compliant resources
- **Audit**: Logs non-compliance without blocking resources
- **Disabled**: Turns off the policy

### Resource Types Parameter
- **Format**: Array of Azure resource type strings
- **Example**: `["Microsoft.Storage/storageAccounts", "Microsoft.Compute/virtualMachines"]`
- **Wildcard**: Use `["*"]` to target all resource types (equivalent to Resources policy)

### Tag Requirement Types

#### RequireTagAndValue
- **Behavior**: Tag must exist AND have a value from the allowed set
- **Use Case**: Mandatory categorization for specific resource types
- **Example**: All storage accounts must have "dataClassification" tag

#### RequireTagValueFromSet
- **Behavior**: If tag exists, it must have a value from the allowed set
- **Use Case**: Optional tags that must conform when present
- **Example**: If "backupPolicy" tag exists on VMs, it must be from approved list

## Policy Logic

```
IF (resource type IN [resourceTypes parameter])
   AND (tag validation fails based on tagRequireType)
THEN APPLY [effect parameter]

Tag Validation:
- RequireTagAndValue: Tag must exist AND value must be in allowed set
- RequireTagValueFromSet: IF tag exists, THEN value must be in allowed set
```

## Usage Examples

### Example 1: Data Classification on Storage Accounts
```json
{
  "effect": {
    "value": "Deny"
  },
  "resourceTypes": {
    "value": ["Microsoft.Storage/storageAccounts"]
  },
  "tagRequireType": {
    "value": "RequireTagAndValue"
  },
  "tagName": {
    "value": "dataClassification"
  },
  "tagValues": {
    "value": ["public", "internal", "confidential", "restricted"]
  }
}
```

### Example 2: Backup Policy on Virtual Machines
```json
{
  "effect": {
    "value": "Audit"
  },
  "resourceTypes": {
    "value": ["Microsoft.Compute/virtualMachines"]
  },
  "tagRequireType": {
    "value": "RequireTagAndValue"
  },
  "tagName": {
    "value": "backupPolicy"
  },
  "tagValues": {
    "value": ["daily", "weekly", "monthly", "none"]
  }
}
```

### Example 3: Security Zone on Networking Resources
```json
{
  "effect": {
    "value": "Deny"
  },
  "resourceTypes": {
    "value": [
      "Microsoft.Network/virtualNetworks",
      "Microsoft.Network/networkSecurityGroups",
      "Microsoft.Network/applicationGateways"
    ]
  },
  "tagRequireType": {
    "value": "RequireTagAndValue"
  },
  "tagName": {
    "value": "securityZone"
  },
  "tagValues": {
    "value": ["dmz", "internal", "restricted", "management"]
  }
}
```

### Example 4: Application Name on Compute Resources
```json
{
  "effect": {
    "value": "Deny"
  },
  "resourceTypes": {
    "value": [
      "Microsoft.Compute/virtualMachines",
      "Microsoft.Web/sites",
      "Microsoft.ContainerService/managedClusters"
    ]
  },
  "tagRequireType": {
    "value": "RequireTagValueFromSet"
  },
  "tagName": {
    "value": "applicationName"
  },
  "tagValues": {
    "value": ["webapp1", "api-service", "frontend", "backend", "database"]
  }
}
```

## Deployment

### Azure CLI
```bash
# Create policy definition
az policy definition create \
  --name "require-tag-from-set-types" \
  --display-name "Require Tag From Set - Specific Types" \
  --description "Enforces tag values from predefined set on specific resource types" \
  --rules @tags-RequireATagFromASetofValuesOnResourceType.json \
  --mode Indexed

# Assign to storage accounts only
az policy assignment create \
  --name "enforce-data-classification-storage" \
  --display-name "Enforce Data Classification on Storage" \
  --policy "require-tag-from-set-types" \
  --scope "/subscriptions/{subscription-id}" \
  --params '{
    "effect": {"value": "Deny"},
    "resourceTypes": {"value": ["Microsoft.Storage/storageAccounts"]},
    "tagRequireType": {"value": "RequireTagAndValue"},
    "tagName": {"value": "dataClassification"},
    "tagValues": {"value": ["public", "internal", "confidential"]}
  }'
```

### PowerShell
```powershell
# Create policy definition
$policyDef = New-AzPolicyDefinition `
  -Name "require-tag-from-set-types" `
  -DisplayName "Require Tag From Set - Specific Types" `
  -Description "Enforces tag values from predefined set on specific resource types" `
  -Policy (Get-Content -Path "tags-RequireATagFromASetofValuesOnResourceType.json" -Raw) `
  -Mode Indexed

# Create assignment for VMs
$params = @{
  effect = "Audit"
  resourceTypes = @("Microsoft.Compute/virtualMachines")
  tagRequireType = "RequireTagAndValue"
  tagName = "backupPolicy"
  tagValues = @("daily", "weekly", "monthly", "none")
}

New-AzPolicyAssignment `
  -Name "audit-vm-backup-policy" `
  -DisplayName "Audit VM Backup Policy Tags" `
  -PolicyDefinition $policyDef `
  -Scope "/subscriptions/{subscription-id}" `
  -PolicyParameterObject $params
```

## When to Use This Policy

✅ **Best For:**
- Specific compliance requirements for certain resource types
- Security classification on sensitive resources
- Different tag requirements per resource type
- Granular governance for critical services

✅ **Use Cases:**
- Data classification on storage and databases
- Security zone classification on networking resources
- Backup policy enforcement on compute resources
- Application identification on workload resources
- Compliance tags on regulated services

✅ **Recommended Approach:**
- Start with most critical resource types
- Use for resource-type-specific compliance
- Implement gradually by resource type
- Focus on security and cost-sensitive resources

## Common Resource Type Scenarios

### Security & Compliance
- **Storage Accounts**: Data classification, encryption requirements
- **Key Vaults**: Security level, access classification
- **Databases**: Data sensitivity, compliance frameworks

### Cost Management
- **Virtual Machines**: Size category, backup policy, lifecycle
- **App Services**: Application tier, scaling policy
- **Storage**: Storage tier, retention policy

### Networking Security
- **Virtual Networks**: Security zone, network tier
- **Network Security Groups**: Security classification
- **Load Balancers**: Traffic classification

### Application Workloads
- **Web Apps**: Application name, version, tier
- **Container Services**: Cluster purpose, environment
- **Function Apps**: Function category, trigger type

## Best Practices

1. **Start Small**: Begin with most critical resource types
2. **Security Focus**: Prioritize security-sensitive resources
3. **Compliance Alignment**: Map to regulatory requirements
4. **Resource Grouping**: Group related resource types together
5. **Testing Approach**: Use audit mode first for each resource type
6. **Documentation**: Clearly document requirements per resource type

## Resource Type Examples

### Common Azure Resource Types
```json
// Compute Resources
"Microsoft.Compute/virtualMachines"
"Microsoft.Web/sites"
"Microsoft.ContainerService/managedClusters"

// Storage Resources
"Microsoft.Storage/storageAccounts"
"Microsoft.Sql/servers"
"Microsoft.DocumentDB/databaseAccounts"

// Networking Resources
"Microsoft.Network/virtualNetworks"
"Microsoft.Network/networkSecurityGroups"
"Microsoft.Network/applicationGateways"

// Security Resources
"Microsoft.KeyVault/vaults"
"Microsoft.Security/automations"
```

## Related Policies

- [Resources Policy](tags-RequireATagFromASetofValuesOnResources.md) - For broad resource governance
- [Resource Groups Policy](tags-RequireATagFromASetofValuesOnResourceGroups.md) - For organizational structure
