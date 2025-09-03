# Network Security Group Requirement Policies

This directory contains Azure Policies that enforce Network Security Group (NSG) assignment to subnets at deployment time.

## Policies

### 1. vnetSubnet-RequireNetworkSecurityGroup.json
**Purpose**: Ensures that standalone subnets have a Network Security Group assigned at deployment time.

**Effect**:
- `Deny` (default): Blocks subnet creation if no NSG is assigned
- `Disabled`: Turns off the policy

**Scope**: This policy targets `Microsoft.Network/virtualNetworks/subnets` resources.

**Excluded Subnets**: By default, the following subnet types are excluded from this requirement:
- AzureFirewallSubnet
- GatewaySubnet
- AzureBastionSubnet
- RouteServerSubnet

### 2. vnetSubnet-RequireNetworkSecurityGroup-Comprehensive.json
**Purpose**: Comprehensive policy that ensures NSG assignment for both standalone subnet deployments and subnets created as part of virtual network deployments.

**Effect**:
- `Deny` (default): Blocks deployment if any non-excluded subnet lacks an NSG
- `Disabled`: Turns off the policy

**Scope**: This policy targets both:
- `Microsoft.Network/virtualNetworks/subnets` (standalone subnet deployments)
- `Microsoft.Network/virtualNetworks` (virtual network deployments with subnets)

**Excluded Subnets**: By default, the following subnet types are excluded:
- AzureFirewallSubnet
- GatewaySubnet
- AzureBastionSubnet
- RouteServerSubnet
- AzureFirewallManagementSubnet

## Usage

### Assignment via Azure Portal
1. Navigate to Azure Policy in the Azure Portal
2. Select "Definitions" and then "Import definition"
3. Upload the JSON policy file
4. Create an assignment at the desired scope (subscription, resource group, etc.)
5. Configure the effect parameter as needed

### Assignment via Azure CLI
```bash
# Create policy definition
az policy definition create \
  --name "require-nsg-on-subnet" \
  --display-name "Require Network Security Group on Subnet" \
  --description "Ensures subnets have NSG assigned at deployment time" \
  --rules @vnetSubnet-RequireNetworkSecurityGroup.json \
  --mode All

# Create policy assignment
az policy assignment create \
  --name "require-nsg-assignment" \
  --display-name "Require NSG on Subnets" \
  --policy "require-nsg-on-subnet" \
  --scope "/subscriptions/{subscription-id}" \
  --params '{"effect":{"value":"Deny"}}'
```

### Assignment via PowerShell
```powershell
# Create policy definition
$policyDef = New-AzPolicyDefinition `
  -Name "require-nsg-on-subnet" `
  -DisplayName "Require Network Security Group on Subnet" `
  -Description "Ensures subnets have NSG assigned at deployment time" `
  -Policy (Get-Content -Path "vnetSubnet-RequireNetworkSecurityGroup.json" -Raw) `
  -Mode All

# Create policy assignment
New-AzPolicyAssignment `
  -Name "require-nsg-assignment" `
  -DisplayName "Require NSG on Subnets" `
  -PolicyDefinition $policyDef `
  -Scope "/subscriptions/{subscription-id}" `
  -PolicyParameterObject @{"effect" = "Deny"}
```

## Policy Logic

The policies evaluate the following conditions:

1. **Resource Type Check**: Targets subnet resources or virtual networks with subnets
2. **Exclusion Check**: Skips Azure service-specific subnets that don't require NSGs
3. **NSG Assignment Check**: Verifies that the `networkSecurityGroup.id` property exists and is not empty
4. **Action**: Applies the configured effect (Deny or Disabled)

## Best Practices

1. **Start with Audit**: Consider creating an audit version first to identify non-compliant resources
2. **Test in Development**: Validate the policy in development environments before production deployment
3. **Gradual Rollout**: Apply to test resource groups first, then expand scope
4. **Monitor Compliance**: Use Azure Policy compliance dashboards to track adherence
5. **Exception Management**: Use the excluded subnets parameter to handle legitimate exceptions

## Troubleshooting

**Common Issues**:
- **Policy not triggering**: Ensure the policy is assigned at the correct scope
- **Legitimate deployments blocked**: Add subnet names to the excluded subnets parameter
- **Performance impact**: The comprehensive policy may have slight performance overhead due to array evaluations

**Validation**:
- Test with ARM templates, Bicep, or Terraform to ensure policy works across deployment methods
- Verify exclusions work correctly for Azure service subnets
