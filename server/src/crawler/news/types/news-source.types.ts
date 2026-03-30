import type { NewsSource } from '@prisma/client';

export const NEWS_SOURCES = {
  LOLESPORTS: 'LOLESPORTS',
  NAVER_ESPORTS: 'NAVER_ESPORTS',
} as const;

export interface ScrapedNewsArticle {
  externalSource: NewsSource;
  externalId: string;
  title: string;
  summary: string | null;
  thumbnailUrl: string | null;
  articleUrl: string;
  publisher: string | null;
  publishedAt: Date | null;
  publishedAtText: string | null;
}

export interface NaverNewsItem {
  title: string;
  subContent?: string;
  thumbnail?: string;
  linkUrl?: string;
  pcLinkUrl?: string;
  mobileLinkUrl?: string;
  officeName?: string;
  createdAt?: number;
  updatedAt?: number;
}

export interface NaverNextData {
  props?: {
    initialState?: {
      news?: {
        list?: NaverNewsItem[];
      };
    };
  };
}
