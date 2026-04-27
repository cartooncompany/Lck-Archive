import { NotFoundException } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersRepository } from './users.repository';

describe('UsersService', () => {
  let service: UsersService;
  let repository: jest.Mocked<UsersRepository>;

  beforeEach(() => {
    repository = {
      create: jest.fn(),
      findById: jest.fn(),
      findByEmail: jest.fn(),
      favoriteTeamExists: jest.fn(),
      updateRefreshTokenHash: jest.fn(),
      deleteAccountData: jest.fn(),
    } as unknown as jest.Mocked<UsersRepository>;

    service = new UsersService(repository);
  });

  it('returns my profile when the user exists', async () => {
    repository.findById.mockResolvedValue({
      id: 'user-1',
      nickname: 'faker',
      email: 'faker@example.com',
      passwordHash: 'hashed-password',
      favoriteTeamId: 'team-1',
      refreshTokenHash: 'hashed-refresh-token',
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await expect(service.getMyProfile('user-1')).resolves.toEqual({
      nickname: 'faker',
      email: 'faker@example.com',
    });
  });

  it('throws when the profile user does not exist', async () => {
    repository.findById.mockResolvedValue(null);

    await expect(service.getMyProfile('missing-user')).rejects.toThrow(
      NotFoundException,
    );
  });

  it('deletes the account when the user exists', async () => {
    repository.deleteAccountData.mockResolvedValue(true);

    await expect(service.deleteMyAccount('user-1')).resolves.toBeUndefined();
    expect(repository.deleteAccountData.mock.calls).toEqual([['user-1']]);
  });

  it('throws when trying to delete a missing user', async () => {
    repository.deleteAccountData.mockResolvedValue(false);

    await expect(service.deleteMyAccount('missing-user')).rejects.toThrow(
      NotFoundException,
    );
  });
});
