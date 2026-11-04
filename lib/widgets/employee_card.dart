import 'package:flutter/material.dart';
import '../models/employee.dart';

/// Reusable card widget representing an employee document fetched from Firestore.
class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onTap,
    required this.onDelete,
  });

  Color _getDepartmentColor(String dept) {
    switch (dept) {
      case 'Engineering':
        return Colors.blue[700]!;
      case 'Cloud Infrastructure':
        return Colors.purple[700]!;
      case 'Product & Design':
        return Colors.teal[700]!;
      case 'Human Resources':
        return Colors.orange[800]!;
      case 'Finance':
        return Colors.green[700]!;
      default:
        return Colors.indigo[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deptColor = _getDepartmentColor(employee.department);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: ID badge + Department Chip + Delete Button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      employee.employeeId,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: deptColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      employee.department,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: deptColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey[500]),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Delete Firestore Document',
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Employee Name & Designation
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: deptColor.withValues(alpha: 0.15),
                    child: Text(
                      _getInitials(employee.name),
                      style: TextStyle(
                        color: deptColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          employee.designation,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Bottom Details Row: Email and Salary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.email_outlined, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            employee.email,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${employee.salary.toStringAsFixed(0)}/yr',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'EM';
  }
}

