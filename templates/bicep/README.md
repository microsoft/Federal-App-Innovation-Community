# Bicep Templates

Many of these templates start from the [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/) (AVM). Federal customers require differences in their templates that AVM does not deliver on, such as no telemetry and seperation of duties on roles.

## Understanding the Parameters

Parameters are broken into 3 distinct sections:  

1. User Configurable Parameters  
    - These are parameters that are expected to be changed by the user.
2. Optional Parameters  
    - These are parameters that are optional and can be left as default. Every optional parameter must have a default value. Nullable is an acceptable default. Please refer to the [Notes on Bicep > Nullable Parameters](#nullable-parameters) section for more information about using nullable parameters.
3. Security Parameters  
    - These are parameters that defaults are set in compliance with EACS ATO standards. Changing this could affect compliance inheritance and should be done with caution.

## Naming Convention

To deviate from the naming convention, a valid reason must be provided and approved by the SOE-C committee.
A comment in the bicep file should be added to explain the deviation.

### PascalCase

- parameters

### camelCase

- variables
- outputs
- modules
- metadata
- type names
- type properties
- functions
- everything else

### _leadingUnderscoreCamelCase

- resources

## Contributing Guidelines

If you want to contribute code to these templates (features, updated API version, modules, etc) and help the build this repository, please follow the contribution guidelines in [here](../../README.md#contributing)

### Parameter Guidelines

- Parameters should be defined in the `parameters` section of the bicep file. The first element in the bicep file.
- Parameters should be defined in PascalCase
- Parameters should have decorators in the following order

  1. metadata (see [Required Parameter Metadata](#required-parameter-metadata) for options)
  1. other decorators
  1. description

#### Required Parameter Metadata

```bicep
@metadata({
  paramType: 'userConfig'
})
```

```bicep
@metadata({
  paramType: 'optionalConfig'
})
```

```bicep
@metadata({
  paramType: 'securityConfig'
})
```

## Resources

[Bicep Documentation][BicepOverview]  
[Bicep CLI Commands][BicepCLI]

- Converting ARM to Bicep (compile)
- Converting Bicep to ARM (decompile)
- Bicep Build - Preparing to deploy to Azure (build)
- Bicep Decompliation to ARM Templates


[BicepOverview]:https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/
[BicepCLI]:https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-cli