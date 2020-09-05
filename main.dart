import 'dart:ffi';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'Indicator.dart';
import 'bill.dart' as bill;
void main() => runApp(new TodoApp());
List<Task> _tasks = [];





class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    debugPaintSizeEnabled = false;
    return new MaterialApp(
      title: 'Todo List',
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  int data_dailySum = 10;
  Widget _homePageRow(IconData icon, String title, int sum) {
    return new Container(
      padding: EdgeInsets.all(10),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Icon(icon),
              new Container(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: new Text(title, style: TextStyle(fontSize: 17)),
              )
            ],
          ),
          new Text(
            sum.toString(),
            style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  /*------daily------*/
  void _pushDaily() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            backgroundColor: Colors.blue[100],
            appBar: new AppBar(title: new Text('Daily')),
            body: _dailyPage(),
          );
        },
      ),
    );
  }

  Widget _dailyPage() {

  }


  /*------daily------*/

  /*------important------*/
  void _pushImportant() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            backgroundColor: Colors.blue[100],
            appBar: new AppBar(title: new Text('Important')),
            body: _dailyPage(),
          );
        },
      ),
    );
  }
  /*------important------*/

  /*------schedual------*/
  void _pushSchedual() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            backgroundColor: Colors.blue[100],
            appBar: new AppBar(title: new Text('Schedual')),
            body: _dailyPage(),
          );
        },
      ),
    );
  }

  /*------schedual------*/

  /*------task------*/
  void _pushTask() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return TaskPage();
        },
      ),
    );
  }



  void _pushBill()  {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return bill.BillPage();
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(title: new Text('Home Page')),
      body: new Container(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pushDaily,
              child: _homePageRow(Icons.wb_sunny, 'Daily', data_dailySum),
            ),
            new GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pushImportant,
              child: _homePageRow(Icons.star, 'Important', 3),
            ),
            new GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pushSchedual,
              child: _homePageRow(Icons.calendar_today, 'Schedual', 15),
            ),
            new GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pushTask,
              child: _homePageRow(Icons.check, 'Task', 16),
            ),
            new GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pushBill,
              child: _homePageRow(Icons.attach_money, 'Bill',bill.numList() ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskPage extends StatefulWidget {
  @override
  createState() => new TaskPageState();
}

class Task {
  String name;
  DateTime deadline;

  @override
  Task(String name, DateTime deadline) {
    this.name = name;
    this.deadline = deadline;
  }
}



class TaskPageState extends State<TaskPage> {
  DateTime selectedDate = null;
  String enterName = null;

  void _addTask(String name, DateTime deadline) {
    if(name.length > 0) {
      setState(() {
        _tasks.add(new Task(name, deadline));
      });
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _removeTaskConfirm (int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Mark "${_tasks[index].name}" as done?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('CANCEL'),
                    // The alert is actually part of the navigation stack, so to close it, we
                    // need to pop it.
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text('MARK AS DONE'),
                    onPressed: () {
                      _removeTask(index);
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }

  Widget _buildTaskList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        // itemBuilder will be automatically be called as many times as it takes for the
        // list to fill up its available space, which is most likely more than the
        // number of todo items we have. So, we need to check the index is OK.
        if(index < _tasks.length) {
          return _buildTaskRow(_tasks[index], index);
        }
      },
    );
  }

  Widget _buildTaskRow(Task task, int index) {
    return ListTile(
      title: Text(task.name),
      onTap: () => _removeTaskConfirm(index),
    );
  }

  void _pushAddTask() {
    enterName = null;
    selectedDate = null;
    Navigator.of(context).push(
      new MaterialPageRoute(
          builder:   (context) {
            return new Scaffold(
                appBar: new AppBar(
                    title: new Text('Add a new task')
                ),
                body: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new TextField(
                      onSubmitted: (val) {
                        enterName = val;
                      },
                      decoration: new InputDecoration(
                          hintText: 'Enter something to do...',
                          contentPadding: const EdgeInsets.all(16.0)
                      ),
                    ),
                    new RaisedButton.icon(
                      icon: Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                      color: Colors.blue,
                      label: new Text(
                          (selectedDate == null) ?
                          'Select Date' :
                          (selectedDate.month.toString() + selectedDate.day.toString())
                      ),
                    ),
                    new RaisedButton(
                      onPressed: (){
                        print(enterName + ' ' + selectedDate.toString());
                        if(enterName == null || selectedDate == null) {
                          new AlertDialog(
                            title: Text('Be Sure You Fill The Name And Date'),
                            actions: <Widget>[
                              new FlatButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Icon(Icons.check)
                              )
                            ],
                          );
                        } else {
                          _addTask(enterName, DateTime.now());
                          Navigator.pop(context); // Close the add todo screen
                        }
                      },
                      child: new Text('Submit'),
                      color: Colors.blue,
                    ),
                  ],
                )
            );
          }
      ),
    );
  }

  _selectDate() async {
    DateTime now = DateTime.now();
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(title: new Text('Task')),
      body: _buildTaskList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _pushAddTask,
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Colors.black,),
      ),
    );
  }
}

