import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart'; // Import the sensors package
import 'dart:async';
import 'package:fl_chart/fl_chart.dart'; // For drawing charts

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  // Variables to hold sensor data
  List<double> _gyroscopeValues = [0.0, 0.0, 0.0];
  List<double> _accelerometerValues = [0.0, 0.0, 0.0];

  // Lists to store the last 20 sensor values for graph
  List<List<double>> _gyroscopeHistory = [];
  List<List<double>> _accelerometerHistory = [];
  final int _maxHistoryLength = 20; // Maximum values to save

  // Stream subscriptions for sensors
  StreamSubscription? _gyroSubscription;
  StreamSubscription? _accelerometerSubscription;

  // Variables to track alerts
  bool _alertShown = false;

  @override
  void initState() {
    super.initState();

    // Start listening to gyroscope sensor
    _gyroSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
        _updateGyroscopeHistory(_gyroscopeValues);
        _checkForAlert();
      });
    });

    // Start listening to accelerometer sensor
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        _updateAccelerometerHistory(_accelerometerValues);
        _checkForAlert();
      });
    });
  }

  // Update history of gyroscope data
  void _updateGyroscopeHistory(List<double> newValue) {
    if (_gyroscopeHistory.length >= _maxHistoryLength) {
      _gyroscopeHistory.removeAt(0); // Remove the oldest value
    }
    _gyroscopeHistory.add(newValue); // Add the new value
  }

  // Update history of accelerometer data
  void _updateAccelerometerHistory(List<double> newValue) {
    if (_accelerometerHistory.length >= _maxHistoryLength) {
      _accelerometerHistory.removeAt(0); // Remove the oldest value
    }
    _accelerometerHistory.add(newValue); // Add the new value
  }

  // Function to check for high movement on any two axes
  void _checkForAlert() {
    double gyroX = _gyroscopeValues[0].abs();
    double gyroY = _gyroscopeValues[1].abs();
    double accelX = _accelerometerValues[0].abs();
    double accelY = _accelerometerValues[1].abs();

    if ((gyroX > 2.5 && gyroY > 2.5) || (accelX > 10 && accelY > 10)) {
      // If high movement on two axes is detected, show alert
      if (!_alertShown) {
        _showAlert();
      }
    } else {
      _alertShown = false; // Reset alert flag when movement is back to normal
    }
  }

  // Function to show alert dialog
  void _showAlert() {
    _alertShown = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ALERT'),
          content: const Text('High movement detected on multiple axes!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _gyroSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Data Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Gyroscope Data (x, y, z)',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: LineChartWidget(
                dataHistory: _gyroscopeHistory,
                label: 'Gyroscope',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Accelerometer Data (x, y, z)',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: LineChartWidget(
                dataHistory: _accelerometerHistory,
                label: 'Accelerometer',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget to display real-time sensor data in a graph
class LineChartWidget extends StatelessWidget {
  final List<List<double>> dataHistory;
  final String label;

  const LineChartWidget({super.key, required this.dataHistory, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$label Latest Values: (${dataHistory.isNotEmpty ? dataHistory.last[0].toStringAsFixed(2) : '0.0'}, ${dataHistory.isNotEmpty ? dataHistory.last[1].toStringAsFixed(2) : '0.0'}, ${dataHistory.isNotEmpty ? dataHistory.last[2].toStringAsFixed(2) : '0.0'})',
          style: const TextStyle(fontSize: 16.0),
        ),
        Container(
          height: 150,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
          color: Colors.blue[100],
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: dataHistory.asMap().entries.map((entry) {
                    int index = entry.key;
                    List<double> value = entry.value;
                    return FlSpot(index.toDouble(), value[0]); // x-axis: index, y-axis: sensor value
                  }).toList(),
                  isCurved: true,
                  colors: [Colors.black],
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
