# Require a Tag from a Set of Values on Resources

**File**: `tags-RequireATagFromASetofValuesOnResources.json`
**Display Name**: "Require a tag and value from a set of values on resources"
**Category**: Tags
**Mode**: Indexed

## Overview

This policy enforces tag governance on all Azure resources by ensuring they have specific tags with values from predefined sets. It provides the most comprehensive tag enforcement across your Azure environment.

## Description

Enforces a tag and its value from a set of values on all resources. Does not apply to resource groups. This policy helps maintain consistency and compliance across your Azure environment by restricting tag values to a predefined set.

## Target Scope

- **Resources**: All Azure resources
- **Mode**: Indexed (resources only, not resource groups)
- **Resource Filter**: All resource types

## Parameters

| Parameter | Type | Description | Required | Default |
|-----------|------|-------------|----------|---------|
| `effect` | String | Policy enforcement effect | Yes | Deny |
| `tagRequireType` | String | Defines the enforcement behavior | Yes | - |
| `tagName` | String | The name of the tag to enforce | Yes | - |
| `tagValues` | Array | List of allowed values for the tag | Yes | - |

### Effect Options
- **Deny**: Blocks deployment of non-compliant resources
- **Audit**: Logs non-compliance without blocking resources
- **Disabled**: Turns off the policy

### Tag Requirement Types

#### RequireTagAndValue
- **Behavior**: Tag must exist AND have a value from the allowed set
- **Use Case**: Mandatory tags with restricted values
- **Example**: All resources must have "environment" tag with values ["production", "staging", "development"]

#### RequireTagValueFromSet
- **Behavior**: If tag exists, it must have a value from the allowed set
- **Use Case**: Optional tags that must conform when present
- **Example**: If "costCenter" tag is applied, it must be from ["CC001", "CC002", "CC003"]

## Policy Logic

```
IF (resource is any type)
   AND (tag validation fails based on tagRequireType)
THEN APPLY [effect parameter]

Tag Validation:
- RequireTagAndValue: Tag must exist AND value must be in allowed set
- RequireTagValueFromSet: IF tag exists, THEN value must be in allowed set
```

## Usage Examples

### Example 1: Enforce Environment Tags (Deny)
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

### Example 2: Audit Application Tags (Optional)
```json
{
  "effect": {
    "value": "Audit"
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
```bash
# Create policy definition
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

### PowerShell
```powershell
# Create policy definition
$policyDef = New-AzPolicyDefinition `
  -Name "require-tag-from-set-resources" `
  -DisplayName "Require Tag From Set - All Resources" `
  -Description "Enforces tag values from predefined set on all resources" `
  -Policy (Get-Content -Path "tags-RequireATagFromASetofValuesOnResources.json" -Raw) `
  -Mode Indexed

# Create assignment
$params = @{
  effect = "Deny"
  tagRequireType = "RequireTagAndValue"
  tagName = "environment"
  tagValues = @("production", "staging", "development")
}

New-AzPolicyAssignment `
  -Name "enforce-environment-tags-resources" `
  -DisplayName "Enforce Environment Tags on Resources" `
  -PolicyDefinition $policyDef `
  -Scope "/subscriptions/{subscription-id}" `
  -PolicyParameterObject $params
```

## When to Use This Policy

✅ **Best For:**
- Organization-wide tag enforcement
- General compliance requirements across all resources
- Environment and business unit identification
- Broad cost center tracking

✅ **Use Cases:**
- Environment governance (prod/staging/dev)
- Business unit identification
- General cost allocation
- Compliance frameworks requiring universal tagging

✅ **Recommended Approach:**
- Start with Audit effect to understand current state
- Use RequireTagValueFromSet for gradual adoption
- Switch to Deny for critical compliance tags
- Implement organization-wide after testing

## Best Practices

1. **Gradual Implementation**: Start with audit mode and RequireTagValueFromSet
2. **Universal Tags**: Focus on tags needed across all resource types
3. **Regular Review**: Periodically update allowed values
4. **Clear Communication**: Document tag requirements for all teams
5. **Exception Planning**: Consider system-generated resources that may need exclusions

## Related Policies

- [Resource Groups Policy](tags-RequireATagFromASetofValuesOnResourceGroups.md) - For resource group-specific governance
- [Resource Type Policy](tags-RequireATagFromASetofValuesOnResourceType.md) - For targeted resource type enforcement
