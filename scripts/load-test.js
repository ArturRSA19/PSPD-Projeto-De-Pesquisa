import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

// Test configuration
export const options = {
  stages: [
    { duration: '30s', target: 10 },   // Ramp up to 10 users
    { duration: '1m', target: 10 },    // Stay at 10 users
    { duration: '30s', target: 50 },   // Ramp up to 50 users
    { duration: '2m', target: 50 },    // Stay at 50 users
    { duration: '30s', target: 100 },  // Ramp up to 100 users
    { duration: '2m', target: 100 },   // Stay at 100 users
    { duration: '30s', target: 0 },    // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
    errors: ['rate<0.1'],              // Error rate should be below 10%
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

export default function () {
  // Test 1: Health check
  let res = http.get(`${BASE_URL}/healthz`);
  check(res, {
    'healthz status is 200': (r) => r.status === 200,
  }) || errorRate.add(1);

  sleep(0.5);

  // Test 2: Get User (Unary RPC)
  const userId = Math.floor(Math.random() * 2) + 1; // Random between 1-2
  res = http.get(`${BASE_URL}/users/${userId}`);
  check(res, {
    'get user status is 200': (r) => r.status === 200,
    'get user has id': (r) => JSON.parse(r.body).id !== undefined,
  }) || errorRate.add(1);

  sleep(0.5);

  // Test 3: List Users (Server Streaming)
  res = http.get(`${BASE_URL}/users`);
  check(res, {
    'list users status is 200': (r) => r.status === 200,
    'list users returns array': (r) => Array.isArray(JSON.parse(r.body)),
  }) || errorRate.add(1);

  sleep(0.5);

  // Test 4: Get Score from Service B (Unary RPC)
  res = http.get(`${BASE_URL}/stats/${userId}`);
  check(res, {
    'get score status is 200': (r) => r.status === 200,
    'get score has user_id': (r) => JSON.parse(r.body).user_id !== undefined,
  }) || errorRate.add(1);

  sleep(1);

  // Test 5: Bulk Create Users (Client Streaming) - ocasionalmente
  if (Math.random() < 0.2) { // 20% chance
    const payload = {
      users: [
        { id: `${Date.now()}-1`, name: `User-${Date.now()}-1`, age: 25 },
        { id: `${Date.now()}-2`, name: `User-${Date.now()}-2`, age: 30 },
      ]
    };
    res = http.post(`${BASE_URL}/users/bulk`, JSON.stringify(payload), {
      headers: { 'Content-Type': 'application/json' },
    });
    check(res, {
      'bulk create status is 200': (r) => r.status === 200,
      'bulk create has count': (r) => JSON.parse(r.body).count !== undefined,
    }) || errorRate.add(1);

    sleep(0.5);
  }
}
