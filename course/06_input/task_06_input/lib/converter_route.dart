// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'unit.dart';

const _padding = EdgeInsets.all(16.0);

/// [ConverterRoute] where users can input amounts to convert in one [Unit]
/// and retrieve the conversion in another [Unit] for a specific [Category].
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
class ConverterRoute extends StatefulWidget {
  /// This [Category]'s name.
  final String name;

  /// Color for this [Category].
  final Color color;

  /// Units for this [Category].
  final List<Unit> units;

  /// This [ConverterRoute] requires the name, color, and units to not be null.
  const ConverterRoute({
    @required this.name,
    @required this.color,
    @required this.units,
  })  : assert(name != null),
        assert(color != null),
        assert(units != null);

  @override
  _ConverterRouteState createState() => _ConverterRouteState();
}

class _ConverterRouteState extends State<ConverterRoute> {
  // value and units
  Unit _fromUnit;
  Unit _toUnit;
  double _inputValue;
  String _convertedValue = "";
  List<DropdownMenuItem> _unitMenuItems;
  bool _showValidationError = false;

  // Determine whether you need to override anything, such as initState()
  @override
  void initState() {
    super.initState();
    _createDropDownItems();
    _setDefaults();
  }

  void _createDropDownItems() {
    var newItems = <DropdownMenuItem>[];
    for (var unit in widget.units) {
      newItems.add(
          DropdownMenuItem(
            value: unit.name,
            child: Container(
              child: Text(
                unit.name,
                softWrap: true,
              ),
            ),
          )
      );
    }
    setState(() {
      _unitMenuItems = newItems;
    });
  }

  void _setDefaults() {
    setState(() {
      _fromUnit = widget.units[0];
      _toUnit = widget.units[1];
    });
  }

  void _updateConversion() {
    setState(() {
      _convertedValue =
          _format(_inputValue * (_toUnit.conversion / _fromUnit.conversion));
    });
  }

  /// Clean up conversion; trim trailing zeros, e.g. 5.500 -> 5.5, 10.0 -> 10
  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7);
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  void _updateInputValue(String input) {
    setState(() {
      if (input == null || input.isEmpty) {
        _convertedValue = '';
        _inputValue = null;
      } else {
        // Even though we are using the numerical keyboard, we still have to check
        // for non-numerical input such as '5..0' or '6 -3'
        try {
          final inputDouble = double.parse(input);
          _showValidationError = false;
          _inputValue = inputDouble;
          _updateConversion();
        } on Exception catch (e) {
          print('Error: $e');
          _showValidationError = true;
        }
      }
    });
  }

  Unit _getUnit(String unitName) {
    return widget.units.firstWhere(
          (Unit unit) {
        return unit.name == unitName;
      },
      orElse: null,
    );
  }

  void _updateFromConversion(dynamic unitName) {
    setState(() {
      _fromUnit = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  void _updateToConversion(dynamic unitName) {
    setState(() {
      _toUnit = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

    Widget _createDropDown(String currentValue,
        ValueChanged<dynamic> onChanged) {
      return Container(
        margin: EdgeInsets.only(top: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(
            color: Colors.grey[500],
            width: 1.0,
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Theme(
          data: Theme.of(context).copyWith(
              canvasColor: Colors.grey[50]
          ),
          child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  value: currentValue,
                  items: _unitMenuItems,
                  onChanged: onChanged,
                  style: Theme
                      .of(context)
                      .textTheme
                      .title,
                ),
              )
          ),
        ),
      );
    }


    @override
    Widget build(BuildContext context) {
      final input = Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              style: Theme
                  .of(context)
                  .textTheme
                  .display1,
              decoration: InputDecoration(
                  errorText: _showValidationError
                      ? 'Invalid number entered'
                      : null,
                  labelText: 'Input',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0)
                  )
              ),
              keyboardType: TextInputType.number,
              onChanged: _updateInputValue,
            ),
            _createDropDown(_fromUnit.name, _updateFromConversion)
          ],
        ),
      );

      final arrows = RotatedBox(
        quarterTurns: 1,
        child: Icon(
          Icons.compare_arrows,
          size: 40.0,
        ),
      );

      final output = Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputDecorator(
              child: Text(
                _convertedValue,
                style: Theme
                    .of(context)
                    .textTheme
                    .display1,
              ),
              decoration: InputDecoration(
                labelText: 'Output',
                labelStyle: Theme
                    .of(context)
                    .textTheme
                    .display1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
            ),
            _createDropDown(_toUnit.name, _updateToConversion),
          ],
        ),
      );

      final converter = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          input,
          arrows,
          output
        ],
      );

      return Padding(
        padding: _padding,
        child: converter,
      );
    }
  }

