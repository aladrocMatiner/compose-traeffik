import http from "k6/http";
import { check, sleep } from "k6";

const iterations = Number(__ENV.K6_ITERATIONS || "10");
const sleepSeconds = Number(__ENV.K6_SLEEP_SECONDS || "1");
const target = __ENV.K6_TARGET_URL || "https://whoami.local.test";

export const options = {
  vus: 1,
  iterations,
  insecureSkipTLSVerify: true,
  thresholds: {
    http_req_failed: ["rate<0.05"],
    http_req_duration: ["p(95)<1200"],
  },
};

export default function () {
  const response = http.get(target, {
    tags: { scenario: "observability-smoke" },
  });

  check(response, {
    "status is 200": (r) => r.status === 200,
  });

  sleep(sleepSeconds);
}
