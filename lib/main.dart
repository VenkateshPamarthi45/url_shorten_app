import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:shorten_url_app/urls_reposistory.dart';
import 'package:shorten_url_app/urls_usecase.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Url Shorten Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'URL Shorten Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _urlShortercontroller = TextEditingController();
  var showProgressBar = false;
  Stream<QuerySnapshot> tasksStream = FirebaseFirestore.instance
      .collection('shorten_urls')
      .orderBy("created_at", descending: true)
      .snapshots();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _urlShortercontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 100,
          ),
          SizedBox(
            width: 500,
            child: TextField(
              controller: _urlShortercontroller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter URL',
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          showProgressBar
              ? const CircularProgressIndicator()
              : TextButton(
                  onPressed: () async {
                    setState(() {
                      showProgressBar = true;
                    });
                    var link = await shortenUrl(_urlShortercontroller.text);
                    setState(() {
                      showProgressBar = false;
                    });
                    await addShortenedUrl(_urlShortercontroller.text, link);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Here is the shortened link : " + link),
                    ));
                  },
                  child: const Text('Shorten'),
                ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasksStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return (snapshot.data != null && snapshot.data!.docs.isNotEmpty)
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 8.0, 0.0, 8.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(
                                                  30.0) //                 <--- border radius here
                                              ),
                                          border: Border.all(
                                              color: Colors.black12)),
                                      child: ListTile(
                                        title: InkWell(
                                          onTap: () => launchUrl(
                                            Uri.parse(data['short_url']),
                                          ),
                                          child: Text(
                                            data['short_url'],
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Colors.blue),
                                          ),
                                        ),
                                        subtitle: Text(
                                          data['long_url'],
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                          }).toList(),
                        ),
                      )
                    : SizedBox();
              },
            ),
          )
        ],
      ),
    );
  }
}
