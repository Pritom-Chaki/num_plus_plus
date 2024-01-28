import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:num_plus_plus/src/backend/math_model.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mathModel = Provider.of<MathModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,),
          onPressed: () {
            mathModel.calcNumber();
            Navigator.pop(context);
          },
        ),
        title: const Text('Setting',),
      ),
      body: ListView(
        itemExtent: 60.0,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        children: <Widget>[
          const ListTile(
            leading: Text(
              'Calc Setting',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Consumer<SettingModel>(
            builder: (context, setModel, _) => ListTile(
              title: ToggleButtons(
                constraints: const BoxConstraints(
                  minWidth: 100,
                  minHeight: 40,
                ),
                isSelected: [setModel.isRadMode, !setModel.isRadMode],
                onPressed: (index) {
                  setModel.changeRadMode((index==0)?true:false);
                },
                children: const <Widget>[
                   Text('RAD'),
                   Text('DEG'),
                ],
              ),
            ),
          ),
          Consumer<SettingModel>(
            builder: (context, setModel, _) => ListTile(
              title: const Text('Calc Precision'),
              subtitle: Slider(
                value: setModel.precision.toDouble(),
                min: 0.0,
                max: 10.0,
                label: "${setModel.precision.toInt()}",
                divisions: 10,
                onChanged: (val) {
                  setModel.changeSlider(val);
                },
              ),
              trailing: Text('${setModel.precision.toInt()}'),
            ),
          ),
          const Divider(),

        ],
      ),
    );
  }



}

class SettingModel with ChangeNotifier {
  num precision = 10;
  bool isRadMode = true;
  bool hideKeyboard = false;
  int initPage = 0;
  Completer loading = Completer();

  SettingModel() {
    initVal();
  }

  Future changeSlider(double val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    precision = val;
    prefs.setDouble('precision', double.parse(precision.toString()));
    notifyListeners();
  }

  Future changeRadMode(bool mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isRadMode = mode;
    prefs.setBool('isRadMode', isRadMode);
    notifyListeners();
  }

  Future changeKeyboardMode(bool mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hideKeyboard = mode;
    prefs.setBool('hideKeyboard', hideKeyboard);
  }

  Future changeInitPage(int val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    initPage = val;
    prefs.setInt('initPage', initPage);
  }

  Future initVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    precision = prefs.getDouble('precision') ?? 10;
    isRadMode = prefs.getBool('isRadMode') ?? true;
    hideKeyboard = prefs.getBool('hideKeyboard') ?? false;
    initPage = prefs.getInt('initPage') ?? 0;
    loading.complete();
    notifyListeners();
  }

}
