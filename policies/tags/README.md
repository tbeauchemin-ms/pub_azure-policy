# Tag Governance Policies

This directory contains Azure Policies that enforce tag governance across different resource types and scopes. These policies ensure resources have specific tags with values from predefined sets of allowed values, providing flexibility in enforcement through different requirement types and effects.

## Policy Overview

### Policy Files

1. **`tags-RequireATagFromASetofValuesOnResources.json`** (Resources - Enhanced)
   - **Scope**: All resources (mode: Indexed)
   - **Effect**: Configurable (Deny, Audit, Disabled)
   - **Use Case**: General resource tag enforcement with flexible effects

2. **`tags-RequireATagFromASetofValuesOnResourceGroups.json`** (Resource Groups)
   - **Scope**: Resource Groups only
   - **Effect**: Configurable (Deny, Audit, Disabled)
   - **Use Case**: Resource group-specific tag governance

3. **`tags-RequireATagFromASetofValuesOnResourceType.json`** (Specific Resource Types)
   - **Scope**: Configurable resource types
   - **Effect**: Configurable (Deny, Audit, Disabled)
   - **Use Case**: Targeted enforcement on specific Azure resource types

**Common Properties**:
- **Category**: Tags
- **Display Name Variations**: "Require a tag and value from a set of values on [scope]"

## Description

These policies enforce tag governance by ensuring that resources are deployed with approved tag values. They help maintain consistency and compliance across your Azure environment by restricting tag values to a predefined set.

## Policy Comparison

| Feature | Resources Policy | Resource Groups Policy | Resource Type Policy |
|---------|-----------------|----------------------|---------------------|
| **Target Scope** | All resources | Resource groups only | Specific resource types |
| **Mode** | Indexed | Indexed | Indexed |
| **Effect Options** | Deny, Audit, Disabled | Deny, Audit, Disabled | Deny, Audit, Disabled |
| **Resource Type Filter** | All resources | Microsoft.Resources/resourceGroups | Configurable array |
| **Use Case** | General resource governance | RG-level organization | Targeted type-specific enforcement |

## Parameters

### Common Parameters (All Policies)
| Parameter | Type | Description | Required | Default |
|-----------|------|-------------|----------|---------|
| `effect` | String | Policy enforcement effect | Yes | Deny |
| `tagRequireType` | String | Defines the enforcement behavior | Yes | - |
| `tagName` | String | The name of the tag to enforce | Yes | - |
| `tagValues` | Array | List of allowed values for the tag | Yes | - |

### Resource Type Policy Additional Parameters
| Parameter | Type | Description | Required | Default |
|-----------|------|-------------|----------|---------|
| `resourceTypes` | Array | The resource types to target | Yes | ["*"] |

### Effect Options (All Policies)
- **Deny**: Blocks deployment of non-compliant resources
- **Audit**: Logs non-compliance without blocking resources
- **Disabled**: Turns off the policy

## Policy Logic

### Resources Policy
```
IF (resource is any type)
   AND (tag validation fails based on tagRequireType)
THEN APPLY [effect parameter]
```

### Resource Groups Policy
```
IF (resource type = Microsoft.Resources/resourceGroups)
   AND (tag validation fails based on tagRequireType)
THEN APPLY [effect parameter]
```

### Resource Type Policy
```
IF (resource type IN [resourceTypes parameter])
   AND (tag validation fails based on tagRequireType)
THEN APPLY [effect parameter]
```

### Tag Validation Logic (All Policies)
```
RequireTagAndValue:
  - Tag must exist AND value must be in allowed set

RequireTagValueFromSet:
  - IF tag exists, THEN value must be in allowed set
  - IF tag doesn't exist, THEN policy passes
```## Usage Examples

### Example 1: Enforce Environment Tags on All Resources
```json
{
  "effect": {
    "value": "Deny"
  },
  "tagRequireType": {
    "value": "RequireTagAndValue"
  },
  "tagName": {
    "value": "environment"
  },
  "tagValues": {
    "value": ["production", "staging", "development", "testing"]
  }
}
```

### Example 2: Audit Cost Center Tags on Resource Groups
```json
{
  "effect": {
    "value": "Audit"
  },
  "tagRequireType": {
    "value": "RequireTagAndValue"
  },
  "tagName": {
    "value": "costCenter"
  },
  "tagValues": {
    "value": ["CC001", "CC002", "CC003", "CC004"]
  }
}
```

### Example 3: Enforce Data Classification on Storage Accounts Only
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

### Example 4: Validate Application Name on Compute Resources
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
    "value": ["webapp1", "api-service", "frontend", "backend"]
  }
}
```

## Deployment

### Azure CLI

#### Resources Policy (All Resources)
```bash
# Create the policy definition
az policy definition create \
  --name "require-tag-from-set-resources" \
  --display-name "Require Tag From Set - All Resources" \
  --description "Enforces tag values from predefined set on all resources" \
  --rules @tags-RequireATagFromASetofValuesOnResources.json \
  --mode Indexed

