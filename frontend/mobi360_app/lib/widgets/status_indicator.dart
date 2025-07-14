import 'package:flutter/material.dart';
import '../providers/app_state_provider.dart';

class StatusIndicator extends StatelessWidget {
  final ConnectionStatus status;

  const StatusIndicator({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case ConnectionStatus.online:
        statusColor = Colors.green;
        statusText = 'オンライン';
        statusIcon = Icons.cloud_done;
        break;
      case ConnectionStatus.offline:
        statusColor = Colors.red;
        statusText = 'オフライン';
        statusIcon = Icons.cloud_off;
        break;
      case ConnectionStatus.connecting:
        statusColor = Colors.orange;
        statusText = '接続中...';
        statusIcon = Icons.cloud_sync;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}