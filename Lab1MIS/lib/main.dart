import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
class Course {
  final int id;
  final String description;

  Course({
    required this.id,
    required this.description});

}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '203120',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Index: 203120'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Course> _courses = [];
  TextEditingController _textEditingController = TextEditingController();

  void _addCourse(){
    setState(() {
      _counter++;
      String description = _textEditingController.text;
      _textEditingController.clear();
      if(description.isNotEmpty){
        _courses.insert(0, Course(id: _counter, description: description));
      }
    });
  }

  void _deleteCourse(int id){
    setState(() {
      _courses.removeWhere((course) => course.id ==id);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        color:Colors.pinkAccent[300],
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText: 'Enter Course',
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addCourse,
              )
                  ],
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(child: ListView.builder(
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return Column(
                    children: [
                      ListTile(
                         title: Text(course.description),
                         trailing: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           SizedBox(width: 20.0),
                           IconButton(
                             icon: Icon(Icons.delete),
                             onPressed: (){
                                _deleteCourse(course.id);
                             },
                    ),
                  ],
                  ),
                  ),

                  Divider(height: 1.0, color: Colors.black),
                  ],
            );
                  },
            ),
            ),
          ],
        ),
      ),

      floatingActionButton:null,
    );
  }
}
