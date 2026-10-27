const express = require('express');
const os = require('os');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static frontend files
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

// API: Health check endpoint for CI/CD smoke test
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    timestamp: new Date().toISOString(),
    uptime: Math.floor(process.uptime()) + ' seconds',
    environment: process.env.NODE_ENV || 'production'
  });
});

// API: System & Deployment Information endpoint
app.get('/api/info', (req, res) => {
  res.status(200).json({
    application: 'DevOps Automated Web App',
    version: '1.0.0',
    platform: os.platform() + ' ' + os.release(),
    hostname: os.hostname(),
    totalMemoryMB: Math.round(os.totalmem() / (1024 * 1024)),
    freeMemoryMB: Math.round(os.freemem() / (1024 * 1024)),
    cpuCores: os.cpus().length,
    deployment: {
      provider: process.env.CLOUD_PROVIDER || 'Microsoft Azure (Simulated / Local)',
      region: process.env.AZURE_REGION || 'East US',
      vmSize: process.env.VM_SIZE || 'Standard_B1s',
      ciServer: 'Jenkins CI/CD Pipeline',
      iacTool: 'Terraform v1.16+',
      buildNumber: process.env.BUILD_NUMBER || 'Build #1',
      gitCommit: process.env.GIT_COMMIT || 'latest-main',
      deployedAt: new Date().toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
  });
});

if (require.main === module) {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`====================================================`);
    console.log(` CloudOps Web Application is LIVE`);
    console.log(` Running on: http://localhost:${PORT}`);
    console.log(` Cloud Target: ${process.env.CLOUD_PROVIDER || 'Azure VM'}`);
    console.log(` Health Check: http://localhost:${PORT}/api/health`);
    console.log(`====================================================`);
  });
}

module.exports = app;
