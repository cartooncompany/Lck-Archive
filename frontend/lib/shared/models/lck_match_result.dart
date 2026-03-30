class LckMatchResult {
  const LckMatchResult({
    required this.opponent,
    required this.playedAt,
    required this.outcome,
    required this.score,
    required this.note,
  });

  final String opponent;
  final DateTime playedAt;
  final String outcome;
  final String score;
  final String note;
}
