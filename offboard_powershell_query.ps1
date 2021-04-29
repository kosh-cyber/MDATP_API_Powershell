$tenantId = ''
$appId = ''
$appSecret = ''
$resourceAppIdUri = 'https://api.securitycenter.microsoft.com'
$oAuthUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"
$authBody = [Ordered] @{
    resource = "$resourceAppIdUri"
    client_id = "$appId"
    client_secret = "$appSecret"
    grant_type = 'client_credentials'
}
$authResponse = Invoke-RestMethod -Method Post -Uri $oAuthUri -Body $authBody -ErrorAction Stop
$token = $authResponse.access_token
$headers = @{ 
    'Content-Type' = 'application/json'
    'Accept' = 'application/json'
    'Authorization' = "Bearer $token" 
}
$filePath = ''
$resultfilePath = ''

foreach($line in Get-Content $filePath) {
	Start-Sleep -Milliseconds 500
	$query = 'https://api.securitycenter.microsoft.com/api/machineactions?$filter=machineId eq '+"'"+"$line"+"'"
	Write-Host "$query"
		try {
			$webResponse = Invoke-WebRequest -Method Get -Uri $query -Headers $headers -ErrorAction SilentlyContinue
			$response = ($webResponse.content | ConvertFrom-Json).value
			$type = $response.type
			$status = $response.status
			$creationDateTime = $response.creationDateTimeUtc
			$computerDnsName = $response.computerDnsName
			$result = "DeviceID:$line,computerName:$computerDnsName,status:$status,type:$type,creationTime:$creationDateTime"
			Write-Host $result
			Out-File -Append -FilePath $resultfilePath -InputObject $result -Encoding ASCII
		}
		catch {
			$Err = "_.Exception.Message,$line"
			Write-Host $Err
			Out-File -Append -FilePath $resultfilePath -InputObject $Err -Encoding ASCII
		}
}  