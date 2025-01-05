import "dart:convert";

import "package:http/http.dart" as http;
import "package:mc_dashboard/.env.dart";

import 'package:intl/intl.dart';
import "package:mc_dashboard/presentation/subscription_screen/subscription_view_model.dart";

class TinkoffPaymentService implements SubscriptionTinkoffPaymentService {
  @override
  Future<String?> processPayment(
      int amount, DateTime endDate, String email) async {
    // if prolongation subscription

    final orderNumber = DateTime.now().millisecond;

    final amountInKopeks = amount * 100;
    final description =
        'Оплата подписки до ${endDate.day}.${endDate.month}.${endDate.year}.'; // Ваше описание

    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    final response = await http.post(
      Uri.parse(
          '${McAuthService.baseUrl}/t_payment_link'), // Замените на ваш URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amountInKopeks,
        'email': email,
        'orderNumber': orderNumber,
        'description': description,
        'endDate': formattedEndDate,
        'receipt': {
          'Email': "ipbogachenko@yandex.ru",
          'Taxation': 'usn_income',
          'Items': [
            {
              'Name': 'Подписка marketconnect',
              'Price': amountInKopeks,
              'Quantity': 1.0,
              'Amount': amountInKopeks,
              "PaymentMethod": "full_payment",
              "PaymentObject": "service",
              "Tax": "none"
            },
          ],
        },
      }),
    );

    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }
}
