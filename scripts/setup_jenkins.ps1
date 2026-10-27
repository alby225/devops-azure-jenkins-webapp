<#
.SYNOPSIS
Installs / Runs Jenkins locally on Windows using Java (already installed) or Docker.
#>

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Local Jenkins CI/CD Pipeline Setup Helper" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$jenkinsDir = "$HOME\.jenkins_standalone"
if (-not (Test-Path $jenkinsDir)) {
    New-Item -ItemType Directory -Path $jenkinsDir -Force | Out-Null
}

$warPath = "$jenkinsDir\jenkins.war"

if (-not (Test-Path $warPath)) {
    Write-Host "[1/3] Downloading official Jenkins LTS WAR package..." -ForegroundColor Yellow
    Write-Host "Destination: $warPath" -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri "https://get.jenkins.io/war-stable/latest/jenkins.war" -OutFile $warPath -UseBasicParsing
        Write-Host "Download complete!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download automatically. You can download manually from https://www.jenkins.io/download/ and place it at $warPath" -ForegroundColor Red
        pause
        exit 1
    }
} else {
    Write-Host "[1/3] jenkins.war is already present." -ForegroundColor Green
}

Write-Host "[2/3] Launching Jenkins on http://localhost:8080 ..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C at any time to stop Jenkins." -ForegroundColor Gray
Write-Host ""
Write-Host "When Jenkins boots for the first time, it will print your Initial Admin Password below!" -ForegroundColor Magenta
Write-Host "==========================================================" -ForegroundColor Cyan

java -jar "$warPath" --httpPort=8080
