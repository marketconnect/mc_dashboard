import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/utils/dates.dart';
import 'package:mc_dashboard/presentation/subscription_screen/subscription_view_model.dart';
import 'package:provider/provider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<SubscriptionViewModel>();
    final isSubscribed = model.isSubscribed;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: isSubscribed
                      ? _buildSubscribedView(context, model)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // const SizedBox(height: 24),
                            // Text(
                            //   'Информация о подписке',
                            //   textAlign: TextAlign.center,
                            //   style: theme.textTheme.headlineSmall?.copyWith(
                            //     fontSize: 24,
                            //     fontWeight: FontWeight.bold,
                            //     color: theme.colorScheme.primary,
                            //   ),
                            // ),
                            // const SizedBox(height: 16),
                            // const SizedBox(height: 16),
                            // Text(
                            //   'Что вы получаете:',
                            //   style: theme.textTheme.titleMedium?.copyWith(
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.w600,
                            //     color: theme.colorScheme.onSurface,
                            //   ),
                            // ),
                            const SizedBox(height: 16),
                            // Text(
                            //   'Email рассылка с актуальной аналитикой и уведомлениями:',
                            //   style: theme.textTheme.titleMedium?.copyWith(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.w500,
                            //     color: theme.colorScheme.onSurface,
                            //   ),
                            // ),
                            // const SizedBox(height: 16),
                            // _buildBenefitItem(
                            //   context,
                            //   'Анализ позиций',
                            //   'Актуальные данные о месте товаров в поисковой выдаче (глубина 3 страницы).',
                            // ),
                            // _buildBenefitItem(
                            //   context,
                            //   'Уведомления о ценах',
                            //   'Отслеживание изменений ваших цен и цен конкурентов.',
                            // ),
                            // _buildBenefitItem(
                            //   context,
                            //   'Тренды',
                            //   'Популярные запросы и изменения в спросе внутри ваших категорий.',
                            // ),
                            // _buildBenefitItem(
                            //   context,
                            //   'Акции',
                            //   'Информация о входе и выходе ваших товаров и конкурентов из акций.',
                            // ),
                            // _buildBenefitItem(
                            //   context,
                            //   'Изменения карточек',
                            //   'Уведомления о корректировках в описаниях, заголовках и характеристиках товаров.',
                            // ),
                            // _buildBenefitItem(
                            //   context,
                            //   'Изменение ассортимента',
                            //   'Добавление новых товаров конкурентами или исчезновение существующих.',
                            // ),
                            // const SizedBox(height: 24),
                            // const SizedBox(height: 24),
                            // Text(
                            //   'Всего 1000 рублей в месяц за полную картину данных по вашим категориям и товарам.',
                            //   textAlign: TextAlign.center,
                            //   style: theme.textTheme.titleMedium?.copyWith(
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.green,
                            //   ),
                            // ),
                            const SizedBox(height: 16),
                            // Text(
                            //   'Подключите подписку, чтобы всегда быть в курсе важных изменений и не упустить новые возможности для роста.',
                            //   textAlign: TextAlign.center,
                            //   style: theme.textTheme.bodyMedium?.copyWith(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.normal,
                            //     color: theme.colorScheme.onSurfaceVariant,
                            //   ),
                            // ),
                            const SizedBox(height: 16),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                model.subscribe();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.tertiary,
                                foregroundColor: theme.colorScheme.onTertiary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 32,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Оформить подписку за 1000 рублей в месяц',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                ),
              ),
            ));
          },
        ),
      ),
    );
  }

  Widget _buildSubscribedView(
      BuildContext context, SubscriptionViewModel model) {
    final theme = Theme.of(context);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final surfaceContainerHighest =
        Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      height: screenH * 0.5,
      margin: const EdgeInsets.all(8.0),
      padding: EdgeInsets.symmetric(horizontal: screenW * 0.1, vertical: 16),
      decoration: BoxDecoration(
        color: surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'Ваша подписка активна!',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Подписка действует до ${formatRuFullDate(model.subsEndDate)}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              model.subscribe();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.tertiary,
              foregroundColor: theme.colorScheme.onTertiary,
              padding: const EdgeInsets.symmetric(
                vertical: 32,
                horizontal: 32,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Продлить подписку',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
      BuildContext context, String title, String description) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
