# QATGTWS3 Course Setup

Tools and resources used to prepare the training tenants for QATGTWS3 deliveries.

## Process

1. Sign in to M365 as the global admin and turn off *Security Defaults*
1. Sign up for a *Power Apps for Developer* license
1. Edit and run the User Provisioning script(s).
1. Assign licences to the Agent accounts, including Microsoft Power Apps for Developer.
1. Pack the Environment Provisioning solution and import it into the training tenant. (Alternatively use the solution file at the root of the repo `AutomatedEnvironmentCreation.zip`)
1. Run the appropriate Environment Provisioning flow(s) to create the learner Developer environments.
1. Edit and run the appropriate Solution Deployment script(s) to deploy the course solution to each learner environment.
1. Check any remaining learner setup requirements before the course.

For deliveries with up to 23 learners, use the Tenant 1 tooling only. For deliveries with 24–40 learners, use both Tenant 1 and Tenant 2 tooling.

Note: The scripts do not import the solution file (Top Secret Database) into the admin account's developer environment - this will need to be done manually

## User Provisioning

`UserProvisioning` contains the PowerShell scripts used to create the learner accounts.

* `MAIP-Users-23.ps1` — creates Agents 01–23.
* `MAIP-Users-40.ps1` — creates Agents 24–40.

Before running a script, update its configuration values for the current training tenant, including the tenant domain and learner password.

## Environment Provisioning

`EnvironmentProvisioning` contains the unpacked Power Platform solution for the environment provisioning flows:

* **Create Environment (23)** — creates Developer environments for Agents 01–23.
* **Create Environment (40)** — creates Developer environments for Agents 24–40.

The flows create a Developer environment on behalf of each learner account.

The unpacked source can be converted back into an importable Power Platform solution using Power Platform CLI:

```powershell
pac solution pack `
    --folder ".\\\\EnvironmentProvisioning" `
    --zipfile ".\\\\AutomatedEnvironmentCreation.zip"
```

Import `AutomatedEnvironmentCreation.zip` into the appropriate training tenant and run the required flow.

## Solution Deployment

`SolutionDeployment` contains the course solution and the PowerShell scripts used to deploy it to each learner Developer environment.

* `TopSecretDatabase\_1\_0\_0\_7.zip` — course solution.
* `Import-TopSecretDataBase-23.ps1` — deploys the solution to Agents 01–23.
* `Import-TopSecretDataBase-40.ps1` — deploys the solution to Agents 24–40.

Before running a deployment script, update its course configuration values:

* Tenant domain.
* Learner password.
* Administrator UPN.
* Administrator password.

The deployment process:

1. Creates a PAC CLI administrator authentication profile for the tenant.
2. Uses the administrator account to locate each learner's Developer environment and obtain its Dataverse URL.
3. Authenticates PAC CLI as the learner.
4. Imports the course solution into that learner's environment.
5. Publishes the customisations.
6. Returns to the administrator profile and removes the temporary learner authentication profile.
7. Continues with the next learner even if an individual deployment fails.
8. Displays a summary of any failures at the end.

The scripts use the environment **Dataverse URL** for learner deployment rather than the environment GUID. Learner Developer environments can be accessible by URL even when they are not returned by `pac env list`.

The administrator profiles are retained after deployment for troubleshooting:

* `CourseAdmin23` — Tenant 1.
* `CourseAdmin40` — Tenant 2.

## Learner Setup

The automated setup creates the learner accounts and Developer environments and deploys the course solution.

Any remaining learner-side setup, including validation or authorisation of connections used by the course flows, should be checked before delivery.

