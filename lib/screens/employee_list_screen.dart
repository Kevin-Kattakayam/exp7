import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/firestore_service.dart';
import '../widgets/employee_card.dart';
import '../widgets/employee_details_sheet.dart';
import '../widgets/firestore_status_banner.dart';
import 'add_employee_screen.dart';

/// Main screen displaying employee records RETRIEVED in real-time from Google Cloud Firestore.
class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedDepartment = 'All';

  final List<String> _departmentFilters = [
    'All',
    'Engineering',
    'Cloud Infrastructure',
    'Product & Design',
    'Human Resources',
    'Finance',
    'Sales & Marketing',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddEmployee() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
    );
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete from Firestore?'),
        content: Text(
          'Are you sure you want to delete "${employee.name}" (${employee.employeeId}) from Cloud Firestore?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && employee.id != null) {
      await FirestoreService.instance.deleteEmployee(employee.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${employee.name}" from Firestore'),
            backgroundColor: Colors.grey[800],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  List<Employee> _filterByQuery(List<Employee> employees) {
    if (_searchQuery.trim().isEmpty) return employees;
    final q = _searchQuery.toLowerCase();
    return employees.where((emp) {
      return emp.name.toLowerCase().contains(q) ||
          emp.employeeId.toLowerCase().contains(q) ||
          emp.designation.toLowerCase().contains(q) ||
          emp.department.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.cloud_circle_rounded, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              'Firestore HR Directory',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.deepOrange[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined),
            tooltip: 'Seed Firestore Data',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await FirestoreService.instance.seedSampleData();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Sample documents seeded to Cloud Firestore!'),
                  backgroundColor: Colors.deepOrange,
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Employee>>(
        stream: FirestoreService.instance.getEmployeesStream(
          departmentFilter: _selectedDepartment,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            );
          }

          final allEmployees = snapshot.data ?? [];
          final filteredEmployees = _filterByQuery(allEmployees);

          return Column(
            children: [
              // Cloud Status Banner
              FirestoreStatusBanner(
                isOnlineSync: FirestoreService.instance.isFirebaseInitialized,
                recordCount: allEmployees.length,
              ),

              // Search Box
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by Name, Role, or EMP ID...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.deepOrange[300]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400]),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              // Department Horizontal Filter Chips
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: _departmentFilters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final dept = _departmentFilters[index];
                    final isSelected = _selectedDepartment == dept;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDepartment = dept;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.deepOrange[700]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepOrange[700]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          dept,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color:
                                isSelected ? Colors.white : Colors.grey[800],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Results count header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Realtime Firestore Documents',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${filteredEmployees.length} of ${allEmployees.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepOrange[800],
                      ),
                    ),
                  ],
                ),
              ),

              // List of Employee Cards
              Expanded(
                child: filteredEmployees.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final emp = filteredEmployees[index];
                          return EmployeeCard(
                            employee: emp,
                            onTap: () =>
                                EmployeeDetailsSheet.show(context, emp),
                            onDelete: () => _deleteEmployee(emp),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddEmployee,
        backgroundColor: Colors.deepOrange[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text(
          'Add Employee',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Employee Documents in Firestore',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add employee documents using the form or click Seed Firestore Data to populate sample records.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => FirestoreService.instance.seedSampleData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange[700],
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.cloud_download),
              label: const Text('Seed Firestore Documents'),
            ),
          ],
        ),
      ),
    );
  }
}
