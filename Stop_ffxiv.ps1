function CheckAndStopProcess {
    param(
        [string]$processName
    )
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($process) {
        $process | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 5

        $checkProcess = Get-Process -Name $processName -ErrorAction SilentlyContinue
        if (-Not $checkProcess) {
            return $true
        } else {
            return $false
        }
    } else {
        return $null
    }
}

function SendDiscordNotification {
    param(
        [string]$webhookUrl,
        [string]$message,
        [string]$username = "FFXIV Monitor"
    )
    $body = ConvertTo-Json -Depth 2 @{
        username = $username
        content = $message
    }
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $body -ContentType 'application/json'
}

function ShutdownComputer {
    Stop-Computer -Force
}

$processName = "ffxiv_dx11"
$webhookUrl = "WEBHOOK HERE"

$result = CheckAndStopProcess -processName $processName

if ($result -eq $true) {
    $message = "The process $processName has been stopped successfully. Shutting down the PC now..."
    SendDiscordNotification -webhookUrl $webhookUrl -message $message
    ShutdownComputer
} elseif ($result -eq $false) {
    $message = "Failed to stop the process $processName."
    SendDiscordNotification -webhookUrl $webhookUrl -message $message
} elseif ($result -eq $null) {
    $message = "The process $processName is not running."
    SendDiscordNotification -webhookUrl $webhookUrl -message $message
}
