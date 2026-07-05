// Orchestrates the whole environment: one shared network, then one VM per entry
// in `vms.items`. Per-VM config (incl. admin passwords) is passed as a single
// @secure() object so secrets stay out of deployment history and logs.

targetScope = 'resourceGroup'

@description('Azure region.')
param location string = resourceGroup().location

@description('Prefix for all resource names.')
param prefix string

@description('Per-VM configuration: { items: [ { name, adminUsername, adminPassword, customData } ] }.')
@secure()
param vms object

module network 'network.bicep' = {
  name: 'network'
  params: {
    prefix: prefix
    location: location
  }
}

module vmMod 'vm.bicep' = [
  for (item, i) in vms.items: {
    name: 'vm-${item.name}'
    params: {
      name: item.name
      location: location
      adminUsername: item.adminUsername
      adminPassword: item.adminPassword
      subnetResourceId: network.outputs.subnetResourceId
      customData: item.customData
      // Per-environment tag so all resources of one VM can be filtered at once,
      // e.g. `az resource list --tag environment=vcenv-01`.
      tags: {
        environment: '${prefix}-${padLeft(string(i + 1), 2, '0')}'
      }
    }
  }
]

// Public IPs / FQDNs are read back via the Azure CLI after deployment
// (see deploy.sh) to avoid surfacing anything derived from the secure `vms` param.
