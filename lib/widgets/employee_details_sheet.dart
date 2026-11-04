import 'package:flutter/material.dart';
import '../models/employee.dart';

/// Modal bottom sheet displaying detailed Firestore document properties.
class EmployeeDetailsSheet extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailsSheet({super.key, required this.employee});

  static void show(BuildContext context, Employee employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EmployeeDetailsSheet(employee: employee),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.orange[50],
                child: Icon(Icons.cloud_done, color: Colors.orange[800], size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${employee.designation} • ${employee.department}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),

          _buildDetailItem(
            icon: Icons.fingerprint,
            label: 'Employee ID',
            value: employee.employeeId,
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: Icons.alternate_email,
            label: 'Corporate Email',
            value: employee.email,
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: Icons.payments_outlined,
            label: 'Annual Compensation',
            value: '\$${employee.salary.toStringAsFixed(2)} USD',
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: Icons.calendar_today,
            label: 'Hire / Joining Date',
            value: employee.joiningDate,
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: Icons.data_object,
            label: 'Firestore Document Reference',
            value: '/employees/${employee.id ?? "auto-generated"}',
            isCode: true,
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isCode = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.orange[800]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: isCode ? 'monospace' : null,
                  color: isCode ? Colors.deepOrange[900] : Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

