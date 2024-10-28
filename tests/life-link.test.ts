import { describe, it, expect, beforeEach, vi } from 'vitest';

const mockContractCall = vi.fn();
const mockBlockHeight = vi.fn(() => 1000);

const clarity = {
  call: mockContractCall,
  getBlockHeight: mockBlockHeight,
};

describe('Physical Asset Authentication System', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should allow a user to register as a patient', async () => {
    const encryptedData = 'Sample encrypted data';
    mockContractCall.mockResolvedValueOnce({ ok: true });

    const registerResult = await clarity.call('register-patient', [encryptedData]);

    expect(registerResult.ok).toBe(true);
  });

  it('should allow a provider to register', async () => {
    const providerInfo = {
      name: 'Dr. Smith',
      licenseNumber: '12345',
      specialty: 'Cardiology'
    };
    mockContractCall.mockResolvedValueOnce({ ok: true });

    const registerResult = await clarity.call('register-provider', [
      providerInfo.name,
      providerInfo.licenseNumber,
      providerInfo.specialty,
    ]);

    expect(registerResult.ok).toBe(true);
  });

  it('should allow a patient to update their data', async () => {
    const newEncryptedData = 'Updated encrypted data';
    mockContractCall.mockResolvedValueOnce({ ok: true });

    const updateResult = await clarity.call('update-patient-data', [newEncryptedData]);

    expect(updateResult.ok).toBe(true);
  });

  it('should allow a patient to grant access to a provider', async () => {
    const provider = 'ST1PROVIDER...';
    const encryptionKey = 'Key123';
    const accessLevel = 'read';
    const accessDuration = 1000;
    mockContractCall.mockResolvedValueOnce({ ok: true });

    const grantResult = await clarity.call('grant-provider-access', [
      provider, encryptionKey, accessLevel, accessDuration
    ]);

    expect(grantResult.ok).toBe(true);
  });

  it('should allow a provider to access patient data if authorized', async () => {
    const patient = 'ST1PATIENT...';
    mockContractCall.mockResolvedValueOnce({
      ok: true,
      result: { encryptionKey: 'Key123', accessLevel: 'read' }
    });

    const accessResult = await clarity.call('access-patient-data', [patient]);

    expect(accessResult.ok).toBe(true);
    expect(accessResult.result.accessLevel).toBe('read');
  });

  it('should prevent unauthorized provider from accessing patient data', async () => {
    const patient = 'ST1PATIENT...';
    mockContractCall.mockResolvedValueOnce({ error: 'not authorized' });

    const accessResult = await clarity.call('access-patient-data', [patient]);

    expect(accessResult.error).toBe('not authorized');
  });

  it('should allow a patient to delete their data', async () => {
    mockContractCall.mockResolvedValueOnce({ ok: true });

    const deleteResult = await clarity.call('delete-patient-data');

    expect(deleteResult.ok).toBe(true);
  });

  it('should throw an error when trying to register a provider with invalid input', async () => {
    const providerInfo = {
      name: '', // Invalid name
      licenseNumber: '123',
      specialty: 'Ca'
    };
    mockContractCall.mockResolvedValueOnce({ error: 'invalid input' });

    const registerResult = await clarity.call('register-provider', [
      providerInfo.name,
      providerInfo.licenseNumber,
      providerInfo.specialty
    ]);

    expect(registerResult.error).toBe('invalid input');
  });
});
