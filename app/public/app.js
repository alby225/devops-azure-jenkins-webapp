document.addEventListener('DOMContentLoaded', () => {
  loadTelemetry();
});

async function loadTelemetry() {
  try {
    const res = await fetch('/api/info');
    if (!res.ok) throw new Error('Network error');
    const data = await res.json();

    // Deployment Telemetry
    if (data.deployment) {
      document.getElementById('dep-provider').innerText = data.deployment.provider;
      document.getElementById('dep-region').innerText = data.deployment.region;
      document.getElementById('dep-vmsize').innerText = data.deployment.vmSize;
      document.getElementById('dep-ci').innerText = data.deployment.ciServer;
      document.getElementById('dep-iac').innerText = data.deployment.iacTool;
      document.getElementById('dep-build').innerText = data.deployment.buildNumber;
      document.getElementById('dep-commit').innerHTML = `<code>${data.deployment.gitCommit}</code>`;
      document.getElementById('dep-timestamp').innerText = data.deployment.deployedAt;
    }

    // Host Runtime Metrics
    document.getElementById('sys-platform').innerText = data.platform || 'Linux Ubuntu (Azure VM)';
    document.getElementById('sys-hostname').innerText = data.hostname || 'azure-vm-web-host';
    document.getElementById('sys-cpu').innerText = `${data.cpuCores} Core(s)`;
    document.getElementById('sys-freemem').innerText = `${data.freeMemoryMB} MB`;
    document.getElementById('sys-totalmem').innerText = `${data.totalMemoryMB} MB`;
    document.getElementById('sys-uptime').innerText = `Node.js ${processNodeVersion(data.version)}`;

  } catch (err) {
    console.error('Failed to load telemetry:', err);
    document.getElementById('dep-provider').innerText = 'Microsoft Azure (Simulated Production)';
    document.getElementById('sys-platform').innerText = 'Linux x64 (Ubuntu 22.04 LTS)';
    document.getElementById('sys-hostname').innerText = 'azure-devops-vm';
    document.getElementById('sys-cpu').innerText = '1 Core';
    document.getElementById('sys-freemem').innerText = '420 MB';
    document.getElementById('sys-totalmem').innerText = '1024 MB';
    document.getElementById('sys-uptime').innerText = 'Node.js v20.x Active';
  }
}

function processNodeVersion(ver) {
  return ver ? `v${ver}` : 'Active (Production)';
}

async function fetchHealth() {
  const output = document.getElementById('api-output');
  output.innerText = 'Fetching GET /api/health ...';
  try {
    const res = await fetch('/api/health');
    const json = await res.json();
    output.innerText = JSON.stringify(json, null, 2);
  } catch (err) {
    output.innerText = 'Error calling /api/health: ' + err.message;
  }
}

async function fetchInfo() {
  const output = document.getElementById('api-output');
  output.innerText = 'Fetching GET /api/info ...';
  try {
    const res = await fetch('/api/info');
    const json = await res.json();
    output.innerText = JSON.stringify(json, null, 2);
  } catch (err) {
    output.innerText = 'Error calling /api/info: ' + err.message;
  }
}
