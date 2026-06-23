import { Module } from '@nestjs/common';
import { MatchesController } from './matches.controller';
import { MatchesRepository } from './matches.repository';
import { MatchesService } from './matches.service';
import { AiModule } from '../ai/ai.module';

@Module({
  imports: [AiModule],
  controllers: [MatchesController],
  providers: [MatchesService, MatchesRepository],
  exports: [MatchesRepository, MatchesService],
})
export class MatchesModule {}
