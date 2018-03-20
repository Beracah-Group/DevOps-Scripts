#gets a list of available metrics for the IoT Hub
#Get-AzureRmMetricDefinition -ResourceId "" |Out-File C:\Users\mchriste\Documents\IoTMetrics.txt -Append

#Login and select subscription
Login-AzureRmAccount
Get-AzureRMResourceGroup
Select-AzureRmSubscription -SubscriptionName ""

#specified resource group
$rg = ""

#OpsGenie outgoing hook
$actionWebhook = New-AzureRmAlertRuleWebhook -ServiceUri 

#gets all the iot hubs in the specified resource group
$iothubresources = @(Find-AzureRmResource -ResourceGroupNameEquals $rg -ResourceType Microsoft.Devices/IotHubs)



#for each IoT Hub in the resource group add alerts and connects to OpsGenie
for($i=0;$i -lt $iothubresources.Length;$i++){

    #if the name of the resource is longer than 17 characters, take a substring so it doesn't go past the max
    if($iothubresources[$i].Name.Length -gt 17){$name = $iothubresources[$i].Name.Substring(0,17)} else{$name = $iothubresources[$i].Name}

    #the name of the alert is the name of the resource plus the metric name to alert on
    $alertname = $name+"-failedjob"

    # add the metric alert rule with the specific theshold values and opsgenie webhook
    Add-AzureRmMetricAlertRule -Name $alertname -Location $iothubresources[$i].Location -ResourceGroup $rg -TargetResourceId $iothubresources[$i].ResourceId -MetricName "jobs.failed" -Operator GreaterThan -Threshold 50 -WindowSize 00:15:00 -TimeAggregationOperator Total -Actions $actionWebhook -Description "failed job on iothub"

    $alertname = $name+"-droppMess"
    Add-AzureRmMetricAlertRule -Name $alertname -Location $iothubresources[$i].Location -ResourceGroup $rg -TargetResourceId $iothubresources[$i].ResourceId -MetricName "d2c.telemetry.egress.dropped" -Operator GreaterThan -Threshold 50 -WindowSize 00:15:00 -TimeAggregationOperator Total -Actions $actionWebhook -Description "dropped message iothub"
    $alertname = $name+"-orphanMess"
    Add-AzureRmMetricAlertRule -Name $alertname -Location $iothubresources[$i].Location -ResourceGroup $rg -TargetResourceId $iothubresources[$i].ResourceId -MetricName "d2c.telemetry.egress.orphaned" -Operator GreaterThan -Threshold 50 -WindowSize 00:15:00 -TimeAggregationOperator Total -Actions $actionWebhook -Description "orphaned message iothub"
    $alertname = $name+"-invalidMess"
    Add-AzureRmMetricAlertRule -Name $alertname -Location $iothubresources[$i].Location -ResourceGroup $rg -TargetResourceId $iothubresources[$i].ResourceId -MetricName "d2c.telemetry.egress.invalid" -Operator GreaterThan -Threshold 50 -WindowSize 00:15:00 -TimeAggregationOperator Total -Actions $actionWebhook -Description "invalid message iothub"
     $alertname = $name+"-MsgEr"
    Add-AzureRmMetricAlertRule -Name $alertname -Location $iothubresources[$i].Location -ResourceGroup $rg -TargetResourceId $iothubresources[$i].ResourceId -MetricName "d2c.endpoints.egress.eventHubs" -Operator LessThan -Threshold 50 -WindowSize 00:15:00 -TimeAggregationOperator Total -Actions $actionWebhook -Description "less than 1 messages delivered by iothub over 15 minutes"

}



