import { NewsSource } from '@prisma/client';
import { BaseEntity } from '../../../common/entities/base.entity';

export class NewsArticleEntity extends BaseEntity {
  title: string;
  summary: string | null;
  thumbnailUrl: string | null;
  articleUrl: string;
  publisher: string | null;
  externalSource: NewsSource;
  externalId: string;
  publishedAt: Date | null;
  publishedAtText: string | null;
}
