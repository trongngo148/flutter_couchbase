import 'dart:async';
import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:couchbase_lite_example/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// void main() => runApp(BeerSampleApp(AppMode.production));
void main() => runApp(ExampleApp());

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  String _displayString = 'Initializing';
  late Database database;
  Replicator? replicator;
  late ListenerToken _listenerToken;

  late TextEditingController _usernameController;
  @override
  void initState() {
    super.initState();
    initPlatformState();
    _usernameController = TextEditingController();
  }

  Future<String> runExample() async {
    try {
      database = await Database.initWithName("gettingStarted");
    } on PlatformException {
      return "Error initializing database";
    }

    // Create a new document (i.e. a record) in the database.
    MutableDocument? mutableDoc = MutableDocument().setDouble("version", 2.0).setString("type", "SDK");

    // Save it to the database.
    try {
      await database.saveDocument(mutableDoc);
    } on PlatformException {
      return "Error saving document";
    }

    // Update a document.
    mutableDoc = (await database.document(mutableDoc.id!))?.toMutable().setString("language", "Dart");

    if (mutableDoc != null) {
      try {
        await database.saveDocument(mutableDoc);

        var document = await (database.document(mutableDoc.id!));

        print("Document ID :: ${document!.id}");
        print("Learning ${document.getString("language")}");
      } on PlatformException {
        return "Error saving document";
      }
    }

    // Create a query to fetch documents of type SDK.
    var query = QueryBuilder.select([SelectResult.all()]).from("gettingStarted").where(Expression.property("type").equalTo(Expression.string("SDK")));

    // Run the query.
    try {
      var result = await query.execute();
      print("Number of rows :: ${result.allResults().length}");
    } on PlatformException {
      return "Error running the query";
    }

    ReplicatorConfiguration config = ReplicatorConfiguration(database, "ws://10.0.2.2:4984/beer-sample");
    config.replicatorType = ReplicatorType.pushAndPull;
    config.continuous = true;

    config.authenticator = BasicAuthenticator("foo", "barbar");

    var replicator = Replicator(config);
    _listenerToken = replicator.addChangeListener((ReplicatorChange event) {
      if (event.status.error != null) {
        print("Error: " + event.status.error!);
      }

      print(event.status.activity.toString());
    });

    // Start replication.
    await replicator.start();
    return "Database and Replicator Started";
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    var result = await runExample();
    if (!mounted) return;

    setState(() {
      _displayString = result;
    });
  }

  ThemeData _buildTheme() {
    final ThemeData base = ThemeData(brightness: Brightness.light, primaryColor: kPrimaryColor, accentColor: kAccentColor, fontFamily: 'Rubik');

    return base.copyWith(
      buttonTheme: base.buttonTheme.copyWith(
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _kTheme = _buildTheme();
    return MaterialApp(
      theme: _kTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(_displayString),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextField(
                textInputAction: TextInputAction.next,
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Text',
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () async {
                print("object");
                MutableDocument? mutableDoc = MutableDocument().setString("Test", _usernameController.text);

                // Save it to the database.
                try {
                  await database.saveDocument(mutableDoc);
                } on PlatformException {
                  print("Error saving document");
                }
                var document = await database.document(mutableDoc.id.toString());
                print("Document ID :: ${document!.id}");
              },
              child: Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.blue),
                child: Center(
                    child: Text(
                  "Send Simple Data",
                  style: TextStyle(color: Colors.white),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() async {
    await replicator?.removeChangeListener(_listenerToken);
    await replicator?.stop();
    await replicator?.dispose();
    await database.close();

    super.dispose();
  }
}
