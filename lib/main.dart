import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_task/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController firstController = TextEditingController();
  final TextEditingController secondController = TextEditingController();
  final FocusNode firstFocusNode = FocusNode();
  final FocusNode secondFocusNode = FocusNode();
  FocusScopeNode? currentFocus;
  final List<Widget> results = [];
  final Map<String, bool> operationControl = {
    "Add": false,
    "Subtract": false,
    "Multiply": false,
    "Divide": false,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        unFocus(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                resultWindow,
                textFields,
                buttons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Main Widgets
  Widget get resultWindow {
    return Expanded(
      flex: 40,
      child: Container(
        decoration: BoxDecoration(
          color: fourthColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: results.isNotEmpty
              ? results
              : [
                  const Text(
                    'No action has been selected yet.',
                    style: primaryTextStyle,
                  ),
                ],
        ),
      ),
    );
  }

  Widget get textFields {
    return Expanded(
      flex: 25,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            textField(
              'First',
              firstFocusNode,
              firstController,
            ),
            textField(
              'Second',
              secondFocusNode,
              secondController,
            ),
          ],
        ),
      ),
    );
  }

  Widget buttons(BuildContext context) {
    return Expanded(
      flex: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            selectionButton(
              text: 'Add',
              icon: Icons.add,
            ),
            selectionButton(
              text: 'Subtract',
              icon: Icons.remove,
            ),
            selectionButton(
              text: 'Multiply',
              icon: Icons.close,
            ),
            selectionButton(
              text: 'Divide',
              icon: Icons.keyboard_arrow_up,
            ),
            bottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget bottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 15,
            child: bottomButton(
              text: 'Clear',
              onPressed: () {
                setState(() {
                  results.clear();
                });
              },
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 15,
            child: bottomButton(
              text: 'Calculate',
              onPressed: () {
                calculateAction(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  //Sub Widgets
  Widget textField(
    String text,
    FocusNode focusNode,
    TextEditingController controller,
  ) {
    return TextField(
      onTap: () {
        setState(() {});
      },
      onSubmitted: (_){
        if(!operationControl.containsValue(true)) {
          setState(() {
            operationControl['Add'] = true;
          });
        }
        calculateAction(context);
      },
      controller: controller,
      style: secondaryTextStyle,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: '$text Number',
        hintText: 'Enter..',
        labelStyle: TextStyle(
          color: focusNode.hasFocus ? firstColor : secondColor,
        ),
        enabledBorder: textFieldBorder(focusNode),
        hintStyle: secondaryTextStyle,
        focusedBorder: textFieldBorder(focusNode),
        contentPadding: const EdgeInsets.all(13),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.deny(
          RegExp(r",| |-|[a-zA-Z]"),
        ),
      ],
    );
  }

  Widget selectionButton({
    required String text,
    required IconData icon,
  }) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          operationControl.updateAll((key, value) {
            if (key != text) {
              return false;
            }
            return true;
          });
        });
        unFocus(context);
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: thirdColor,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                text,
                style: operationControl[text]!
                    ? tertiaryTextStyle
                    : secondaryTextStyle,
              ),
            ),
          ),
          operationControl[text]!
              ? const Icon(
                  Icons.task_alt_outlined,
                  color: thirdColor,
                )
              : const Icon(
                  Icons.circle_outlined,
                  color: thirdColor,
                ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: BorderSide(
          color: operationControl[text]! ? thirdColor : secondColor,
          width: 2.0,
        ),
      ),
    );
  }

  Widget bottomButton({
    required void Function() onPressed,
    required String text,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: tertiaryTextStyle,
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: fourthColor,
        padding: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  //Methods
  void calculateAction(BuildContext context) {
    double? first = double.tryParse(firstController.text);
    double? second = double.tryParse(secondController.text);
    if (firstController.text.isEmpty || secondController.text.isEmpty) {
      showErrorDialog(context, 'You have to fill into fields.');
    } else if (first == null || second == null) {
      showErrorDialog(context, 'Please enter a valid character...');
    } else {
      if (results.length == 5) {
        results.removeAt(0);
      }
      if (operationControl['Add']!) {
        addOperation(first, second);
      } else if (operationControl['Subtract']!) {
        subtractOperation(first, second);
      } else if (operationControl['Multiply']!) {
        multiplyOperation(first, second);
      } else if (operationControl['Divide']!) {
        divideOperation(first, second);
      }
      setState(() {
        firstController.clear();
        secondController.clear();
      });
    }
  }

  void addOperation(double first, double second) {
    double result = first + second;
    standardOperation(result);
  }

  void subtractOperation(double first, double second) {
    double result = first - second;
    standardOperation(result);
  }

  void multiplyOperation(double first, double second) {
    double result = first * second;
    standardOperation(result);
  }

  void divideOperation(double first, double second) {
    double result = first / second;
    standardOperation(result);
  }

  void standardOperation(double result) {
    String sResult = result.toString();
    if (sResult.split('.').last == '0') {
      sResult = sResult.split('.').first;
    }
    results.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Text(
          sResult,
          style: primaryTextStyle,
        ),
      ),
    );
  }

  void showErrorDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void unFocus(BuildContext context) {
    currentFocus = FocusScope.of(context);

    if (!currentFocus!.hasPrimaryFocus) {
      currentFocus!.unfocus();
    }
  }

  OutlineInputBorder textFieldBorder(FocusNode focusNode) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(
        color: focusNode.hasFocus ? firstColor : secondColor,
      ),
    );
  }
}
