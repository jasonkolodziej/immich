import { NestFactory } from '@nestjs/core';
import { isMainThread } from 'node:worker_threads';
import { MicroservicesModule } from 'src/app.module';
import { serverVersion } from 'src/constants';
import { IConfigRepository } from 'src/interfaces/config.interface';
import { ILoggerRepository } from 'src/interfaces/logger.interface';
import { WebSocketAdapter } from 'src/middleware/websocket.adapter';
import { ConfigRepository } from 'src/repositories/config.repository';
import { bootstrapTelemetry } from 'src/repositories/telemetry.repository';
import { isStartUpError } from 'src/services/storage.service';
//? mtls
// import { MicroserviceOptions, Transport } from '@nestjs/microservices';

export async function bootstrap() {
  const { telemetry } = new ConfigRepository().getEnv();
  if (telemetry.metrics.size > 0) {
    bootstrapTelemetry(telemetry.microservicesPort);
  }
  const app = await NestFactory.create(MicroservicesModule, { bufferLogs: true });
  //? ssl - https://docs.nestjs.com/microservices/basics#tls-support
  // const key = readFileSync('<pathToKeyFile>', 'utf8').toString();
  // const cert = readFileSync('<pathToCertFile>', 'utf8').toString();
  // const app = await NestFactory.createMicroservice<MicroserviceOptions>(MicroservicesModule, {
  //   bufferLogs: true,
  //   transport: Transport.TCP,
  //   options: {
  //     tlsOptions: {
  //       key,
  //       cert,
  //     },
  //   },
  // });

  const logger = await app.resolve(ILoggerRepository);
  logger.setContext('Bootstrap');
  app.useLogger(logger);
  app.useWebSocketAdapter(new WebSocketAdapter(app));

  await app.listen(0);

  const configRepository = app.get<IConfigRepository>(IConfigRepository);
  const { environment } = configRepository.getEnv();
  logger.log(`Immich Microservices is running [v${serverVersion}] [${environment}] `);
}

if (!isMainThread) {
  bootstrap().catch((error) => {
    if (!isStartUpError(error)) {
      console.error(error);
    }
    throw error;
  });
}
