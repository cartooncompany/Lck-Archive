-- Remove AI-related columns from Player and Match tables

ALTER TABLE "Player" DROP COLUMN IF EXISTS "aiSummary";

ALTER TABLE "Match" DROP COLUMN IF EXISTS "aiSummary";
ALTER TABLE "Match" DROP COLUMN IF EXISTS "aiWinnerTeamId";
ALTER TABLE "Match" DROP COLUMN IF EXISTS "aiPrediction";
