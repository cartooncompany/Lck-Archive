import { Module } from '@nestjs/common';
import { AiModule } from '../ai/ai.module';
import { PlayersController } from './players.controller';
import { PlayersRepository } from './players.repository';
import { PlayersService } from './players.service';

@Module({
  imports: [AiModule],
  controllers: [PlayersController],
  providers: [PlayersService, PlayersRepository],
})
export class PlayersModule {}

