# ============================================================
# Mission AI: Possible
# Solution Deployment - Tenant 1 (Agents 01-23)
# ============================================================


# ============================================================
# COURSE CONFIGURATION
# Update these values for each new course tenant
# ============================================================

$tenantDomain = "QADelegate0100XXXX.onmicrosoft.com"
$password = "<UserPassword>"

$adminUPN = "QA@QADelegate0100XXXX.onmicrosoft.com"
$adminPassword = "<AdminPassword>"

$adminProfile = "CourseAdmin23"

$solutionPath = ".\SolutionDeployment\TopSecretDatabase_1_0_0_7.zip"


# ============================================================
# USERS - AGENTS 01-23
# ============================================================

$users = @(
    @{UserPrincipalName="Agent01"; DisplayName="Agent Amber";      Surname="Amber"}
    @{UserPrincipalName="Agent02"; DisplayName="Agent Aqua";       Surname="Aqua"}
    @{UserPrincipalName="Agent03"; DisplayName="Agent Beige";      Surname="Beige"}
    @{UserPrincipalName="Agent04"; DisplayName="Agent Black";      Surname="Black"}
    @{UserPrincipalName="Agent05"; DisplayName="Agent Blue";       Surname="Blue"}
    @{UserPrincipalName="Agent06"; DisplayName="Agent Bronze";     Surname="Bronze"}
    @{UserPrincipalName="Agent07"; DisplayName="Agent Brown";      Surname="Brown"}
    @{UserPrincipalName="Agent08"; DisplayName="Agent Burgundy";   Surname="Burgundy"}
    @{UserPrincipalName="Agent09"; DisplayName="Agent Cerulean";   Surname="Cerulean"}
    @{UserPrincipalName="Agent10"; DisplayName="Agent Chartreuse"; Surname="Chartreuse"}
    @{UserPrincipalName="Agent11"; DisplayName="Agent Coral";      Surname="Coral"}
    @{UserPrincipalName="Agent12"; DisplayName="Agent Crimson";    Surname="Crimson"}
    @{UserPrincipalName="Agent13"; DisplayName="Agent Cyan";       Surname="Cyan"}
    @{UserPrincipalName="Agent14"; DisplayName="Agent Emerald";    Surname="Emerald"}
    @{UserPrincipalName="Agent15"; DisplayName="Agent Fuchsia";    Surname="Fuchsia"}
    @{UserPrincipalName="Agent16"; DisplayName="Agent Gold";       Surname="Gold"}
    @{UserPrincipalName="Agent17"; DisplayName="Agent Gray";       Surname="Gray"}
    @{UserPrincipalName="Agent18"; DisplayName="Agent Green";      Surname="Green"}
    @{UserPrincipalName="Agent19"; DisplayName="Agent Indigo";     Surname="Indigo"}
    @{UserPrincipalName="Agent20"; DisplayName="Agent Ivory";      Surname="Ivory"}
    @{UserPrincipalName="Agent21"; DisplayName="Agent Jade";       Surname="Jade"}
    @{UserPrincipalName="Agent22"; DisplayName="Agent Lavender";   Surname="Lavender"}
    @{UserPrincipalName="Agent23"; DisplayName="Agent Lime";       Surname="Lime"}
)


# ============================================================
# CREATE ADMINISTRATOR PAC PROFILE
# ============================================================

Write-Host ""
Write-Host "========================================"
Write-Host "Preparing PAC administrator profile"
Write-Host "========================================"

$authProfiles = pac auth list

if ($authProfiles -match "\b$adminProfile\b") {

    Write-Host "Removing existing $adminProfile profile..."

    pac auth delete --name $adminProfile

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to remove existing $adminProfile authentication profile."
    }
}

Write-Host "Creating $adminProfile profile..."

