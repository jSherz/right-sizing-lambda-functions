import { Logger } from "@aws-lambda-powertools/logger";
import { Tracer } from "@aws-lambda-powertools/tracer";

const serviceName = "shift-security-left-aws-config";

export const logger = new Logger({
  serviceName,
  persistentLogAttributes: {
    region: process.env.AWS_REGION || "N/A",
    executionEnv: process.env.AWS_EXECUTION_ENV || "N/A",
  },
});

export const tracer = new Tracer({
  serviceName,
});
