import { Controller, Get, Query } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiOkResponse,
  ApiOperation,
  ApiServiceUnavailableResponse,
  ApiTags,
} from '@nestjs/swagger';
import {
  ServiceUnavailableErrorResponseDto,
  ValidationErrorResponseDto,
} from '../../common/responses/error-response.dto';
import { GetNewsQueryDto } from './dto/get-news.query.dto';
import { NewsService } from './news.service';
import { NewsListResponseDto } from './responses/news-summary.response';

@ApiTags('News')
@ApiServiceUnavailableResponse({
  description: '데이터베이스 연결을 사용할 수 없습니다.',
  type: ServiceUnavailableErrorResponseDto,
})
@Controller('news')
export class NewsController {
  constructor(private readonly newsService: NewsService) {}

  @Get()
  @ApiOperation({
    summary: '뉴스 목록 조회',
    description:
      '출처, 키워드, 정렬 조건으로 LCK 관련 뉴스 기사 목록을 페이지네이션하여 조회합니다.',
  })
  @ApiOkResponse({
    type: NewsListResponseDto,
    description: '조건에 맞는 뉴스 기사 목록',
  })
  @ApiBadRequestResponse({
    description: '쿼리 파라미터 검증에 실패했습니다.',
    type: ValidationErrorResponseDto,
  })
  getNews(@Query() query: GetNewsQueryDto): Promise<NewsListResponseDto> {
    return this.newsService.getNews(query);
  }
}
