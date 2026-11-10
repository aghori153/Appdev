import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/item_model.dart';

abstract class ItemRepository {
  Stream<List<Item>> watchItems();
  Stream<Item?> watchItem(String id);
  Future<void> addItem(Item item);
  Future<void> markAsClaimed(String id);
  Future<void> deleteItem(String id);
}

class FirestoreItemRepository implements ItemRepository {
  final CollectionReference<Map<String, dynamic>> itemsRef =
      FirebaseFirestore.instance.collection('items');

  @override
  Stream<List<Item>> watchItems() {
    return itemsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  @override
  Stream<Item?> watchItem(String id) {
    return itemsRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Item.fromMap(doc.id, doc.data()!);
    });
  }

  @override
  Future<void> addItem(Item item) async {
    await itemsRef.add(item.toMap());
  }

  @override
  Future<void> markAsClaimed(String id) async {
    final docRef = itemsRef.doc(id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Item not found');
      }

      if (snapshot.data()!['status'] == 'Claimed') {
        throw Exception('Item is already claimed');
      }

      transaction.update(docRef, {
        'status': 'Claimed',
        'claimedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> deleteItem(String id) async {
    await itemsRef.doc(id).delete();
  }
}
