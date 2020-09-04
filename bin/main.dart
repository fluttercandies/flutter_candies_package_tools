import 'dart:io';

void main(List<String> arguments) {
  final String name = arguments.first;
  processRun(
    executable: 'flutter',
    arguments: 'create --template=package $name',
  );

  processRun(
    executable: 'flutter',
    arguments: 'create example',
    workingDirectory: './$name',
  );

  File('./$name/example/pubspec.yaml')
      .writeAsStringSync(exampleYaml.replaceAll('create_package', name));

  File('./$name/example/ff_annotation_route_commands')
    ..createSync()
    ..writeAsStringSync(ffRoute);

  File('./$name/example/lib/main.dart').writeAsStringSync(mainS);

  Directory('./$name/example/lib/pages/').createSync();
  Directory('./$name/example/lib/pages/simple').createSync();
  Directory('./$name/example/lib/pages/complex').createSync();
  Directory('./$name/example/assets').createSync();
  File(
    './$name/example/lib/pages/simple/demo1.dart',
  )
    ..createSync()
    ..writeAsStringSync(demo1);

  File(
    './$name/example/lib/pages/complex/demo2.dart',
  )
    ..createSync()
    ..writeAsStringSync(demo2);

  File(
    './$name/example/lib/pages/main_page.dart',
  )
    ..createSync()
    ..writeAsStringSync(mainPage.replaceAll('create_package', name));

  processRun(
    executable: 'flutter',
    arguments: 'packages get',
    workingDirectory: name,
  );

  processRun(
    executable: 'ff_route',
    workingDirectory: './$name/example/',
  );
}

void processRun({
  String executable,
  String arguments,
  bool runInShell = true,
  String workingDirectory,
}) {
  final ProcessResult result = Process.runSync(
    executable,
    arguments == null ? <String>[] : arguments.split(' '),
    runInShell: runInShell,
    workingDirectory: workingDirectory,
  );
  if (result.exitCode != 0) {
    throw Exception(result.stderr);
  }
  print('${result.stdout}\n');
}

const String exampleYaml = '''
name: example
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"
  flutter: ">=1.12.13"

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^0.1.2
  url_launcher: 5.3.0  
  http_client_helper: any  
  extended_image: any    
  like_button: any
  extended_sliver: ^1.0.1    
  create_package:
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  ff_annotation_route: any

flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true
  assets:
      - assets/
''';

const String ffRoute =
    '--route-constants --route-names --route-helper --no-is-initial-route';

const String mainS = '''
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'example_route.dart';
import 'example_route_helper.dart';
import 'example_routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'create_package demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.fluttercandiesMainpage,
      onGenerateRoute: (RouteSettings settings) {
        //when refresh web, route will as following
        //   /
        //   /fluttercandies:
        //   /fluttercandies:/
        //   /fluttercandies://mainpage
        if (kIsWeb && settings.name.startsWith('/')) {
          return onGenerateRouteHelper(
            settings.copyWith(name: settings.name.replaceFirst('/', '')),
            notFoundFallback:
                getRouteResult(name: Routes.fluttercandiesMainpage).widget,
          );
        }
        return onGenerateRouteHelper(settings,
            builder: (Widget child, RouteResult result) {
          if (settings.name == Routes.fluttercandiesMainpage ||
              settings.name == Routes.fluttercandiesDemogrouppage) {
            return child;
          }
          return CommonWidget(
            child: child,
            result: result,
          );
        });
      },
    );
  }
}

class CommonWidget extends StatelessWidget {
  const CommonWidget({
    this.child,
    this.result,
  });
  final Widget child;
  final RouteResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          result.routeName,
        ),
      ),
      body: child,
    );
  }
}
''';

const String mainPage = '''
import 'package:example/example_routes.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';
import '../example_route.dart';
import '../example_routes.dart' as example_routes;

@FFRoute(
  name: 'fluttercandies://mainpage',
  routeName: 'MainPage',
)
class MainPage extends StatelessWidget {
  MainPage() {
    final List<String> routeNames = <String>[];
    routeNames.addAll(example_routes.routeNames);
    routeNames.remove(Routes.fluttercandiesMainpage);
    routeNames.remove(Routes.fluttercandiesDemogrouppage);
    routesGroup.addAll(groupBy<DemoRouteResult, String>(
        routeNames
            .map<RouteResult>((String name) => getRouteResult(name: name))
            .where((RouteResult element) => element.exts != null)
            .map<DemoRouteResult>((RouteResult e) => DemoRouteResult(e))
            .toList()
              ..sort((DemoRouteResult a, DemoRouteResult b) =>
                  b.group.compareTo(a.group)),
        (DemoRouteResult x) => x.group));
  }
  final Map<String, List<DemoRouteResult>> routesGroup =
      <String, List<DemoRouteResult>>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('create_package'),
        actions: <Widget>[
          ButtonTheme(
            minWidth: 0.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: FlatButton(
              child: const Text(
                'Github',
                style: TextStyle(
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                launch('https://github.com/fluttercandies/create_package');
              },
            ),
          ),
          ButtonTheme(
            padding: const EdgeInsets.only(right: 10.0),
            minWidth: 0.0,
            child: FlatButton(
              child:
                  Image.network('https://pub.idqqimg.com/wpa/images/group.png'),
              onPressed: () {
                launch('https://jq.qq.com/?_wv=1027&k=5bcc0gy');
              },
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext c, int index) {
          // final RouteResult page = routes[index];
          final String type = routesGroup.keys.toList()[index];
          return Container(
              margin: const EdgeInsets.all(20.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (index + 1).toString() + '.' + type,
                      //style: TextStyle(inherit: false),
                    ),
                    Text(
                      '\$type demos of create_package',
                      //page.description,
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(
                      context, Routes.fluttercandiesDemogrouppage,
                      arguments: <String, dynamic>{
                        'keyValue': routesGroup.entries.toList()[index],
                      });
                },
              ));
        },
        itemCount: routesGroup.length,
      ),
    );
  }
}

@FFRoute(
  name: 'fluttercandies://demogrouppage',
  routeName: 'DemoGroupPage',
  argumentNames: <String>['keyValue'],
  argumentTypes: <String>['List<DemoRouteResult>'],
)
class DemoGroupPage extends StatelessWidget {
  DemoGroupPage({MapEntry<String, List<DemoRouteResult>> keyValue})
      : routes = keyValue.value
          ..sort((DemoRouteResult a, DemoRouteResult b) =>
              a.order.compareTo(b.order)),
        group = keyValue.key;
  final List<DemoRouteResult> routes;
  final String group;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('\$group demos'),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final DemoRouteResult page = routes[index];
          return Container(
            margin: const EdgeInsets.all(20.0),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    (index + 1).toString() + '.' + page.routeResult.routeName,
                    //style: TextStyle(inherit: false),
                  ),
                  Text(
                    page.routeResult.description,
                    style: const TextStyle(color: Colors.grey),
                  )
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, page.routeResult.name);
              },
            ),
          );
        },
        itemCount: routes.length,
      ),
    );
  }
}

class DemoRouteResult {
  DemoRouteResult(
    this.routeResult,
  )   : order = routeResult.exts['order'] as int,
        group = routeResult.exts['group'] as String;

  final int order;
  final String group;
  final RouteResult routeResult;
}

''';

const String demo1 = '''
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
  name: 'fluttercandies://demo1',
  routeName: 'demo1',
  description: 'demo1',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class Demo1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

''';
const String demo2 = '''
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
  name: 'fluttercandies://demo2',
  routeName: 'demo2',
  description: 'demo2',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 0,
  },
)
class Demo2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

''';
