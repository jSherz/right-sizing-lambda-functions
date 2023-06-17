import { logger } from "../../shared/powertools";
import { DeleteObjectCommand, S3Client } from "@aws-sdk/client-s3";
import * as z from "zod";

const eventValidator = z.object({
  version: z.literal("0"),
  id: z.string(),
  "detail-type": z.literal("Object Created"),
  source: z.string(),
  account: z.string(),
  time: z.string(),
  region: z.string(),
  resources: z.array(z.string()),
  detail: z.object({
    version: z.literal("0"),
    bucket: z.object({
      name: z.string(),
    }),
    object: z.object({
      key: z.string(),
      size: z.number(),
      etag: z.string(),
      "version-id": z.string().optional(),
      sequencer: z.string(),
    }),
    "request-id": z.string(),
    requester: z.string(),
    "source-ip-address": z.string(),
    reason: z.string(),
  }),
});

export function buildHandler(s3Client: S3Client) {
  return async function unwrappedHandler(rawEvent: unknown) {
    const event = eventValidator.parse(rawEvent);

    const ctx = {
      bucket: event.detail.bucket.name,
      object: event.detail.object.key,
      size: event.detail.object.size,
    };

    await s3Client.send(
      new DeleteObjectCommand({
        Bucket: event.detail.bucket.name,
        Key: event.detail.object.key,
      }),
    );

    logger.info("pretended to process file", ctx);
  };
}
