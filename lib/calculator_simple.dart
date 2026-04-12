import 'package:flutter/material.dart';
import 'colors.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _equation = '';
  bool _shouldStartNewInput = false;

  // ================= BUTTON HANDLER =================
  void onBtnTap(String value) {
    setState(() {
      if ('0123456789'.contains(value)) {
        _handleNumber(value);
      } else if (['+', '-', '×', '÷'].contains(value)) {
        _handleOperation(value);
      } else if (value == '=') {
        _calculateResult();
      } else if (value == 'C') {
        _clearAll();
      } else if (value == '.') {
        _addDecimal();
      } else if (value == '+/-') {
        _toggleSign();
      } else if (value == '%') {
        _percent();
      } else if (value == '( )') {
        _handleBracket();
      }
    });
  }

  // ================= INPUT =================

  void _handleNumber(String value) {
    if (_display == '0' || _shouldStartNewInput) {
      _display = value;
      _shouldStartNewInput = false;
    } else {
      if (_display.length < 15) {
        _display += value;
      }
    }

    _equation += value;
    _previewResult();
  }

  void _handleOperation(String op) {
    if (_equation.isEmpty) return;

    _equation += ' $op ';
    _shouldStartNewInput = true;
  }

  void _handleBracket() {
    int open = '('.allMatches(_equation).length;
    int close = ')'.allMatches(_equation).length;

    if (_equation.isEmpty ||
        _equation.endsWith('(') ||
        _isOperator(_equation)) {
      _equation += '(';
    } else if (open > close) {
      _equation += ')';
    } else {
      _equation += '×(';
    }
  }

  void _addDecimal() {
    if (!_display.contains('.')) {
      if (_shouldStartNewInput) {
        _display = '0.';
        _shouldStartNewInput = false;
        _equation += '0.';
      } else {
        _display += '.';
        _equation += '.';
      }
    }
  }

  void _toggleSign() {
    if (_display == '0') return;

    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else {
      _display = '-$_display';
    }

    _equation = _display;
  }

  void _percent() {
    double val = double.tryParse(_display) ?? 0;
    val = val / 100;

    _display = val.toString();
    _equation = _display;
  }

  void _clearAll() {
    _display = '0';
    _equation = '';
    _shouldStartNewInput = false;
  }

  // ================= CALCULATE =================

  void _calculateResult() {
    try {
      double result = _evaluate(_equation);
      _display = _format(result);
      _equation = '';
      _shouldStartNewInput = true;
    } catch (e) {
      _display = 'Error';
      _equation = '';
    }
  }

  void _previewResult() {
    try {
      double result = _evaluate(_equation);
      _display = _format(result);
    } catch (_) {}
  }

  // ================= PARSER =================

  double _evaluate(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');

    List<double> nums = [];
    List<String> ops = [];

    int i = 0;

    while (i < expr.length) {
      if (expr[i] == ' ') {
        i++;
        continue;
      }

      // number
      if (RegExp(r'[0-9.]').hasMatch(expr[i])) {
        String num = '';
        while (i < expr.length &&
            RegExp(r'[0-9.]').hasMatch(expr[i])) {
          num += expr[i++];
        }
        nums.add(double.parse(num));
        continue;
      }

      // (
      if (expr[i] == '(') {
        ops.add('(');
      }

      // )
      else if (expr[i] == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          _calc(nums, ops);
        }
        ops.removeLast();
      }

      // operator
      else {
        String op = expr[i];

        while (ops.isNotEmpty &&
            _priority(ops.last) >= _priority(op)) {
          _calc(nums, ops);
        }
        ops.add(op);
      }

      i++;
    }

    while (ops.isNotEmpty) {
      _calc(nums, ops);
    }

    return nums.last;
  }

  void _calc(List<double> nums, List<String> ops) {
    double b = nums.removeLast();
    double a = nums.removeLast();
    String op = ops.removeLast();

    switch (op) {
      case '+':
        nums.add(a + b);
        break;
      case '-':
        nums.add(a - b);
        break;
      case '*':
        nums.add(a * b);
        break;
      case '/':
        if (b == 0) throw Exception();
        nums.add(a / b);
        break;
    }
  }

  int _priority(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
  }

  bool _isOperator(String s) {
    if (s.isEmpty) return false;
    return ['+', '-', '×', '÷'].contains(s[s.length - 1]);
  }

  String _format(double value) {
    String s = value.toString();
    return s.endsWith('.0') ? s.replaceAll('.0', '') : s;
  }

  // ================= UI =================

  Widget _buildRow(List<String> labels, List<Color> colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (i) {
        return _btn(labels[i], colors[i]);
      }),
    );
  }

  Widget _btn(String text, Color color) {
    return GestureDetector(
      onTap: () => onBtnTap(text),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 35,
              child: Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_equation,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 22)),
                    const SizedBox(height: 10),
                    FittedBox(
                      child: Text(_display,
                          style: const TextStyle(
                              fontSize: 60, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 65,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRow(['C', '( )', '%', '÷'],
                        [AppColors.btnClear, AppColors.btnFunction, AppColors.btnFunction, AppColors.btnCalculations]),
                    _buildRow(['7', '8', '9', '×'],
                        [AppColors.btnNumber, AppColors.btnNumber, AppColors.btnNumber, AppColors.btnCalculations]),
                    _buildRow(['4', '5', '6', '-'],
                        [AppColors.btnNumber, AppColors.btnNumber, AppColors.btnNumber, AppColors.btnCalculations]),
                    _buildRow(['1', '2', '3', '+'],
                        [AppColors.btnNumber, AppColors.btnNumber, AppColors.btnNumber, AppColors.btnCalculations]),
                    _buildRow(['+/-', '0', '.', '='],
                        [AppColors.btnNumber, AppColors.btnNumber, AppColors.btnNumber, AppColors.btnEqual]),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}