import 'package:flutter/material.dart';

/// Informational banner displaying Google Cloud Firestore synchronization and offline persistence status.
class FirestoreStatusBanner extends StatelessWidget {
  final bool isOnlineSync;
  final int recordCount;

  const FirestoreStatusBanner({
    super.key,
    required this.isOnlineSync,
    required this.recordCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber[800]!,
            Colors.deepOrange[700]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_done_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Google Cloud Firestore',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'NoSQL Persistence',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Path: /employees • Realtime Sync & Offline Cache Enabled',
            style: TextStyle(
              color: Colors.orange[100],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  label: 'Cloud Documents',
                  value: '$recordCount records',
                  icon: Icons.description_outlined,
                ),
              ),
              Container(height: 30, width: 1, color: Colors.white24),
              Expanded(
                child: _buildMetric(
                  label: 'Persistence',
                  value: 'Local + Cloud Cache',
                  icon: Icons.storage_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.orange[100],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
