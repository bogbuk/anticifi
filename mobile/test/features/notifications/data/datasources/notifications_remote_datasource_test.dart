import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:anticifi/core/network/dio_client.dart';
import 'package:anticifi/features/notifications/data/datasources/notifications_remote_datasource.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late NotificationsRemoteDataSource dataSource;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = NotificationsRemoteDataSource(dioClient: mockDioClient);
  });

  group('NotificationsRemoteDataSource', () {
    group('getNotifications', () {
      test('should return list of NotificationModel', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {
                'data': [
                  {
                    'id': 'notif-1',
                    'title': 'Payment Due',
                    'body': 'Your rent is due',
                    'type': 'payment_reminder',
                    'isRead': false,
                    'createdAt': '2026-03-01T08:00:00.000Z',
                  },
                ],
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/notifications'),
            ));

        final result = await dataSource.getNotifications();

        expect(result.length, 1);
        expect(result[0].id, 'notif-1');
        expect(result[0].title, 'Payment Due');
        expect(result[0].isRead, false);
      });
    });

    group('getUnreadCount', () {
      test('should return unread count', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {'count': 3},
              statusCode: 200,
              requestOptions:
                  RequestOptions(path: '/notifications/unread-count'),
            ));

        final result = await dataSource.getUnreadCount();

        expect(result, 3);
      });

      test('should default to 0 when count is null', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: <String, dynamic>{},
              statusCode: 200,
              requestOptions:
                  RequestOptions(path: '/notifications/unread-count'),
            ));

        final result = await dataSource.getUnreadCount();

        expect(result, 0);
      });
    });

    group('markAsRead', () {
      test('should send PATCH to mark notification as read', () async {
        when(() => mockDio.patch(any())).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions:
                  RequestOptions(path: '/notifications/notif-1/read'),
            ));

        await dataSource.markAsRead('notif-1');

        verify(() => mockDio.patch(any())).called(1);
      });
    });

    group('markAllAsRead', () {
      test('should send PATCH to mark all as read', () async {
        when(() => mockDio.patch(any())).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions:
                  RequestOptions(path: '/notifications/read-all'),
            ));

        await dataSource.markAllAsRead();

        verify(() => mockDio.patch(any())).called(1);
      });
    });
  });
}
