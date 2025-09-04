# Tag Governance Policies

This directory contains Azure Policies that enforce tag governance across different resource types and scopes. These policies ensure resources have specific tags with values from predefined sets of allowed values, providing flexibility in enforcement through different requirement types and effects.

## Table of Contents

| Policy | Description | Target Scope | Documentation |
|--------|-------------|--------------|---------------|
| **Resources Policy** | Enforces tag governance on all Azure resources | All resources | [📄 View Details](tags-RequireATagFromASetofValuesOnResources.md) |
| **Resource Groups Policy** | Enforces tag governance specifically on resource groups | Resource groups only | [📄 View Details](tags-RequireATagFromASetofValuesOnResourceGroups.md) |
| **Resource Type Policy** | Enforces tag governance on specific resource types | Configurable resource types | [📄 View Details](tags-RequireATagFromASetofValuesOnResourceType.md) |
| **Append Tag Policy** | Automatically appends missing tags with default values | Configurable resource types | [📄 View Details](tags-AppendATagOnResourceType.md) |
| **Inherit Tag Policy** | Inherits tag values from parent resource groups | Configurable resource types | [📄 View Details](tags-InheritATagFromResourceGroupOnResourceType.md) |

## Quick Overview

### 📋 Resources Policy (`tags-RequireATagFromASetofValuesOnResources.json`)
**Best for**: Organization-wide tag enforcement and general compliance requirements
- **Scope**: All Azure resources (mode: Indexed)
- **Effect**: Configurable (Deny, Audit, Disabled)
- **Use Cases**: Environment governance, business unit identification, universal compliance

### 🏢 Resource Groups Policy (`tags-RequireATagFromASetofValuesOnResourceGroups.json`)
**Best for**: High-level organizational structure and cost allocation
- **Scope**: Resource groups only
- **Effect**: Configurable (Deny, Audit, Disabled)
- **Use Cases**: Project identification, department ownership, cost center allocation

### 🎯 Resource Type Policy (`tags-RequireATagFromASetofValuesOnResourceType.json`)
**Best for**: Targeted enforcement on specific Azure services
- **Scope**: Configurable resource types
- **Effect**: Configurable (Deny, Audit, Disabled)
- **Use Cases**: Data classification on storage, security zones on networking, backup policies on VMs

### 🏷️ Append Tag Policy (`tags-AppendATagOnResourceType.json`)
**Best for**: Automatic baseline tagging without blocking deployments
- **Scope**: Configurable resource types
- **Effect**: Append (fixed, non-blocking)
- **Use Cases**: Default environment tags, automatic cost center assignment, baseline compliance tags

### 🔗 Inherit Tag Policy (`tags-InheritATagFromResourceGroupOnResourceType.json`)
**Best for**: Hierarchical tag governance from resource groups to resources
- **Scope**: Configurable resource types within resource groups
- **Effect**: Modify (fixed, with permissions)
- **Use Cases**: Cost center inheritance, project name propagation, organizational hierarchy
- **Use Cases**: Data classification on storage, security zones on networking, backup policies on VMs

## Common Properties

All policies in this directory share:
- **Category**: Tags
- **Policy Type**: Custom
- **Mode**: Indexed
- **Effect Options**: Deny, Audit, Disabled (default: Deny)

## Implementation Strategy

### 🚀 Phase 1: Foundation (Resource Groups + Auto-Tagging)
Start with resource group governance and baseline auto-tagging
- Deploy Resource Groups Policy with basic organizational tags
- Deploy Append Tag Policy for automatic baseline tags
- Focus on cost center, department, and project identification
- Use Audit effect initially to understand current state

### � Phase 2: Hierarchical Inheritance
Establish tag inheritance from resource groups to resources
- Deploy Inherit Tag Policy for cost center and department propagation
- Enable automatic inheritance of organizational context
- Reduce manual tagging overhead through hierarchy
- Monitor inheritance compliance and effectiveness

### �📈 Phase 3: General Resources
Expand to all resources for universal compliance
- Deploy Resources Policy for organization-wide requirements
- Start with environment and business unit tags
- Monitor compliance rates before enforcing
- Complement with append policies for missing baseline tags

### 🎯 Phase 4: Targeted Enforcement
Apply specific requirements to critical resource types
- Deploy Resource Type Policy for security and compliance needs
- Focus on storage accounts, VMs, and networking resources
- Use Deny effect for critical security and compliance tags
- Leverage inheritance for organizational context

### ✅ Phase 5: Full Governance
Complete comprehensive tag governance across all scopes
- Switch enforcement policies to Deny effect where appropriate
- Maintain automatic tagging through append and inherit policies
- Regular review and optimization of tag values
- Ongoing compliance monitoring and reporting

## Tag Requirement Types

All policies support two enforcement behaviors:

### RequireTagAndValue
- **Behavior**: Tag must exist AND have a value from the allowed set
- **Use Case**: Mandatory tags with restricted values
- **Example**: All resources must have "environment" with values ["prod", "staging", "dev"]

### RequireTagValueFromSet
- **Behavior**: If tag exists, it must have a value from the allowed set
- **Use Case**: Optional tags that must conform when present
- **Example**: If "costCenter" is applied, it must be from approved list

## Policy Selection Guide

| Scenario | Recommended Policy | Reasoning |
|----------|-------------------|-----------|
| Organization-wide environment tags | Resources Policy | Applies to all resources uniformly |
| Cost center allocation | Resource Groups Policy + Inherit Policy | RG-level tracking with automatic propagation |
| Data classification on storage | Resource Type Policy | Specific to sensitive resource types |
| Project identification | Resource Groups Policy + Inherit Policy | Natural organizational boundary with propagation |
| Security zone classification | Resource Type Policy | Targeted to networking resources |
| General compliance framework | Resources Policy | Broad applicability |
| Baseline tagging for new resources | Append Tag Policy | Non-disruptive automatic tagging |
| Hierarchical cost center tracking | Inherit Tag Policy | Automatic RG-to-resource propagation |
| Default values for optional tags | Append Tag Policy | Ensures minimum baseline without blocking |
| Organizational context inheritance | Inherit Tag Policy | Maintains consistent hierarchical metadata |

## Best Practices

### 🎯 **Start Strategic**
- Begin with Resource Groups Policy for organizational foundation
- Focus on most critical tags first (environment, cost center)
- Use Audit effect initially to understand impact

### 📊 **Layered Approach**
- Use multiple policies for different governance levels
- Resource Groups for organizational structure
- Resources for universal requirements
- Resource Types for specific compliance needs

### 🔄 **Gradual Implementation**
- Phase rollout across environments (dev → staging → prod)
- Start with RequireTagValueFromSet for less disruptive adoption
- Monitor compliance before switching to Deny effect

### 📚 **Documentation & Communication**
- Clearly document all required tags and allowed values
- Provide examples and use cases to teams
- Regular training on tag governance requirements

## Monitoring and Compliance

- Use Azure Policy Compliance dashboard for monitoring
- Set up Azure Monitor alerts for policy violations
- Regular review of tag values and policy effectiveness
- Use Azure Resource Graph for compliance reporting

## Related Documentation

- [Azure Policy Documentation](https://docs.microsoft.com/en-us/azure/governance/policy/)
- [Azure Resource Tagging Best Practices](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)
- [Cost Management with Tags](https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/cost-analysis-common-uses)

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
