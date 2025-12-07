import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

// Stress Test - Carga muito maior
export const options = {
  stages: [
    { duration: '1m', target: 50 },    // Warm up
    { duration: '2m', target: 150 },   // Ramp up para 150
    { duration: '3m', target: 200 },   // Pico em 200 usuários
    { duration: '2m', target: 200 },   // Manter pico
    { duration: '1m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'], // Mais tolerante em stress
    errors: ['rate<0.2'],               // Aceita mais erros
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

export default function () {
  let res = http.get(`${BASE_URL}/healthz`);
  check(res, {
    'healthz status is 200': (r) => r.status === 200,
  }) || errorRate.add(1);

  sleep(0.3);

  const userId = Math.floor(Math.random() * 2) + 1;
  res = http.get(`${BASE_URL}/users/${userId}`);
  check(res, {
    'get user status is 200': (r) => r.status === 200,
  }) || errorRate.add(1);

  sleep(0.3);

  res = http.get(`${BASE_URL}/users`);
  check(res, {
    'list users status is 200': (r) => r.status === 200,
  }) || errorRate.add(1);

  sleep(0.5);
}
