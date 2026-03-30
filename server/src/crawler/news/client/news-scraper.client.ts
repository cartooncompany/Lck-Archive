import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance } from 'axios';
import { NewsParser } from '../parser/news.parser';
import { ScrapedNewsArticle } from '../types/news-source.types';

const DEFAULT_USER_AGENT = 'Mozilla/5.0';
const DEFAULT_ACCEPT_LANGUAGE = 'ko-KR,ko;q=0.9';
const DEFAULT_LOLESPORTS_NEWS_URL = 'https://lolesports.com/ko-KR/news';
const DEFAULT_NAVER_NEWS_URL =
  'https://game.naver.com/esports/League_of_Legends/news/lol';

@Injectable()
export class NewsScraperClient {
  private readonly logger = new Logger(NewsScraperClient.name);
  private readonly axiosClient: AxiosInstance;
  private readonly lolesportsNewsUrl: string;
  private readonly naverNewsUrl: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly newsParser: NewsParser,
  ) {
    this.lolesportsNewsUrl =
      this.configService.get<string>('LOLESPORTS_NEWS_URL') ??
      DEFAULT_LOLESPORTS_NEWS_URL;
    this.naverNewsUrl =
      this.configService.get<string>('NAVER_ESPORTS_NEWS_URL') ??
      DEFAULT_NAVER_NEWS_URL;

    this.axiosClient = axios.create({
      timeout: 10000,
      headers: {
        'User-Agent': DEFAULT_USER_AGENT,
        'Accept-Language': DEFAULT_ACCEPT_LANGUAGE,
      },
    });
  }

  async fetchLatestNews(): Promise<ScrapedNewsArticle[]> {
    const [lolesportsArticles, naverArticles] = await Promise.all([
      this.fetchLolesportsNews(),
      this.fetchNaverNews(),
    ]);

    const articles = [...lolesportsArticles, ...naverArticles].sort(
      (left, right) =>
        (right.publishedAt?.getTime() ?? 0) -
        (left.publishedAt?.getTime() ?? 0),
    );

    this.logger.log(
      `Fetched news articles. lolesports=${lolesportsArticles.length}, naver=${naverArticles.length}, total=${articles.length}`,
    );

    return articles;
  }

  private async fetchLolesportsNews(): Promise<ScrapedNewsArticle[]> {
    const html = await this.fetchHtml(this.lolesportsNewsUrl);
    return this.newsParser.parseLolesportsNewsList(html);
  }

  private async fetchNaverNews(): Promise<ScrapedNewsArticle[]> {
    const html = await this.fetchHtml(this.naverNewsUrl);
    return this.newsParser.parseNaverNewsList(html);
  }

  private async fetchHtml(url: string): Promise<string> {
    const response = await this.axiosClient.get<string>(url, {
      responseType: 'text',
    });

    return response.data;
  }
}
