import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:anticifi/features/settings/domain/entities/user_profile_entity.dart';
import 'package:anticifi/features/settings/domain/repositories/settings_repository.dart';
import 'package:anticifi/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:anticifi/features/settings/presentation/bloc/settings_state.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  final testProfile = UserProfileEntity(
    id: 'user-1',
    email: 'test@example.com',
    firstName: 'John',
    lastName: 'Doe',
    currency: 'USD',
    locale: 'en',
    notificationsEnabled: true,
    theme: 'system',
    createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
  );

  final updatedProfile = UserProfileEntity(
    id: 'user-1',
    email: 'test@example.com',
    firstName: 'Jane',
    lastName: 'Doe',
    currency: 'EUR',
    locale: 'en',
    notificationsEnabled: true,
    theme: 'dark',
    createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
  );

  group('SettingsCubit', () {
    test('initial state is SettingsInitial', () {
      final cubit = SettingsCubit(mockRepository);
      expect(cubit.state, const SettingsInitial());
      cubit.close();
    });

    group('loadProfile', () {
      blocTest<SettingsCubit, SettingsState>(
        'emits [Loading, Loaded] when succeeds',
        build: () {
          when(() => mockRepository.getProfile())
              .thenAnswer((_) async => testProfile);
          return SettingsCubit(mockRepository);
        },
        act: (cubit) => cubit.loadProfile(),
        expect: () => [
          const SettingsLoading(),
          SettingsLoaded(testProfile),
        ],
      );

      blocTest<SettingsCubit, SettingsState>(
        'emits [Loading, Error] when fails',
        build: () {
          when(() => mockRepository.getProfile())
              .thenThrow(Exception('Failed'));
          return SettingsCubit(mockRepository);
        },
        act: (cubit) => cubit.loadProfile(),
        expect: () => [
          const SettingsLoading(),
          isA<SettingsError>(),
        ],
      );
    });

    group('updateProfile', () {
      blocTest<SettingsCubit, SettingsState>(
        'emits [Updating, Updated] when succeeds from Loaded state',
        build: () {
          when(() => mockRepository.updateProfile(any()))
              .thenAnswer((_) async => updatedProfile);
          return SettingsCubit(mockRepository);
        },
        seed: () => SettingsLoaded(testProfile),
        act: (cubit) => cubit.updateProfile({
          'firstName': 'Jane',
          'currency': 'EUR',
        }),
        expect: () => [
          SettingsUpdating(testProfile),
          SettingsUpdated(updatedProfile),
        ],
      );

      blocTest<SettingsCubit, SettingsState>(
        'emits [Error] when update fails',
        build: () {
          when(() => mockRepository.updateProfile(any()))
              .thenThrow(Exception('Update failed'));
          return SettingsCubit(mockRepository);
        },
        seed: () => SettingsLoaded(testProfile),
        act: (cubit) => cubit.updateProfile({'firstName': 'Jane'}),
        expect: () => [
          SettingsUpdating(testProfile),
          isA<SettingsError>(),
        ],
      );
    });

    group('deleteAccount', () {
      blocTest<SettingsCubit, SettingsState>(
        'emits [AccountDeleted] when succeeds',
        build: () {
          when(() => mockRepository.deleteAccount())
              .thenAnswer((_) async {});
          return SettingsCubit(mockRepository);
        },
        act: (cubit) => cubit.deleteAccount(),
        expect: () => [
          const SettingsAccountDeleted(),
        ],
      );

      blocTest<SettingsCubit, SettingsState>(
        'emits [Error] when delete fails',
        build: () {
          when(() => mockRepository.deleteAccount())
              .thenThrow(Exception('Delete failed'));
          return SettingsCubit(mockRepository);
        },
        act: (cubit) => cubit.deleteAccount(),
        expect: () => [
          isA<SettingsError>(),
        ],
      );
    });
  });
}
