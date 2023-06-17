import {
  BaseConfigurationItem,
  BatchGetResourceConfigCommand,
  ConfigServiceClient,
  paginateListDiscoveredResources,
  paginateSelectResourceConfig,
  ResourceIdentifier,
  ResourceKey,
  SelectResourceConfigCommand,
} from "@aws-sdk/client-config-service";
import _ from "lodash";
import { promises as fs } from "fs";

export interface IConfigService {
  lookupResourceTags(): Promise<Record<string, string>>;
}

export class ConfigService implements IConfigService {
  lookupResourceTags(): Promise<Record<string, string>> {
    return Promise.resolve({});
  }
}

(async () => {
  const configServiceClient = new ConfigServiceClient({});

  // const resourceIdentifiers: ResourceIdentifier[] = [];
  //
  // for await (const resources of paginateListDiscoveredResources(
  //   { client: configServiceClient },
  //   { resourceType: undefined },
  // )) {
  //   (resources.resourceIdentifiers || []).forEach(resourceIdentifier => {
  //     resourceIdentifiers.push(resourceIdentifier);
  //   });
  // }
  //
  // fs.writeFile(
  //   "resource-identifiers.json",
  //   JSON.stringify(resourceIdentifiers, null, 2),
  // );

  const resourceKeys: ResourceKey[] = [];

  for await (const results of paginateSelectResourceConfig(
    { client: configServiceClient },
    {
      Expression: "SELECT resourceId, resourceType",
    },
  )) {
    results?.Results?.forEach(result => {
      const { resourceId, resourceType } = JSON.parse(result);

      resourceKeys.push({ resourceType, resourceId });
    });
  }

  const results: BaseConfigurationItem[] = [];

  for (const batch of _.chunk(resourceKeys, 100)) {
    const output = await configServiceClient.send(
      new BatchGetResourceConfigCommand({
        resourceKeys: batch,
      }),
    );

    output.baseConfigurationItems?.forEach(configItem =>
      results.push(configItem),
    );
  }

  await fs.writeFile("output.json", JSON.stringify(results, null, 2));
})().catch(console.error);
