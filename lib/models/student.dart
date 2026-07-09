import 'dart:convert';

class Student {
  const Student({
    required this.name,
    required this.number,
    required this.department,
  });

  final String name;
  final String number;
  final String department;

  Map<String, String> toJson() => {
    'name': name,
    'number': number,
    'department': department,
  };

  static Student? fromJson(String? source) {
    if (source == null || source.isEmpty) return null;
    final data = jsonDecode(source) as Map<String, dynamic>;
    return Student(
      name: data['name'] as String? ?? '',
      number: data['number'] as String? ?? '',
      department: data['department'] as String? ?? '',
    );
  }
}
