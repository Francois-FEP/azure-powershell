# This script assumes that the http and https listeners are already in place. 

# Get the application gateway
$gw = Get-AzureRmApplicationGateway -Name ATLAS-WAF01 -ResourceGroupName ATLAS-Res

# Get the existing HTTPS listener, because it had already exists
$httpslistener = Get-AzureRmApplicationGatewayHttpListener -Name appGatewayHttpsListener -ApplicationGateway $gw

# Get the HTTP listener, because it had already exists
$listener = Get-AzureRmApplicationGatewayHttpListener -Name appGatewayHttpListener -ApplicationGateway $gw

# Add a redirection configuration using a permanent redirect and targeting the existing listener
Add-AzureRmApplicationGatewayRedirectConfiguration -Name redirectHttptoHttps -RedirectType Permanent -TargetListener $httpslistener -IncludePath $true -IncludeQueryString $true -ApplicationGateway $gw

# Get the redirect configuration
$redirectconfig = Get-AzureRmApplicationGatewayRedirectConfiguration -Name redirectHttptoHttps -ApplicationGateway $gw

# Add a new rule to handle the redirect and use the new listener
Add-AzureRmApplicationGatewayRequestRoutingRule -Name rule02 -RuleType Basic -HttpListener $listener -RedirectConfiguration $redirectconfig -ApplicationGateway $gw

# Update the application gateway
Set-AzureRmApplicationGateway -ApplicationGateway $gw
