# ================================
# CONFIGURATION
# ================================
$tenantDomain = "QADelegate01006323.onmicrosoft.com"
$password     = "Apples-0807"

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
$Users = @(
    @{UserPrincipalName="Agent24";DisplayName="Agent Magenta";GivenName="Agent";Surname="Magenta";MailNickName="Magenta"} , 
    @{UserPrincipalName="Agent25";DisplayName="Agent Maroon";GivenName="Agent";Surname="Maroon";MailNickName="Maroon"} ,
    @{UserPrincipalName="Agent26";DisplayName="Agent Mauve";GivenName="Agent";Surname="Mauve";MailNickName="Mauve"},
    @{UserPrincipalName="Agent27";DisplayName="Agent Navy";GivenName="Agent";Surname="Navy";MailNickName="Navy"} ,
    @{UserPrincipalName="Agent28";DisplayName="Agent Olive";GivenName="Agent";Surname="Olive";MailNickName="Olive"} ,
    @{UserPrincipalName="Agent29";DisplayName="Agent Orange";GivenName="Agent";Surname="Orange";MailNickName="Orange"} ,
    @{UserPrincipalName="Agent30";DisplayName="Agent Peach";GivenName="Agent";Surname="Peach";MailNickName="Peach"} ,
    @{UserPrincipalName="Agent31";DisplayName="Agent Pink";GivenName="Agent";Surname="Pink";MailNickName="Pink"} ,
    @{UserPrincipalName="Agent32";DisplayName="Agent Plum";GivenName="Agent";Surname="Plum";MailNickName="Plum"} ,
    @{UserPrincipalName="Agent33";DisplayName="Agent Purple";GivenName="Agent";Surname="Purple";MailNickName="Purple"} , 
    @{UserPrincipalName="Agent34";DisplayName="Agent Red";GivenName="Agent";Surname="Red";MailNickName="Red"} ,
    @{UserPrincipalName="Agent35";DisplayName="Agent Ruby";GivenName="Agent";Surname="Ruby";MailNickName="Ruby"},
    @{UserPrincipalName="Agent36";DisplayName="Agent Saffron";GivenName="Agent";Surname="Saffron";MailNickName="Saffron"} ,
    @{UserPrincipalName="Agent37";DisplayName="Agent Salmon";GivenName="Agent";Surname="Salmon";MailNickName="Salmon"} ,
    @{UserPrincipalName="Agent38";DisplayName="Agent Silver";GivenName="Agent";Surname="Silver";MailNickName="Silver"} ,
    @{UserPrincipalName="Agent39";DisplayName="Agent Teal";GivenName="Agent";Surname="Teal";MailNickName="Teal"} ,
    @{UserPrincipalName="Agent40";DisplayName="Agent Yellow";GivenName="Agent";Surname="Yellow";MailNickName="Yellow"} 
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
