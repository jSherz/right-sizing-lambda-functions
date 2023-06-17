import { injectLambdaContext } from "@aws-lambda-powertools/logger";
import { captureLambdaHandler } from "@aws-lambda-powertools/tracer";
import middy from "@middy/core";
import { logger, tracer } from "../../shared/powertools";
import { buildHandler } from "./handler";
import { S3Client } from "@aws-sdk/client-s3";

const s3Client = tracer.captureAWSv3Client(new S3Client({}));

export const handler = middy(buildHandler(s3Client))
  .use(injectLambdaContext(logger, { logEvent: true }))
  .use(captureLambdaHandler(tracer, { captureResponse: false }));
