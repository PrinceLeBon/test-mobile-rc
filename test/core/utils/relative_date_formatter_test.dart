import 'package:blog_app/core/utils/relative_date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  final now = DateTime(2026, 11, 4, 12);

  String format(DateTime date) => RelativeDateFormatter.format(date, now: now);

  test('moins de 60 secondes donne à l’instant', () {
    expect(format(now.subtract(const Duration(seconds: 59))), 'à l’instant');
    expect(format(now.add(const Duration(minutes: 2))), 'à l’instant');
  });

  test('moins de 60 minutes donne les minutes', () {
    expect(
      format(now.subtract(const Duration(minutes: 5))),
      'il y a 5\u00A0min',
    );
    expect(
      format(now.subtract(const Duration(minutes: 59))),
      'il y a 59\u00A0min',
    );
  });

  test('le même jour donne les heures', () {
    expect(format(now.subtract(const Duration(hours: 3))), 'il y a 3\u00A0h');
    expect(format(DateTime(2026, 11, 4, 0, 1)), 'il y a 11\u00A0h');
  });

  test('la veille calendaire donne hier', () {
    expect(format(DateTime(2026, 11, 3, 23, 59)), 'hier');
    expect(format(DateTime(2026, 11, 3, 0, 1)), 'hier');
  });

  test('juste après minuit, les minutes passent avant hier', () {
    final justAfterMidnight = DateTime(2026, 11, 4, 0, 10);
    expect(
      RelativeDateFormatter.format(
        DateTime(2026, 11, 3, 23, 50),
        now: justAfterMidnight,
      ),
      'il y a 20\u00A0min',
    );
  });

  test('la même année donne le jour et le mois', () {
    expect(format(DateTime(2026, 11, 2, 9)), '2 nov.');
    expect(format(DateTime(2026, 10, 12, 9)), '12 oct.');
  });

  test('une autre année ajoute l’année', () {
    expect(format(DateTime(2025, 10, 12, 9)), '12 oct. 2025');
  });

  test('une date UTC du serveur est comparée en heure locale', () {
    final serverDate = now.toUtc().subtract(const Duration(minutes: 5));
    expect(format(serverDate), 'il y a 5\u00A0min');
  });
}
