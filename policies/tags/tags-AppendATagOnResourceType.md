# Append a Tag on Resource Type

**File**: `tags-AppendATagOnResourceType.json`
**Display Name**: "Require a tag and value from a set of values on specific resource types"
**Category**: Tags
**Mode**: Indexed
**Effect**: Append (Fixed)

## Overview

This policy automatically appends a specific tag with a predefined value to resources of specified types when the tag doesn't exist. It's designed for ensuring consistent tagging without disrupting existing deployments or requiring manual intervention.

## Description

Enforces a tag and its value on specific resource types by automatically appending the tag when it's missing. This policy uses the `append` effect to add tags during resource creation without blocking deployments, making it ideal for gradual tag adoption and ensuring baseline compliance.

## Target Scope

- **Resources**: Configurable resource types
- **Mode**: Indexed
- **Effect**: Append (non-blocking)
- **Resource Filter**: Configurable array of resource types

## How It Works

The policy operates during resource **creation and updates** with the following logic:
1. **Checks**: If the resource type matches the configured types AND the specified tag doesn't exist
2. **Action**: Automatically appends the tag with the specified value
3. **Result**: Resource deployment continues successfully with the tag applied

> **Note**: The `append` effect only works during resource creation/update operations. It does not modify existing resources retroactively.

## Parameters

| Parameter | Type | Description | Required | Default |
|-----------|------|-------------|----------|---------|
| `resourceTypes` | Array | The resource types to target | Yes | ["*"] |
| `tagName` | String | The name of the tag to append | Yes | - |
| `tagValue` | String | The value to assign to the tag | Yes | - |

### Resource Types Parameter
- **Format**: Array of Azure resource type strings
- **Example**: `["Microsoft.Storage/storageAccounts", "Microsoft.Compute/virtualMachines"]`
- **Wildcard**: Use `["*"]` to target all resource types
- **Common Types**: See examples section for frequently used resource types

## Policy Logic

```
IF (resource type IN [resourceTypes parameter])
   AND (tag [tagName] does NOT exist on resource)
THEN APPEND tag [tagName] with value [tagValue]
```

**Key Behaviors:**
- ✅ **Non-blocking**: Deployments continue successfully
- ✅ **Conditional**: Only applies when tag is missing
- ✅ **Automatic**: No manual intervention required
- ❌ **Creation-only**: Does not modify existing resources

## Usage Examples

### Example 1: Auto-tag Storage Accounts with Environment
```json
{
  "resourceTypes": {
    "value": ["Microsoft.Storage/storageAccounts"]
  },
  "tagName": {
    "value": "environment"
  },
  "tagValue": {
    "value": "production"
  }
}
```

### Example 2: Add Default Cost Center to All Resources
```json
{
  "resourceTypes": {
    "value": ["*"]
  },
  "tagName": {
    "value": "defaultCostCenter"
  },
  "tagValue": {
    "value": "IT-Operations"
  }
}
```

### Example 3: Auto-tag Virtual Machines with Backup Policy
```json
{
  "resourceTypes": {
    "value": ["Microsoft.Compute/virtualMachines"]
  },
  "tagName": {
    "value": "backupPolicy"
  },
  "tagValue": {
    "value": "daily-backup"
  }
}
```

### Example 4: Add Monitoring Flag to Web Apps
```json
{
  "resourceTypes": {
    "value": [
      "Microsoft.Web/sites",
      "Microsoft.Web/serverfarms"
    ]
  },
  "tagName": {
    "value": "monitoringEnabled"
  },
  "tagValue": {
    "value": "true"
  }
}
```

## Deployment

### Azure CLI
```bash
# Create policy definition
az policy definition create \
  --name "append-tag-resource-type" \
  --display-name "Append Tag on Resource Type" \
  --description "Automatically appends a tag to specified resource types" \
  --rules @tags-AppendATagOnResourceType.json \
  --mode Indexed

# Assign to append environment tag on storage accounts
az policy assignment create \
  --name "append-env-storage" \
  --display-name "Auto-tag Storage with Environment" \
  --policy "append-tag-resource-type" \
  --scope "/subscriptions/{subscription-id}" \
  --params '{
    "resourceTypes": {"value": ["Microsoft.Storage/storageAccounts"]},
    "tagName": {"value": "environment"},
    "tagValue": {"value": "production"}
  }'
```

