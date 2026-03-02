import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:anticifi/core/services/biometric_service.dart';
import 'package:anticifi/features/auth/domain/entities/user_entity.dart';
import 'package:anticifi/features/auth/domain/repositories/auth_repository.dart';
import 'package:anticifi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:anticifi/features/auth/presentation/bloc/auth_event.dart';
import 'package:anticifi/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockBiometricService extends Mock implements BiometricService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockBiometricService mockBiometricService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockBiometricService = MockBiometricService();
    when(() => mockBiometricService.clear()).thenAnswer((_) async {});
  });

  const testUser = UserEntity(
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
  );

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      final bloc = AuthBloc(mockAuthRepository, mockBiometricService);
      expect(bloc.state, const AuthInitial());
      bloc.close();
    });

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthLoginSuccessState] when login succeeds',
        build: () {
          when(() => mockAuthRepository.login('john@example.com', 'password'))
              .thenAnswer((_) async => testUser);
          return AuthBloc(mockAuthRepository, mockBiometricService);
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          email: 'john@example.com',
          password: 'password',
        )),
        expect: () => [
          const AuthLoading(),
          const AuthLoginSuccessState(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails',
        build: () {
          when(() => mockAuthRepository.login('john@example.com', 'wrong'))
              .thenThrow(Exception('Invalid credentials'));
          return AuthBloc(mockAuthRepository, mockBiometricService);
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          email: 'john@example.com',
          password: 'wrong',
        )),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>(),
        ],
      );
    });

    group('AuthRegisterRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthLoginSuccessState] when register succeeds',
        build: () {
          when(() => mockAuthRepository.register(
                'John Doe',
                'john@example.com',
                'password',
              )).thenAnswer((_) async => testUser);
          return AuthBloc(mockAuthRepository, mockBiometricService);
        },
        act: (bloc) => bloc.add(const AuthRegisterRequested(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password',
        )),
        expect: () => [
          const AuthLoading(),
          const AuthLoginSuccessState(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when register fails',
        build: () {
          when(() => mockAuthRepository.register(
                'John Doe',
                'john@example.com',
                'password',
              )).thenThrow(Exception('Email already in use'));
          return AuthBloc(mockAuthRepository, mockBiometricService);
        },
        act: (bloc) => bloc.add(const AuthRegisterRequested(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password',
        )),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>(),
        ],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when logout succeeds',
        build: () {
          when(() => mockAuthRepository.logout())
              .thenAnswer((_) async {});
          return AuthBloc(mockAuthRepository, mockBiometricService);
        },
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when authenticated with profile',
        build: () {
          when(() => mockAuthRepository.isAuthenticated())
              .thenAnswer((_) async => true);
          when(() => mockAuthRepository.getUserProfile())
              .thenAnswer((_) async => testUser);
          return AuthBloc(mockAuthRepository, mockBiometricService);
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when not authenticated',
        build: () {
          when(() => mockAuthRepository.isAuthenticated())
              .thenAnswer((_) async => false);
          return AuthBloc(mockAuthRepository, mockBiometricService);
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when check throws error',
        build: () {
          when(() => mockAuthRepository.isAuthenticated())
              .thenThrow(Exception('Network error'));
          return AuthBloc(mockAuthRepository, mockBiometricService);
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );
    });

    group('AuthBiometricRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when biometric succeeds',
        build: () {
          when(() => mockBiometricService.authenticate())
              .thenAnswer((_) async => true);
          when(() => mockAuthRepository.getUserProfile())
              .thenAnswer((_) async => testUser);
          return AuthBloc(mockAuthRepository, mockBiometricService);
        },
        act: (bloc) => bloc.add(const AuthBiometricRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when biometric fails',
        build: () {
          when(() => mockBiometricService.authenticate())
              .thenAnswer((_) async => false);
          return AuthBloc(mockAuthRepository, mockBiometricService);
        },
        act: (bloc) => bloc.add(const AuthBiometricRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );
    });

    group('AuthConfirmLogin', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthAuthenticated] when confirm login',
        build: () => AuthBloc(mockAuthRepository, mockBiometricService),
        act: (bloc) => bloc.add(const AuthConfirmLogin(testUser)),
        expect: () => [
          const AuthAuthenticated(testUser),
        ],
      );
    });
  });
}
