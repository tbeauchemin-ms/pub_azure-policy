// ============================================================================
// Policy Initiative Template: Diagnostic Settings Standard
// Description: Deploy diagnostic settings policies to send logs to Log Analytics Workspace
//
// Features:
// - Built-in policy definitions (Microsoft-provided)
// - Custom policy definitions (organization-specific)
// - Built-in policy definition groups for organization
// - Optional parameters for additional policies and groups
// - Automatic merging of built-in, custom, and additional content
// ============================================================================

targetScope = 'managementGroup' // Can be changed to 'subscription' if needed

@description('The policy initiative display name')
param initiativeDisplayName string = 'Diagnostic Settings - Send logs to Log Analytics Workspace'

@description('The policy initiative description')
param initiativeDescription string = 'This initiative contains policies that deploy diagnostic settings for Azure resources to send logs to a Log Analytics Workspace.'

@description('Optional additional policy definition groups to include')
param additionalPolicyDefinitionGroups array = []
/*
Example of additional policy definition groups:
[
    {
        name: 'analytics'
        displayName: 'Analytics Resources'
        description: 'Policies for analytics-related Azure resources diagnostic settings'
    }
    {
        name: 'messaging'
        displayName: 'Messaging Resources'
        description: 'Policies for messaging-related Azure resources diagnostic settings'
    }
]
*/

@description('Optional additional policy definitions to include in the initiative')
param additionalPolicyDefinitions array = []
/*
Example of additional policy definitions:
[
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/your-policy-id'
        policyDefinitionReferenceId: 'customResource-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            effect: {
                value: '[parameters(\'effect\')]'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            categoryGroup: {
                value: '[parameters(\'logCategoryGroup\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            logAnalyticsDestinationType: {
                value: '[parameters(\'logAnalyticsDestinationType\')]'
            }
        }
        groupNames: [
            'analytics'
        ]
    }
]
*/

// Variables for built-in policy groups
var builtInPolicyDefinitionGroups = [
    {
        name: 'ai'
        displayName: 'AI and Machine Learning Resources'
        description: 'Policies for AI and machine learning-related Azure resources diagnostic settings'
    }
    {
        name: 'application'
        displayName: 'Application Resources'
        description: 'Policies for application-related Azure resources diagnostic settings'
    }
    {
        name: 'compute'
        displayName: 'Compute Resources'
        description: 'Policies for compute-related Azure resources diagnostic settings'
    }
    {
        name: 'database'
        displayName: 'Database Resources'
        description: 'Policies for database-related Azure resources diagnostic settings'
    }
    {
        name: 'monitoring'
        displayName: 'Monitoring Resources'
        description: 'Policies for monitoring-related Azure resources diagnostic settings'
    }
    {
        name: 'networking'
        displayName: 'Network Resources'
        description: 'Policies for network-related Azure resources diagnostic settings'
    }
    {
        name: 'security'
        displayName: 'Security Resources'
        description: 'Policies for security-related Azure resources diagnostic settings'
    }
    {
        name: 'storage'
        displayName: 'Storage Resources'
        description: 'Policies for storage-related Azure resources diagnostic settings'
    }
]

