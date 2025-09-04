# Inherit a Tag from Resource Group on Resource Type

**File**: `tags-InheritATagFromResourceGroupOnResourceType.json`
**Display Name**: "Inherit a tag from the resource group on specific resource types"
**Category**: Tags
**Mode**: Indexed
**Effect**: Modify (Fixed)

## Overview

This policy automatically inherits tag values from the parent resource group to resources of specified types. It ensures consistent tagging hierarchy by copying tag values from resource groups to their contained resources, supporting both creation-time inheritance and ongoing synchronization.

## Description

Adds or replaces the specified tag and value from the parent resource group on specific resource types when any resource is created or updated. This policy uses the `modify` effect to ensure resources inherit organizational context from their resource group, enabling hierarchical tag governance and consistent metadata propagation.

## Target Scope

- **Resources**: Configurable resource types within resource groups
- **Mode**: Indexed
- **Effect**: Modify (with role permissions)
- **Resource Filter**: Configurable array of resource types
- **Inheritance Source**: Parent resource group tags

## How It Works

The policy operates during resource **creation and updates** with the following logic:
1. **Checks**: If the resource type matches AND resource group has the specified tag AND resource's tag value differs
2. **Action**: Copies the tag value from resource group to the resource
3. **Result**: Resource inherits the tag value from its parent resource group
4. **Remediation**: Existing resources can be updated through remediation tasks

## Parameters

| Parameter | Type | Description | Required | Default |
|-----------|------|-------------|----------|---------|
| `resourceTypes` | Array | The resource types to target | Yes | ["*"] |
| `tagName` | String | The name of the tag to inherit | Yes | - |

### Resource Types Parameter
- **Format**: Array of Azure resource type strings
- **Example**: `["Microsoft.Storage/storageAccounts", "Microsoft.Compute/virtualMachines"]`
- **Wildcard**: Use `["*"]` to target all resource types
- **Inheritance**: Only works for resources deployed within resource groups

## Policy Logic

```
IF (resource type IN [resourceTypes parameter])
   AND (resource group has tag [tagName])
   AND (resource tag [tagName] != resource group tag [tagName])
   AND (resource group tag [tagName] is not empty)
THEN MODIFY resource tag [tagName] = resource group tag [tagName]
```

**Key Behaviors:**
- ✅ **Hierarchical**: Inherits from parent resource group
- ✅ **Dynamic**: Updates when resource group tag changes
- ✅ **Conditional**: Only applies when values differ
- ✅ **Remediation**: Can update existing resources
- ✅ **Role-based**: Requires Contributor permissions

## Required Permissions

The policy uses the `modify` effect, which requires:
- **Role**: Contributor (`b24988ac-6180-42a0-ab88-20f7382dd24c`)
- **Scope**: Subscription or resource group level
- **Purpose**: Allows modification of resource tags

## Usage Examples

### Example 1: Inherit Cost Center from Resource Group
```json
{
  "resourceTypes": {
    "value": ["*"]
  },
  "tagName": {
    "value": "costCenter"
  }
}
```

### Example 2: Inherit Environment Tags for Compute Resources
```json
{
  "resourceTypes": {
    "value": [
      "Microsoft.Compute/virtualMachines",
      "Microsoft.Web/sites"
    ]
  },
  "tagName": {
    "value": "environment"
  }
}
```

### Example 3: Inherit Project Name for Storage Resources
```json
{
  "resourceTypes": {
    "value": [
      "Microsoft.Storage/storageAccounts",
      "Microsoft.DocumentDB/databaseAccounts",
      "Microsoft.Sql/servers"
    ]
  },
  "tagName": {
    "value": "projectName"
  }
}
```

### Example 4: Inherit Department for All Resources
```json
{
  "resourceTypes": {
    "value": ["*"]
  },
  "tagName": {
    "value": "department"
  }
}
```

## Deployment

### Azure CLI
```bash
# Create policy definition
az policy definition create \
  --name "inherit-tag-from-rg" \
  --display-name "Inherit Tag from Resource Group" \
  --description "Inherits tag values from parent resource group" \
  --rules @tags-InheritATagFromResourceGroupOnResourceType.json \
  --mode Indexed

# Assign to inherit cost center on all resources
az policy assignment create \
  --name "inherit-cost-center" \
  --display-name "Inherit Cost Center from RG" \
  --policy "inherit-tag-from-rg" \
  --scope "/subscriptions/{subscription-id}" \
  --assign-identity \
  --location "{location}" \
  --params '{
    "resourceTypes": {"value": ["*"]},
    "tagName": {"value": "costCenter"}
  }'

# Assign required permissions to the policy identity
az role assignment create \
  --assignee "{policy-identity-principal-id}" \
  --role "Contributor" \
  --scope "/subscriptions/{subscription-id}"
```

### PowerShell
```powershell
# Create policy definition
$policyDef = New-AzPolicyDefinition `
  -Name "inherit-tag-from-rg" `
  -DisplayName "Inherit Tag from Resource Group" `
  -Description "Inherits tag values from parent resource group" `
  -Policy (Get-Content -Path "tags-InheritATagFromResourceGroupOnResourceType.json" -Raw) `
  -Mode Indexed

# Create assignment with managed identity
$params = @{
  resourceTypes = @("*")
  tagName = "department"
}

$assignment = New-AzPolicyAssignment `
  -Name "inherit-department" `
  -DisplayName "Inherit Department from RG" `
  -PolicyDefinition $policyDef `
  -Scope "/subscriptions/{subscription-id}" `
  -AssignIdentity `
  -Location "{location}" `
  -PolicyParameterObject $params

# Assign required permissions to the managed identity
New-AzRoleAssignment `
  -ObjectId $assignment.Identity.PrincipalId `
  -RoleDefinitionName "Contributor" `
  -Scope "/subscriptions/{subscription-id}"
