import { Injectable } from '@nestjs/common';
import { randomBytes, scrypt, timingSafeEqual } from 'crypto';
import { promisify } from 'util';

const scryptAsync = promisify(scrypt);
const SALT_LENGTH = 16;
const KEY_LENGTH = 64;

@Injectable()
export class PasswordHasherService {
  async hash(value: string): Promise<string> {
    const salt = randomBytes(SALT_LENGTH).toString('hex');
    const derivedKey = (await scryptAsync(value, salt, KEY_LENGTH)) as Buffer;

    return `${salt}:${derivedKey.toString('hex')}`;
  }

  async verify(value: string, hashedValue: string): Promise<boolean> {
    const [salt, storedHash] = hashedValue.split(':');

    if (!salt || !storedHash) {
      return false;
    }

    const storedHashBuffer = Buffer.from(storedHash, 'hex');

    if (storedHashBuffer.length === 0) {
      return false;
    }

    const derivedKey = (await scryptAsync(
      value,
      salt,
      storedHashBuffer.length,
    )) as Buffer;

    return timingSafeEqual(storedHashBuffer, derivedKey);
  }
}
