import 'package:env_flutter/env_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future main() async {
  await dotenv.load(
    fileNames: [
      'assets/.env',
      'assets/.env.production',
      'assets/.env.production.europe-stage',
    ],
    mergeWith: {
      'TEST_VAR': '5',
    },
  ); // mergeWith optional, you can include Platform.environment for Mobile/Desktop app

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override

  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dotenv Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dotenv Demo'),
        ),
        body: SingleChildScrollView(
          child: FutureBuilder<String>(
            future: rootBundle.loadString('assets/.env'),
            initialData: '',
            builder: (context, snapshot) => Container(
              padding: EdgeInsets.all(50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Env map:'),
                  Divider(thickness: 1),
                  _buildEnvEntries(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ignore: prefer_expression_function_bodies
  Widget _buildEnvEntries() {
    return Column(
      children: dotenv.env.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    child: Text('${entry.key} = '),
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    color: Colors.amberAccent,
                    child: Text(entry.value),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