pac auth create `
    --name $adminProfile `
    --username $adminUPN `
    --password $adminPassword

if ($LASTEXITCODE -ne 0) {
    throw "Unable to create the $adminProfile authentication profile."
}

Write-Host ""
Write-Host "$adminProfile created successfully."


# ============================================================
# TRACK DEPLOYMENT FAILURES
# ============================================================

$failures = @()


# ============================================================
# DEPLOY SOLUTION TO EACH LEARNER
# ============================================================

foreach ($user in $users) {

    $environmentId = $null
    $environmentUrl = $null
    $learnerProfileCreated = $false

    $upn = "$($user.UserPrincipalName)@$tenantDomain"
    $profileName = $user.Surname
    $environmentName = "$($user.DisplayName)'s Environment"

    Write-Host ""
    Write-Host "========================================"
    Write-Host "Processing $($user.DisplayName)"
    Write-Host "========================================"

    try {

        # ----------------------------------------------------
        # Find the learner's Developer environment
        # while authenticated as CourseAdmin23
        # ----------------------------------------------------

        $envOutput = pac admin list `
            --type Developer `
            --name $environmentName

        if ($LASTEXITCODE -ne 0) {
            throw "Unable to retrieve Developer environment."
        }


        # ----------------------------------------------------
        # Extract the Environment ID
        # ----------------------------------------------------

        $environmentMatch = $envOutput |
            Select-String '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})'

        if (-not $environmentMatch) {
            throw "Developer environment '$environmentName' was not found."
        }

        $environmentId = $environmentMatch.Matches[0].Value


        # ----------------------------------------------------
        # Extract the Dataverse Environment URL
        # ----------------------------------------------------

        $urlMatch = $envOutput |
            Select-String 'https://[^\s]+\.dynamics\.com/?'

        if (-not $urlMatch) {
            throw "Unable to determine URL for Developer environment '$environmentName'."
        }

        $environmentUrl = $urlMatch.Matches[0].Value


        Write-Host "Environment: $environmentName"
        Write-Host "Environment ID: $environmentId"
        Write-Host "Environment URL: $environmentUrl"


        # ----------------------------------------------------
        # Authenticate as the learner
        # ----------------------------------------------------

        pac auth create `
            --name $profileName `
            --username $upn `
            --password $password

        if ($LASTEXITCODE -ne 0) {
            throw "Authentication failed."
        }

        $learnerProfileCreated = $true


        # ----------------------------------------------------
        # Import the solution as the learner
        #
        # IMPORTANT:
        # Use the Dataverse URL rather than the Environment ID.
        # Developer environments provisioned for these users
        # are accessible by URL but are not returned by
        # pac env list for the learner.
        # ----------------------------------------------------

        pac solution import `
            --environment $environmentUrl `
            --path $solutionPath `
            --async `
            --max-async-wait-time 10

        if ($LASTEXITCODE -ne 0) {
            throw "Solution import failed."
        }


        # ----------------------------------------------------
        # Publish customisations as the learner
        # ----------------------------------------------------

        pac solution publish `
            --environment $environmentUrl

        if ($LASTEXITCODE -ne 0) {
            throw "Solution publish failed."
        }


        Write-Host ""
        Write-Host "SUCCESS: $($user.DisplayName)"
    }

    catch {

        $errorMessage = $_.Exception.Message

        Write-Host ""
        Write-Host "FAILED: $($user.DisplayName)"
        Write-Host $errorMessage

        $failures += [PSCustomObject]@{
            User          = $user.DisplayName
            EnvironmentId = $environmentId
            EnvironmentUrl = $environmentUrl
            Error         = $errorMessage
        }
    }

    finally {

        # Always return to the course administrator

        pac auth select --name $adminProfile


        # Remove the temporary learner profile if it was created

        if ($learnerProfileCreated) {
            pac auth delete --name $profileName
        }
    }
}


# ============================================================
# DEPLOYMENT SUMMARY
# ============================================================

Write-Host ""
Write-Host "========================================"
Write-Host "Deployment Summary"
Write-Host "========================================"

if ($failures.Count -eq 0) {

    Write-Host "All learners deployed successfully."

}
else {

    Write-Host "$($failures.Count) deployment(s) failed:"
    Write-Host ""

    foreach ($failure in $failures) {

        Write-Host "User:            $($failure.User)"

        if ($failure.EnvironmentId) {
            Write-Host "Environment ID:  $($failure.EnvironmentId)"
        }
        else {
            Write-Host "Environment ID:  Not found"
        }

        if ($failure.EnvironmentUrl) {
            Write-Host "Environment URL: $($failure.EnvironmentUrl)"
        }
        else {
            Write-Host "Environment URL: Not found"
        }

        Write-Host "Error:           $($failure.Error)"
        Write-Host ""
    }
}


# ============================================================
# FINISHED
# ============================================================

Write-Host "Administrator PAC profile '$adminProfile' has been retained."