# ================================
# CONFIGURATION
# ================================
$tenantDomain = "QADelegate01006517.onmicrosoft.com"
$password     = "Apples-2907"

# ================================
# AUTHENTICATION
# ================================
# Required permission: User.ReadWrite.All
# You must be User Admin or Global Admin

Connect-MgGraph -Scopes "User.ReadWrite.All" 

# Optional but recommended: verify context
$context = Get-MgContext
Write-Host "Connected to tenant:" $context.TenantId
Write-Host "Account:" $context.Account

# ================================
# USERS TO CREATE (OPTION 1)
# ================================
$users = @(
    @{UserPrincipalName="Agent01";DisplayName="Agent Amber";GivenName="Agent";Surname="Amber";MailNickName="Amber"} , 
    @{UserPrincipalName="Agent02";DisplayName="Agent Aqua";GivenName="Agent";Surname="Aqua";MailNickName="Aqua"} ,
    @{UserPrincipalName="Agent03";DisplayName="Agent Beige";GivenName="Agent";Surname="Beige";MailNickName="Beige"},
    @{UserPrincipalName="Agent04";DisplayName="Agent Black";GivenName="Agent";Surname="Black";MailNickName="Black"} ,
    @{UserPrincipalName="Agent05";DisplayName="Agent Blue";GivenName="Agent";Surname="Blue";MailNickName="Blue"} ,
    @{UserPrincipalName="Agent06";DisplayName="Agent Bronze";GivenName="Agent";Surname="Bronze";MailNickName="Bronze"} ,
    @{UserPrincipalName="Agent07";DisplayName="Agent Brown";GivenName="Agent";Surname="Brown";MailNickName="Brown"} ,
    @{UserPrincipalName="Agent08";DisplayName="Agent Burgundy";GivenName="Agent";Surname="Burgundy";MailNickName="Burgundy"} ,
    @{UserPrincipalName="Agent09";DisplayName="Agent Cerulean";GivenName="Agent";Surname="Cerulean";MailNickName="Cerulean"} ,
    @{UserPrincipalName="Agent10";DisplayName="Agent Chartreuse";GivenName="Agent";Surname="Chartreuse";MailNickName="Chartreuse"} ,
    @{UserPrincipalName="Agent11";DisplayName="Agent Coral";GivenName="Agent";Surname="Coral";MailNickName="Coral"} ,
    @{UserPrincipalName="Agent12";DisplayName="Agent Crimson";GivenName="Agent";Surname="Crimson";MailNickName="Crimson"} ,
    @{UserPrincipalName="Agent13";DisplayName="Agent Cyan";GivenName="Agent";Surname="Cyan";MailNickName="Cyan"} ,
    @{UserPrincipalName="Agent14";DisplayName="Agent Emerald";GivenName="Agent";Surname="Emerald";MailNickName="Emerald"} ,
    @{UserPrincipalName="Agent15";DisplayName="Agent Fuchsia";GivenName="Agent";Surname="Fuchsia";MailNickName="Fuchsia"},
    @{UserPrincipalName="Agent16";DisplayName="Agent Gold";GivenName="Agent";Surname="Gold";MailNickName="Gold"} ,
    @{UserPrincipalName="Agent17";DisplayName="Agent Gray";GivenName="Agent";Surname="Gray";MailNickName="Gray"} ,
    @{UserPrincipalName="Agent18";DisplayName="Agent Green";GivenName="Agent";Surname="Green";MailNickName="Green"} ,
    @{UserPrincipalName="Agent19";DisplayName="Agent Indigo";GivenName="Agent";Surname="Indigo";MailNickName="Indigo"} ,
    @{UserPrincipalName="Agent20";DisplayName="Agent Ivory";GivenName="Agent";Surname="Ivory";MailNickName="Ivory"} ,
    @{UserPrincipalName="Agent21";DisplayName="Agent Jade";GivenName="Agent";Surname="Jade";MailNickName="Jade"} ,
    @{UserPrincipalName="Agent22";DisplayName="Agent Lavender";GivenName="Agent";Surname="Lavender";MailNickName="Lavender"} ,
    @{UserPrincipalName="Agent23";DisplayName="Agent Lime";GivenName="Agent";Surname="Lime";MailNickName="Lime"} 

)

# ================================
# USER CREATION LOOP
# ================================
foreach ($user in $users) {

    $upn = "$($user.UserPrincipalName)@$tenantDomain"

    # Idempotency check
    $existingUser = Get-MgUser `
        -Filter "userPrincipalName eq '$upn'" `
        -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Host "User already exists — skipping:" $upn
        continue
    }

    Write-Host "Creating user:" $upn

    $body = @{
        accountEnabled = $true
        displayName    = $user.DisplayName
        userPrincipalName = $upn
        mailNickname   = $user.UserPrincipalName
        passwordProfile = @{
            password = $password
            forceChangePasswordNextSignIn = $false
        }
    }

New-MgUser -BodyParameter $body
}

# ================================
# CLEAN DISCONNECT (OPTIONAL)
# ================================
Disconnect-MgGraph
