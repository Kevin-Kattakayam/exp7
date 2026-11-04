import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../models/employee.dart';

/// Centralized service handling Google Cloud Firestore storage, queries, and streams.
class FirestoreService {
  static const String collectionName = 'employees';

  // Singleton instance
  FirestoreService._internal();
  static final FirestoreService instance = FirestoreService._internal();

  bool _isFirebaseInitialized = false;
  bool get isFirebaseInitialized => _isFirebaseInitialized;

  FirebaseFirestore? _firestore;

  // In-memory fallback repository for offline/unconfigured environments
  final List<Employee> _localCache = [];
  final StreamController<List<Employee>> _localStreamController =
      StreamController<List<Employee>>.broadcast();

  /// Initialize Firebase Core and Cloud Firestore settings.
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firestore = FirebaseFirestore.instance;

      // Enable offline persistence in Cloud Firestore
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _isFirebaseInitialized = true;
    } catch (_) {
      // Graceful fallback to persistent local cache if running in demo/offline mode
      _isFirebaseInitialized = false;
      _initDemoData();
    }
  }

  void _initDemoData() {
    if (_localCache.isEmpty) {
      _localCache.addAll([
        const Employee(
          id: 'doc_emp_001',
          employeeId: 'EMP-1001',
          name: 'Sarah Connor',
          department: 'Engineering',
          designation: 'Staff Mobile Architect',
          email: 'sarah.c@cloudcorp.io',
          salary: 135000.0,
          joiningDate: '2023-03-15',
        ),
        const Employee(
          id: 'doc_emp_002',
          employeeId: 'EMP-1002',
          name: 'David Kim',
          department: 'Cloud Infrastructure',
          designation: 'DevOps & Firestore Lead',
          email: 'david.k@cloudcorp.io',
          salary: 128000.0,
          joiningDate: '2023-06-01',
        ),
        const Employee(
          id: 'doc_emp_003',
          employeeId: 'EMP-1003',
          name: 'Aisha Morales',
          department: 'Product & Design',
          designation: 'Principal UI/UX Designer',
          email: 'aisha.m@cloudcorp.io',
          salary: 118000.0,
          joiningDate: '2023-08-20',
        ),
        const Employee(
          id: 'doc_emp_004',
          employeeId: 'EMP-1004',
          name: 'Marcus Vance',
          department: 'Engineering',
          designation: 'Senior Backend Engineer',
          email: 'marcus.v@cloudcorp.io',
          salary: 122000.0,
          joiningDate: '2024-01-10',
        ),
      ]);
      _localStreamController.add(List.unmodifiable(_localCache));
    }
  }

  // ==================== FIRESTORE STREAMS & READS ====================

  /// Stream of all employee documents in real-time.
  Stream<List<Employee>> getEmployeesStream({String? departmentFilter}) {
    if (_isFirebaseInitialized && _firestore != null) {
      try {
        Query<Map<String, dynamic>> query =
            _firestore!.collection(collectionName);

        if (departmentFilter != null && departmentFilter != 'All') {
          query = query.where('department', isEqualTo: departmentFilter);
        }

        return query.snapshots().map((snapshot) {
          return snapshot.docs.map((doc) {
            return Employee.fromMap(doc.data(), doc.id);
          }).toList();
        });
      } catch (_) {
        // Fallback to local stream on unexpected exception
      }
    }

    // Local stream emission
    Future.microtask(() {
      final list = departmentFilter == null || departmentFilter == 'All'
          ? _localCache
          : _localCache
              .where((e) => e.department == departmentFilter)
              .toList();
      _localStreamController.add(List.unmodifiable(list));
    });

    return _localStreamController.stream;
  }

  /// One-time fetch of all employees from Cloud Firestore.
  Future<List<Employee>> getAllEmployees() async {
    if (_isFirebaseInitialized && _firestore != null) {
      try {
        final snapshot =
            await _firestore!.collection(collectionName).get();
        return snapshot.docs
            .map((doc) => Employee.fromMap(doc.data(), doc.id))
            .toList();
      } catch (_) {}
    }
    return List.unmodifiable(_localCache);
  }

  // ==================== FIRESTORE WRITES (CREATE / UPDATE / DELETE) ====================

  /// Create and store a new employee document in Cloud Firestore.
  Future<String> addEmployee(Employee employee) async {
    if (_isFirebaseInitialized && _firestore != null) {
      try {
        final docRef = await _firestore!
            .collection(collectionName)
            .add(employee.toFirestore());
        return docRef.id;
      } catch (_) {}
    }

    // Local cache creation
    final generatedId = 'doc_local_${DateTime.now().millisecondsSinceEpoch}';
    final savedEmployee = employee.copyWith(id: generatedId);
    _localCache.insert(0, savedEmployee);
    _localStreamController.add(List.unmodifiable(_localCache));
    return generatedId;
  }

  /// Delete an employee document from Cloud Firestore.
  Future<void> deleteEmployee(String docId) async {
    if (_isFirebaseInitialized && _firestore != null) {
      try {
        await _firestore!.collection(collectionName).doc(docId).delete();
        return;
      } catch (_) {}
    }

    _localCache.removeWhere((e) => e.id == docId);
    _localStreamController.add(List.unmodifiable(_localCache));
  }

  /// Seed sample employees into Cloud Firestore if collection is empty.
  Future<void> seedSampleData() async {
    _initDemoData();
    if (_isFirebaseInitialized && _firestore != null) {
      try {
        final count = (await _firestore!.collection(collectionName).get()).size;
        if (count == 0) {
          for (final emp in _localCache) {
            await _firestore!.collection(collectionName).add(emp.toFirestore());
          }
        }
      } catch (_) {}
    }
  }

  /// Check if employee ID already exists to prevent duplicates.
  Future<bool> employeeIdExists(String employeeId) async {
    if (_isFirebaseInitialized && _firestore != null) {
      try {
        final query = await _firestore!
            .collection(collectionName)
            .where('employeeId', isEqualTo: employeeId)
            .limit(1)
            .get();
        return query.docs.isNotEmpty;
      } catch (_) {}
    }

    return _localCache.any((e) => e.employeeId == employeeId);
  }
}

