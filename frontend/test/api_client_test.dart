import 'dart:convert';

import 'package:evidyalaya/core/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Client _server({
  required int status,
  required Object body,
  void Function(http.Request)? onRequest,
}) {

  return MockClient((request) async {

    onRequest?.call(request);
    return http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

  });

}

void main() {

  tearDown(() => ApiClient.instance.token = null);

  test('returns only the data of a successful reply', () async {

    final result = await http.runWithClient(
      () => ApiClient.instance.get(path: '/classes'),
      () => _server(
        status: 200,
        body: {
          'status': true,
          'data': [
            {'class_id': 1},
          ],
        },
      ),
    );

    expect(
      result,
      [
        {'class_id': 1},
      ],
    );

  });

  test('returns null when the reply has no data', () async {

    final result = await http.runWithClient(
      () => ApiClient.instance.post(
        path: '/auth/forgot-password',
        body: {
          'username': 'a@b',
        },
      ),
      () => _server(
        status: 200,
        body: {
          'status': true,
          'message': 'sent',
        },
      ),
    );

    expect(
      result,
      isNull,
    );

  });

  test('reports the server message and status of a failure', () async {

    final call = http.runWithClient(
      () => ApiClient.instance.post(
        path: '/auth/login',
        body: {},
      ),
      () => _server(
        status: 401,
        body: {
          'status': false,
          'message': 'Invalid username or password',
        },
      ),
    );

    await expectLater(
      call,
      throwsA(
        isA<ApiException>()
            .having(
              (e) => e.message,
              'message',
              'Invalid username or password',
            )
            .having(
              (e) => e.isUnauthorized,
              'isUnauthorized',
              isTrue,
            ),
      ),
    );

  });

  test('sends the bearer token and a JSON body', () async {

    ApiClient.instance.token = 'abc';
    late http.Request seen;

    await http.runWithClient(
      () => ApiClient.instance.post(
        path: '/notes',
        body: {
          'title': 't',
        },
      ),
      () => _server(
        status: 201,
        body: {
          'status': true,
        },
        onRequest: (request) => seen = request,
      ),
    );

    expect(
      seen.headers['authorization'],
      'Bearer abc',
    );
    expect(
      jsonDecode(seen.body),
      {
        'title': 't',
      },
    );

  });

}
