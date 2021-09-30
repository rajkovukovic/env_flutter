import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:env_flutter/env_flutter.dart';

Future main() async {
  await dotenv.load(fileNames: [
    "assets/.env"
  ], mergeWith: {
    'TEST_VAR': '5',
  }); // mergeWith optional, you can include Platform.environment for Mobile/Desktop app

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
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
                  children: [
                    Text(
                      'Env map: ${dotenv.env.toString()}',
                    ),
                    Divider(thickness: 5),
                    Text('Original'),
                    Divider(),
                    Text(snapshot.data ?? ''),
                    Text(dotenv.get('MISSING',
                        fallback: 'Default fallback value')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
