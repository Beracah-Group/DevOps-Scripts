# Deployment Templates

## Overview


## Layout
There are several layers of templates with each providing a useful abstraction either conceptually or to separate concerns. 

For example the docker-ubuntu template will provide docker ready ubuntu hosts but doesn't imply /how/ that happens.

The scaleset template will create a scaleset but depends on higher level abstractions to provide much of the details.


### Resources
Concrete resources ie scalesets or storage accounts.

### Services
Abstraction that combine resources and/or other services. Represents a single coherent concept.

### Roles
Abstract high-level collection of resources/services that fulfil a particular purpose.

##### Parameters
Unlike resource and service templates, roles have both a base template file and a parameters template. A parameter template is 
needed when a runtime lookup's value is referenced in template. For example using the value from a KeyVault lookup. Any lookup
/must/ happen in a template above the template were the value is actually used. For consistency even roles that do no such lookups
have a parameter template.

### Scripts
Support scripts used by resources. Primarily this is for provisioning scripts.


## Executing templates

## Environment parameters
There are many parameters that must be passed into a role.  Manually entering these for every deployment is a pain. Specifying a 
parameters file will make rerunning deploys much easier. 

Here is an example parameter file... just fill in the empty sections.
```
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "templateBaseUrl": {
      "value": "https://raw.githubusercontent.com/SC-TechDev/DevOps-Scripts/master"
    },
    "virtualNetworkName": {
      "value": ""
    },
    "subnetName": {
      "value": ""
    },
    "diskSize": {
      "value": "512"
    },
    "keyVaultSubscriptionId": {
      "value": ""
    },
    "keyVaultResourceGroupName": {
      "value": ""
    },
    "keyVaultName": {
      "value": ""
    },
    "component": {
      "value": "rancher"
    },
    "application": {
      "value": "cattle"
    },
    "environment": {
      "value": "prod"
    },
    "rancherUrl": {
      "value": ""
    },
    "installTwistlockDefender": {
      "value": true
    }
  }
}
```

### Via docker

1. Get and azure-cli container `docker run -v ${HOME}/<path_to_checkout>:/root -it microsoft/azure-cli`
2. Navigate to roles directory `cd /root/azure/deployment-templates/roles`
3. Execute deploy 
`az group deployment create -g <resource group name> --template-file <role>.parameters.json --parameters ../../environments/<environment>.json`


## Provisioning 
Provisioning of hosts happens via the execution of provision.py which is pushed down in the scaleset template.  The data this 
script uses is provided via a config.json file (generated at the same time provision.py is pushed to the node).  This file is 
generated from the provisioningConfig variable.  This variable holds what provisioning scripts that need to be executed and any 
environment variables that should be present.  The important thing is that this variable is a union() of baseProvisioningConfig 
and the provisioningConfig parameter.  This means that higher level abstractions can augment the provisioning process while still
ensuring that the 'base' provisioning occurs consistently.

#### When provisioning occurs.
Rather then a one-off thing execution of provision.py happens every time the model changes for the scaleset and more specifically when
the length of the final provisioningConfig changes.  Because not all provisioning scripts are idempotent each script saves on the node
when it was last ran.  Each script in the template can also be marked as being safe to run multiple times, ie if it is idempotent.  
This means that if a fix script is added and running it multiple times would cause issues it can be marked as 'run once'.
See provision.py to see how this process is managed. A scripts 'execution model' is set via the value of it's key in ProvisioningConfig

"o" == 'run once'
"i" == 'idempotent'

