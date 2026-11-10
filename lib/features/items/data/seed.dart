import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/item_model.dart';

Future<void> seedItems() async {
  final itemsCollection = FirebaseFirestore.instance.collection('items');

  final existing = await itemsCollection.limit(1).get();
  if (existing.docs.isNotEmpty) return;

  final now = DateTime.now();

  final samples = [
    Item(
      title: 'Black Backpack',
      category: 'Bag',
      location: 'MCC Cafeteria',
      status: 'Found',
      description: 'Black backpack left on a chair near the counter. Has a few notebooks inside.',
      postedBy: 'Hamza',
    ),
    Item(
      title: 'Blue Water Bottle',
      category: 'Accessory',
      location: 'Library, 2nd Floor',
      status: 'Found',
      description: 'Blue steel bottle found on one of the study tables.',
      postedBy: 'Areeba',
    ),
    Item(
      title: 'Student ID Card — M. Ali',
      category: 'ID Card',
      location: 'Main Gate',
      status: 'Found',
      description: 'IBA student card with the name M. Ali. Given to the guard at main gate.',
      postedBy: 'Usman',
    ),
    Item(
      title: 'Laptop Charger (Dell)',
      category: 'Electronics',
      location: 'Room 301',
      status: 'Lost',
      description: 'Dell 65W charger, forgot it plugged in after the 11:30 class.',
      postedBy: 'Fatima',
    ),
    Item(
      title: 'Umbrella (Black)',
      category: 'Accessory',
      location: 'Admin Block',
      status: 'Lost',
      description: 'Plain black folding umbrella, left outside the accounts office.',
      postedBy: 'Bilal',
    ),
    Item(
      title: 'Bunch of Keys',
      category: 'Keys',
      location: 'Parking Lot',
      status: 'Found',
      description: 'Three keys on a ring with a Honda keychain.',
      postedBy: 'Saad',
    ),
    Item(
      title: 'Calculus Textbook',
      category: 'Book',
      location: 'Student Lounge',
      status: 'Lost',
      description: 'Thomas Calculus, my name is written on the first page.',
      postedBy: 'Maryam',
    ),
    Item(
      title: 'Grey Jacket',
      category: 'Clothing',
      location: 'Auditorium',
      status: 'Found',
      description: 'Grey zipper jacket, medium size, found on a seat in the back row.',
      postedBy: 'Zain',
    ),
  ];

  final batch = FirebaseFirestore.instance.batch();

  for (int i = 0; i < samples.length; i++) {
    final data = samples[i].toMap();
    data['createdAt'] = Timestamp.fromDate(now.subtract(Duration(hours: i * 3)));
    batch.set(itemsCollection.doc(), data);
  }
  await batch.commit();
}
