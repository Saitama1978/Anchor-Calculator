import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const AnchorCalculatorApp());
}

class AnchorCalculatorApp extends StatelessWidget {
  const AnchorCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anchor Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey[900],
        scaffoldBackgroundColor: const Color(0xFF121B22),
        // Ginawang mas modern ang look ng mga Input Border
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal, width: 2.0),
          ),
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _depthController = TextEditingController();
  final _loaController = TextEditingController();
  final _shacklesController = TextEditingController(text: "7");

  double _totalChain = 0.0;
  double _turningCircle = 0.0;
  String _statusMessage = "";
  Color _statusColor = Colors.white;

  void _calculate() {
    double depth = double.tryParse(_depthController.text) ?? 0.0;
    double loa = double.tryParse(_loaController.text) ?? 0.0;
    double shackles = double.tryParse(_shacklesController.text) ?? 0.0;

    if (depth <= 0 || loa <= 0 || shackles <= 0) {
      setState(() {
        _statusMessage = "⚠️ Paki-kumpleto ang mga detalye.";
        _statusColor = Colors.orange;
        _totalChain = 0.0; // I-reset para hindi lumabas ang lumang kalkulasyon
      });
      return;
    }

    // 1 shackle = 27.5 meters (15 fathoms)
    double chainInMeters = shackles * 27.5;
    // Turning Circle Radius = Chain Length + LOA (Length Overall of ship)
    double radius = chainInMeters + loa;
    // Scope Ratio = Chain Length / Depth
    double scope = chainInMeters / depth;

    setState(() {
      _totalChain = chainInMeters;
      _turningCircle = radius;

      if (scope < 3) {
        _statusMessage = "⚠️ Masyadong maikli ang kadena! Scope Ratio: ${scope.toStringAsFixed(1)}";
        _statusColor = Colors.redAccent;
      } else if (scope >= 3 && scope <= 5) {
        _statusMessage = "✅ Ligtas para sa Good Weather. Scope Ratio: ${scope.toStringAsFixed(1)}";
        _statusColor = Colors.greenAccent;
      } else {
        _statusMessage = "🌊 Heavy Scope! Ligtas sa Rough Weather. Scope Ratio: ${scope.toStringAsFixed(1)}";
        _statusColor = Colors.blueAccent;
      }
    });
  }

  @override
  void dispose() {
    // Magandang habit ang i-dispose ang controllers para iwas memory leak
    _depthController.dispose();
    _loaController.dispose();
    _shacklesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚓ Anchor Turning Circle'),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _depthController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Water Depth (Meters)',
                  prefixIcon: Icon(Icons.waves),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _loaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Ship's LOA (Meters)",
                  prefixIcon: Icon(Icons.directions_boat),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _shacklesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Shackles to Let Go',
                  prefixIcon: Icon(Icons.link), // Pinalitan ng valid icon dahil walang Icons.chains sa standard flutter
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text('CALCULATE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 25),
              
              // Lalabas lang ang resulta o error kapag may mensahe na
              if (_statusMessage.isNotEmpty) ...[
                Card(
                  color: Colors.blueGrey[800],
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    // INAYOS: Mula sa 'with: Column' papuntang 'child: Column'
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_totalChain > 0) ...[
                          Text('Total Chain in Water: ${_totalChain.toStringAsFixed(1)} m', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Text('Turning Circle Radius: ${_turningCircle.toStringAsFixed(1)} m', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                        ],
                        Text(_statusMessage, style: TextStyle(fontSize: 14, color: _statusColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
