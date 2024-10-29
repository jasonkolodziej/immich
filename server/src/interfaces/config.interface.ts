import { RegisterQueueOptions } from '@nestjs/bullmq';
import { QueueOptions } from 'bullmq';
import { RedisOptions } from 'ioredis';
import { OpenTelemetryModuleOptions } from 'nestjs-otel/lib/interfaces';
import { ImmichEnvironment, ImmichTelemetry, ImmichWorker, LogLevel } from 'src/enum';
import { DatabaseConnectionParams, VectorExtension } from 'src/interfaces/database.interface';
import { PostgresConnectionOptions } from 'typeorm/driver/postgres/PostgresConnectionOptions.js';

export const IConfigRepository = 'IConfigRepository';

export interface EnvData {
  host?: string;
  port: number;
  environment: ImmichEnvironment;
  configFile?: string;
  logLevel?: LogLevel;

  buildMetadata: {
    build?: string;
    buildUrl?: string;
    buildImage?: string;
    buildImageUrl?: string;
    repository?: string;
    repositoryUrl?: string;
    sourceRef?: string;
    sourceCommit?: string;
    sourceUrl?: string;
    thirdPartySourceUrl?: string;
    thirdPartyBugFeatureUrl?: string;
    thirdPartyDocumentationUrl?: string;
    thirdPartySupportUrl?: string;
  };

  bull: {
    config: QueueOptions;
    queues: RegisterQueueOptions[];
  };

  //? ssl
  certs?: {
    ca: string; // path/to/server-certificates/root.crt
    key: string; // path/to/client-key/postgresql.key
    cert: string; // path/to/client-certificates/postgresql.crt
  };

  database: {
    config: PostgresConnectionOptions & DatabaseConnectionParams;
    skipMigrations: boolean;
    vectorExtension: VectorExtension;
  };

  licensePublicKey: {
    client: string;
    server: string;
  };

  network: {
    trustedProxies: string[];
  };

  otel: OpenTelemetryModuleOptions;

  resourcePaths: {
    lockFile: string;
    geodata: {
      dateFile: string;
      admin1: string;
      admin2: string;
      cities500: string;
      naturalEarthCountriesPath: string;
    };
    web: {
      root: string;
      indexHtml: string;
    };
  };

  redis: RedisOptions;

  telemetry: {
    apiPort: number;
    microservicesPort: number;
    metrics: Set<ImmichTelemetry>;
  };

  storage: {
    ignoreMountCheckErrors: boolean;
  };

  workers: ImmichWorker[];

  noColor: boolean;
  nodeVersion?: string;
}

export interface IConfigRepository {
  getEnv(): EnvData;
}