### PowerShell
```powershell
# Create policy definition
$policyDef = New-AzPolicyDefinition `
  -Name "append-tag-resource-type" `
  -DisplayName "Append Tag on Resource Type" `
  -Description "Automatically appends a tag to specified resource types" `
  -Policy (Get-Content -Path "tags-AppendATagOnResourceType.json" -Raw) `
  -Mode Indexed

# Create assignment for VM backup policy
$params = @{
  resourceTypes = @("Microsoft.Compute/virtualMachines")
  tagName = "backupPolicy"
  tagValue = "daily-backup"
}

New-AzPolicyAssignment `
  -Name "append-backup-policy-vms" `
  -DisplayName "Auto-tag VMs with Backup Policy" `
  -PolicyDefinition $policyDef `
  -Scope "/subscriptions/{subscription-id}" `
  -PolicyParameterObject $params
```

## When to Use This Policy

✅ **Best For:**
- Ensuring baseline tags without blocking deployments
- Gradual tag adoption across the organization
- Default values for optional tags
- Consistent metadata application

✅ **Use Cases:**
- Auto-tagging new resources with environment information
- Adding default cost centers or departments
- Applying monitoring or backup policies
- Setting compliance or security baseline tags

✅ **Advantages:**
- Non-disruptive to existing workflows
- Automatic compliance without user action
- Reduces manual tagging errors
- Enables consistent baseline governance

❌ **Limitations:**
- Only applies to new/updated resources
- Cannot override existing tag values
- Single tag value (not dynamic)
- Requires remediation for existing resources

## Common Use Cases

### 🏢 **Organizational Defaults**
- Default department or business unit
- Standard cost center allocation
- Default project categorization

### 🛡️ **Security & Compliance**
- Security baseline classifications
- Compliance framework tags
- Default encryption requirements

### 💰 **Cost Management**
- Default billing codes
- Standard cost allocation
- Budget category assignments

### 🔧 **Operations**
- Monitoring enablement flags
- Backup policy assignments
- Maintenance window specifications

## Best Practices

### 🎯 **Strategic Implementation**
1. **Start Small**: Begin with most critical tags and resource types
2. **Test First**: Implement in development environments before production
3. **Document Standards**: Clearly define what tags will be auto-applied
4. **Monitor Impact**: Track compliance improvement over time

### 📊 **Tag Selection**
1. **Universal Tags**: Choose tags that apply broadly across resource types
2. **Default Values**: Use sensible defaults that work for most scenarios
3. **Avoid Conflicts**: Don't auto-append tags that teams manually manage
4. **Complement Other Policies**: Use alongside require/inherit policies

### 🔄 **Operational Considerations**
1. **Remediation Planning**: Plan for existing resources without these tags
2. **Change Management**: Communicate auto-tagging to development teams
3. **Exception Handling**: Consider resources that shouldn't have certain tags
4. **Regular Review**: Periodically review and update default values

## Remediation for Existing Resources

Since the `append` effect only works during resource creation/update, existing resources need remediation:

### Azure CLI Remediation
```bash
# Create remediation task for existing resources
az policy remediation create \
  --name "remediate-missing-tags" \
  --policy-assignment "append-env-storage" \
  --resource-group "my-resource-group"
```

### PowerShell Remediation
```powershell
# Start remediation for existing resources
Start-AzPolicyRemediation `
  -Name "remediate-missing-tags" `
  -PolicyAssignmentId "/subscriptions/{sub-id}/providers/Microsoft.Authorization/policyAssignments/append-env-storage" `
  -ResourceGroupName "my-resource-group"
```

## Monitoring and Validation

### Compliance Tracking
- Monitor policy compliance in Azure Policy dashboard
- Use Azure Resource Graph to query tagged resources
- Set up alerts for compliance rate changes

### Sample Resource Graph Query
```kusto
Resources
| where type in ('microsoft.storage/storageaccounts')
| extend hasEnvironmentTag = isnotempty(tags.environment)
| summarize
    TotalResources = count(),
    TaggedResources = countif(hasEnvironmentTag),
    ComplianceRate = round(100.0 * countif(hasEnvironmentTag) / count(), 2)
```

## Related Policies

- [Inherit Tag Policy](tags-InheritATagFromResourceGroupOnResourceType.md) - For inheriting tags from resource groups
- [Require Tag Policy](tags-RequireATagFromASetofValuesOnResourceType.md) - For enforcing specific tag values
- [Resources Policy](tags-RequireATagFromASetofValuesOnResources.md) - For broad resource governance
