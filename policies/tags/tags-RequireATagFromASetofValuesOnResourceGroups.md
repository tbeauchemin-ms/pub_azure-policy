# Require a Tag from a Set of Values on Resource Groups

**File**: `tags-RequireATagFromASetofValuesOnResourceGroups.json`
**Display Name**: "Require a tag and value from a set of values on resource groups"
**Category**: Tags
**Mode**: Indexed

## Overview

This policy enforces tag governance specifically on Azure Resource Groups, ensuring they have specific tags with values from predefined sets. It's designed for high-level organizational structure enforcement.

## Description

Enforces a tag and its value from a set of values on resource groups only. This policy helps maintain organizational structure and enables proper cost allocation and governance at the resource group level.

## Target Scope

- **Resources**: Resource Groups only
- **Mode**: Indexed
- **Resource Filter**: `Microsoft.Resources/resourceGroups`

## Parameters

| Parameter | Type | Description | Required | Default |
|-----------|------|-------------|----------|---------|
| `effect` | String | Policy enforcement effect | Yes | Deny |
| `tagRequireType` | String | Defines the enforcement behavior | Yes | - |
| `tagName` | String | The name of the tag to enforce | Yes | - |
| `tagValues` | Array | List of allowed values for the tag | Yes | - |

### Effect Options
- **Deny**: Blocks creation/modification of non-compliant resource groups
- **Audit**: Logs non-compliance without blocking operations
- **Disabled**: Turns off the policy

### Tag Requirement Types

#### RequireTagAndValue
- **Behavior**: Tag must exist AND have a value from the allowed set
- **Use Case**: Mandatory resource group categorization
- **Example**: All resource groups must have "costCenter" tag with values ["CC001", "CC002", "CC003"]

#### RequireTagValueFromSet
- **Behavior**: If tag exists, it must have a value from the allowed set
- **Use Case**: Optional tags that must conform when present
- **Example**: If "project" tag is applied, it must be from approved project list

## Policy Logic

```
IF (resource type = Microsoft.Resources/resourceGroups)
   AND (tag validation fails based on tagRequireType)
THEN APPLY [effect parameter]

Tag Validation:
- RequireTagAndValue: Tag must exist AND value must be in allowed set
- RequireTagValueFromSet: IF tag exists, THEN value must be in allowed set
```

## Usage Examples

### Example 1: Enforce Cost Center on Resource Groups
```json
{
  "effect": {
    "value": "Deny"
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

### Example 2: Validate Project Names (Optional)
```json
{
  "effect": {
    "value": "Audit"
  },
  "tagRequireType": {
    "value": "RequireTagValueFromSet"
  },
  "tagName": {
    "value": "projectName"
  },
  "tagValues": {
    "value": ["ProjectAlpha", "ProjectBeta", "ProjectGamma"]
  }
}
```

### Example 3: Enforce Department Tags
```json
{
  "effect": {
    "value": "Deny"
  },
  "tagRequireType": {
    "value": "RequireTagAndValue"
  },
  "tagName": {
    "value": "department"
  },
  "tagValues": {
    "value": ["finance", "hr", "engineering", "marketing", "operations"]
  }
}
```

## Deployment

### Azure CLI
```bash
# Create policy definition
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

### PowerShell
```powershell
# Create policy definition
$policyDef = New-AzPolicyDefinition `
  -Name "require-tag-from-set-rg" `
  -DisplayName "Require Tag From Set - Resource Groups" `
  -Description "Enforces tag values from predefined set on resource groups" `
  -Policy (Get-Content -Path "tags-RequireATagFromASetofValuesOnResourceGroups.json" -Raw) `
  -Mode All

# Create assignment
$params = @{
  effect = "Deny"
  tagRequireType = "RequireTagAndValue"
  tagName = "costCenter"
  tagValues = @("CC001", "CC002", "CC003")
}

New-AzPolicyAssignment `
  -Name "enforce-cost-center-rg" `
  -DisplayName "Enforce Cost Center on Resource Groups" `
  -PolicyDefinition $policyDef `
  -Scope "/subscriptions/{subscription-id}" `
  -PolicyParameterObject $params
```

## When to Use This Policy

✅ **Best For:**
- Resource group-specific governance
- High-level organizational structure enforcement
- Project or application-level tagging
- Billing and cost allocation at RG level

✅ **Use Cases:**
- Project identification and management
- Department ownership tracking
- Cost center allocation
- Application lifecycle management
- Environment separation at RG level

✅ **Recommended Approach:**
- Implement early in Azure adoption
- Focus on financial and organizational tags
- Use for hierarchical governance structure
- Combine with resource-level policies

## Best Practices

1. **Organizational Alignment**: Align tags with your organizational structure
2. **Financial Integration**: Use for cost allocation and chargeback
3. **Naming Standards**: Establish clear naming conventions for tag values
4. **Lifecycle Management**: Include tags for resource group lifecycle tracking
5. **Governance Hierarchy**: Use as foundation for broader governance policies

## Common Tag Examples

### Cost Management
- `costCenter`: ["CC001", "CC002", "CC003"]
- `budgetCode`: ["B001", "B002", "B003"]
- `businessUnit`: ["finance", "hr", "engineering"]

### Project Management
- `projectName`: ["ProjectAlpha", "ProjectBeta"]
- `projectOwner`: ["team-a", "team-b", "team-c"]
- `projectPhase`: ["development", "testing", "production"]

### Organizational
- `department`: ["finance", "hr", "it", "marketing"]
- `environment`: ["prod", "staging", "dev"]
- `criticality`: ["high", "medium", "low"]

## Related Policies

- [Resources Policy](tags-RequireATagFromASetofValuesOnResources.md) - For all resource governance
- [Resource Type Policy](tags-RequireATagFromASetofValuesOnResourceType.md) - For specific resource type enforcement
