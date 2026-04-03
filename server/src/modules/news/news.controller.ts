import { Controller, Get, Query } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { GetNewsQueryDto } from './dto/get-news.query.dto';
import { NewsService } from './news.service';
import { NewsListResponseDto } from './responses/news-summary.response';

@ApiTags('News')
@Controller('news')
export class NewsController {
  constructor(private readonly newsService: NewsService) {}

  @Get()
  @ApiOperation({ summary: '뉴스 목록 조회' })
  @ApiOkResponse({ type: NewsListResponseDto })
  getNews(@Query() query: GetNewsQueryDto): Promise<NewsListResponseDto> {
    return this.newsService.getNews(query);
  }
}
