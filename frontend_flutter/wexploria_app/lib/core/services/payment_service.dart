import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../constants/app_constants.dart';

class PaymentService {
  final String baseUrl = ApiConstants.baseUrl + ApiConstants.paymentsEndpoint;

  /// Initialise Stripe avec la clé publique
  static Future<void> initializeStripe(String publishableKey) async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  /// Crée une session Stripe Checkout
  Future<Map<String, dynamic>> createCheckoutSession({
    required String reservationId,
    required String successUrl,
    required String cancelUrl,
    String? codePromo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'reservation_id': reservationId,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
        if (codePromo != null) 'code_promo': codePromo,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la création de la session de paiement');
    }
  }

  /// Lance le flux de paiement Stripe
  Future<bool> processPayment({
    required String reservationId,
    String? codePromo,
  }) async {
    try {
      // Créer la session Checkout
      final session = await createCheckoutSession(
        reservationId: reservationId,
        successUrl: 'wexploria://payment-success',
        cancelUrl: 'wexploria://payment-cancel',
        codePromo: codePromo,
      );

      // Rediriger vers Stripe Checkout (Web)
      // Pour mobile, utiliser presentPaymentSheet
      final sessionId = session['session_id'] as String;
      
      // Initialiser le Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Wexploria',
          paymentIntentClientSecret: sessionId,
          style: ThemeMode.system,
        ),
      );

      // Présenter le Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      print('Erreur de paiement: $e');
      return false;
    }
  }

  /// Crée un lien d'onboarding Stripe Connect pour un opérateur
  Future<Map<String, dynamic>> createConnectOnboarding({
    required String operateurId,
    required String refreshUrl,
    required String returnUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/connect/onboarding'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'operateur_id': operateurId,
        'refresh_url': refreshUrl,
        'return_url': returnUrl,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la création du lien d\'onboarding');
    }
  }

  /// Demande un remboursement
  Future<Map<String, dynamic>> requestRefund(String paiementId, {String? reason}) async {
    final queryParams = reason != null ? {'reason': reason} : <String, String>{};
    final uri = Uri.parse('$baseUrl/$paiementId/refund').replace(queryParameters: queryParams);
    
    final response = await http.post(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la demande de remboursement');
    }
  }

  /// Récupère l'historique des paiements d'un client
  Future<List<Map<String, dynamic>>> getClientPayments(String clientId) async {
    final response = await http.get(Uri.parse('$baseUrl/client/$clientId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['payments']);
    } else {
      throw Exception('Erreur lors de la récupération de l\'historique des paiements');
    }
  }
}
