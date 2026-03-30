-- CreateEnum
CREATE TYPE "PlayerPosition" AS ENUM ('TOP', 'JUNGLE', 'MID', 'ADC', 'SUPPORT', 'COACH', 'SUBSTITUTE', 'FLEX');

-- CreateEnum
CREATE TYPE "MatchStatus" AS ENUM ('SCHEDULED', 'COMPLETED', 'CANCELED');

-- CreateTable
CREATE TABLE "Team" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "shortName" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "logoUrl" TEXT,
    "rank" INTEGER,
    "wins" INTEGER NOT NULL DEFAULT 0,
    "losses" INTEGER NOT NULL DEFAULT 0,
    "setWins" INTEGER NOT NULL DEFAULT 0,
    "setLosses" INTEGER NOT NULL DEFAULT 0,
    "setDifferential" INTEGER NOT NULL DEFAULT 0,
    "externalSource" TEXT NOT NULL DEFAULT 'LCK',
    "externalId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Team_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Player" (
    "id" TEXT NOT NULL,
    "teamId" TEXT,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "position" "PlayerPosition" NOT NULL,
    "profileImageUrl" TEXT,
    "realName" TEXT,
    "nationality" TEXT,
    "birthDate" TIMESTAMP(3),
    "recentMatchCount" INTEGER NOT NULL DEFAULT 0,
    "externalSource" TEXT NOT NULL DEFAULT 'LCK',
    "externalId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Player_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Match" (
    "id" TEXT NOT NULL,
    "externalSource" TEXT NOT NULL DEFAULT 'LCK',
    "externalId" TEXT NOT NULL,
    "scheduledAt" TIMESTAMP(3) NOT NULL,
    "seasonYear" INTEGER NOT NULL,
    "split" TEXT NOT NULL,
    "stage" TEXT NOT NULL,
    "matchNumber" TEXT,
    "homeTeamId" TEXT NOT NULL,
    "awayTeamId" TEXT NOT NULL,
    "homeScore" INTEGER NOT NULL DEFAULT 0,
    "awayScore" INTEGER NOT NULL DEFAULT 0,
    "winnerTeamId" TEXT,
    "status" "MatchStatus" NOT NULL DEFAULT 'SCHEDULED',
    "vodUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Match_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MatchPlayerParticipation" (
    "id" TEXT NOT NULL,
    "matchId" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "teamId" TEXT NOT NULL,
    "role" "PlayerPosition",
    "isStarter" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MatchPlayerParticipation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SyncJobLog" (
    "id" TEXT NOT NULL,
    "jobName" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "message" TEXT,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" TIMESTAMP(3),
    "recordsCount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SyncJobLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Team_shortName_key" ON "Team"("shortName");

-- CreateIndex
CREATE UNIQUE INDEX "Team_slug_key" ON "Team"("slug");

-- CreateIndex
CREATE INDEX "Team_rank_idx" ON "Team"("rank");

-- CreateIndex
CREATE UNIQUE INDEX "Team_externalSource_externalId_key" ON "Team"("externalSource", "externalId");

-- CreateIndex
CREATE UNIQUE INDEX "Player_slug_key" ON "Player"("slug");

-- CreateIndex
CREATE INDEX "Player_teamId_idx" ON "Player"("teamId");

-- CreateIndex
CREATE INDEX "Player_position_idx" ON "Player"("position");

-- CreateIndex
CREATE UNIQUE INDEX "Player_externalSource_externalId_key" ON "Player"("externalSource", "externalId");

-- CreateIndex
CREATE INDEX "Match_scheduledAt_idx" ON "Match"("scheduledAt");

-- CreateIndex
CREATE INDEX "Match_seasonYear_split_stage_idx" ON "Match"("seasonYear", "split", "stage");

-- CreateIndex
CREATE INDEX "Match_homeTeamId_scheduledAt_idx" ON "Match"("homeTeamId", "scheduledAt");

-- CreateIndex
CREATE INDEX "Match_awayTeamId_scheduledAt_idx" ON "Match"("awayTeamId", "scheduledAt");

-- CreateIndex
CREATE UNIQUE INDEX "Match_externalSource_externalId_key" ON "Match"("externalSource", "externalId");

-- CreateIndex
CREATE INDEX "MatchPlayerParticipation_playerId_matchId_idx" ON "MatchPlayerParticipation"("playerId", "matchId");

-- CreateIndex
CREATE INDEX "MatchPlayerParticipation_teamId_matchId_idx" ON "MatchPlayerParticipation"("teamId", "matchId");

-- CreateIndex
CREATE UNIQUE INDEX "MatchPlayerParticipation_matchId_playerId_key" ON "MatchPlayerParticipation"("matchId", "playerId");

-- CreateIndex
CREATE INDEX "SyncJobLog_jobName_startedAt_idx" ON "SyncJobLog"("jobName", "startedAt");

-- AddForeignKey
ALTER TABLE "Player" ADD CONSTRAINT "Player_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Match" ADD CONSTRAINT "Match_homeTeamId_fkey" FOREIGN KEY ("homeTeamId") REFERENCES "Team"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Match" ADD CONSTRAINT "Match_awayTeamId_fkey" FOREIGN KEY ("awayTeamId") REFERENCES "Team"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Match" ADD CONSTRAINT "Match_winnerTeamId_fkey" FOREIGN KEY ("winnerTeamId") REFERENCES "Team"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchPlayerParticipation" ADD CONSTRAINT "MatchPlayerParticipation_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchPlayerParticipation" ADD CONSTRAINT "MatchPlayerParticipation_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchPlayerParticipation" ADD CONSTRAINT "MatchPlayerParticipation_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;
