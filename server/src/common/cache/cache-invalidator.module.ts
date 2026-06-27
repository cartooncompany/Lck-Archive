import { Global, Module } from '@nestjs/common';
import { CacheInvalidatorService } from './cache-invalidator.service';

@Global()
@Module({
  providers: [CacheInvalidatorService],
  exports: [CacheInvalidatorService],
})
export class CacheInvalidatorModule {}
