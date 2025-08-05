import { Module } from '@nestjs/common'
import { {{.Inputs.module|toPascalCase}}Service } from '@lambda/{{.Inputs.module|toLowerCase}}/{{.Inputs.module|toLowerCase}}.service'

@Module({
  providers: [{{.Inputs.module|toPascalCase}}Service]
})
export class {{.Inputs.module|toPascalCase}}Module {}
