import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../shared/models/lck_match_result.dart';
import '../../shared/models/news_article.dart';
import '../../shared/models/player_profile.dart';
import '../../shared/models/team_summary.dart';

final class MockLckData {
  static final List<TeamSummary> teams = [
    TeamSummary(
      id: 't1',
      name: 'T1',
      initials: 'T1',
      rank: 1,
      seasonRecord: '14-3',
      setRecord: '+18',
      summary: '초반 주도권 장악과 한타 응집력이 가장 안정적인 팀.',
      recentForm: const ['W', 'W', 'W', 'L', 'W'],
      recentMatches: [
        LckMatchResult(
          opponent: 'Gen.G',
          playedAt: DateTime(2026, 3, 29),
          outcome: 'W',
          score: '2:1',
          note: '후반 오브젝트 교전에서 역전.',
        ),
        LckMatchResult(
          opponent: 'KT Rolster',
          playedAt: DateTime(2026, 3, 26),
          outcome: 'W',
          score: '2:0',
          note: '바텀 주도권으로 세트 연속 승리.',
        ),
        LckMatchResult(
          opponent: 'Hanwha Life Esports',
          playedAt: DateTime(2026, 3, 23),
          outcome: 'L',
          score: '1:2',
          note: '3세트 장기전 패배.',
        ),
      ],
      color: const Color(0xFFE74C3C),
    ),
    TeamSummary(
      id: 'geng',
      name: 'Gen.G',
      initials: 'GEN',
      rank: 2,
      seasonRecord: '13-4',
      setRecord: '+16',
      summary: '라인 관리와 스노우볼 연결 속도가 뛰어난 상위권 팀.',
      recentForm: const ['W', 'L', 'W', 'W', 'W'],
      recentMatches: [
        LckMatchResult(
          opponent: 'T1',
          playedAt: DateTime(2026, 3, 29),
          outcome: 'L',
          score: '1:2',
          note: '3세트 바론 교전 실패.',
        ),
        LckMatchResult(
          opponent: 'Dplus KIA',
          playedAt: DateTime(2026, 3, 27),
          outcome: 'W',
          score: '2:0',
          note: '정글-미드 연계가 강점.',
        ),
        LckMatchResult(
          opponent: 'DRX',
          playedAt: DateTime(2026, 3, 24),
          outcome: 'W',
          score: '2:0',
          note: '세트 평균 31분 마감.',
        ),
      ],
      color: const Color(0xFFFFC107),
    ),
    TeamSummary(
      id: 'hle',
      name: 'Hanwha Life Esports',
      initials: 'HLE',
      rank: 3,
      seasonRecord: '11-6',
      setRecord: '+9',
      summary: '한타 집중력과 캐리 라인 파괴력이 강한 팀.',
      recentForm: const ['W', 'W', 'L', 'W', 'L'],
      recentMatches: [
        LckMatchResult(
          opponent: 'DRX',
          playedAt: DateTime(2026, 3, 28),
          outcome: 'W',
          score: '2:0',
          note: '상체 교전 설계 우위.',
        ),
        LckMatchResult(
          opponent: 'T1',
          playedAt: DateTime(2026, 3, 23),
          outcome: 'W',
          score: '2:1',
          note: '결정적 바론 스틸 성공.',
        ),
        LckMatchResult(
          opponent: 'Gen.G',
          playedAt: DateTime(2026, 3, 20),
          outcome: 'L',
          score: '0:2',
          note: '초중반 라인전 열세.',
        ),
      ],
      color: const Color(0xFFFF7A00),
    ),
    TeamSummary(
      id: 'dk',
      name: 'Dplus KIA',
      initials: 'DK',
      rank: 4,
      seasonRecord: '10-7',
      setRecord: '+5',
      summary: '공격적인 초반 설계가 장점인 업템포 팀.',
      recentForm: const ['L', 'W', 'W', 'L', 'W'],
      recentMatches: [
        LckMatchResult(
          opponent: 'KT Rolster',
          playedAt: DateTime(2026, 3, 29),
          outcome: 'W',
          score: '2:1',
          note: '정글 성장 차이로 후반 우세.',
        ),
        LckMatchResult(
          opponent: 'Gen.G',
          playedAt: DateTime(2026, 3, 27),
          outcome: 'L',
          score: '0:2',
          note: '미드 시야 장악 열세.',
        ),
        LckMatchResult(
          opponent: 'NS RedForce',
          playedAt: DateTime(2026, 3, 22),
          outcome: 'W',
          score: '2:0',
          note: '첫 용 타이밍부터 흐름 주도.',
        ),
      ],
      color: const Color(0xFF5A7CFF),
    ),
    TeamSummary(
      id: 'kt',
      name: 'KT Rolster',
      initials: 'KT',
      rank: 5,
      seasonRecord: '8-9',
      setRecord: '-2',
      summary: '중반 운영 변수가 큰 팀, 상위권 상대전이 관건.',
      recentForm: const ['L', 'L', 'W', 'W', 'L'],
      recentMatches: [
        LckMatchResult(
          opponent: 'Dplus KIA',
          playedAt: DateTime(2026, 3, 29),
          outcome: 'L',
          score: '1:2',
          note: '3세트 후반 오더 흔들림.',
        ),
        LckMatchResult(
          opponent: 'T1',
          playedAt: DateTime(2026, 3, 26),
          outcome: 'L',
          score: '0:2',
          note: '라인 스왑 대응 부족.',
        ),
        LckMatchResult(
          opponent: 'BRO',
          playedAt: DateTime(2026, 3, 21),
          outcome: 'W',
          score: '2:0',
          note: '바텀 중심 교전 성공.',
        ),
      ],
      color: const Color(0xFF111111),
    ),
    TeamSummary(
      id: 'drx',
      name: 'DRX',
      initials: 'DRX',
      rank: 6,
      seasonRecord: '7-10',
      setRecord: '-5',
      summary: '기복은 있지만 신인 선수들의 성장세가 두드러지는 팀.',
      recentForm: const ['L', 'W', 'L', 'L', 'W'],
      recentMatches: [
        LckMatchResult(
          opponent: 'Hanwha Life Esports',
          playedAt: DateTime(2026, 3, 28),
          outcome: 'L',
          score: '0:2',
          note: '초반 전령 구간이 아쉬움.',
        ),
        LckMatchResult(
          opponent: 'BRO',
          playedAt: DateTime(2026, 3, 25),
          outcome: 'W',
          score: '2:1',
          note: '탑 캐리 픽 적중.',
        ),
        LckMatchResult(
          opponent: 'Gen.G',
          playedAt: DateTime(2026, 3, 24),
          outcome: 'L',
          score: '0:2',
          note: '후반 집중력 저하.',
        ),
      ],
      color: const Color(0xFF1E88E5),
    ),
  ];