# Assign the policy
az policy assignment create \
  --name "enforce-environment-tags-resources" \
  --display-name "Enforce Environment Tags on Resources" \
  --policy "require-tag-from-set-resources" \
  --scope "/subscriptions/{subscription-id}" \
  --params '{
    "effect": {"value": "Deny"},
    "tagRequireType": {"value": "RequireTagAndValue"},
    "tagName": {"value": "environment"},
    "tagValues": {"value": ["production", "staging", "development"]}
  }'
```

#### Resource Groups Policy
```bash
# Create the policy definition
az policy definition create \
  --name "require-tag-from-set-rg" \
  --display-name "Require Tag From Set - Resource Groups" \
  --description "Enforces tag values from predefined set on resource groups" \
  --rules @tags-RequireATagFromASetofValuesOnResourceGroups.json \
  --mode All

# Assign the policy
az policy assignment create \
  --name "enforce-cost-center-rg" \
  --display-name "Enforce Cost Center on Resource Groups" \
  --policy "require-tag-from-set-rg" \
  --scope "/subscriptions/{subscription-id}" \
  --params '{
    "effect": {"value": "Deny"},
    "tagRequireType": {"value": "RequireTagAndValue"},
    "tagName": {"value": "costCenter"},
    "tagValues": {"value": ["CC001", "CC002", "CC003"]}
  }'
```

#### Resource Type Specific Policy
```bash
# Create the policy definition
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
```### PowerShell

#### Enhanced Version (with Effect Parameter)
```powershell
# Create policy definition
$policyDef = New-AzPolicyDefinition `
  -Name "require-tag-from-set-enhanced" `
  -DisplayName "Require Tag From Set of Values (Enhanced)" `
  -Description "Enforces tag values from predefined set with configurable effect" `
  -Policy (Get-Content -Path "tags-RequireATagFromASetofValuesOnResources.json" -Raw) `
  -Mode Indexed

# Create assignment with Deny effect
$params = @{
  effect = "Deny"
  tagRequireType = "RequireTagAndValue"
  tagName = "environment"
  tagValues = @("production", "staging", "development")
}

New-AzPolicyAssignment `
  -Name "enforce-environment-tags" `
  -DisplayName "Enforce Environment Tags" `
  -PolicyDefinition $policyDef `
  -Scope "/subscriptions/{subscription-id}" `
  -PolicyParameterObject $params

# Create assignment with Audit effect
$auditParams = @{
  effect = "Audit"
  tagRequireType = "RequireTagValueFromSet"
  tagName = "costCenter"
  tagValues = @("CC001", "CC002", "CC003")
}

New-AzPolicyAssignment `
  -Name "audit-cost-center-tags" `
  -DisplayName "Audit Cost Center Tags" `
  -PolicyDefinition $policyDef `
  -Scope "/subscriptions/{subscription-id}" `
  -PolicyParameterObject $auditParams
```

#### Basic Version (Hardcoded Deny)
```powershell
# Create policy definition
$policyDef = New-AzPolicyDefinition `
  -Name "require-tag-from-set-basic" `
  -DisplayName "Require Tag From Set of Values (Basic)" `
  -Description "Enforces tag values from predefined set with deny effect" `
  -Policy (Get-Content -Path "tags-RequireATagFromASetofValues.json" -Raw) `
  -Mode Indexed

# Create assignment
$params = @{
  tagRequireType = "RequireTagAndValue"
  tagName = "businessUnit"
  tagValues = @("finance", "hr", "engineering")
}

New-AzPolicyAssignment `
  -Name "enforce-business-unit-tags" `
  -DisplayName "Enforce Business Unit Tags" `
  -PolicyDefinition $policyDef `
  -Scope "/subscriptions/{subscription-id}" `
  -PolicyParameterObject $params
```

