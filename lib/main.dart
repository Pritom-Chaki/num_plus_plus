import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:num_plus_plus/src/widgets/math_box.dart';
import 'package:num_plus_plus/src/widgets/result.dart';
import 'package:num_plus_plus/src/widgets/matrix_button.dart';
import 'package:num_plus_plus/src/widgets/keyboard.dart';
import 'package:num_plus_plus/src/backend/math_model.dart';
import 'package:num_plus_plus/src/pages/setting_page.dart';
import 'package:num_plus_plus/src/pages/function_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return MultiProvider(
      providers: [
        Provider(create: (context) => MathBoxController()),
        ChangeNotifierProvider(create: (_) => SettingModel()),
        ChangeNotifierProxyProvider<SettingModel, MathModel>(
          create: (context) => MathModel(),
          update: (context, settings, model) => model!
            ..changeSetting(
                precision: settings.precision.toInt(),
                isRadMode: settings.isRadMode),
        ),
        ChangeNotifierProxyProvider<SettingModel, MatrixModel>(
          create: (context) => MatrixModel(),
          update: (context, settings, model) => model!
            ..changeSetting(
              precision: settings.precision.toInt(),
            ),
        ),
        Provider(create: (context) => FunctionModel()),
        ListenableProxyProvider<SettingModel, CalculationMode>(
          create: (context) => CalculationMode(Mode.Basic),
          update: (context, settings, model) {
            if (settings.loading.isCompleted) {
              switch (settings.initPage) {
                case 0:
                  if (model!.value == Mode.Matrix) {
                    model.value = Mode.Basic;
                  }
                  break;
                case 1:
                  model!.changeMode(Mode.Matrix);
                  break;
              }
            }
            return model!;
          },
          dispose: (context, value) => value.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'num++',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          canvasColor: Colors.white,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // final Server _server = Server();
  TabController? tabController;
  List tabs = ["Basic", "Matrix"];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    // _server.start();
  }

  @override
  void dispose() {
    // _server.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<CalculationMode>(context, listen: false);
    final mathBoxController =
        Provider.of<MathBoxController>(context, listen: false);
    final setting = Provider.of<SettingModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingPage()),
            );
          },
        ),
        title: FutureBuilder(
          future: setting.loading.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              tabController!.index = setting.initPage;
            }
            return TabBar(
              indicatorColor: Colors.blueAccent[400],
              indicatorPadding:
                  const EdgeInsets.symmetric(horizontal: -10, vertical: 5),
              controller: tabController,
              labelColor: Colors.black,
              indicator: BoxDecoration(
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              tabs: const <Widget>[
                Tab(text: 'Basic'),
                Tab(text: 'Matrix'),
                // Tab(text: 'Function'),
              ],
              onTap: (index) {
                setting.changeInitPage(index);
                switch (index) {
                  case 0:
                    if (mode.value == Mode.Matrix) {
                      mode.value = Mode.Basic;
                      mathBoxController.deleteAllExpression();
                    }
                    break;
                  case 1:
                    if (mode.value != Mode.Matrix) {
                      mode.value = Mode.Matrix;
                      mathBoxController.deleteAllExpression();
                      mathBoxController.addExpression('\\\\bmatrix');
                    }
                    break;
                  case 2:
                    if (mode.value == Mode.Function) {
                      mode.value = Mode.Function;
                      mathBoxController.deleteAllExpression();
                      // mathBoxController.addExpression('\\\\bmatrix');
                    }
                    break;
                  default:
                    throw 'Unknown type';
                }
              },
            );
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                MathBox(),
                const SlidComponent(),
              ],
            ),
          ),
          const MathKeyBoard(),
        ],
      ),
    );
  }
}

class SlidComponent extends StatelessWidget {
  const SlidComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Consumer<CalculationMode>(
          builder: (context, mathMode, _) {
            switch (mathMode.value) {
              case Mode.Basic:
                return const Result();
                break;
              case Mode.Matrix:
                return const MatrixButton();
                break;
              case Mode.Function:
                return ElevatedButton(
                  child: const Text('Analyze'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FunctionPage()),
                    );
                  },
                );
                break;
              default:
                throw 'Error';
            }
          },
        ),
        const SizedBox(height: 10.0),
        Consumer<CalculationMode>(
          builder: (context, mathMode, _) => mathMode.value != Mode.Matrix
              ? const ExpandKeyBoard()
              : const SizedBox(
                  height: 0.0,
                ),
        ),
      ],
    );
  }
}
