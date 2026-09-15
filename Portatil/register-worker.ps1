# Avisa al NAS de que este worker GPU está disponible (Windows PowerShell).
$NAS = "http://192.168.1.50:8000"   # <-- IP del NAS
$WORKER = "http://192.168.1.60"     # <-- IP de este portátil
try {
  Invoke-RestMethod -Method Post -Uri "$NAS/api/worker/register" `
    -ContentType "application/json" `
    -Body (@{ url = $WORKER; models = @("phi4-mini","qwen3:4b") } | ConvertTo-Json)
  Write-Host "Worker registrado en el NAS."
} catch {
  Write-Host "No se pudo registrar (NAS apagado?): $_"
}
