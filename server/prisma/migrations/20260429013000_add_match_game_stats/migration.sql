-- CreateTable
CREATE TABLE "MatchGame" (
    "id" TEXT NOT NULL,
    "matchId" TEXT NOT NULL,
    "externalId" TEXT,
    "sequenceNumber" INTEGER NOT NULL,
    "startedAt" TIMESTAMP(3),
    "duration" TEXT,
    "mapId" TEXT,
    "mapName" TEXT,
    "winnerTeamId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MatchGame_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MatchGamePlayerStat" (
    "id" TEXT NOT NULL,
    "matchGameId" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "teamId" TEXT NOT NULL,
    "role" "PlayerPosition",
    "participationStatus" TEXT,
    "characterId" TEXT,
    "characterName" TEXT,
    "kills" INTEGER,
    "deaths" INTEGER,
    "assists" INTEGER,
    "totalMoneyEarned" INTEGER,
    "damageDealt" INTEGER,
    "damageTaken" INTEGER,
    "visionScore" DOUBLE PRECISION,
    "kdaRatio" DOUBLE PRECISION,
    "killParticipation" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MatchGamePlayerStat_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MatchDraftAction" (
    "id" TEXT NOT NULL,
    "matchGameId" TEXT NOT NULL,
    "externalId" TEXT,
    "type" TEXT NOT NULL,
    "sequenceNumber" TEXT NOT NULL,
    "sequenceOrder" INTEGER,
    "drafterId" TEXT,
    "drafterType" TEXT,
    "draftableId" TEXT,
    "draftableType" TEXT,
    "draftableName" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MatchDraftAction_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "MatchGame_matchId_idx" ON "MatchGame"("matchId");

-- CreateIndex
CREATE INDEX "MatchGame_winnerTeamId_idx" ON "MatchGame"("winnerTeamId");

-- CreateIndex
CREATE UNIQUE INDEX "MatchGame_matchId_sequenceNumber_key" ON "MatchGame"("matchId", "sequenceNumber");

-- CreateIndex
CREATE INDEX "MatchGamePlayerStat_playerId_matchGameId_idx" ON "MatchGamePlayerStat"("playerId", "matchGameId");

-- CreateIndex
CREATE INDEX "MatchGamePlayerStat_teamId_matchGameId_idx" ON "MatchGamePlayerStat"("teamId", "matchGameId");

-- CreateIndex
CREATE UNIQUE INDEX "MatchGamePlayerStat_matchGameId_playerId_key" ON "MatchGamePlayerStat"("matchGameId", "playerId");

-- CreateIndex
CREATE INDEX "MatchDraftAction_matchGameId_idx" ON "MatchDraftAction"("matchGameId");

-- CreateIndex
CREATE INDEX "MatchDraftAction_matchGameId_sequenceNumber_idx" ON "MatchDraftAction"("matchGameId", "sequenceNumber");

-- AddForeignKey
ALTER TABLE "MatchGame" ADD CONSTRAINT "MatchGame_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchGame" ADD CONSTRAINT "MatchGame_winnerTeamId_fkey" FOREIGN KEY ("winnerTeamId") REFERENCES "Team"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchGamePlayerStat" ADD CONSTRAINT "MatchGamePlayerStat_matchGameId_fkey" FOREIGN KEY ("matchGameId") REFERENCES "MatchGame"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchGamePlayerStat" ADD CONSTRAINT "MatchGamePlayerStat_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchGamePlayerStat" ADD CONSTRAINT "MatchGamePlayerStat_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchDraftAction" ADD CONSTRAINT "MatchDraftAction_matchGameId_fkey" FOREIGN KEY ("matchGameId") REFERENCES "MatchGame"("id") ON DELETE CASCADE ON UPDATE CASCADE;
