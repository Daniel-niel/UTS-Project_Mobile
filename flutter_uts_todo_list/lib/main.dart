import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uts_todo_list/about_screen.dart';
import 'package:flutter_uts_todo_list/app_color.dart';
import 'package:flutter_uts_todo_list/widget_background.dart';
import 'package:flutter_uts_todo_list/create_task_screen.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTS Pemograman Mobile - To Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColor().colorSecondary,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AppColor appColor = AppColor();

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double heightScreen = mediaQueryData.size.height;

    return Scaffold(
      key: scaffoldState,
      backgroundColor: appColor.colorPrimary,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            WidgetBackground(),
            _buildWidgetListTodo(widthScreen, heightScreen, context),
          ],
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Padding(
            padding: const EdgeInsets.only(left: 35.0),
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
              onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen()));
              },
              backgroundColor: appColor.colorTertiary,
            ),
          ),

         FloatingActionButton(
              heroTag: null,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                // TODO: fitur tambah task
                bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTaskScreen(isEdit: false)));
                if (result != null && result) {
                  scaffoldState.currentState.showSnackBar(SnackBar(
                    content: Text('Aktivitas telah berhasil dibuat'),
                  ));
                  setState(() {});
                }
              },
              backgroundColor: appColor.colorTertiary,
            ),

        ],
      ),
    );
  }

  Container _buildWidgetListTodo(double widthScreen, double heightScreen, BuildContext context) {
    return Container(
      width: widthScreen,
      height: heightScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: Text(
              '[UTS-TIH01] To Do List',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('tasks').orderBy('date').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data.docs[index];
                    Map<String, dynamic> task = document.data();
                    String strDate = task['date'];
                    return Card(
                      child: ListTile(
                        title: Text(task['name']),
                        subtitle: Text(
                          task['description'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: false,
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 24.0,
                              height: 24.0,
                              decoration: BoxDecoration(
                                color: appColor.colorSecondary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${int.parse(strDate.split(' ')[0])}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              strDate.split(' ')[1],
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (BuildContext context) {
                            return List<PopupMenuEntry<String>>()
                              ..add(PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit'),
                              ))
                              ..add(PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ));
                          },
                          onSelected: (String value) async {
                            if (value == 'edit') {
                              // TODO: fitur edit task
                              bool result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return CreateTaskScreen(
                                    isEdit: true,
                                    documentId: document.id,
                                    name: task['name'],
                                    description: task['description'],
                                    date: task['date'],
                                  );
                                }),
                              );
                              if (result != null && result) {
                                scaffoldState.currentState.showSnackBar(SnackBar(
                                  content: Text('Aktivitas telah berhasil di Update'),
                                ));
                                setState(() {});
                              }
                            } else if (value == 'delete') {
                              // TODO: fitur hapus task
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Apakah kamu yakin ?'),
                                    content: Text('Apakah kamu yakin ingin menghapus file bernama [ ${task['name']} ] ?'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('Tidak'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('Hapus'),
                                        onPressed: () {
                                          document.reference.delete();
                                          Navigator.pop(context);
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Icon(Icons.more_vert),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}