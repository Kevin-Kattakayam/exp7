import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/employee.dart';
import '../services/firestore_service.dart';

/// Form screen to CREATE and store employee records in Google Cloud Firestore.
class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _empIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _emailController = TextEditingController();
  final _salaryController = TextEditingController();

  String _selectedDepartment = 'Engineering';
  DateTime _joiningDate = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _departments = [
    'Engineering',
    'Cloud Infrastructure',
    'Product & Design',
    'Human Resources',
    'Finance',
    'Sales & Marketing',
  ];

  @override
  void dispose() {
    _empIdController.dispose();
    _nameController.dispose();
    _designationController.dispose();
    _emailController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  String get _formattedDate =>
      '${_joiningDate.year}-${_joiningDate.month.toString().padLeft(2, '0')}-${_joiningDate.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _joiningDate = picked;
      });
    }
  }

  Future<void> _submitToFirestore() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final empId = _empIdController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final exists = await FirestoreService.instance.employeeIdExists(empId);
      if (exists) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee ID "$empId" already exists in Firestore!'),
            backgroundColor: Colors.red[800],
          ),
        );
        return;
      }

      final employee = Employee(
        employeeId: empId,
        name: _nameController.text.trim(),
        department: _selectedDepartment,
        designation: _designationController.text.trim(),
        email: _emailController.text.trim(),
        salary: double.parse(_salaryController.text.trim()),
        joiningDate: _formattedDate,
      );

      final docId = await FirestoreService.instance.addEmployee(employee);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Employee stored in Cloud Firestore! (Doc: $docId)',
          ),
          backgroundColor: Colors.deepOrange[700],
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firestore write error: $e'),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee Record'),
        backgroundColor: Colors.deepOrange[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: Colors.deepOrange[800]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Store Document in Google Cloud Firestore (/employees)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Employee ID
              TextFormField(
                controller: _empIdController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Employee ID *',
                  hintText: 'e.g., EMP-2026-105',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter Employee ID';
                  }
                  if (val.trim().length < 4) {
                    return 'Employee ID must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Full Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'e.g., Alexander Hayes',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter employee name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Department Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedDepartment,
                decoration: InputDecoration(
                  labelText: 'Department *',
                  prefixIcon: const Icon(Icons.business_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _departments.map((dept) {
                  return DropdownMenuItem(value: dept, child: Text(dept));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDepartment = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Designation
              TextFormField(
                controller: _designationController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Designation / Role *',
                  hintText: 'e.g., Senior Systems Architect',
                  prefixIcon: const Icon(Icons.work_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter designation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address *',
                  hintText: 'e.g., alex.h@cloudcorp.io',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter email address';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(val.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Annual Salary
              TextFormField(
                controller: _salaryController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: 'Annual Salary (USD) *',
                  hintText: 'e.g., 125000',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter salary';
                  }
                  final num = double.tryParse(val.trim());
                  if (num == null || num <= 0) {
                    return 'Please enter a valid positive salary';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Joining Date Picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Joining',
                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _formattedDate,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitToFirestore,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_upload, color: Colors.white),
                label: Text(
                  _isSubmitting
                      ? 'Saving to Firestore...'
                      : 'Store in Cloud Firestore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

