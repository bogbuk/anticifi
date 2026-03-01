import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:anticifi/features/notifications/domain/entities/notification_entity.dart';
import 'package:anticifi/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:anticifi/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:anticifi/features/notifications/presentation/bloc/notifications_state.dart';

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  late MockNotificationsRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationsRepository();
  });

  final testNotifications = [
    NotificationEntity(
      id: 'notif-1',
      title: 'Payment Due',
      body: 'Rent is due tomorrow',
      type: 'payment_reminder',
      isRead: false,
      createdAt: DateTime.parse('2026-03-01T08:00:00.000Z'),
    ),
    NotificationEntity(
      id: 'notif-2',
      title: 'Welcome',
      body: 'Welcome to AnticiFi',
      type: 'system',
      isRead: true,
      createdAt: DateTime.parse('2026-02-28T10:00:00.000Z'),
    ),
  ];

  group('NotificationsCubit', () {
    test('initial state is NotificationsInitial', () {
      final cubit = NotificationsCubit(mockRepository);
      expect(cubit.state, const NotificationsInitial());
      cubit.close();
    });

    group('loadNotifications', () {
      blocTest<NotificationsCubit, NotificationsState>(
        'emits [Loading, Loaded] when succeeds',
        build: () {
          when(() => mockRepository.getNotifications())
              .thenAnswer((_) async => testNotifications);
          when(() => mockRepository.getUnreadCount())
              .thenAnswer((_) async => 1);
          return NotificationsCubit(mockRepository);
        },
        act: (cubit) => cubit.loadNotifications(),
        expect: () => [
          const NotificationsLoading(),
          NotificationsLoaded(
            notifications: testNotifications,
            unreadCount: 1,
          ),
        ],
      );

      blocTest<NotificationsCubit, NotificationsState>(
        'emits [Loading, Error] when fails',
        build: () {
          when(() => mockRepository.getNotifications())
              .thenThrow(Exception('Failed'));
          return NotificationsCubit(mockRepository);
        },
        act: (cubit) => cubit.loadNotifications(),
        expect: () => [
          const NotificationsLoading(),
          isA<NotificationsError>(),
        ],
      );
    });

    group('markAsRead', () {
      blocTest<NotificationsCubit, NotificationsState>(
        'marks notification as read and reloads',
        build: () {
          when(() => mockRepository.markAsRead('notif-1'))
              .thenAnswer((_) async {});
          when(() => mockRepository.getNotifications())
              .thenAnswer((_) async => testNotifications);
          when(() => mockRepository.getUnreadCount())
              .thenAnswer((_) async => 0);
          return NotificationsCubit(mockRepository);
        },
        act: (cubit) => cubit.markAsRead('notif-1'),
        verify: (_) {
          verify(() => mockRepository.markAsRead('notif-1')).called(1);
        },
      );
    });

    group('markAllAsRead', () {
      blocTest<NotificationsCubit, NotificationsState>(
        'marks all as read and reloads',
        build: () {
          when(() => mockRepository.markAllAsRead())
              .thenAnswer((_) async {});
          when(() => mockRepository.getNotifications())
              .thenAnswer((_) async => testNotifications);
          when(() => mockRepository.getUnreadCount())
              .thenAnswer((_) async => 0);
          return NotificationsCubit(mockRepository);
        },
        act: (cubit) => cubit.markAllAsRead(),
        verify: (_) {
          verify(() => mockRepository.markAllAsRead()).called(1);
        },
      );
    });

    group('loadUnreadCount', () {
      blocTest<NotificationsCubit, NotificationsState>(
        'emits Loaded with updated count when in Loaded state',
        build: () {
          when(() => mockRepository.getUnreadCount())
              .thenAnswer((_) async => 5);
          return NotificationsCubit(mockRepository);
        },
        seed: () => NotificationsLoaded(
          notifications: testNotifications,
          unreadCount: 1,
        ),
        act: (cubit) => cubit.loadUnreadCount(),
        expect: () => [
          NotificationsLoaded(
            notifications: testNotifications,
            unreadCount: 5,
          ),
        ],
      );
    });
  });
}