// Variables for built-in policy definitions (Microsoft-provided)
var builtInPolicyDefinitions = [
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/c0d8e23a-47be-4032-961f-8b0ff3957061'
        policyDefinitionReferenceId: 'appService-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'application'
            'compute'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/92012204-a7e4-4a95-bbe5-90d0d3e12735'
        policyDefinitionReferenceId: 'applicationGateway-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: '[parameters(\'logCategoryGroup\')]'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'networking'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/fea83f6c-a18a-4338-8f1f-80ecba4c5643'
        policyDefinitionReferenceId: 'backupVault-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: '[parameters(\'logCategoryGroup\')]'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'storage'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/f8352124-56fa-4f94-9441-425109cdc14b'
        policyDefinitionReferenceId: 'bastion-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: '[parameters(\'logCategoryGroup\')]'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'networking'
            'security'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/55d1f543-d1b0-4811-9663-d6d0dbc6326d'
        policyDefinitionReferenceId: 'cognitiveServices-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: '[parameters(\'logCategoryGroup\')]'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'ai'
            'application'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/acbb9698-46bd-4800-89da-e3473c4ab10d'
        policyDefinitionReferenceId: 'communicationServices-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: 'allLogs'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'application'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/dc1b5908-da05-4eed-a988-c5e32fdb682d'
        policyDefinitionReferenceId: 'dnsResolverPolicies-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: 'allLogs'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'networking'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/6b359d8f-f88d-4052-aa7c-32015963ecc1'
        policyDefinitionReferenceId: 'keyVault-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: '[parameters(\'logCategoryGroup\')]'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'security'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/889bfebf-7428-426e-a86f-79e2a7de2f71'
        policyDefinitionReferenceId: 'loadBalancer-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: '[parameters(\'logCategoryGroup\')]'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'networking'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/818719e5-1338-4776-9a9d-3c31e4df5986'
        policyDefinitionReferenceId: 'logAnalyticsWorkspace-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: '[parameters(\'logCategoryGroup\')]'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'monitoring'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/baa4c6de-b7cf-4b12-b436-6e40ef44c8cb'
        policyDefinitionReferenceId: 'networkSecurityGroup-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: 'allLogs'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'networking'
            'security'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1513498c-3091-461a-b321-e9b433218d28'
        policyDefinitionReferenceId: 'publicIPAddress-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: '[parameters(\'logCategoryGroup\')]'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'networking'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/8def4bdd-4362-4ed6-a26f-7bf8f2c58839'
        policyDefinitionReferenceId: 'searchServices-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: '[parameters(\'logCategoryGroup\')]'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'ai'
            'application'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/3234ff41-8bec-40a3-b5cb-109c95f1c8ce'
        policyDefinitionReferenceId: 'virtualNetwork-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: 'allLogs'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'networking'
        ]
    }
    {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ed6ae75a-828f-4fea-88fd-dead1145f1dd'
        policyDefinitionReferenceId: 'virtualNetworkGateway-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: '[parameters(\'logCategoryGroup\')]'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'networking'
        ]
    }
]

// Variables for custom policy definitions (organization-specific)
var customPolicyDefinitions = [
    {
        policyDefinitionId: '/providers/Microsoft.Management/managementGroups/mg-todd-corp/providers/Microsoft.Authorization/policyDefinitions/2f1984a4-82f8-4beb-a2b7-846c36f05798'
        policyDefinitionReferenceId: 'azureFirewall-diagnosticSettings-logAnalytics'
        definitionVersion: '1.*.*'
        parameters: {
            categoryGroup: {
                value: 'allLogs'
            }
            diagnosticSettingName: {
                value: '[parameters(\'diagnosticSettingName\')]'
            }
            effect: {
                value: '[parameters(\'effect\')]'
            }
            logAnalytics: {
                value: '[parameters(\'logAnalyticsWorkspaceId\')]'
            }
            logAnalyticsDestinationType: {
                value: '[parameters(\'logAnalyticsDestinationType\')]'
            }
            resourceLocationList: {
                value: '[parameters(\'resourceLocationList\')]'
            }
        }
        groupNames: [
            'networking'
            'security'
        ]
    }
]

// Combined arrays for final use
var allPolicyDefinitionGroups = union(builtInPolicyDefinitionGroups, additionalPolicyDefinitionGroups)
var allPolicyDefinitions = union(union(builtInPolicyDefinitions, customPolicyDefinitions), additionalPolicyDefinitions)

// Policy Initiative (Policy Set Definition)
resource diagnosticSettingsInitiative 'Microsoft.Authorization/policySetDefinitions@2025-03-01' = {
    name: guid(managementGroup().id, 'diagnosticSettings-Standard-LogAnalytics')
    properties: {
        displayName: initiativeDisplayName
        description: initiativeDescription

        metadata: {
            category: 'Monitoring'
            version: '1.0.0'
        }

        // Parameters that will be exposed at the initiative level
        parameters: {
            diagnosticSettingName: {
                type: 'String'
                metadata: {
                    displayName: 'Diagnostic Setting Name'
                    description: 'Name for the diagnostic setting'
                }
                defaultValue: 'setByPolicy-LogAnalytics'
            }
            effect: {
                type: 'String'
                metadata: {
                    displayName: 'Effect'
                    description: 'Enable or disable the execution of the policies'
                }
                allowedValues: [
                    'DeployIfNotExists'
                    'AuditIfNotExists'
                    'Disabled'
                ]
                defaultValue: 'DeployIfNotExists'
            }
            logAnalyticsDestinationType: {
                type: 'String'
                metadata: {
                    displayName: 'Log Analytics Destination Type'
                    description: 'Destination type for Log Analytics - AzureDiagnostics or ResourceSpecific'
                }
                allowedValues: [
                    'AzureDiagnostics'
                    'ResourceSpecific'
                ]
                defaultValue: 'ResourceSpecific'
            }
            logAnalyticsWorkspaceId: {
                type: 'String'
                metadata: {
                    displayName: 'Log Analytics Workspace'
                    description: 'The Log Analytics workspace to send diagnostic logs to'
                    strongType: 'omsWorkspace'
                    assignPermissions: true
                }
            }
            logCategoryGroup: {
                type: 'String'
                metadata: {
                    displayName: 'Log Category Group'
                    description: 'Diagnostic category group - audit or allLogs'
                }
                allowedValues: [
                    'audit'
                    'allLogs'
                ]
                defaultValue: 'audit'
            }
            resourceLocationList: {
                type: 'Array'
                metadata: {
                    displayName: 'Resource Location List'
                    description: 'List of allowed locations for resources. Use ["*"] for all locations'
                }
                defaultValue: [
                    '*'
                ]
            }
        }

        // Policy definitions included in this initiative
        policyDefinitions: allPolicyDefinitions

        // Policy definition groups for organization
        policyDefinitionGroups: allPolicyDefinitionGroups

        policyType: 'Custom'

        version: '1.0.0'
        versions: []

    }
}

// Outputs
@description('The resource ID of the policy initiative')
output policyInitiativeId string = diagnosticSettingsInitiative.id

@description('The name of the policy initiative')
output policyInitiativeName string = diagnosticSettingsInitiative.name

@description('Number of built-in policy definitions included')
output builtInPolicyDefinitionsCount int = length(builtInPolicyDefinitions)

@description('Number of custom policy definitions included')
output customPolicyDefinitionsCount int = length(customPolicyDefinitions)

@description('Number of additional policy definitions included')
output additionalPolicyDefinitionsCount int = length(additionalPolicyDefinitions)

@description('Total number of policy definitions in the initiative')
output totalPolicyDefinitionsCount int = length(allPolicyDefinitions)

@description('Number of built-in policy definition groups')
output builtInPolicyGroupsCount int = length(builtInPolicyDefinitionGroups)

@description('Number of additional policy definition groups')
output additionalPolicyGroupsCount int = length(additionalPolicyDefinitionGroups)

@description('Total number of policy definition groups')
output totalPolicyGroupsCount int = length(allPolicyDefinitionGroups)
