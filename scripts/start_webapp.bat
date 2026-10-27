@echo off
title DevOps Web Application - Port 3000
echo =======================================================
echo  Starting DevOps Cloud Web Application on Port 3000
echo =======================================================
cd /d "%~dp0..\app"
node server.js
pause
