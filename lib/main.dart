// ignore_for_file: no_logic_in_create_state, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'database_helper.dart';

// Here we are using a global variable. You can use something like
// get_it in a production app.
final dbHelper = DatabaseHelper();
final myTitle = TextEditingController();
final mySubtitle = TextEditingController();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize database
  dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
          title: const Text("Record List"),
          backgroundColor: Colors.blueGrey,
          leading: isSelectionMode
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      isSelectionMode = false;
                    });
                  },
                  icon: const Icon(Icons.list))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isSelectionMode = true;
                    });
                  },
                  icon: const Icon(Icons.grid_3x3_rounded))),
      body: !isSelectionMode
          // listView
          ? FutureBuilder(
              future: dbHelper.queryAllRows(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                List data = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    String myTitle = (data[index])['title'];
                    String mySubTitle = (data[index])['subTitle'];
                    int myID = (data[index])['_id'];
                    return Card(
                      child: ListTile(
                        title:
                            Text(myTitle, style: const TextStyle(fontSize: 25)),
                        subtitle: Center(
                          child: Text(mySubTitle,
                              style: const TextStyle(fontSize: 15)),
                        ),
                        onTap: () {
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecordEditorPage(
                                    courierTitle: myTitle,
                                    courierSubTitle: mySubTitle,
                                    CourierID: myID),
                              ),
                            );
                          });
                        },
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder<List>(
              // Grid View
              future: dbHelper.queryAllRows(),
              builder: (context, snapshot) {
                List data = snapshot.data ?? [];
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    String myTitle = (data[index])['title'];
                    String mySubTitle = (data[index])['subTitle'];
                    int myID = (data[index])['_id'];
                    return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(5),
                        child: SingleChildScrollView(
                          child: snapshot.hasData
                              ? ListTile(
                                  title: Text(myTitle,
                                      style: const TextStyle(fontSize: 30)),
                                  subtitle: Center(
                                    child: Text(mySubTitle,
                                        style: const TextStyle(fontSize: 15)),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecordEditorPage(
                                                  courierTitle: myTitle,
                                                  courierSubTitle: mySubTitle,
                                                  CourierID: myID),
                                        ),
                                      );
                                    });
                                  },
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add_business_rounded),
          label: const Text("ADD"),
          onPressed: () {
            setState(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InsertRecordPage()));
            });
          }),
    );
  }
}

class InsertRecordPage extends StatefulWidget {
  const InsertRecordPage({super.key});

  @override
  State<InsertRecordPage> createState() => _InsertRecordPageState();
}

class _InsertRecordPageState extends State<InsertRecordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Insert Record'),
      ),
      body: Card(
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 50),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 0.5, color: Colors.grey)),
        child: SingleChildScrollView(
          child: Column(
            // ignore: prefer_const_literals_to_create_immutables
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 50, left: 10, right: 10, bottom: 10),
                child: TextField(
                  controller: myTitle,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: "Enter your Title"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: TextField(
                  maxLines: null,
                  controller: mySubtitle,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: "Enter your Subtitle"),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
                onPressed: _insert,
                child: const Text(
                  "Save",
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
                onPressed: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage()),
                    );
                  });
                },
                child: const Text(
                  "Show",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordEditorPage extends StatefulWidget {
  final String courierTitle;
  final String courierSubTitle;
  final int CourierID;
  const RecordEditorPage(
      {super.key,
      required this.courierTitle,
      required this.courierSubTitle,
      required this.CourierID});

  @override
  State<RecordEditorPage> createState() => _RecordEditorPageState(
      myNewTitle: courierTitle,
      myNewSubTitle: courierSubTitle,
      myNewID: CourierID);
}

class _RecordEditorPageState extends State<RecordEditorPage> {
  final String myNewTitle;
  final String myNewSubTitle;
  final int myNewID;

  _RecordEditorPageState(
      {required this.myNewTitle,
      required this.myNewSubTitle,
      required this.myNewID});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: const Text('Edit Record'),
        ),
        body: SingleChildScrollView(
          child: Card(
            margin:
                const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(width: 0.5, color: Colors.grey)),
            child: Column(
              // ignore: prefer_const_literals_to_create_immutables
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 10, right: 10, bottom: 10),
                  child: ListTile(
                    title:
                        Text(myNewTitle, style: const TextStyle(fontSize: 24)),
                    subtitle: Center(
                      child: Text(myNewSubTitle),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                  ),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(myNewTitle),
                      content: const Text('Are your sure you want to delete?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _delete(myNewID);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyHomePage(),
                                  ),
                                );
                              });
                            },
                            child: const Text('Ok'))
                      ],
                    ),
                  ),
                  child: const Text(
                    "Delete",
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// insert data to database
void _insert() async {
  Map<String, dynamic> row = {
    DatabaseHelper.colTitle: myTitle.text,
    DatabaseHelper.colSubTitle: mySubtitle.text,
  };
  final id = await dbHelper.insert(row);
  debugPrint("inserted row ID = $id");
}

// Delete data to database
void _delete(int myNewID) async {
  final rowDelete = await dbHelper.delete(myNewID);
  debugPrint('Deleted $rowDelete row(s): row $myNewID');
}
