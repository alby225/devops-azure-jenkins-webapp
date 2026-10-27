@echo off
title Jenkins CI/CD Automation Server - Port 8080
echo ==========================================================
echo  Starting Jenkins Automation Server on http://localhost:8080
echo ==========================================================
echo.
echo Initial Admin Password: f6d40bb80a104645998c6a11e6bc6fb2
echo.
echo IMPORTANT: Keep this window OPEN while using Jenkins!
echo.
"C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot\bin\java.exe" -jar "%USERPROFILE%\.jenkins_standalone\jenkins.war" --httpPort=8080
pause
