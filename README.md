# QATGTWS3 Course Setup

Tools and resources used to prepare the training tenants for QATGTWS3 deliveries.

## Process
1. Edit and then run the User Provisioning scripts
1. Assign licenses to the Agent accounts (including Power Platform Developer License)
1. Import the Environment Provisioning solution
1. Run the Environment provisioning flow
1. Do the solution stuff

## User Provisioning

`UserProvisioning` contains the PowerShell scripts used to create the learner accounts.

- `MAIP-Users-1.ps1` — used for deliveries with up to 23 learners.
- `MAIP-Users-2.ps1` — used in addition to the first script for deliveries with 24–40 learners.

## Environment Provisioning

`EnvironmentProvisioning` contains the unpacked Power Platform solution for the **Create Environment** flow.

The flow creates a Developer environment on behalf of each learner account.

The solution source can be packed using Power Platform CLI and imported into a training tenant.

## Solution Deployment

To be added.

This will contain the tooling used to deploy the required course solution to each learner Developer environment.