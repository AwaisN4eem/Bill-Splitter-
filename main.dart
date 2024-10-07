import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Splitter',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.purple,
          accentColor: Colors.amberAccent,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade100, Colors.amber.shade100],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bill Splitter',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BillSplitterPage(),
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'Get Started',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.purple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BillSplitterPage extends StatefulWidget {
  const BillSplitterPage({Key? key}) : super(key: key);

  @override
  _BillSplitterPageState createState() => _BillSplitterPageState();
}

class _BillSplitterPageState extends State<BillSplitterPage> {
  final TextEditingController _billController = TextEditingController();
  final List<Person> _people = [Person('Person 1', 100.0)];
  double _totalBill = 0.0;
  String _selectedCurrency = '\$';
  final List<String> _currencies = ['\$', '₨', '£'];

  void _addPerson() {
    if (_people.length < 10) {
      setState(() {
        _people.add(Person('Person ${_people.length + 1}', 0.0));
        _redistributePercentages();
      });
    }
  }

  void _removePerson(int index) {
    if (_people.length > 1) {
      setState(() {
        _people.removeAt(index);
        _redistributePercentages();
      });
    }
  }

  void _redistributePercentages() {
    double evenShare = 100.0 / _people.length;
    for (var person in _people) {
      person.percentage = evenShare;
    }
  }

  void _updatePercentage(int index, double newValue) {
    setState(() {
      double oldValue = _people[index].percentage;
      double difference = newValue - oldValue;
      _people[index].percentage = newValue;

      double remainingDifference = difference;
      for (int i = 0; i < _people.length; i++) {
        if (i != index) {
          double adjustment = remainingDifference / (_people.length - 1);
          _people[i].percentage -= adjustment;
          if (_people[i].percentage < 0) {
            remainingDifference += _people[i].percentage;
            _people[i].percentage = 0;
          } else {
            remainingDifference -= adjustment;
          }
        }
      }

      // Ensure total is exactly 100%
      double total = _people.fold(0, (sum, person) => sum + person.percentage);
      if (total != 100) {
        int lastNonZeroIndex = _people.lastIndexWhere((person) => person.percentage > 0);
        if (lastNonZeroIndex != -1) {
          _people[lastNonZeroIndex].percentage += 100 - total;
        }
      }
    });
  }

  String _formatCurrency(double amount) {
    return '$_selectedCurrency${amount.toStringAsFixed(2)}';
  }

  void _editPersonName(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = _people[index].name;
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: "Enter new name"),
            controller: TextEditingController(text: _people[index].name),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  _people[index].name = newName;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Splitter App'),
        actions: [
          DropdownButton<String>(
            value: _selectedCurrency,
            items: _currencies.map((String currency) {
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(currency, style: TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCurrency = newValue;
                });
              }
            },
            dropdownColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade100, Colors.amber.shade100],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _billController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Total Bill Amount',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _totalBill = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _people.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(_people[index].name, style: TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editPersonName(index),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _removePerson(index),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.purpleAccent,
                                inactiveTrackColor: Colors.purple.shade100,
                                thumbColor: Colors.amberAccent,
                              ),
                              child: Slider(
                                value: _people[index].percentage,
                                min: 0,
                                max: 100,
                                divisions: 100,
                                label: '${_people[index].percentage.toStringAsFixed(1)}%',
                                onChanged: (newValue) => _updatePercentage(index, newValue),
                              ),
                            ),
                            Text(
                              'Amount: ${_formatCurrency(_totalBill * _people[index].percentage / 100)}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addPerson,
                icon: Icon(Icons.person_add),
                label: const Text('Add Person'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Person {
  String name;
  double percentage;

  Person(this.name, this.percentage);
}