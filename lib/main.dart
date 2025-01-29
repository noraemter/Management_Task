import 'package:flutter/material.dart';
import 'package:my_first/utils/database_helper.dart';
import 'utils/task.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            theme: ThemeData(
              primaryColor: Colors.blue[500],
              appBarTheme: AppBarTheme(
                backgroundColor:
                    themeProvider.isDarkMode ? Colors.black : Colors.blue[500],
                titleTextStyle: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.white),
              ),
              scaffoldBackgroundColor:
                  themeProvider.isDarkMode ? Colors.black : Colors.blue[100],
              textTheme: TextTheme(
                bodyLarge: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.white),
                bodyMedium: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.white),
              ),
              brightness:
                  themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(seconds: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Management',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                      fontFamily: 'Roboto')),
              Text('App',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[700],
                      fontFamily: 'Roboto')),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Task> _tasks = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  _loadTasks() async {
    final tasks = await DatabaseHelper().getTasks();
    setState(() {
      _tasks.addAll(tasks);
    });
  }

  void _addTask() async {
    if (_controller.text.isNotEmpty) {
      Task newTask = Task(name: _controller.text);
      int id = await DatabaseHelper().insertTask(newTask);
      setState(() {
        _tasks.add(newTask.copyWith(id: id));
      });
      _controller.clear();
    }
  }

  void _toggleTaskStatus(int index) async {
    Task task = _tasks[index];
    task.isCompleted = !task.isCompleted;
    await DatabaseHelper().updateTask(task);
    setState(() {});
  }

  void _editTask(int index) {
    setState(() {
      _editingIndex = index;
      _controller.text = _tasks[index].name;
    });
  }

  void _saveTask() async {
    Task task = _tasks[_editingIndex!];
    task.name = _controller.text;
    await DatabaseHelper().updateTask(task);
    setState(() {
      _editingIndex = null;
      _controller.clear();
    });
  }

  void _cancelEdit() {
    setState(() {
      _controller.clear();
      _editingIndex = null;
    });
  }

  void _deleteTask(int index) async {
    Task task = _tasks[index];
    await DatabaseHelper().deleteTask(task.id!);
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
                color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Dismissible(
                  key: Key(task.id.toString()),
                  onDismissed: (direction) {
                    _deleteTask(index);
                  },
                  background: Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.0)),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 16.0),
                    child: Icon(Icons.delete, color: Colors.black, size: 28),
                  ),
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.blueGrey[500]
                          : Colors.blue[500],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) {
                          _toggleTaskStatus(index);
                        },
                        activeColor: themeProvider.isDarkMode
                            ? Colors.teal[500]
                            : Colors.blue[500],
                        checkColor: themeProvider.isDarkMode
                            ? Colors.grey[500]
                            : Colors.blue[500],
                        fillColor: MaterialStateProperty.all(Colors.white),
                      ),
                      title: Text(
                        task.name,
                        style: TextStyle(
                          color: Colors.white,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: task.isCompleted
                          ? null
                          : IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _editTask(index),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter task',
                        hintStyle: TextStyle(
                            color: themeProvider.isDarkMode
                                ? Colors.black54
                                : Colors.black54),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        filled: true,
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                if (_editingIndex != null)
                  Row(
                    children: [
                      SizedBox(width: 16.0),
                      Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0)),
                        child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.black),
                            onPressed: _saveTask),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0)),
                        child: IconButton(
                            icon: Icon(Icons.close, color: Colors.black),
                            onPressed: _cancelEdit),
                      ),
                    ],
                  ),
                if (_editingIndex == null)
                  Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0)),
                    child: Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.add, color: Colors.black),
                            onPressed: _addTask),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
