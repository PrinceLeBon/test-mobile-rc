import 'package:blog_app/shared/widgets/user_avatar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la couleur de l’avatar suit le calcul fixe de la charte', () {
    const expectedIndexes = {
      'alice': 0,
      'carol': 1,
      'eli': 2,
      'ines': 3,
      'thomas': 4,
      'bob': 5,
      'nina': 6,
      'adam': 7,
    };
    expectedIndexes.forEach((username, index) {
      expect(UserAvatar.paletteIndexFor(username), index, reason: username);
    });
  });

  test('l’initiale est en majuscule, ou ? si le nom est vide', () {
    expect(UserAvatar.initialOf('alice'), 'A');
    expect(UserAvatar.initialOf(''), '?');
  });
}
