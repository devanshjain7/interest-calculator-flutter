import 'package:flutter/material.dart';
import'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interest Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.ubuntuTextTheme(
          Theme.of(context).textTheme,
        )
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Interest Calculator',
            style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(child: HomePage(),)
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  num selectedPrincipal;
  num selectedRate;
  bool toggle = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _pField = TextEditingController();
  TextEditingController _rField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('From:',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            Text(
              '${fromDate.day}-${fromDate.month}-${fromDate.year}',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            _buildRaisedButton('Change Lending Date', datePicker1),
            SizedBox(height: 20,),
            Text('To:',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            Text(
              '${toDate.day}-${toDate.month}-${toDate.year}',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            _buildRaisedButton('Change Repayment Date', datePicker2),
            SizedBox(height: 30,),
            _buildTextField('Enter Principal Balance', 'Principal'),
            SizedBox(height: 30,),
            _buildTextField('Enter Rate of Interest', 'Rate'),
            SizedBox(height: 15,),
            Row(
              children: [
                Text('Change Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
                ),
                Spacer(),
                Switch(
                  value: toggle, 
                  onChanged: (value) {
                    setState(() {
                      toggle = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20,),
            _buildRaisedButton('Get Amount', _displayAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, String setFor) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: setFor == 'Principal' ? _pField : _rField,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r"\d+([\.]\d+)?"))
      ],
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: labelText,
      ),
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      validator: (value) {
        if (setFor == 'Principal') {
          if (_pField.text.isEmpty) {
            return 'Please enter a value';
          }
        }
        else {
          if (_rField.text.isEmpty) {
            return 'Please enter a value';
          }
        }
        return null;
      },
    );
  }

  Widget _buildRaisedButton(String labelText, void doOnPressed()) {
    return SizedBox(
      height: 45,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Text(labelText,
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
        color: Colors.blue,
        onPressed: () {
          doOnPressed();
        },
      ),
    );
  }


  num getAmount(bool toggle) {

    num diffMonths;
    num rate = 0.01 * selectedRate;
    num amount;

    if (toggle == false) {
      // num lastDayMatch = fromDate.day;
      // DateTime toCompare = DateTime(toDate.year, toDate.month, lastDayMatch);
      // if (toDate.day < fromDate.day) {
      //   toCompare = DateTime(toDate.year, toDate.month - 1, lastDayMatch);
      // }
      // print(toCompare);
      Duration difference = toDate.difference(fromDate);
      diffMonths = difference.inDays ~/ 30 - 1;
      if (difference.inDays / 30 - difference.inDays ~/ 30 > 0.1) {
        diffMonths += 1;
      }
      print(difference.inDays);
      // num diffDays = toDate.difference(toCompare).inDays;
      


      if (diffMonths < 0) {
        diffMonths = 0;
      }

      num takeMon;

      if (diffMonths >= 12) {
        num int1 = selectedPrincipal * rate * 11;
        num p1 = selectedPrincipal + int1;
        diffMonths -= 11;

        while (diffMonths > 0) {
          if (diffMonths > 12) {
            takeMon = 12;
          }
          else {
            takeMon = diffMonths;
          }
          num int = p1 * rate * takeMon;
          p1 += int;
          diffMonths -= 12;
        }
        amount = p1;
      }
      else {
        num int3 = selectedPrincipal * rate * diffMonths;
        amount = selectedPrincipal + int3;
      }
    }

    else {
      num diffDays = toDate.difference(fromDate).inDays + 1;
      num diffYears = (diffDays ~/ 365);

      if (toDate.isBefore(DateTime(fromDate.year + diffYears, fromDate.month, fromDate.day))) {
        diffYears = max(0, diffYears - 1);
      }
      num int1;
      num p1 = selectedPrincipal;
      
      if (diffYears > 0) {
        diffDays = toDate.difference(DateTime(fromDate.year + diffYears, fromDate.month, fromDate.day)).inDays + 1;
      }

      while (diffYears > 0) {
        int1 = p1 * rate * (365/30);
        p1 += int1;
        diffYears -= 1;
      }

      num int3 = p1 * rate * (diffDays/30);
      amount = p1 + int3;
    }
    
    amount = amount.round();
    return amount;
  }

  void _displayAmount() {
    if (_formKey.currentState.validate()) {
      selectedPrincipal = double.parse(_pField.text);
      selectedRate = double.parse(_rField.text);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            final num amount = getAmount(toggle);

            return Scaffold(
              appBar: AppBar(
                title: Text('Total Amount to be paid'),
              ),
              body: Center(
                child: Text('Rs. $amount',
                  style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold),),
              ),
            );
          },
        ),
      );
    }
  }

  void datePicker1() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
      });
    }
  }
  void datePicker2() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: fromDate,
      lastDate: DateTime(toDate.year + 10),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
      });
    }
  }
}