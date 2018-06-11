# https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-3rdparty-device-config-cisco-asa

# Note
# The sample configuration connects a Cisco ASA device to an Azure route-based VPN gateway. The connection uses a custom IPsec/IKE policy with the UsePolicyBasedTrafficSelectors option, as described in this article.
# The sample requires that ASA devices use the IKEv2 policy with access-list-based configurations, not VTI-based. Consult your VPN device vendor specifications to verify that the IKEv2 policy is supported on your on-premises # VPN devices.

# https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-connect-multiple-policybased-rm-ps


# https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-ipsecikepolicy-rm-powershell

Select-AzureRmSubscription -SubscriptionName "Subscription Name"

Get-AzureRmVirtualNetworkGateway -Name hub-vnet-gw -ResourceGroupName hubnetwork-rg

Get-AzureRmVirtualNetworkGatewayConnection -Name azure-ldh-conn -ResourceGroupName hubnetwork-rg

$RG1          = "rg-name"
$Connection16 = "connector-name"
$connection6  = Get-AzureRmVirtualNetworkGatewayConnection -Name $Connection16 -ResourceGroupName $RG1
$connection6.IpsecPolicies


# Update or add a policy

$RG1          = "rg-name"
$Connection16 = "connector-name"
$connection6  = Get-AzureRmVirtualNetworkGatewayConnection -Name $Connection16 -ResourceGroupName $RG1

$newpolicy6   = New-AzureRmIpsecPolicy -IkeEncryption AES128 -IkeIntegrity SHA1 -DhGroup DHGroup14 -IpsecEncryption AES256 -IpsecIntegrity SHA256 -PfsGroup None -SALifeTimeSeconds 14400 -SADataSizeKilobytes 102400000

Set-AzureRmVirtualNetworkGatewayConnection -VirtualNetworkGatewayConnection $connection6 -IpsecPolicies $newpolicy6

# To enable "UsePolicyBasedTrafficSelectors" when connecting to an on-premises policy-based VPN device, add the "-UsePolicyBaseTrafficSelectors" parameter to the cmdlet, or set it to $False to disable the option:

Set-AzureRmVirtualNetworkGatewayConnection -VirtualNetworkGatewayConnection $connection6 -IpsecPolicies $newpolicy6 -UsePolicyBasedTrafficSelectors $True

# Remove an IPsec/IKE policy from a connection
# Once you remove the custom policy from a connection, the Azure VPN gateway reverts back to the default list of IPsec/IKE proposals and renegotiates again with your on-premises VPN device.

$RG1          = "rg-name"
$Connection16 = "connector-name"
$connection6   = Get-AzureRmVirtualNetworkGatewayConnection -Name $Connection16 -ResourceGroupName $RG1

$currentpolicy = $connection6.IpsecPolicies[0]
$connection6.IpsecPolicies.Remove($currentpolicy)

Set-AzureRmVirtualNetworkGatewayConnection -VirtualNetworkGatewayConnection $connection6
