$data = Get-Content -Raw -Path portinfo.json | ConvertFrom-Json

$output = ""

$total = $data.servers.ports.Count
$count = 0

foreach ($server in $data.servers) {
    foreach ($port in $server.ports) {
        $portNumbers = $port
        if ($port -is [System.Management.Automation.PSCustomObject]) {
            $portNumbers = $port.from..$port.to
        }
        foreach ($portNumber in $portNumbers) {
            $count++
            Write-Progress $ProgressPreference -Activity "Testing port $portNumber on $($server.name)"  -PercentComplete ($count / $total * 100) -Status "Processing"
            $result = Test-NetConnection -ComputerName $server.ip -Port $portNumber -InformationLevel Quiet

            if ($result) {
                $output += "Port $($portNumber) is open on $($server.name)`n"
            } else {
                $output += "Port $($portNumber) is closed on $($server.name)`n"
            }
        }
    }
}

$output