import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static Future<Map<String, dynamic>> checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();
    return {'current': info.version, 'latest': info.version, 'available': false};
  }

  static Future<void> showUpdateDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('تحديث متوفر'),
        content: const Text('هناك إصدار جديد من التطبيق متوفر'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('لاحقاً')),
          ElevatedButton(onPressed: () => Navigator.pop(c), child: const Text('تحديث')),
        ],
      ),
    );
  }
}
