import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      themeMode: _themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),

      home: CalculatorPage(
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeChanged: (isDark) {
          setState(() {
            _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
          });
        },
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const CalculatorPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String display = '0';

  double? firstOperand;
  String? selectedOperator;

  bool waitingForSecondOperand = false;
  bool isError = false;
  bool justCalculated = false;

  void inputNumber(String number) {
    setState(() {
      if (isError || justCalculated) {
        display = number;
        firstOperand = null;
        selectedOperator = null;
        waitingForSecondOperand = false;
        isError = false;
        justCalculated = false;
        return;
      }

      if (display == '0' || waitingForSecondOperand) {
        display = number;
        waitingForSecondOperand = false;
      } else {
        display += number;
      }
    });
  }

  void selectOperator(String operator) {
    setState(() {
      if (isError) {
        return;
      }

      firstOperand = double.parse(display);
      selectedOperator = operator;
      waitingForSecondOperand = true;
      justCalculated = false;
    });
  }

  void calculate() {
    if (firstOperand == null ||
        selectedOperator == null ||
        waitingForSecondOperand) {
      setState(() {
        display = 'Incomplete calculation';
        isError = true;
      });

      return;
    }

    double secondOperand = double.parse(display);
    double result = 0;

    if (selectedOperator == '+') {
      result = firstOperand! + secondOperand;
    } else if (selectedOperator == '-') {
      result = firstOperand! - secondOperand;
    } else if (selectedOperator == '×') {
      result = firstOperand! * secondOperand;
    } else if (selectedOperator == '÷') {
      if (secondOperand == 0) {
        setState(() {
          display = 'Cannot divide by zero';
          isError = true;
        });

        return;
      }

      result = firstOperand! / secondOperand;
    }

    setState(() {
      if (result % 1 == 0) {
        display = result.toInt().toString();
      } else {
        display = result.toString();
      }

      firstOperand = null;
      selectedOperator = null;
      waitingForSecondOperand = false;
      isError = false;
      justCalculated = true;
    });
  }

  void clearCalculator() {
    setState(() {
      display = '0';
      firstOperand = null;
      selectedOperator = null;
      waitingForSecondOperand = false;
      isError = false;
      justCalculated = false;
    });
  }

  Widget calculatorButton(
    String text,
    VoidCallback onPressed, {
    int flex = 1,
    bool isOperator = false,
    bool isClear = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color foregroundColor;

    if (isClear) {
      backgroundColor = colorScheme.errorContainer;
      foregroundColor = colorScheme.onErrorContainer;
    } else if (isOperator) {
      bool isSelected =
          selectedOperator == text && waitingForSecondOperand;

      backgroundColor = isSelected
          ? colorScheme.primary
          : colorScheme.primaryContainer;

      foregroundColor = isSelected
          ? colorScheme.onPrimary
          : colorScheme.onPrimaryContainer;
    } else {
      backgroundColor = colorScheme.surfaceContainerHighest;
      foregroundColor = colorScheme.onSurface;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 72,
          child: ElevatedButton(
            onPressed: onPressed,

            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),

            child: Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buttonSpacer() {
    return const Expanded(
      child: SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    widget.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),

                  const SizedBox(width: 8),

                  Switch(
                    value: widget.isDarkMode,
                    onChanged: widget.onThemeChanged,
                  ),
                ],
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 24,
                  ),

                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,

                    child: Text(
                      display,
                      textAlign: TextAlign.right,

                      style: TextStyle(
                        fontSize: isError ? 32 : 64,
                        fontWeight: FontWeight.w400,
                        color: isError
                            ? colorScheme.error
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  calculatorButton(
                    'AC',
                    clearCalculator,
                    isClear: true,
                  ),

                  buttonSpacer(),
                  buttonSpacer(),

                  calculatorButton(
                    '÷',
                    () => selectOperator('÷'),
                    isOperator: true,
                  ),
                ],
              ),

              Row(
                children: [
                  calculatorButton(
                    '7',
                    () => inputNumber('7'),
                  ),

                  calculatorButton(
                    '8',
                    () => inputNumber('8'),
                  ),

                  calculatorButton(
                    '9',
                    () => inputNumber('9'),
                  ),

                  calculatorButton(
                    '×',
                    () => selectOperator('×'),
                    isOperator: true,
                  ),
                ],
              ),

              Row(
                children: [
                  calculatorButton(
                    '4',
                    () => inputNumber('4'),
                  ),

                  calculatorButton(
                    '5',
                    () => inputNumber('5'),
                  ),

                  calculatorButton(
                    '6',
                    () => inputNumber('6'),
                  ),

                  calculatorButton(
                    '-',
                    () => selectOperator('-'),
                    isOperator: true,
                  ),
                ],
              ),

              Row(
                children: [
                  calculatorButton(
                    '1',
                    () => inputNumber('1'),
                  ),

                  calculatorButton(
                    '2',
                    () => inputNumber('2'),
                  ),

                  calculatorButton(
                    '3',
                    () => inputNumber('3'),
                  ),

                  calculatorButton(
                    '+',
                    () => selectOperator('+'),
                    isOperator: true,
                  ),
                ],
              ),

              Row(
                children: [
                  calculatorButton(
                    '0',
                    () => inputNumber('0'),
                    flex: 3,
                  ),

                  calculatorButton(
                    '=',
                    calculate,
                    isOperator: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}