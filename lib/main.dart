import 'package:flutter/material.dart';

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

  final List<Appointment> _appointments = [
    Appointment(patientName: 'Aisha Khan', time: '09:00', status: 'Confirmed', doctor: 'Dr. Rana'),
    Appointment(patientName: 'Noor Ali', time: '10:30', status: 'Checked In', doctor: 'Dr. Malik'),
    Appointment(patientName: 'Zainab Noor', time: '11:15', status: 'Pending', doctor: 'Dr. Amina'),
  ];

  final List<QueuePatient> _queue = [
    QueuePatient(name: 'Salman H.', priority: 'Urgent', status: 'Waiting'),
    QueuePatient(name: 'Sara M.', priority: 'Normal', status: 'In Progress'),
    QueuePatient(name: 'Bilal A.', priority: 'Normal', status: 'Waiting'),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      _buildAppointments(),
      _buildQueue(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClinicSync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new alerts')),
              );
            },
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.event_available_outlined), label: 'Appointments'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Queue'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today queue', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Keep clinic operations moving with a quick overview.'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _summaryCard('Appointments', '12', Icons.calendar_today_outlined),
              _summaryCard('Checked In', '7', Icons.check_circle_outline),
              _summaryCard('Waiting', '5', Icons.hourglass_top_outlined),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Upcoming appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._appointments.take(2).map(
            (appointment) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patientName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${appointment.time} - ${appointment.doctor}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(label: Text(appointment.status)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointments() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appointment.time} - ${appointment.doctor}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(label: Text(appointment.status)),
                    const SizedBox(height: 4),
                    Text(
                      appointment.status == 'Pending' ? 'Needs review' : 'Ready',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQueue() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _queue.length,
      itemBuilder: (context, index) {
        final patient = _queue[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(patient.name),
            subtitle: Text(patient.priority),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(label: Text(patient.status)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      final nextStatus = patient.status == 'Waiting' ? 'In Progress' : 'Completed';
                      _queue[index] = QueuePatient(
                        name: patient.name,
                        priority: patient.priority,
                        status: nextStatus,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
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
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

class Appointment {
  const Appointment({
    required this.patientName,
    required this.time,
    required this.status,
    required this.doctor,
  });

  final String patientName;
  final String time;
  final String status;
  final String doctor;
}

class QueuePatient {
  const QueuePatient({
    required this.name,
    required this.priority,
    required this.status,
  });

  final String name;
  final String priority;
  final String status;
}
