import { NewsParser } from './news.parser';
import { NEWS_SOURCES } from '../types/news-source.types';

describe('NewsParser', () => {
  const parser = new NewsParser();

  it('parses Naver esports latest news from NEXT_DATA', () => {
    const html = `<script id="__NEXT_DATA__" type="application/json">${JSON.stringify(
      {
        props: {
          initialState: {
            news: {
              list: [
                {
                  title: 'LCK 정규 시즌 4월 1일 개막',
                  subContent: '정규 시즌 개막 기사 요약',
                  thumbnail: 'https://example.com/naver.jpg',
                  pcLinkUrl:
                    'https://m.sports.naver.com/esports/article/382/0001265180',
                  officeName: '스포츠동아',
                  createdAt: Date.UTC(2026, 2, 30, 9, 47, 50),
                },
              ],
            },
          },
        },
      },
    )}</script>`;

    const [article] = parser.parseNaverNewsList(html);

    expect(article).toEqual({
      externalSource: NEWS_SOURCES.NAVER_ESPORTS,
      externalId: '/esports/article/382/0001265180',
      title: 'LCK 정규 시즌 4월 1일 개막',
      summary: '정규 시즌 개막 기사 요약',
      thumbnailUrl: 'https://example.com/naver.jpg',
      articleUrl: 'https://m.sports.naver.com/esports/article/382/0001265180',
      publisher: '스포츠동아',
      publishedAt: new Date('2026-03-30T09:47:50.000Z'),
      publishedAtText: null,
    });
  });

  it('parses LoL Esports article cards and localized dates', () => {
    const html = `
      <div hidden id="S:1">
        <a class="group pos_relative ov_hidden d_flex flex-d_column gap_15" href="/article/example-article/blt1234567890">
          <div class="ov_hidden pos_relative w_100%">
            <img alt="" loading="lazy" srcSet="https://example.com/lolesports-small.jpg 1x" src="https://example.com/lolesports.jpg?foo=1&amp;bar=2"/>
          </div>
          <div class="c_text.secondary textStyle_label/lg">11. Juni 2024</div>
          <div class="textStyle_headline/sm">리그 오브 레전드 이스포츠: 더 밝은 미래의 기반 마련</div>
          <div class="c_text.secondary textStyle_body/lg">2025년과 함께 리그 오브 레전드 이스포츠에 찾아올 신나는 변화를 말씀드립니다.</div>
          <div class="c_accent.primary textStyle_label/md tt_uppercase">더 알아보기</div>
        </a>
      </div>
    `;

    const [article] = parser.parseLolesportsNewsList(html);

    expect(article).toEqual({
      externalSource: NEWS_SOURCES.LOLESPORTS,
      externalId: '/article/example-article/blt1234567890',
      title: '리그 오브 레전드 이스포츠: 더 밝은 미래의 기반 마련',
      summary:
        '2025년과 함께 리그 오브 레전드 이스포츠에 찾아올 신나는 변화를 말씀드립니다.',
      thumbnailUrl: 'https://example.com/lolesports.jpg?foo=1&bar=2',
      articleUrl: 'https://lolesports.com/article/example-article/blt1234567890',
      publisher: 'LoL Esports',
      publishedAt: new Date('2024-06-11T00:00:00.000Z'),
      publishedAtText: '11. Juni 2024',
    });
  });
});
