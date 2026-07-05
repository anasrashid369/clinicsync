import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ClinicSyncApp());
}

class ClinicSyncApp extends StatelessWidget {
  const ClinicSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClinicSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      home: const ClinicSyncHomePage(),
    );
  }
}

class ClinicSyncHomePage extends StatefulWidget {
  const ClinicSyncHomePage({super.key});

  @override
  State<ClinicSyncHomePage> createState() => _ClinicSyncHomePageState();
}

class _ClinicSyncHomePageState extends State<ClinicSyncHomePage> {
  int _selectedIndex = 0;
  String _appointmentSearch = '';
  String _appointmentStatusFilter = 'All';
  String _queueSearch = '';
  String _queueStatusFilter = 'All';
  bool _isLoading = true;

  static const _appointmentsKey = 'clinic_sync_appointments';
  static const _queueKey = 'clinic_sync_queue';

  final List<Appointment> _appointments = [
    Appointment(
      patientName: 'Aisha Khan',
      time: '09:00',
      status: 'Confirmed',
      doctor: 'Dr. Rana',
    ),
    Appointment(
      patientName: 'Noor Ali',
      time: '10:30',
      status: 'Checked In',
      doctor: 'Dr. Malik',
    ),
    Appointment(
      patientName: 'Zainab Noor',
      time: '11:15',
      status: 'Pending',
      doctor: 'Dr. Amina',
    ),
  ];

  final List<QueuePatient> _queue = [
    QueuePatient(name: 'Salman H.', priority: 'Urgent', status: 'Waiting'),
    QueuePatient(name: 'Sara M.', priority: 'Normal', status: 'In Progress'),
    QueuePatient(name: 'Bilal A.', priority: 'Normal', status: 'Waiting'),
  ];

  static const _appointmentStatusOptions = [
    'All',
    'Pending',
    'Confirmed',
    'Checked In',
  ];
  static const _queueStatusOptions = [
    'All',
    'Waiting',
    'In Progress',
    'Completed',
  ];
  static const _priorityOptions = ['Urgent', 'Normal'];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final preferences = await SharedPreferences.getInstance();
    final appointmentJson = preferences.getString(_appointmentsKey);
    final queueJson = preferences.getString(_queueKey);

    if (appointmentJson != null) {
      final decoded = jsonDecode(appointmentJson) as List<dynamic>;
      _appointments
        ..clear()
        ..addAll(decoded.map((item) => Appointment.fromJson(item as Map<String, dynamic>)));
    }