  static final List<PlayerProfile> players = [
    PlayerProfile(
      id: 'faker',
      name: 'Faker',
      teamId: 't1',
      teamName: 'T1',
      position: 'MID',
      seasonMatches: 17,
      headline: '중후반 한타 설계와 오브젝트 전투 판단이 뛰어남.',
      keyStats: const {'KDA': '4.7', '킬 관여': '71%', '평균 킬': '4.2'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 29),
          opponent: 'Gen.G',
          result: '승',
          performance: '아지르 6/1/8, 후반 한타 MVP',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 26),
          opponent: 'KT Rolster',
          result: '승',
          performance: '탈리야 4/0/11, 로밍 주도',
        ),
      ],
      teamColor: const Color(0xFFE74C3C),
    ),
    PlayerProfile(
      id: 'gumayusi',
      name: 'Gumayusi',
      teamId: 't1',
      teamName: 'T1',
      position: 'ADC',
      seasonMatches: 17,
      headline: '안정적인 라인전과 후반 딜링 기대치가 높은 원딜.',
      keyStats: const {'KDA': '5.1', 'DPM': '612', '퍼스트 킬 관여': '48%'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 29),
          opponent: 'Gen.G',
          result: '승',
          performance: '제리 8/2/5, 후반 포지셔닝 우위',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 23),
          opponent: 'Hanwha Life Esports',
          result: '패',
          performance: '카이사 3/3/4, 중반 교전 손실',
        ),
      ],
      teamColor: const Color(0xFFE74C3C),
    ),
    PlayerProfile(
      id: 'keria',
      name: 'Keria',
      teamId: 't1',
      teamName: 'T1',
      position: 'SUP',
      seasonMatches: 17,
      headline: '시야 장악과 로밍 타이밍 설계가 강점인 서포터.',
      keyStats: const {'KDA': '4.9', '와드 설치': '1.78', '어시스트': '10.6'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 29),
          opponent: 'Gen.G',
          result: '승',
          performance: '레나타 1/2/14, 한타 구도 설계',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 26),
          opponent: 'KT Rolster',
          result: '승',
          performance: '라칸 0/1/13, 이니시에이팅 성공',
        ),
      ],
      teamColor: const Color(0xFFE74C3C),
    ),
    PlayerProfile(
      id: 'chovy',
      name: 'Chovy',
      teamId: 'geng',
      teamName: 'Gen.G',
      position: 'MID',
      seasonMatches: 17,
      headline: '라인전 우세를 바탕으로 오브젝트 설계를 이끄는 미드.',
      keyStats: const {'KDA': '5.4', 'CS@15': '+11.2', '킬 관여': '69%'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 29),
          opponent: 'T1',
          result: '패',
          performance: '오리아나 4/2/4, 3세트 교전 패배',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 27),
          opponent: 'Dplus KIA',
          result: '승',
          performance: '트위스티드 페이트 5/1/9, 글로벌 운영',
        ),
      ],
      teamColor: const Color(0xFFFFC107),
    ),
    PlayerProfile(
      id: 'ruler',
      name: 'Ruler',
      teamId: 'geng',
      teamName: 'Gen.G',
      position: 'ADC',
      seasonMatches: 17,
      headline: '후반 캐리력이 높은 대표적인 하이퍼 캐리 원딜.',
      keyStats: const {'KDA': '6.0', 'DPM': '640', '평균 데스': '1.7'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 27),
          opponent: 'Dplus KIA',
          result: '승',
          performance: '시비르 7/0/6, 완벽한 후반 운영',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 24),
          opponent: 'DRX',
          result: '승',
          performance: '애쉬 4/1/10, 전령 교전 핵심',
        ),
      ],
      teamColor: const Color(0xFFFFC107),
    ),
    PlayerProfile(
      id: 'canyon',
      name: 'Canyon',
      teamId: 'geng',
      teamName: 'Gen.G',
      position: 'JGL',
      seasonMatches: 17,
      headline: '템포 조율과 카운터 정글 설계가 정확한 정글러.',
      keyStats: const {'KDA': '4.3', '퍼스트 블러드 관여': '61%', '오브젝트 점유': '58%'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 29),
          opponent: 'T1',
          result: '패',
          performance: '바이 2/3/8, 바론 교전 아쉬움',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 27),
          opponent: 'Dplus KIA',
          result: '승',
          performance: '세주아니 1/1/12, 초반 갱킹 성공',
        ),
      ],
      teamColor: const Color(0xFFFFC107),
    ),
    PlayerProfile(
      id: 'zeka',
      name: 'Zeka',
      teamId: 'hle',
      teamName: 'Hanwha Life Esports',
      position: 'MID',
      seasonMatches: 17,
      headline: '교전 집중력이 높은 캐리형 미드.',
      keyStats: const {'KDA': '4.5', '킬': '78', '분당 데미지': '596'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 28),
          opponent: 'DRX',
          result: '승',
          performance: '사일러스 7/2/6, 진입 각도 우수',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 23),
          opponent: 'T1',
          result: '승',
          performance: '아칼리 5/1/5, 결승 교전 주도',
        ),
      ],
      teamColor: const Color(0xFFFF7A00),
    ),
    PlayerProfile(
      id: 'viper',
      name: 'Viper',
      teamId: 'hle',
      teamName: 'Hanwha Life Esports',
      position: 'ADC',
      seasonMatches: 17,
      headline: '라인 안정성과 후반 캐리력을 동시에 가진 원딜.',
      keyStats: const {'KDA': '5.2', 'DPM': '628', '킬 관여': '70%'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 28),
          opponent: 'DRX',
          result: '승',
          performance: '자야 6/1/9, 후반 딜링 우세',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 20),
          opponent: 'Gen.G',
          result: '패',
          performance: '이즈리얼 2/2/3, 라인전 무난',
        ),
      ],
      teamColor: const Color(0xFFFF7A00),
    ),
    PlayerProfile(
      id: 'delight',
      name: 'Delight',
      teamId: 'hle',
      teamName: 'Hanwha Life Esports',
      position: 'SUP',
      seasonMatches: 17,
      headline: '전투 개시와 교전 각도 설계에 강점을 가진 서포터.',
      keyStats: const {'KDA': '4.1', '어시스트': '10.1', '와드 설치': '1.82'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 28),
          opponent: 'DRX',
          result: '승',
          performance: '알리스타 0/2/15, 한타 진입 성공',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 23),
          opponent: 'T1',
          result: '승',
          performance: '노틸러스 1/3/12, 시야 장악',
        ),
      ],
      teamColor: const Color(0xFFFF7A00),
    ),
    PlayerProfile(
      id: 'showmaker',
      name: 'ShowMaker',
      teamId: 'dk',
      teamName: 'Dplus KIA',
      position: 'MID',
      seasonMatches: 17,
      headline: '변칙적인 픽과 운영 주도력이 강한 미드.',
      keyStats: const {'KDA': '4.0', '킬': '72', '킬 관여': '68%'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 29),
          opponent: 'KT Rolster',
          result: '승',
          performance: '르블랑 7/2/4, 사이드 압박 주도',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 27),
          opponent: 'Gen.G',
          result: '패',
          performance: '빅토르 2/3/2, 시야 열세',
        ),
      ],
      teamColor: const Color(0xFF5A7CFF),
    ),
    PlayerProfile(
      id: 'aiming',
      name: 'Aiming',
      teamId: 'dk',
      teamName: 'Dplus KIA',
      position: 'ADC',
      seasonMatches: 17,
      headline: '공격적인 라인전과 교전 마무리에 강한 원딜.',
      keyStats: const {'KDA': '4.8', 'DPM': '603', '퍼스트 킬 관여': '44%'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 29),
          opponent: 'KT Rolster',
          result: '승',
          performance: '바루스 5/1/8, 드래곤 교전 활약',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 22),
          opponent: 'NS RedForce',
          result: '승',
          performance: '루시안 8/0/5, 라인전 압도',
        ),
      ],
      teamColor: const Color(0xFF5A7CFF),
    ),
    PlayerProfile(
      id: 'bdd',
      name: 'Bdd',
      teamId: 'kt',
      teamName: 'KT Rolster',
      position: 'MID',
      seasonMatches: 17,
      headline: '미드 메이킹과 오더 안정감이 장점인 베테랑 미드.',
      keyStats: const {'KDA': '3.9', '킬 관여': '67%', '평균 데스': '2.3'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 29),
          opponent: 'Dplus KIA',
          result: '패',
          performance: '아리 3/2/4, 3세트 진입 실패',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 21),
          opponent: 'BRO',
          result: '승',
          performance: '탈론 6/1/7, 로밍 장악',
        ),
      ],
      teamColor: const Color(0xFFAAAAAA),
    ),
    PlayerProfile(
      id: 'deft',
      name: 'Deft',
      teamId: 'kt',
      teamName: 'KT Rolster',
      position: 'ADC',
      seasonMatches: 15,
      headline: '클러치 상황에서 집중력이 좋은 베테랑 원딜.',
      keyStats: const {'KDA': '4.2', 'DPM': '581', '킬': '63'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 29),
          opponent: 'Dplus KIA',
          result: '패',
          performance: '이즈리얼 4/2/3, 중반 화력 유지',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 26),
          opponent: 'T1',
          result: '패',
          performance: '애쉬 1/2/5, 시야 열세',
        ),
      ],
      teamColor: const Color(0xFFAAAAAA),
    ),
    PlayerProfile(
      id: 'rascal',
      name: 'Rascal',
      teamId: 'drx',
      teamName: 'DRX',
      position: 'TOP',
      seasonMatches: 17,
      headline: '사이드 운영과 라인전 견제가 강점인 탑.',
      keyStats: const {'KDA': '3.6', 'CS@15': '+5.8', '킬 관여': '62%'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 25),
          opponent: 'BRO',
          result: '승',
          performance: '크산테 3/1/10, 전선 유지',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 28),
          opponent: 'Hanwha Life Esports',
          result: '패',
          performance: '그웬 1/3/2, 라인전 분전',
        ),
      ],
      teamColor: const Color(0xFF1E88E5),
    ),
    PlayerProfile(
      id: 'teddy',
      name: 'Teddy',
      teamId: 'drx',
      teamName: 'DRX',
      position: 'ADC',
      seasonMatches: 16,
      headline: '안정적인 후반 포지셔닝이 장점인 원딜.',
      keyStats: const {'KDA': '4.4', 'DPM': '574', '평균 킬': '4.0'},
      recentAppearances: [
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 25),
          opponent: 'BRO',
          result: '승',
          performance: '카이사 7/1/6, 후반 딜링 캐리',
        ),
        PlayerMatchAppearance(
          playedAt: DateTime(2026, 3, 24),
          opponent: 'Gen.G',
          result: '패',
          performance: '제리 2/2/4, 화력 분전',
        ),
      ],
      teamColor: const Color(0xFF1E88E5),
    ),
  ];

  static final List<NewsArticle> news = [
    NewsArticle(
      id: 'news-1',
      title: 'T1, 주말 빅매치에서 Gen.G 제압하며 선두 수성',
      publishedAt: DateTime(2026, 3, 30),
      summary: '3세트 후반 바론 교전에서 승부를 뒤집으며 응원팀 관심도가 가장 높은 경기로 집계됐습니다.',
      tags: const ['T1', 'Gen.G', 'Faker'],
      sourceLabel: 'LCK Weekly',
      link: 'https://example.com/news/t1-geng',
    ),
    NewsArticle(
      id: 'news-2',
      title: 'Hanwha Life Esports, 연승 구간 진입하며 상위권 압박',
      publishedAt: DateTime(2026, 3, 29),
      summary: 'Zeka와 Viper 중심의 캐리력이 살아나며 플레이오프 경쟁 구도가 더 치열해졌습니다.',
      tags: const ['Hanwha Life Esports', 'Zeka', 'Viper'],
      sourceLabel: 'eSports Desk',
      link: 'https://example.com/news/hle-streak',
    ),
    NewsArticle(
      id: 'news-3',
      title: 'Dplus KIA, 정글-미드 템포 회복으로 중위권 싸움 우위',
      publishedAt: DateTime(2026, 3, 28),
      summary: 'ShowMaker 중심 운영이 다시 정리되면서 세트 득실 관리에도 긍정적인 흐름이 이어지고 있습니다.',
      tags: const ['Dplus KIA', 'ShowMaker'],
      sourceLabel: 'Match Review',
      link: 'https://example.com/news/dk-tempo',
    ),
    NewsArticle(
      id: 'news-4',
      title: 'KT Rolster, 상위권 상대전 보완이 남은 과제',
      publishedAt: DateTime(2026, 3, 27),
      summary: 'Bdd와 Deft의 안정감은 유지되지만, 중후반 판단 개선이 필요하다는 분석이 나왔습니다.',
      tags: const ['KT Rolster', 'Bdd', 'Deft'],
      sourceLabel: 'Power Ranking',
      link: 'https://example.com/news/kt-focus',
    ),
    NewsArticle(
      id: 'news-5',
      title: 'DRX, 신예 성장세로 후반 라운드 변수 팀 부상',
      publishedAt: DateTime(2026, 3, 26),
      summary: '신규 조합 적응도가 높아지며 중하위권 경쟁에서 반등 가능성을 보이고 있습니다.',
      tags: const ['DRX', 'Teddy', 'Rascal'],
      sourceLabel: 'Analyst Note',
      link: 'https://example.com/news/drx-rise',
    ),
  ];

  static TeamSummary get defaultFavoriteTeam => teams.first;

  static List<PlayerProfile> playersForTeam(String teamId) {
    return players.where((player) => player.teamId == teamId).toList();
  }

  static List<NewsArticle> newsForTeam(String teamId) {
    final team = teamById(teamId);
    return news
        .where((article) => article.tags.contains(team.name))
        .followedBy(news.where((article) => !article.tags.contains(team.name)))
        .toList();
  }

  static TeamSummary teamById(String teamId) {
    return teams.firstWhere((team) => team.id == teamId);
  }

  static TeamSummary? findTeamByTag(String tag) {
    for (final team in teams) {
      if (team.name == tag || team.initials == tag) {
        return team;
      }
    }
    return null;
  }

  static PlayerProfile? findPlayerByTag(String tag) {
    for (final player in players) {
      if (player.name == tag) {
        return player;
      }
    }
    return null;
  }

  static Color accentForOutcome(String outcome) {
    return outcome == 'W' || outcome == '승'
        ? AppColors.success
        : AppColors.danger;
  }
}
