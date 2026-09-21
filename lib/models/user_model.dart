class Address {
  final String street;
  final String suite;
  final String city;
  final String zipcode;

  const Address({
    required this.street,
    required this.city,
    this.suite = '',
    this.zipcode = '',
  });

  factory Address.fromJson(Map<String, dynamic> j) => Address(
    street: j['street'] as String,
    city: j['city'] as String,
    suite: (j['suite'] as String?) ?? '',
    zipcode: (j['zipcode'] as String?) ?? '',
  );

  String get fullAddress => [
    street,
    suite,
    [city, zipcode].where((s) => s.isNotEmpty).join(' '),
  ].where((s) => s.isNotEmpty).join(', ');
}

class Company {
  final String name;
  final String catchPhrase;

  const Company({required this.name, this.catchPhrase = ''});

  factory Company.fromJson(Map<String, dynamic> j) => Company(
    name: j['name'] as String,
    catchPhrase: (j['catchPhrase'] as String?) ?? '',
  );
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final Address address;
  final Company company;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'] as int,
    name: j['name'] as String,
    email: j['email'] as String,
    phone: j['phone'] as String,
    address: Address.fromJson(j['address'] as Map<String, dynamic>),
    company: Company.fromJson(j['company'] as Map<String, dynamic>),
  );

  String get initials {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(p[0]))
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