### ARM Template
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-08-01/managementGroupDeploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "policyDefinition": {
      "type": "object",
      "defaultValue": "[json(loadTextContent('tags-RequireATagFromASetofValues.json'))]"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Authorization/policyDefinitions",
      "apiVersion": "2020-09-01",
      "name": "require-tag-from-set",
      "properties": "[parameters('policyDefinition').properties]"
    }
  ]
}
```

## Common Use Cases

### 1. Environment Governance
- **Tag**: `environment`
- **Values**: `["production", "staging", "development", "sandbox"]`
- **Type**: `RequireTagAndValue`

### 2. Cost Management
- **Tag**: `costCenter`
- **Values**: `["CC001", "CC002", "CC003"]`
- **Type**: `RequireTagAndValue`

### 3. Data Classification
- **Tag**: `dataClassification`
- **Values**: `["public", "internal", "confidential", "restricted"]`
- **Type**: `RequireTagAndValue`

### 4. Application Lifecycle
- **Tag**: `lifecycle`
- **Values**: `["active", "deprecated", "sunset"]`
- **Type**: `RequireTagValueFromSet`

## Policy Selection Guide

### Resources Policy (`tags-RequireATagFromASetofValuesOnResources.json`)
**When to Use:**
- ✅ General tag governance across all Azure resources
- ✅ Organization-wide tag enforcement
- ✅ Broad compliance requirements
- ✅ When you want consistent tagging across all resource types

**Best For:**
- Environment tags (prod/staging/dev)
- General business unit identification
- Broad cost center tracking

### Resource Groups Policy (`tags-RequireATagFromASetofValuesOnResourceGroups.json`)
**When to Use:**
- ✅ Resource group-specific governance
- ✅ High-level organizational structure enforcement
- ✅ Project or application-level tagging
- ✅ Billing and cost allocation at RG level

**Best For:**
- Project identification
- Department ownership
- Cost center allocation
- Application lifecycle management

### Resource Type Policy (`tags-RequireATagFromASetofValuesOnResourceType.json`)
**When to Use:**
- ✅ Specific compliance requirements for certain resource types
- ✅ Security classification on sensitive resources
- ✅ Different tag requirements per resource type
- ✅ Granular governance for critical services

**Best For:**
- Data classification on storage accounts
- Application names on compute resources
- Backup policies on VMs
- Security zones on networking resources

## Common Use Cases by Policy

### 1. Environment Governance
- **Policy**: Resources Policy
- **Tag**: `environment`
- **Values**: `["production", "staging", "development", "sandbox"]`
- **Type**: `RequireTagAndValue`

### 2. Cost Management
- **Policy**: Resource Groups Policy
- **Tag**: `costCenter`
- **Values**: `["CC001", "CC002", "CC003"]`
- **Type**: `RequireTagAndValue`

### 3. Data Classification
- **Policy**: Resource Type Policy (Storage/Databases)
- **Tag**: `dataClassification`
- **Values**: `["public", "internal", "confidential", "restricted"]`
- **Type**: `RequireTagAndValue`

### 4. Application Lifecycle
- **Policy**: Resources Policy
- **Tag**: `lifecycle`
- **Values**: `["active", "deprecated", "sunset"]`
- **Type**: `RequireTagValueFromSet`

### 5. Security Zone Classification
- **Policy**: Resource Type Policy (Networking)
- **Tag**: `securityZone`
- **Values**: `["dmz", "internal", "restricted"]`
- **Type**: `RequireTagAndValue`

## Best Practices

1. **Start with Audit Effect**: Begin with audit mode to understand impact across all policies
2. **Layered Approach**: Use multiple policies for different scopes:
   - Resource Groups Policy for high-level organization
   - Resource Type Policy for specific compliance needs
   - Resources Policy for general governance
3. **Gradual Rollout**: Apply to development environments first
4. **Clear Documentation**: Document approved tag values for teams
5. **Phased Implementation**:
   - Phase 1: Deploy with Audit effect
   - Phase 2: Analyze compliance reports
   - Phase 3: Switch to Deny effect for critical tags
6. **Resource Type Targeting**: Use specific resource type policies for:
   - Security-sensitive resources (storage, databases)
   - High-cost resources (VMs, managed services)
   - Compliance-critical resources
7. **Exception Handling**: Consider exclusions for:
   - System-generated resources
   - Legacy resources during migration
   - Service-specific requirements

## Implementation Strategy

### Phase 1: Foundation (Resource Groups)
1. Deploy Resource Groups Policy with basic tags (environment, costCenter)
2. Use Audit effect initially
3. Establish baseline compliance

### Phase 2: General Resources
1. Deploy Resources Policy for organization-wide tags
2. Start with RequireTagValueFromSet for optional enforcement
3. Monitor compliance rates

### Phase 3: Targeted Enforcement
1. Deploy Resource Type Policy for specific requirements
2. Focus on critical resource types first
3. Use Deny effect for security/compliance tags

### Phase 4: Full Enforcement
1. Switch all policies to Deny effect
2. Implement comprehensive tag governance
3. Regular review and updates

## Troubleshooting

### Common Issues

**Issue**: Policy blocking legitimate deployments
- **Solution**: Verify tag values match exactly (case-sensitive)
- **Check**: Ensure tag name spelling is correct

**Issue**: Policy not triggering
- **Solution**: Confirm policy is assigned at correct scope
- **Check**: Verify policy assignment parameters

**Issue**: Existing resources not evaluated
- **Solution**: This policy only affects new deployments
- **Action**: Use remediation for existing resources

### Testing

Test the policy with sample deployments:

```bash
# This should succeed
az vm create \
  --name "test-vm" \
  --resource-group "test-rg" \
  --image "Ubuntu2204" \
  --tags environment=development

# This should fail
az vm create \
  --name "test-vm2" \
  --resource-group "test-rg" \
  --image "Ubuntu2204" \
  --tags environment=invalid
```

## Compliance Monitoring

Monitor policy compliance through:
- Azure Policy Compliance dashboard
- Azure Resource Graph queries
- Azure Monitor alerts for policy violations

```kusto
// Query for non-compliant resources
PolicyResources
| where type == "microsoft.authorization/policyassignments"
| where properties.displayName == "Enforce Environment Tags"
| project assignmentId = id, scope = properties.scope
| join (
    Resources
    | where tags !has "environment" or tags.environment !in ("production", "staging", "development")
    | project resourceId = id, resourceType = type, tags
) on $left.scope == $right.resourceId
```

## Related Policies

Consider combining this policy with:
- Tag inheritance policies
- Required tags policies
- Tag governance initiative
- Resource naming conventions
