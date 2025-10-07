import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:farmeasy/main.dart';
import 'package:farmeasy/providers/user_provider.dart';
import 'package:farmeasy/providers/crop_provider.dart';
import 'package:farmeasy/providers/weather_provider.dart';
import 'package:farmeasy/services/api_service.dart';

class _MockClient extends http.BaseClient {
  final Map<String, Map<String, dynamic>> _routes = {
    '/api/auth/register': {
      'status': 200,
      'body': {
        'token': 'mock-register-token',
        'user': {
          'id': 1,
          'username': 'testuser',
          'email': 'test@example.com',
          'phone': '1234567890',
        }
      }
    },
    '/api/auth/login': {
      'status': 200,
      'body': {
        'token': 'mock-login-token',
        'user': {
          'id': 1,
          'username': 'testuser',
          'email': 'test@example.com',
          'phone': '1234567890',
        }
      }
    },
    '/api/crops/recommend': {
      'status': 200,
      'body': {
        'soil_test': {
          'user_id': 1,
          'nitrogen': 50,
          'phosphorus': 40,
          'potassium': 30,
          'ph_level': 6.5,
          'organic_carbon': 1.2,
        },
        'recommendations': [
          {
            'crop': {
              'id': 1,
              'name': 'Wheat',
              'description': 'A common cereal crop.',
              'season': 'Rabi',
            },
            'confidence': 0.92,
          },
          {
            'crop': {
              'id': 2,
              'name': 'Rice',
              'description': 'Staple food crop.',
              'season': 'Kharif',
            },
            'confidence': 0.84,
          }
        ]
      }
    },
    '/api/crops/all': {
      'status': 200,
      'body': {
        'crops': [
          {'id': 1, 'name': 'Wheat'},
          {'id': 2, 'name': 'Rice'},
        ]
      }
    },
    '/api/crops/history': {
      'status': 200,
      'body': {'history': []}
    },
  };

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final key = request.url.path;
    final entry = _routes[key];
    final status = entry?['status'] as int? ?? 404;
    final body = json.encode(entry?['body'] ?? {'message': 'Not Found'});
    return http.StreamedResponse(
      Stream<List<int>>.fromIterable([utf8.encode(body)]),
      status,
      headers: {'Content-Type': 'application/json'},
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FarmEasy register -> login -> soil test -> recommendations',
      (tester) async {
    // Inject mock client
    ApiService().setClient(_MockClient());

    // Pump the app with needed providers (same as app)
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CropProvider()),
          ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ],
        child: const MaterialApp(home: AuthChecker()),
      ),
    );

    // Wait for AuthChecker navigation
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // We expect to land on LoginScreen; navigate to Register
    final signUpFinder = find.text('Sign Up');
    if (signUpFinder.evaluate().isEmpty) {
      // If we're not on Login, push LoginScreen by restarting app
      await tester.pumpWidget(const FarmEasyApp());
      await tester.pumpAndSettle();
    }

    // Tap Sign Up to go to Register
    expect(find.text('Sign Up'), findsOneWidget);
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Fill registration form
    await tester.enterText(find.byKey(const Key('reg_username')), 'testuser');
    await tester.enterText(
        find.byKey(const Key('reg_email')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('reg_phone')), '1234567890');
    await tester.enterText(find.byKey(const Key('reg_password')), 'password1');
    await tester.enterText(
        find.byKey(const Key('reg_confirm_password')), 'password1');

    // Submit registration
    await tester.tap(find.byKey(const Key('btn_register')));
    await tester.pumpAndSettle();

    // After register, we should be on Dashboard
    expect(find.text('FarmEasy Dashboard'), findsOneWidget);

    // Navigate to Soil Test
    await tester.scrollUntilVisible(find.text('Quick Actions'), 300);
    await tester.tap(find.text('Soil Analysis'));
    await tester.pumpAndSettle();

    // Fill soil test fields
    await tester.enterText(find.byKey(const Key('soil_nitrogen')), '50');
    await tester.enterText(find.byKey(const Key('soil_phosphorus')), '40');
    await tester.enterText(find.byKey(const Key('soil_potassium')), '30');
    await tester.enterText(find.byKey(const Key('soil_ph')), '6.5');
    await tester.enterText(find.byKey(const Key('soil_organic_carbon')), '1.2');

    // Analyze Soil
    await tester.tap(find.byKey(const Key('btn_analyze_soil')));
    // Let async + navigation complete
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Recommendations screen shows
    expect(find.text('Crop Recommendations'), findsOneWidget);
    expect(find.text('Top Recommendation'), findsOneWidget);
    expect(find.text('Wheat'), findsWidgets);

    // Return success
  });
}
