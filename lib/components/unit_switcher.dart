import 'package:flutter/material.dart';

class UnitSwitcher extends StatefulWidget {
  final String defaultUnit;
  final List<String> availableUnits;
  final Function(String selectedUnit) onUnitChange;

  const UnitSwitcher(
      {Key? key, this.defaultUnit = 'g', this.availableUnits = const ['mg', 'g', 'kg'], required this.onUnitChange})
      : super(key: key);

  @override
  State<UnitSwitcher> createState() => _UnitSwitcherState();
}

class _UnitSwitcherState extends State<UnitSwitcher> {
  String selectedUnit = 'g';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedUnit,
      elevation: 16,
      style: const TextStyle(color: Colors.blue),
      underline: Container(
        height: 2,
        color: Colors.blueAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          selectedUnit = newValue!;
          widget.onUnitChange(selectedUnit);
        });
      },
      items: widget.availableUnits.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
