import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<DeviceInfo> _devices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _addCurrentDevice();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final devicesJson = prefs.getStringList('saved_devices') ?? [];
    
    setState(() {
      _devices = devicesJson.map((json) {
        final parts = json.split('|');
        if (parts.length >= 3) {
          return DeviceInfo(
            name: parts[0],
            model: parts[1],
            addedDate: DateTime.tryParse(parts[2]) ?? DateTime.now(),
            isCurrent: parts.length > 3 && parts[3] == 'true',
          );
        }
        return DeviceInfo(
          name: 'Unknown Device',
          model: 'Unknown',
          addedDate: DateTime.now(),
        );
      }).toList();
      _isLoading = false;
    });
  }

  Future<void> _addCurrentDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('current_device_id');
    
    if (deviceId == null) {
      // Generate device ID
      final newDeviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('current_device_id', newDeviceId);
      
      // Add current device
      final currentDevice = DeviceInfo(
        name: Platform.isAndroid ? 'Android Device' : 'iOS Device',
        model: '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
        addedDate: DateTime.now(),
        isCurrent: true,
      );
      
      final devicesJson = prefs.getStringList('saved_devices') ?? [];
      devicesJson.add('${currentDevice.name}|${currentDevice.model}|${currentDevice.addedDate.toIso8601String()}|true');
      await prefs.setStringList('saved_devices', devicesJson);
      
      _loadDevices();
    }
  }

  Future<void> _removeDevice(DeviceInfo device) async {
    if (device.isCurrent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot remove current device'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final devicesJson = prefs.getStringList('saved_devices') ?? [];
    devicesJson.removeWhere((json) {
      final parts = json.split('|');
      return parts.length >= 3 && parts[0] == device.name && parts[1] == device.model;
    });
    await prefs.setStringList('saved_devices', devicesJson);
    _loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Devices',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_android, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No devices found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    return _buildDeviceCard(_devices[index]);
                  },
                ),
    );
  }

  Widget _buildDeviceCard(DeviceInfo device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: device.isCurrent ? Colors.lightGreen : Colors.grey.shade200,
          width: device.isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.lightGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.phone_android,
            color: Colors.lightGreen,
            size: 28,
          ),
        ),
        title: Text(
          device.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: device.isCurrent ? Colors.lightGreen : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(device.model),
            const SizedBox(height: 4),
            Text(
              'Added: ${_formatDate(device.addedDate)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (device.isCurrent)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.lightGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Current Device',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.lightGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: device.isCurrent
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeDevice(device),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class DeviceInfo {
  final String name;
  final String model;
  final DateTime addedDate;
  final bool isCurrent;

  DeviceInfo({
    required this.name,
    required this.model,
    required this.addedDate,
    this.isCurrent = false,
  });
}

