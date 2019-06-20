import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "ToDo List",
      home: new TodoList()
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  
  List<String> _todoItems = [];

  @override
  void initState(){
    super.initState();
    _loadTodoList();
  }


  // Lade TodoListe beim Start
  _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _todoItems = (prefs.getStringList('todolist') ?? [] );
    });
  }


  void _addTodoItem(String task) async{
    // füge nur ein neues item hinzu, wenn wirklich etwas eingetragen wurde
    if (task.length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // setState rendert liste automatisch neu
      setState(() {
        _todoItems = (prefs.getStringList('todolist') ?? [] );
        _todoItems.add(task);
        prefs.setStringList('todolist', _todoItems);
    });
    }
  }

  // Löscht das todo element am index
  void _removeTodoItem(int index) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _todoItems = (prefs.getStringList('todolist') ?? [] );
      _todoItems.removeAt(index);
      prefs.setStringList('todolist', _todoItems);
    });
  }

  // Zeige Alert Dialog, der abfragt ob der user das item löschen möchte
  void _promptRemoveTodoItem(int index){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return new AlertDialog(
          title: new Text("Mark '${_todoItems[index]}' as done?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            new FlatButton(
              child: new Text('Mark as done'),
              onPressed: (){
                _removeTodoItem(index);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  // Baut die ganze todoliste auf
  Widget _buildTodoList(){
    return new ListView.builder(
      itemBuilder: (context, index) {
        if (index < _todoItems.length) {
          return _buildTodoItem(_todoItems[index], index);
        }
      },
    );
  }

  // Baut ein einzelnes Todo item
  Widget _buildTodoItem(String todoText, int index){
    return new ListTile(
      title: new Text("• " + todoText),
      onTap: () => _promptRemoveTodoItem(index),
    );
  }

  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("ToDo List"),
      ),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _pushAddTodoScreen,  // dieser knopf öffnet ein neues fenster
        tooltip: 'Add task',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _pushAddTodoScreen() {
    // push this page onto the stack
    Navigator.of(context).push(
      // MaterialPageRoute will automatically animate the screen entry, as well as adding a back button to close it
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("Add a new task"),
            ),
            body: new TextField(
              autofocus: true,
              onSubmitted: (val) {
                _addTodoItem(val);
                Navigator.pop(context);
              },
              decoration: new InputDecoration(
                hintText: "Enter something to do...",
                contentPadding: const EdgeInsets.all(16.0)
              ),
            ),
          );
        }
      )
    );
  }
}