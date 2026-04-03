import { Injectable } from '@nestjs/common';
import {
  NEWS_SOURCES,
  NaverNextData,
  NaverNewsItem,
  ScrapedNewsArticle,
} from '../types/news-source.types';

const LOLESPORTS_CARD_REGEX =
  /<a class="group pos_relative ov_hidden d_flex flex-d_column gap_15" href="(?<path>\/article\/[^"]+)">[\s\S]*?<img[^>]+src="(?<image>[^"]+)"[\s\S]*?<div class="c_text.secondary textStyle_label\/lg">\s*(?<publishedAtText>[^<]+?)\s*<\/div>\s*<div class="textStyle_headline\/sm">\s*(?<title>[\s\S]*?)\s*<\/div>\s*<div class="c_text.secondary textStyle_body\/lg">\s*(?<summary>[\s\S]*?)\s*<\/div>/g;
const NEXT_DATA_REGEX =
  /<script id="__NEXT_DATA__" type="application\/json">([\s\S]*?)<\/script>/;

const MONTH_INDEX_BY_TOKEN = new Map<string, number>([
  ['jan', 1],
  ['january', 1],
  ['janvier', 1],
  ['enero', 1],
  ['januar', 1],
  ['janeiro', 1],
  ['feb', 2],
  ['february', 2],
  ['fevrier', 2],
  ['fevrero', 2],
  ['febrero', 2],
  ['februar', 2],
  ['fevereiro', 2],
  ['mar', 3],
  ['march', 3],
  ['mars', 3],
  ['marzo', 3],
  ['marz', 3],
  ['maerz', 3],
  ['abril', 4],
  ['apr', 4],
  ['april', 4],
  ['avril', 4],
  ['may', 5],
  ['mai', 5],
  ['mayo', 5],
  ['maio', 5],
  ['jun', 6],
  ['june', 6],
  ['juin', 6],
  ['junio', 6],
  ['juni', 6],
  ['junho', 6],
  ['jul', 7],
  ['july', 7],
  ['juillet', 7],
  ['julio', 7],
  ['juli', 7],
  ['julho', 7],
  ['aug', 8],
  ['august', 8],
  ['aout', 8],
  ['agosto', 8],
  ['augusto', 8],
  ['sep', 9],
  ['sept', 9],
  ['september', 9],
  ['septembre', 9],
  ['septiembre', 9],
  ['oct', 10],
  ['october', 10],
  ['octobre', 10],
  ['octubre', 10],
  ['oktober', 10],
  ['nov', 11],
  ['november', 11],
  ['novembre', 11],
  ['noviembre', 11],
  ['dec', 12],
  ['december', 12],
  ['decembre', 12],
  ['diciembre', 12],
  ['dezember', 12],
  ['dezembro', 12],
]);

@Injectable()
export class NewsParser {
  parseLolesportsNewsList(html: string): ScrapedNewsArticle[] {
    const articles: ScrapedNewsArticle[] = [];

    for (const match of html.matchAll(LOLESPORTS_CARD_REGEX)) {
      const path = match.groups?.path;
      const image = match.groups?.image;
      const publishedAtText = this.normalizeText(match.groups?.publishedAtText);
      const title = this.normalizeText(match.groups?.title);
      const summary = this.toNullable(this.normalizeText(match.groups?.summary));

      if (!path || !title) {
        continue;
      }

      articles.push({
        externalSource: NEWS_SOURCES.LOLESPORTS,
        externalId: path,
        title,
        summary,
        thumbnailUrl: this.toNullable(this.decodeHtml(image ?? '')),
        articleUrl: `https://lolesports.com${path}`,
        publisher: 'LoL Esports',
        publishedAt: this.parseLocalizedDate(publishedAtText),
        publishedAtText: this.toNullable(publishedAtText),
      });
    }

    return this.deduplicate(articles);
  }

  parseNaverNewsList(html: string): ScrapedNewsArticle[] {
    const nextDataMatch = html.match(NEXT_DATA_REGEX);

    if (!nextDataMatch) {
      return [];
    }

    const nextData = JSON.parse(nextDataMatch[1]) as NaverNextData;
    const items = nextData.props?.initialState?.news?.list ?? [];

    return this.deduplicate(
      items
        .map((item) => this.toNaverNewsArticle(item))
        .filter((item): item is ScrapedNewsArticle => item !== null),
    );
  }

  private toNaverNewsArticle(item: NaverNewsItem): ScrapedNewsArticle | null {
    const articleUrl = item.pcLinkUrl ?? item.mobileLinkUrl ?? item.linkUrl;
    const title = this.toNullable(this.normalizeText(item.title));

    if (!articleUrl || !title) {
      return null;
    }

    return {
      externalSource: NEWS_SOURCES.NAVER_ESPORTS,
      externalId: this.extractUrlKey(articleUrl),
      title,
      summary: this.toNullable(this.normalizeText(item.subContent ?? '')),
      thumbnailUrl: this.toNullable(item.thumbnail ?? ''),
      articleUrl,
      publisher: this.toNullable(item.officeName ?? ''),
      publishedAt: this.toDateFromTimestamp(item.createdAt ?? item.updatedAt),
      publishedAtText: null,
    };
  }

  private parseLocalizedDate(input: string): Date | null {
    const trimmed = input.trim();

    if (!trimmed) {
      return null;
    }

    const koreanMatch = trimmed.match(
      /(?<year>\d{4})\s*년\s*(?<month>\d{1,2})\s*월\s*(?<day>\d{1,2})\s*일/,
    );

    if (
      koreanMatch?.groups?.year &&
      koreanMatch.groups.month &&
      koreanMatch.groups.day
    ) {
      return this.toUtcDate(
        Number(koreanMatch.groups.year),
        Number(koreanMatch.groups.month),
        Number(koreanMatch.groups.day),
      );
    }

    const normalized = trimmed
      .normalize('NFD')
      .replace(/\p{Diacritic}/gu, '')
      .replace(/[.,]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim()
      .toLowerCase();

    const tokens = normalized.split(' ').filter(Boolean).filter((token) => {
      return token !== 'de';
    });
    const yearToken = tokens.find((token) => /^\d{4}$/.test(token));
    const dayToken = tokens.find((token) => /^\d{1,2}$/.test(token));
    const monthToken = tokens.find((token) => MONTH_INDEX_BY_TOKEN.has(token));

    if (!yearToken || !dayToken || !monthToken) {
      return null;
    }

    return this.toUtcDate(
      Number(yearToken),
      MONTH_INDEX_BY_TOKEN.get(monthToken) ?? 0,
      Number(dayToken),
    );
  }

  private toUtcDate(year: number, month: number, day: number): Date | null {
    if (!year || !month || !day) {
      return null;
    }

    const parsed = new Date(Date.UTC(year, month - 1, day, 0, 0, 0));

    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  private toDateFromTimestamp(timestamp?: number): Date | null {
    if (!timestamp) {
      return null;
    }

    const parsed = new Date(timestamp);

    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  private extractUrlKey(url: string): string {
    try {
      const parsed = new URL(url, 'https://game.naver.com');
      const oid = parsed.searchParams.get('oid');
      const aid = parsed.searchParams.get('aid');

      if (oid && aid) {
        return `${oid}:${aid}`;
      }

      return `${parsed.pathname}${parsed.search}`;
    } catch {
      return url;
    }
  }

  private normalizeText(raw: string | undefined): string {
    return this.decodeHtml((raw ?? '').replace(/<[^>]+>/g, ' '))
      .replace(/\s+/g, ' ')
      .trim();
  }

  private decodeHtml(raw: string): string {
    return raw
      .replace(/&amp;/g, '&')
      .replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'")
      .replace(/&apos;/g, "'")
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&#(\d+);/g, (_, code: string) =>
        String.fromCodePoint(Number(code)),
      )
      .replace(/&#x([0-9a-f]+);/gi, (_, code: string) =>
        String.fromCodePoint(parseInt(code, 16)),
      );
  }

  private toNullable(value: string): string | null {
    return value.length > 0 ? value : null;
  }

  private deduplicate(
    articles: ScrapedNewsArticle[],
  ): ScrapedNewsArticle[] {
    return [
      ...new Map(
        articles.map((article) => [
          `${article.externalSource}:${article.externalId}`,
          article,
        ]),
      ).values(),
    ];
  }
}
