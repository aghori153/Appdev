import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String? id;
  final String title;
  final String category;
  final String location;
  final String status;
  final String description;
  final String postedBy;
  final DateTime? createdAt;

  Item({
    this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.status,
    required this.description,
    required this.postedBy,
    this.createdAt,
  });

  bool get isClaimed => status == 'Claimed';

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'location': location,
      'status': status,
      'description': description,
      'postedBy': postedBy,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  factory Item.fromMap(String id, Map<String, dynamic> map) {
    final created = map['createdAt'];
    return Item(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? 'Other',
      location: map['location'] ?? '',
      status: map['status'] ?? 'Found',
      description: map['description'] ?? '',
      postedBy: map['postedBy'] ?? '',
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }
}
