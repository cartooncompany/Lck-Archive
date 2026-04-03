import { Controller, Post } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { NewsSyncJob } from './jobs/news-sync.job';

@ApiTags('Crawler')
@Controller('crawler/news')
export class NewsSyncController {
  constructor(private readonly newsSyncJob: NewsSyncJob) {}

  @Post('sync')
  @ApiOperation({ summary: '뉴스 데이터 수동 동기화' })
  @ApiOkResponse({
    schema: {
      type: 'object',
      properties: {
        newsArticles: { type: 'number', example: 31 },
      },
    },
  })
  sync() {
    return this.newsSyncJob.sync();
  }
}
