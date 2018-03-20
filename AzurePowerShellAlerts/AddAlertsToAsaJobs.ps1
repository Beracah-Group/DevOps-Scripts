#gets a list of available metrics for the asa job
#Get-AzureRmMetricDefinition -ResourceId "/subscriptions/3005731b-d8d6-4709-957c-048045d8a479/resourceGroups/mchriste/providers/Microsoft.StreamAnalytics/streamingjobs/mikeasa" |Out-File C:\Users\mchriste\Documents\asaMetrics.txt -Append

Login-AzureRmAccount
#Get-AzureRMResourceGroup


Select-AzureRmSubscription -SubscriptionName ""

#specified resource group
$rg = ""

#OpsGenie outgoing hook, goes to DevOps OpsGenie
$actionWebhook = New-AzureRmAlertRuleWebhook -ServiceUri 

#gets all the asa hubs in the specified resource group
$asaresources = @(Find-AzureRmResource -ResourceGroupNameEquals $rg -ResourceType Microsoft.StreamAnalytics/streamingjobs)


# for each asa add alerts for data conversion errors and failed function requests
for($i=0;$i -lt $asaresources.Length;$i++){
    #if the name of the resource is longer than 17 characters, take a substring so it doesn't go past the max
    if($asaresources[$i].Name.Length -gt 17){$name = $asaresources[$i].Name.Substring(0,17)} else{$name = $asaresources[$i].Name}
    $alertname = $name+"converEr"
    Add-AzureRmMetricAlertRule -Name $alertname -Location $asaresources[$i].Location -ResourceGroup $rg -TargetResourceId $asaresources[$i].ResourceId -MetricName "ConversionErrors" -Operator GreaterThan -Threshold 50 -WindowSize 00:15:00 -TimeAggregationOperator Total -Actions $actionWebhook -Description "data conversion error on Asa job"
    $alertname = $name+"FailedFunc"
    Add-AzureRmMetricAlertRule -Name $alertname -Location $asaresources[$i].Location -ResourceGroup $rg -TargetResourceId $asaresources[$i].ResourceId -MetricName "AMLCalloutFailedRequests" -Operator GreaterThan -Threshold 50 -WindowSize 00:15:00 -TimeAggregationOperator Total -Actions $actionWebhook -Description "failed function request asa job"
}

