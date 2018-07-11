# This script assumes that the http and https listeners are already in place. 

# Get the application gateway
$appgw = Get-AzureRmApplicationGateway `
    -Name appgw-name `
    -ResourceGroupName appgw-rg

# Get the existing HTTPS listener
$myHTTPSListener = Get-AzureRmApplicationGatewayHttpListener `
    -Name appGatewayHttpsListener `
    -ApplicationGateway $appgw

# Get the HTTP listener
$myHTTPListener = Get-AzureRmApplicationGatewayHttpListener `
    -Name appGatewayHttpListener `
    -ApplicationGateway $appgw

# Add a redirection configuration using a permanent redirect and targeting the existing listener
Add-AzureRmApplicationGatewayRedirectConfiguration `
    -Name redirectHttptoHttps `
    -RedirectType Permanent `
    -TargetListener $myHTTPSListener `
    -IncludePath $true `
    -IncludeQueryString $true `
    -ApplicationGateway $appgw

# Get the redirect configuration
$redirectconfig = Get-AzureRmApplicationGatewayRedirectConfiguration `
    -Name redirectHttptoHttps `
    -ApplicationGateway $appgw

# Add a new rule to handle the redirect and use the new listener
Add-AzureRmApplicationGatewayRequestRoutingRule `
    -Name rule2 `
    -RuleType Basic `
    -HttpListener $myHTTPListener `
    -RedirectConfiguration $redirectconfig `
    -ApplicationGateway $appgw

# Update the application gateway
Set-AzureRmApplicationGateway `
    -ApplicationGateway $appgw
