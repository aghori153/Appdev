import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found/features/items/domain/item_model.dart';

void main() {
  test('item is read from a firestore map', () {
    final item = Item.fromMap('abc', {
      'title': 'Black Backpack',
      'category': 'Bag',
      'location': 'MCC Cafeteria',
      'status': 'Found',
    });

    expect(item.id, 'abc');
    expect(item.title, 'Black Backpack');
    expect(item.isClaimed, false);
    expect(item.description, '');
  });
}