    if (queueJson != null) {
      final decoded = jsonDecode(queueJson) as List<dynamic>;
      _queue
        ..clear()
        ..addAll(decoded.map((item) => QueuePatient.fromJson(item as Map<String, dynamic>)));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveAppointments() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_appointments.map((item) => item.toJson()).toList());
    await preferences.setString(_appointmentsKey, encoded);
  }

  Future<void> _saveQueue() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_queue.map((item) => item.toJson()).toList());
    await preferences.setString(_queueKey, encoded);
  }

  Future<void> _saveAllData() async {
    await Future.wait([_saveAppointments(), _saveQueue()]);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [_buildDashboard(), _buildAppointments(), _buildQueue()];

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle()),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'appointment') {
                _showAddOrEditAppointmentDialog();
              } else if (value == 'queue') {
                _showAddOrEditQueueDialog();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'appointment',
                child: Text('Add appointment'),
              ),
              PopupMenuItem(value: 'queue', child: Text('Add queue patient')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Queue',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedIndex == 2
            ? _showAddOrEditQueueDialog
            : _showAddOrEditAppointmentDialog,
        icon: const Icon(Icons.add),
        label: Text(_selectedIndex == 2 ? 'New queue' : 'New appointment'),
      ),
    );
  }

  String _appBarTitle() {
    switch (_selectedIndex) {
      case 1:
        return 'Appointments';
      case 2:
        return 'Queue';
      default:
        return 'ClinicSync';
    }
  }

  Widget _buildDashboard() {
    final checkedInCount = _appointments
        .where((item) => item.status == 'Checked In')
        .length;
    final waitingCount = _queue
        .where((item) => item.status == 'Waiting')
        .length;
    final completedQueueCount = _queue
        .where((item) => item.status == 'Completed')
        .length;
    final upcoming = _appointments.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today queue',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Monitor appointments and queue status in one place.'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _summaryCard(
                'Appointments',
                '${_appointments.length}',
                Icons.calendar_today_outlined,
              ),
              _summaryCard(
                'Checked In',
                '$checkedInCount',
                Icons.check_circle_outline,
              ),
              _summaryCard(
                'Waiting',
                '$waitingCount',
                Icons.hourglass_top_outlined,
              ),
              _summaryCard(
                'Completed',
                '$completedQueueCount',
                Icons.done_all_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Upcoming appointments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              FilledButton.tonal(
                onPressed: () => setState(() => _selectedIndex = 1),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (upcoming.isEmpty)
            const Text('No appointments scheduled yet.')
          else
            ...upcoming.map(
              (appointment) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.patientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${appointment.time} • ${appointment.doctor}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      _statusChip(appointment.status),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'Clinic highlights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Staff tip',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Use the queue screen to keep consultation rooms occupied and reduce patient wait time.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointments() {
    final filtered = _appointments.where((appointment) {
      final searchMatch =
          appointment.patientName.toLowerCase().contains(
            _appointmentSearch.toLowerCase(),
          ) ||
          appointment.doctor.toLowerCase().contains(
            _appointmentSearch.toLowerCase(),
          );
      final statusMatch =
          _appointmentStatusFilter == 'All' ||
          appointment.status == _appointmentStatusFilter;
      return searchMatch && statusMatch;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search appointments',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) =>
                    setState(() => _appointmentSearch = value),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _appointmentStatusOptions.map((status) {
                    final selected = status == _appointmentStatusFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _appointmentStatusFilter = status),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No matching appointments found.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final appointment = filtered[index];
                    final originalIndex = _appointments.indexOf(appointment);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    appointment.patientName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _statusChip(appointment.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${appointment.time} • ${appointment.doctor}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      _showAddOrEditAppointmentDialog(
                                        appointment: appointment,
                                      ),
                                  child: const Text('Edit'),
                                ),
                                TextButton(
                                  onPressed: () => _showConfirmDelete(
                                    title: 'Delete appointment',
                                    message:
                                        'Remove this appointment from the schedule?',
                                    onConfirm: () {
                                      setState(() {
                                        _appointments.removeAt(originalIndex);
                                      });
                                    },
                                  ),
                                  child: const Text('Delete'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () =>
                                      _advanceAppointmentStatus(originalIndex),
                                  child: const Text('Advance'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQueue() {
    final filtered = _queue.where((patient) {
      final searchMatch = patient.name.toLowerCase().contains(
        _queueSearch.toLowerCase(),
      );
      final statusMatch =
          _queueStatusFilter == 'All' || patient.status == _queueStatusFilter;
      return searchMatch && statusMatch;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search queue',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _queueSearch = value),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _queueStatusOptions.map((status) {
                    final selected = status == _queueStatusFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _queueStatusFilter = status),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No patients currently in queue.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final patient = filtered[index];
                    final originalIndex = _queue.indexOf(patient);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(patient.name),
                        subtitle: Text(
                          '${patient.priority} priority • ${patient.status}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddOrEditQueueDialog(patient: patient);
                            } else if (value == 'delete') {
                              _showConfirmDelete(
                                title: 'Remove from queue',
                                message: 'Delete this patient from the queue?',
                                onConfirm: () {
                                  setState(() {
                                    _queue.removeAt(originalIndex);
                                  });
                                },
                              );
                            } else if (value == 'next') {
                              _advanceQueueStatus(originalIndex);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'next',
                              child: Text('Advance status'),
                            ),
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status) {
      'Pending' => Colors.orange,
      'Confirmed' => Colors.blue,
      'Checked In' => Colors.green,
      'Waiting' => Colors.orange,
      'In Progress' => Colors.blue,
      'Completed' => Colors.green,
      _ => Colors.grey,
    };
    return Chip(
      backgroundColor: color.withOpacity(0.14),
      label: Text(status, style: TextStyle(color: color)),
    );
  }

  void _advanceAppointmentStatus(int index) {
    setState(() {
      final current = _appointments[index].status;
      _appointments[index].status = current == 'Pending'
          ? 'Confirmed'
          : current == 'Confirmed'
          ? 'Checked In'
          : 'Checked In';
    });
  }

  void _advanceQueueStatus(int index) {
    setState(() {
      final current = _queue[index].status;
      _queue[index].status = current == 'Waiting'
          ? 'In Progress'
          : current == 'In Progress'
          ? 'Completed'
          : 'Completed';
    });
  }

  Future<void> _showAddOrEditAppointmentDialog({
    Appointment? appointment,
  }) async {
    final nameController = TextEditingController(
      text: appointment?.patientName ?? '',
    );
    final doctorController = TextEditingController(
      text: appointment?.doctor ?? '',
    );
    final timeController = TextEditingController(text: appointment?.time ?? '');
    var status = appointment?.status ?? 'Confirmed';
    final isEditing = appointment != null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit appointment' : 'New appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Patient name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: doctorController,
                decoration: const InputDecoration(labelText: 'Doctor'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(
                    value: 'Confirmed',
                    child: Text('Confirmed'),
                  ),
                  DropdownMenuItem(
                    value: 'Checked In',
                    child: Text('Checked In'),
                  ),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                ],
                onChanged: (value) => status = value ?? 'Confirmed',
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                setState(() {
                  if (isEditing) {
                    appointment!.patientName = name;
                    appointment.doctor = doctorController.text.trim().isEmpty
                        ? appointment.doctor
                        : doctorController.text.trim();
                    appointment.time = timeController.text.trim().isEmpty
                        ? appointment.time
                        : timeController.text.trim();
                    appointment.status = status;
                  } else {
                    _appointments.add(
                      Appointment(
                        patientName: name,
                        time: timeController.text.trim().isEmpty
                            ? 'TBD'
                            : timeController.text.trim(),
                        status: status,
                        doctor: doctorController.text.trim().isEmpty
                            ? 'Assigned doctor'
                            : doctorController.text.trim(),
                      ),
                    );
                  }
                });
                Navigator.of(dialogContext).pop();
              },
              child: Text(isEditing ? 'Save' : 'Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddOrEditQueueDialog({QueuePatient? patient}) async {
    final nameController = TextEditingController(text: patient?.name ?? '');
    var priority = patient?.priority ?? 'Normal';
    final isEditing = patient != null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit queue patient' : 'Add queue patient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Patient name'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: priority,
                items: _priorityOptions.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) => priority = value ?? 'Normal',
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                setState(() {
                  if (isEditing) {
                    patient!.name = name;
                    patient.priority = priority;
                  } else {
                    _queue.add(
                      QueuePatient(
                        name: name,
                        priority: priority,
                        status: 'Waiting',
                      ),
                    );
                  }
                });
                Navigator.of(dialogContext).pop();
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmDelete({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                onConfirm();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

class Appointment {
  Appointment({
    required this.patientName,
    required this.time,
    required this.status,
    required this.doctor,
  });

  Appointment.fromJson(Map<String, dynamic> json)
      : patientName = json['patientName'] as String,
        time = json['time'] as String,
        status = json['status'] as String,
        doctor = json['doctor'] as String;

  Map<String, dynamic> toJson() {
    return {
      'patientName': patientName,
      'time': time,
      'status': status,
      'doctor': doctor,
    };
  }

  String patientName;
  String time;
  String status;
  String doctor;
}

class QueuePatient {
  QueuePatient({
    required this.name,
    required this.priority,
    required this.status,
  });

  QueuePatient.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        priority = json['priority'] as String,
        status = json['status'] as String;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'priority': priority,
      'status': status,
    };
  }

  String name;
  String priority;
  String status;
}
