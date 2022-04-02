import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  }

  Future<void> createInitDocument() async {
    MutableDocument? mutableDoc = MutableDocument().setString("Test", _usernameController.text);

    // Save it to the database.
    try {
      await database.saveDocument(mutableDoc);
    } on PlatformException {
      print("Error saving document");
    }
    var document = await database.document(mutableDoc.id.toString());
    print("Document ID :: ${document.id}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return Column(
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
            MutableDocument? mutableDoc = MutableDocument().setString("Test", _usernameController.text);

            // Save it to the database.
            try {
              await database.saveDocument(mutableDoc);
            } on PlatformException {
              print("Error saving document");
            }
            var document = await database.document(mutableDoc.id.toString());
            print("Document ID :: ${document.id}");
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
        ),
        SizedBox(
          height: 20,
        ),
        InkWell(
          onTap: () async {
            printDocument();
          },
          child: Container(
            height: 50,
            width: 200,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.blue),
            child: Center(
                child: Text(
              "Search Document",
              style: TextStyle(color: Colors.white),
            )),
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