```

## When to Use This Policy

✅ **Best For:**
- Hierarchical tag governance
- Consistent organizational metadata
- Cost allocation from resource groups
- Simplified tag management

✅ **Use Cases:**
- Cost center inheritance for billing
- Project identification propagation
- Environment classification consistency
- Department ownership tracking

✅ **Advantages:**
- Automatic synchronization with resource group changes
- Reduces manual tag management overhead
- Ensures consistent hierarchical tagging
- Works with existing resources through remediation

⚠️ **Considerations:**
- Requires Contributor permissions
- Only works within resource groups (not subscriptions)
- Overwrites existing resource tag values
- May conflict with manually managed tags

## Tag Inheritance Scenarios

### 🏢 **Organizational Structure**
```
Subscription: Production
├── Resource Group: Finance-Apps (costCenter: CC001, department: Finance)
│   ├── Storage Account → Inherits: costCenter=CC001, department=Finance
│   └── Web App → Inherits: costCenter=CC001, department=Finance
└── Resource Group: Engineering-Apps (costCenter: CC002, department: Engineering)
    ├── Virtual Machine → Inherits: costCenter=CC002, department=Engineering
    └── Database → Inherits: costCenter=CC002, department=Engineering
```

### 📊 **Project-Based Organization**
```
Resource Group: Project-Alpha (projectName: Alpha, owner: TeamA)
├── App Service → Inherits: projectName=Alpha, owner=TeamA
├── SQL Database → Inherits: projectName=Alpha, owner=TeamA
└── Storage Account → Inherits: projectName=Alpha, owner=TeamA
```

## Best Practices

### 🎯 **Strategic Implementation**
1. **Resource Group Strategy**: Establish clear resource group organization
2. **Tag Hierarchy**: Define which tags should inherit vs. be resource-specific
3. **Consistent RG Tagging**: Ensure resource groups have required tags
4. **Gradual Rollout**: Start with non-production environments

### 🏗️ **Architecture Considerations**
1. **Resource Group Design**: Align resource groups with inheritance needs
2. **Tag Conflicts**: Consider how inheritance interacts with other tag policies
3. **Permission Management**: Plan for Contributor role requirements
4. **Remediation Strategy**: Plan for updating existing resources

### 🔄 **Operational Excellence**
1. **Monitor Inheritance**: Track successful tag inheritance
2. **Regular Audits**: Verify resource group tags are properly maintained
3. **Change Management**: Coordinate resource group tag changes
4. **Documentation**: Document inheritance patterns for teams

## Common Inheritance Patterns

### Pattern 1: Financial Management
- **Resource Group Tags**: `costCenter`, `budgetCode`, `businessUnit`
- **Inherited By**: All resources for cost allocation
- **Benefit**: Automatic cost center tracking

### Pattern 2: Project Organization
- **Resource Group Tags**: `projectName`, `projectOwner`, `projectPhase`
- **Inherited By**: All project resources
- **Benefit**: Consistent project metadata

### Pattern 3: Environment Classification
- **Resource Group Tags**: `environment`, `criticality`, `dataClassification`
- **Inherited By**: All resources for compliance
- **Benefit**: Consistent environment governance

### Pattern 4: Operational Context
- **Resource Group Tags**: `supportTeam`, `maintenanceWindow`, `backupPolicy`
- **Inherited By**: Specific resource types (VMs, databases)
- **Benefit**: Operational consistency

## Remediation and Management

### Immediate Remediation
```bash
# Create remediation task for existing resources
az policy remediation create \
  --name "remediate-tag-inheritance" \
  --policy-assignment "inherit-cost-center" \
  --resource-group "finance-apps" \
  --resource-discovery-mode "ReEvaluateCompliance"
```

### Bulk Remediation
```powershell
# Remediate all non-compliant resources
$assignment = Get-AzPolicyAssignment -Name "inherit-department"
Start-AzPolicyRemediation `
  -Name "bulk-inherit-remediation" `
  -PolicyAssignmentId $assignment.Id `
  -ResourceDiscoveryMode "ReEvaluateCompliance"
```

### Monitoring Inheritance Success
```kusto
// Azure Resource Graph query to check inheritance compliance
Resources
| extend rgTags = resourceGroup().tags
| extend resourceCostCenter = tags.costCenter
| extend rgCostCenter = rgTags.costCenter
| where isnotempty(rgCostCenter)
| summarize
    TotalResources = count(),
    InheritedCorrectly = countif(resourceCostCenter == rgCostCenter),
    MissingInheritance = countif(isempty(resourceCostCenter)),
    ComplianceRate = round(100.0 * countif(resourceCostCenter == rgCostCenter) / count(), 2)
by resourceGroup
```

## Troubleshooting

### Common Issues
1. **No Inheritance**: Check resource group has the specified tag
2. **Permission Errors**: Verify Contributor role assignment to policy identity
3. **Tag Not Updated**: Trigger remediation or update the resource
4. **Partial Inheritance**: Check resource type inclusion in policy

### Validation Steps
1. Verify resource group has source tag with value
2. Confirm resource type is included in policy
3. Check policy assignment has managed identity enabled
4. Validate managed identity has required permissions

## Related Policies

- [Append Tag Policy](tags-AppendATagOnResourceType.md) - For adding default tags
- [Require Tag Policy](tags-RequireATagFromASetofValuesOnResourceType.md) - For enforcing specific values
- [Resource Groups Policy](tags-RequireATagFromASetofValuesOnResourceGroups.md) - For resource group governance
