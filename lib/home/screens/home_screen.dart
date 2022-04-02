import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:couchbase_lite_example/home/domain/models/user_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../configs/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _displayString = 'Initializing';
  late Database database;
  Replicator? replicator;
  late ListenerToken _listenerToken;

  late TextEditingController _textInputController;
  @override
  void initState() {
    super.initState();
    initPlatformState();
    _textInputController = TextEditingController();
  }

  Future<String> runExample() async {
    try {
      database = await Database.initWithName("gettingStarted");
    } on PlatformException {
      return "Error initializing database";
    }

    var query = QueryBuilder.select([SelectResult.all()]).from("gettingStarted");

    // Run the query.
    try {
      var result = await query.execute();
      print("Number of rows : ${result.allResults().length}");
    } on PlatformException {
      return "Error running the query";
    }

    ReplicatorConfiguration config = ReplicatorConfiguration(database, "ws://10.0.2.2:4985/beer-sample");
    config.replicatorType = ReplicatorType.pushAndPull;
    config.continuous = true;

    late String userChannel = "channel\\foo";
    config.authenticator = BasicAuthenticator("foo", "barbar");
    config.channels = [userChannel];

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

  Future<void> printDocument() async {
    var query =
        QueryBuilder.select([SelectResult.all()]).from("gettingStarted").where(Expression.property("Test").equalTo(Expression.string("Trong 1156")));

    // Run the query.
    try {
      var result = await query.execute();
      print("Number of rows : ${result.allResults().length}");
    } on PlatformException {
      print("Error running the query");
    }

    var doc = database.document("e2f5d8f5-2f31-4972-9210-c34d80d7c817");
    var result = doc.asStream().toList();
    result.then((v) => {print(v)});
    print(doc.asStream().toList());
  }

  Future<void> createInitDocument() async {
    var userRecord = UserRecord(
      type: "user",
      name: "TrongNgo",
      user: "foo",
      address: "ABC 123",
      university: "CanTho University",
    );
    MutableDocument? mutableDoc = MutableDocument().setData(userRecord.toJson);

    // Save it to the database.
    try {
      await database.saveDocument(mutableDoc);
    } on PlatformException {
      print("Error saving document");
    }
    var document = await database.document(mutableDoc.id.toString());
    print("Document ID : ${document.id}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: getBody(),
      ),
    );
  }

  Widget getBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(_displayString),
        ),
        SizedBox(
          height: 20,
        ),
        TextField(
          textInputAction: TextInputAction.next,
          controller: _textInputController,
          decoration: InputDecoration(
            labelText: 'Text',
          ),
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () async {
            MutableDocument? mutableDoc = MutableDocument().setString("Test", _textInputController.text);

            // Save it to the database.
            try {
              await database.saveDocument(mutableDoc);
            } on PlatformException {
              print("Error saving document");
            }
            var document = await database.document(mutableDoc.id.toString());
            print("Document ID: ${document.id}");
          },
          style: raisedButtonStyle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Container(
              width: 160,
              child: Center(
                child: Text(
                  "Send Text",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () async => printDocument(),
          style: raisedButtonStyle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Container(
              width: 160,
              child: Center(
                child: Text(
                  "Search Document",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () async => createInitDocument(),
          style: raisedButtonStyle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Container(
              width: 160,
              child: Center(
                child: Text(
                  "Create Document",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        )
      ],
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
