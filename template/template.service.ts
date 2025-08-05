import { Injectable, Logger } from '@nestjs/common'
import { ConfigService } from '@nestjs/config';
import { {{.Inputs.module|toPascalCase}}InputDto, {{.Inputs.module|toPascalCase}}OutputDto } from '@lambda/{{.Inputs.module|toLowerCase}}/{{.Inputs.module|toLowerCase}}.dto'

@Injectable()
export class {{.Inputs.module|toPascalCase}}Service {
  private readonly logger = new Logger({{.Inputs.module|toPascalCase}}Service.name)
  constructor (
    private readonly configService: ConfigService,
  ) {}
  async process (input: {{.Inputs.module|toPascalCase}}InputDto): Promise<{{.Inputs.module|toPascalCase}}OutputDto> {
    const dummy = this.configService.get<string>('dummy')
    this.logger.log(`dummy: ${dummy}`)
    return {
      name: `${dummy} ${input.name}`
    }
  }
}
