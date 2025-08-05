import { Module } from '@nestjs/common'
import configuration from '@lambda/configuration';
import { ConfigModule } from '@nestjs/config';
import { {{.Inputs.module|toPascalCase}}Module } from '@lambda/{{.Inputs.module|toLowerCase}}/{{.Inputs.module|toLowerCase}}.module'

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    {{.Inputs.module|toPascalCase}}Module,
  ]
})
export class AppModule {}
