import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

void main() {
  runApp(ReminderApp());
}

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      home: ReminderScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  String? selectedDay;
  TimeOfDay? selectedTime;
  String? selectedActivity;
  Timer? timer;

  final List<String> days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  final List<String> activities = [
    'Wake up', 'Go to gym', 'Breakfast', 'Meetings',
    'Lunch', 'Quick nap', 'Go to library', 'Dinner', 'Go to sleep'
  ];

  final player = AudioPlayer();
  final cache = AudioCache(prefix: 'assets/');

  void startTimer() {
    timer?.cancel();
    DateTime now = DateTime.now();
    DateTime targetTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
    if (targetTime.isBefore(now)) {
      targetTime = targetTime.add(Duration(days: 1));
    }
    Duration diff = targetTime.difference(now);

    timer = Timer(diff, () async {
      await cache.play('reminder_sound.mp3');  // Play sound from assets

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Reminder"),
          content: Text("It's time for $selectedActivity!"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    });
  }

  Future<void> pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Select Day"),
              value: selectedDay,
              items: days.map((day) {
                return DropdownMenuItem(value: day, child: Text(day));
              }).toList(),
              onChanged: (value) => setState(() => selectedDay = value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickTime,
              child: Text(selectedTime == null
                  ? "Select Time"
                  : "Time: ${selectedTime!.format(context)}"),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Select Activity"),
              value: selectedActivity,
              items: activities.map((activity) {
                return DropdownMenuItem(value: activity, child: Text(activity));
              }).toList(),
              onChanged: (value) => setState(() => selectedActivity = value),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: (selectedDay != null && selectedTime != null && selectedActivity != null)
                  ? startTimer
                  : null,
              child: Text("Set Reminder"),
            ),
          ],
        ),
      ),
    );
  }
}
