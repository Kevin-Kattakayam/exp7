/// Data model representing an Employee record stored in Google Cloud Firestore.
class Employee {
  final String? id; // Firestore document ID
  final String employeeId; // e.g. 'EMP-2026-101'
  final String name;
  final String department;
  final String designation;
  final String email;
  final double salary;
  final String joiningDate;

  const Employee({
    this.id,
    required this.employeeId,
    required this.name,
    required this.department,
    required this.designation,
    required this.email,
    required this.salary,
    required this.joiningDate,
  });

  /// Convert Employee to Map for Firestore document insertion.
  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'name': name,
      'department': department,
      'designation': designation,
      'email': email,
      'salary': salary,
      'joiningDate': joiningDate,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Factory constructor to parse document data and document ID from Firestore.
  factory Employee.fromMap(Map<String, dynamic> map, String id) {
    return Employee(
      id: id,
      employeeId: map['employeeId'] as String? ?? 'EMP-UNKNOWN',
      name: map['name'] as String? ?? 'Unnamed',
      department: map['department'] as String? ?? 'General',
      designation: map['designation'] as String? ?? 'Associate',
      email: map['email'] as String? ?? 'no-email@company.com',
      salary: (map['salary'] as num?)?.toDouble() ?? 0.0,
      joiningDate: map['joiningDate'] as String? ?? '2024-01-01',
    );
  }

  Employee copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? department,
    String? designation,
    String? email,
    double? salary,
    String? joiningDate,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      email: email ?? this.email,
      salary: salary ?? this.salary,
      joiningDate: joiningDate ?? this.joiningDate,
    );
  }
}

