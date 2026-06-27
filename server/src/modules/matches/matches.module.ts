import { Module } from '@nestjs/common';
import { MatchMapper } from './matches.mapper';
import { MatchesController } from './matches.controller';
import { MatchesRepository } from './matches.repository';
import { MatchesService } from './matches.service';

@Module({
  imports: [],
  controllers: [MatchesController],
  providers: [MatchesService, MatchesRepository, MatchMapper],
  exports: [MatchesRepository, MatchesService, MatchMapper],
})
export class MatchesModule {}
