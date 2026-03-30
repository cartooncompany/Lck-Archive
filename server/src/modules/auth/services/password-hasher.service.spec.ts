import { PasswordHasherService } from './password-hasher.service';

describe('PasswordHasherService', () => {
  let service: PasswordHasherService;

  beforeEach(() => {
    service = new PasswordHasherService();
  });

  it('hashes and verifies a value', async () => {
    const hashedValue = await service.hash('securePassword123!');

    expect(hashedValue).not.toBe('securePassword123!');
    await expect(
      service.verify('securePassword123!', hashedValue),
    ).resolves.toBe(true);
    await expect(service.verify('wrong-password', hashedValue)).resolves.toBe(
      false,
    );
  });
});
