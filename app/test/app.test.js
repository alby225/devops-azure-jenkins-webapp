const assert = require('assert');
const http = require('http');
const app = require('../server');

const TEST_PORT = 3099;
const server = app.listen(TEST_PORT, () => {
  console.log(`[TEST RUNNER] Test server started on port ${TEST_PORT}`);

  // Test 1: Health check endpoint returns 200 OK
  http.get(`http://localhost:${TEST_PORT}/api/health`, (res) => {
    assert.strictEqual(res.statusCode, 200, 'Expected status code 200 from /api/health');
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      const parsed = JSON.parse(data);
      assert.strictEqual(parsed.status, 'UP', 'Health check status must be UP');
      console.log('✓ PASS: Health check endpoint returns 200 OK and UP status');

      // Test 2: Info endpoint
      http.get(`http://localhost:${TEST_PORT}/api/info`, (res2) => {
        assert.strictEqual(res2.statusCode, 200, 'Expected status code 200 from /api/info');
        let data2 = '';
        res2.on('data', chunk => data2 += chunk);
        res2.on('end', () => {
          const parsedInfo = JSON.parse(data2);
          assert(parsedInfo.application, 'Application name should be present');
          assert(parsedInfo.deployment, 'Deployment metadata should be present');
          console.log('✓ PASS: Info endpoint returns system and deployment metadata');
          console.log('========================================================');
          console.log('ALL UNIT & SMOKE TESTS PASSED SUCCESSFULLY! (EXIT CODE 0)');
          console.log('========================================================');
          server.close(() => {
            process.exit(0);
          });
        });
      });
    });
  }).on('error', (err) => {
    console.error('✗ FAIL: HTTP request error:', err.message);
    server.close(() => process.exit(1));
  });
});
