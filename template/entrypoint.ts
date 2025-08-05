import { NestFactory } from '@nestjs/core'
import {
  Context,
  Handler,
  SQSEvent,
  SQSRecord
} from 'aws-lambda'
import { AppModule } from '@lambda/app.module'
import { INestApplicationContext, Logger as NestLogger } from '@nestjs/common'
import { Logger } from 'nestjs-pino'

const logger = new NestLogger('{{.Inputs.module|toLowerCase}}LambdaHandler')

async function initApp(): Promise<INestApplicationContext> {
  const app = await NestFactory.createApplicationContext(AppModule, {
    bufferLogs: true,
  });
  app.useLogger(app.get(Logger));
  await app.init()
  app.flushLogs()

  return app
}

let app: INestApplicationContext | undefined;

if (app === undefined) {
  app = await initApp();
}

export const handler: Handler<SQSEvent> = async (
  event: SQSEvent,
  _context: Context
): Promise<void> => {
  if (event && event.Records && Array.isArray(event.Records)) {
    try {
      logger.log(`Iniciando {{.Inputs.module|toLowerCase}}LambdaHandler: ${JSON.stringify(event)}`)

      const records: any[] = event.Records.map(
        (record: SQSRecord) => JSON.parse(record.body) as any
      )

      const promises = records.map(async (record) => {
        console.log(`Procesando mensaje: ${JSON.stringify(record)}`)
        return Promise.resolve()
      })

      await Promise.all(promises)

      logger.log('{{.Inputs.module|toLowerCase}}LambdaHandler finalizado.')
    } catch (e) {
      logger.error('Error al procesar el servicio')
      logger.error(e)
      throw e
    }
  }
}
