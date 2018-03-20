#gets a list of available metrics for the Event hub
#Get-AzureRmMetricDefinition -ResourceId "/subscriptions/d90d7cc2-9fa4-4013-906d-ac68c204c68b/resourceGroups/devscssb-ResourcePool/providers/Microsoft.EventHub/namespaces/Namespace-0705271b-9db7-4c23-8288-0d5583b4ed1c" |Out-File C:\Users\mchriste\Documents\EventHubMetrics.txt -Append

#login
Login-AzureRmAccount

#select subscription
Select-AzureRmSubscription -SubscriptionName ""

#specified resource group
$rg = ""

#OpsGenie outgoing hook
$actionWebhook = New-AzureRmAlertRuleWebhook -ServiceUri 

#gets all the event hubs in the specified resource group
$eventhubresources = @(Find-AzureRmResource -ResourceGroupNameEquals $rg -ResourceType Microsoft.EventHub/namespaces)

#for each event hub Hub in the resource group, add alerts
for($i=0;$i -lt $eventhubresources.Length;$i++){
    #if the name of the resource is longer than 17 characters, take a substring so it doesn't go past the max
    if($eventhubresources[$i].Name.Length -gt 17){$name = $eventhubresources[$i].Name.Substring(0,17)} else{$name = $eventhubresources[$i].Name}
    $alertname = $name+"-failedReq"
    Add-AzureRmMetricAlertRule -Name $alertname -Location $eventhubresources[$i].Location -ResourceGroup $rg -TargetResourceId $eventhubresources[$i].ResourceId -MetricName "FAILREQ" -Operator GreaterThan -Threshold 50 -WindowSize 00:15:00 -TimeAggregationOperator Total -Actions $actionWebhook -Description "failed request on Event hub"
    $alertname = $name+"-svrBusy"
    Add-AzureRmMetricAlertRule -Name $alertname -Location $eventhubresources[$i].Location -ResourceGroup $rg -TargetResourceId $eventhubresources[$i].ResourceId -MetricName "SVRBSY" -Operator GreaterThan -Threshold 50 -WindowSize 00:15:00 -TimeAggregationOperator Total -Actions $actionWebhook -Description "Server Busy error on Event Hub"
    $alertname = $name+"-svrEr"
    Add-AzureRmMetricAlertRule -Name $alertname -Location $eventhubresources[$i].Location -ResourceGroup $rg -TargetResourceId $eventhubresources[$i].ResourceId -MetricName "INTERR" -Operator GreaterThan -Threshold 50 -WindowSize 00:15:00 -TimeAggregationOperator Total -Actions $actionWebhook -Description "internal server error on Event Hub"
    $alertname = $name+"-OtherEr"
    Add-AzureRmMetricAlertRule -Name $alertname -Location $eventhubresources[$i].Location -ResourceGroup $rg -TargetResourceId $eventhubresources[$i].ResourceId -MetricName "MISCERR" -Operator GreaterThan -Threshold 50 -WindowSize 00:15:00 -TimeAggregationOperator Total -Actions $actionWebhook -Description "other error on Event Hub"
    
}
