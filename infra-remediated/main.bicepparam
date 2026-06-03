using './main.bicep'

param location = 'usgovvirginia'
param workloadName = 'fedrampdemo'
// AU-2/AU-12: a real Log Analytics workspace resource ID would be supplied here.
param logAnalyticsWorkspaceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-law/providers/Microsoft.OperationalInsights/workspaces/law-fedrampdemo'
