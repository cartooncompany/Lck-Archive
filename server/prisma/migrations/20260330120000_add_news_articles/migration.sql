-- CreateEnum
CREATE TYPE "NewsSource" AS ENUM ('LOLESPORTS', 'NAVER_ESPORTS');

-- CreateTable
CREATE TABLE "NewsArticle" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "summary" TEXT,
    "thumbnailUrl" TEXT,
    "articleUrl" TEXT NOT NULL,
    "publisher" TEXT,
    "externalSource" "NewsSource" NOT NULL,
    "externalId" TEXT NOT NULL,
    "publishedAt" TIMESTAMP(3),
    "publishedAtText" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "NewsArticle_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "NewsArticle_publishedAt_idx" ON "NewsArticle"("publishedAt");

-- CreateIndex
CREATE INDEX "NewsArticle_externalSource_publishedAt_idx" ON "NewsArticle"("externalSource", "publishedAt");

-- CreateIndex
CREATE UNIQUE INDEX "NewsArticle_externalSource_externalId_key" ON "NewsArticle"("externalSource", "externalId");
