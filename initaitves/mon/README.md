# Diagnostic Settings Standard Initiative

This Bicep template creates an Azure Policy Initiative (Policy Set Definition) that contains diagnostic settings policies for sending logs to a Log Analytics Workspace.

## Overview

The template creates:
- A Policy Initiative with configurable parameters
- Policy definition groups for organization
- Optional policy assignment (disabled by default)
- Optional role assignment for managed identity (disabled by default)

## Usage

### Basic Deployment

Deploy the initiative only (recommended approach):

```bash
az deployment mg create \
  --management-group "mg-example" \
  --location "East US" \
  --template-file "diagnosticSettings-Standard.bicep" \
  --parameters logAnalyticsWorkspaceId="/subscriptions/{subscription-id}/resourcegroups/{rg-name}/providers/microsoft.operationalinsights/workspaces/{workspace-name}"
```

### Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `logAnalyticsWorkspaceId` | string | The Log Analytics workspace resource ID | Required |
| `initiativeDisplayName` | string | Display name for the initiative | "Diagnostic Settings - Send logs to Log Analytics Workspace" |
| `initiativeDescription` | string | Description for the initiative | Default description |
| `policyDefinitions` | array | Array of policy definitions to include | Azure Firewall policy |
| `policyDefinitionGroups` | array | Groups for organizing policies | Predefined groups |

### Extending the Initiative

To add more diagnostic settings policies:

1. **Update the `policyDefinitions` parameter** with your new policies:

```bicep
{
  policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/diagnosticSettings-AppService-LogAnalytics'
  policyDefinitionReferenceId: 'diagnosticSettings-AppService-LogAnalytics'
  groupNames: ['compute']
  parameters: {
    logAnalytics: { value: '[parameters(\'logAnalyticsWorkspaceId\')]' }
    effect: { value: '[parameters(\'effect\')]' }
    diagnosticSettingName: { value: '[parameters(\'diagnosticSettingName\')]' }
    categoryGroup: { value: '[parameters(\'categoryGroup\')]' }
    resourceLocationList: { value: '[parameters(\'resourceLocationList\')]' }
    logAnalyticsDestinationType: { value: '[parameters(\'logAnalyticsDestinationType\')]' }
  }
}
```

2. **Update policy definition IDs** with actual subscription IDs and policy names
3. **Assign appropriate groups** from the predefined groups or create new ones

### Policy Assignment

To deploy the policy assignment:

1. Set the assignment condition to `true` in the template
2. Deploy with appropriate scope
3. Ensure the managed identity has necessary permissions

### Role Assignment

For policies with `DeployIfNotExists` effect:

1. Deploy the initiative first
2. Deploy the policy assignment
3. Get the managed identity principal ID from the assignment
4. Update the role assignment with the actual principal ID
5. Deploy the role assignment

### Available Policy Groups

- **networking**: Network-related resources (VNets, Firewalls, etc.)
- **compute**: Compute resources (VMs, App Services, etc.)
- **storage**: Storage resources (Storage Accounts, etc.)
- **database**: Database resources (SQL, Cosmos DB, etc.)
- **security**: Security resources (Key Vault, etc.)

## Example Policies to Add

Here are examples of additional diagnostic settings policies you might want to include:

### App Service
```bicep
{
  policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/diagnosticSettings-AppService-LogAnalytics'
  policyDefinitionReferenceId: 'diagnosticSettings-AppService-LogAnalytics'
  groupNames: ['compute']
  // ... parameters
}
```

### Key Vault
```bicep
{
  policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/diagnosticSettings-KeyVault-LogAnalytics'
  policyDefinitionReferenceId: 'diagnosticSettings-KeyVault-LogAnalytics'
  groupNames: ['security']
  // ... parameters
}
```

### SQL Database
```bicep
{
  policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/diagnosticSettings-SqlDatabase-LogAnalytics'
  policyDefinitionReferenceId: 'diagnosticSettings-SqlDatabase-LogAnalytics'
  groupNames: ['database']
  // ... parameters
}
```

## Important Notes

1. **Policy Definition IDs**: Update the placeholder `{subscription-id}` with actual subscription IDs where your policies are defined
2. **Managed Identity**: For `DeployIfNotExists` policies, ensure the managed identity has appropriate permissions
3. **Scope**: Consider the appropriate scope (Management Group, Subscription) for your initiative
4. **Testing**: Test the initiative with a few policies before adding all diagnostic settings policies

## Prerequisites

- Azure CLI or PowerShell
- Appropriate permissions to create policy initiatives at the target scope
- Log Analytics workspace already deployed
- Individual diagnostic settings policies already created

## Monitoring and Compliance

After deployment, you can monitor compliance through:
- Azure Policy compliance dashboard
- Azure Monitor logs
- Azure Resource Graph queries

Example query to check compliance:
```kusto
PolicyStates
| where PolicyDefinitionName contains "diagnosticSettings"
| summarize count() by ComplianceState, PolicyDefinitionName
```
