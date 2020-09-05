import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:numberpicker/numberpicker.dart';
import 'Indicator.dart';
import 'dart:ffi';
List<BillSolo> _bills = [];


int numList(){
  return _bills.length;
}

 //单个账单数据结构
class BillSolo{
  String name;      //名称
  double num;       //数额
  DateTime date;    //日期
  var kind;         //种类+
  BillSolo(String name,double num,DateTime date,var kind){
    this.name = name;
    this.num = num;
    this.date = date;
    this.kind = kind;
  }
}

//每月统计数据结构，用于统计以月为单位的账单数额总和
class monthTotal{

  double entert;    //娱乐开销总和
  double study;    //学习开销总和
  double daily;    //生活开销总和
  double save;    //存款总和
  double income; //收入总和
  double sum;    //全月支出总和
  monthTotal(double e,double s,double d,double sa,double inc,double sum)
  {
    this.entert=e;
    this.study=s;
    this.daily=d;
    this.save = sa;
    this.income = inc;
    this.sum = sum;
  }
}

//以年为单位的账单总和
class Total{
  int year;      //存储年份
  double entert; //全年娱乐开销总额
  double study; //全年学习开销总和
  double daily; //全年日常开销总和
  double save;   //全年存款总和
  double income; //全年收入总和
  double sum;   //全年支出总和
  //存储12个月的内容
  List<monthTotal> month = [];
  Total(int y,double e,double s,double d,double sa,double inc,double sum)
  {
    this.year = y;
    this.entert=e;
    this.study=s;
    this.daily=d;
    this.save = sa;
    this.income = inc;
    this.sum = sum;
  }

}
//实例化
List<Total> _all = [];

//总和列表实例化(用于数据可视化)
void TotalInitial(){
  for(int i=0;i<27;i++)
    {
      int ye = i+1999;
      _all.add(new Total(ye, 0, 0, 0, 0,0,0));
      for(int j=0;j<12;j++)
        {
          _all[_all.length-1].month.add(new monthTotal(0, 0, 0, 0,0,0));
        }
    }
  //print("all初始化完成");
}


//日期选择器页面
class DatePickerDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DatePickerDemo();
}

class _DatePickerDemo extends State<DatePickerDemo> {

  _showDataPicker() async {
    Locale myLocale = Localizations.localeOf(context);

    var picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1999),
        lastDate: DateTime(2020),
        locale: myLocale);
    setState(() {
      _time = picker;

    });
  }

  _showTimePicker() async {
    var picker =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
      _time = picker;
    });
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        RaisedButton(
          child: Text(_time == null ? 'select date' : _time),
          onPressed: () => _showDataPicker(),
        ),
        RaisedButton(
          child: Text(_time == null ? 'select time' : _time),
          onPressed: () => _showTimePicker(),
        ),

      ],
    );
  }
}

//四个变量代表筛选条件中的checkbox是否选中
bool _wlife=false;
bool _wstu=false;
bool _wsave=false;
bool _went=false;
String barYear="2016";
List<double> monthlySum=[0,0,0,0,0,0,0,0,0,0,0,0];

//存储长按中选中的账单
BillSolo show;

int  _selectedyear = 2020;  //数据可视化选中的年份
int _selectedmonth = 1;     //数据可视化选中的月份
var _billKind = " ";        //账单种类

var _time;   //存储当前选择的日期
String _errInfo=" ";        //错误信息


class BillMain extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=> new BillMainState();
}
class BillMainState extends State<BillMain>{
  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return BillPage();
  }
}



class BillPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new BillState();
}

class BillState extends State<BillPage>{

  DateTime billSelectTime;     //新建账单选中的日期
  String billName;             //账单名称
  double billCount;           //账单数额


  String mbillName;
  double mbillCount;
  var _mtime;
  var _mbillKind = " ";
  var _merrInfo;




  var _billComplete = " ";    //账单是否完成（已废弃）
  var _time;                  //账单日期
  var currentIndex = 0;
  var curentShow=null;            //当前body界面（用于底部菜单栏跳转)
  var touchedIndex;           //

  var PieView;                //饼图Widget
  var BarView;
  var SumView;                //总统计Widget
 var _PageIndex=0;            //底部菜单栏索引



  //点击其中任意一个账单弹出的页面（账单详情）




  //底部菜单栏列表元素定义
  final List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
        backgroundColor: Colors.orange[300],
        icon:Icon(Icons.monetization_on),
        title:Text("bill list")
    ),
    BottomNavigationBarItem(
        backgroundColor: Colors.orange[300],
        icon:Icon(Icons.lens),
        title:Text("statistics")
    )
  ];


  //日期选择器定义
  _showDataPicker() async {
    Locale myLocale = Localizations.localeOf(context);
    var picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1999),
        lastDate: DateTime(2025),
        locale: myLocale);
    setState(() {
      _time = picker;
      //print("_time:"+_time.toString());
    });
  }



  _MshowDataPicker() async {
    Locale myLocale = Localizations.localeOf(context);
    var picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1999),
        lastDate: DateTime(2025),
        locale: myLocale);
    setState(() {
      _mtime = picker;
     // print("_time:"+_time.toString());
    });
  }

  //底部菜单栏功能实现
  void  _changePage(index){
    _PageIndex = index;
    if(index!=currentIndex)
      setState(() {
        currentIndex = index;
       // print("index:" + index.toString());
        if (index == 0) {
         // print("一");
          renewList(_bills);
        }
        else if (index == 1) {
          DataProcess(_selectedyear, _selectedmonth);
          renewPieChart();
          curentShow = this.getStatic();
        }
      });
  }
  void noConditions(){
    _conInfo = null;
    renewList(_bills);
  }

  //AppBar标题内容
  String _MainText= "Bill";
  //筛选条件的四个标志(是否选中)




  @override
  Widget build(BuildContext context) {
    //初始化总和列表
  if(_all.length==0)
    {
      print("初始化");
      TotalInitial();
    }
  //初始化饼图
  if (PieView == null) {
    PieView = PieShow(2020, 1);
  }

  //print("PageIndex:"+_PageIndex.toString());
  //这段代码实现了自由进出页面而不会产生空白页面


    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.orange[300],
      appBar: AppBar(
          title: Text(_MainText),
          backgroundColor: Colors.orange[300],
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.do_not_disturb),
            onPressed: (){
              print("按下去了");
              setState(() {
                noConditions();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: (){
              showDialog(
                  context: context,
                child: SimpleDialog(
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: <Widget>[
                          Text(
                            "choose conditions",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700
                      ),
                          ),
                          DialogPage(),
                          Column(
                            children: <Widget>[
                              RaisedButton(
                                child: Text("done"),
                                onPressed: (){
                                  setState(() {
                                    //print('选中年份:'+_selectedyear.toString()+" 选中月份:"+_selectedmonth.toString());
                                    Listfilter();
                                    Navigator.of(context).pop();
                                    //print("选择完成:"+_selectedyear.toString()+" "+_selectedmonth.toString());

                                  });
                                },
                              ),
                              RaisedButton(
                                child: Text("cancel"),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                )
              );
            }
          )

        ],
      ),
      body: ((curentShow==null)?BillList(_bills):curentShow),


      floatingActionButton: FloatingActionButton(

        onPressed: (){
          _billKind=null;
          _addBill();
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavItems,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index){
          _changePage(index);
        },
      ),

    );
  }

  //更新饼图函数，根据选择的日期来实时更新饼图和总统计数据
  void renewPieChart(){
   // print("更新饼图完成 "+"isempty:"+_isEmpty.toString());
    setState(() {
      if(_yearEmpty){
        this.BarView = Text("no monthly data");
          _yearEmpty=false;

      }
      else{
        this.BarView = this.BarShow();
      }
      if(_isEmpty)
        {
          print("你没修");
          this.PieView = Text("no details");
          this.SumView = Text("no summary");

            _isEmpty=false;
        }
      else{
        print("你修了");
        this.PieView = this.PieShow(_selectedyear, _selectedmonth);
        this.SumView = this.sumShow();
      }
      curentShow = this.getStatic();
    });
  }
String _conInfo ;
  String _insertText;
  void Listfilter()
  {

    _conInfo="conditions:"+(_selectedyear.toString()+"."+_selectedmonth.toString()+"( ");
    //print("过滤器运行中");
    List kind = [];
    if(_wsave)
      {
        _conInfo+="deposit ";
        kind.add('deposit');
      }
    if(_went){
      _conInfo+="amusement ";
      kind.add("amusement");
    }
    if(_wstu){
      _conInfo+="education ";
      kind.add("education");
    }
    if(_wlife){
      _conInfo+="daily ";
      kind.add("daily");
    }
    _conInfo+=")";
    List<BillSolo>target = _bills.sublist(0);
    for(int i=0;i<_bills.length;i++)
    {
     // print(_bills[i].name);
    }
    target.removeWhere((a){
      return !(kind.contains(a.kind) && a.date.year == _selectedyear && a.date.month == _selectedmonth);
    });
    for(int i=0;i<target.length;i++)
      {
        //print(target[i].name);
      }
    renewList(target);
  }

  //删除账单操作
  void toDelete(BillSolo a){
    int year = a.date.year;
    int monthA = a.date.month;
    //print("删除操作:"+a.num.toString()+" "+year.toString()+" "+monthA.toString()+" "+a.kind.toString());
    setState(() {
      //print("before:"+_all[year-1999].month[monthA-1].income.toString());
    switch(a.kind)
    {
      case 'amusement':{
          _all[year-1999].month[monthA-1].entert-=a.num;
          _all[year-1999].month[monthA-1].sum-=a.num;
          _all[year-1999].sum-=a.num;
          _all[year-1999].entert-=a.num;
        }
        break;
      case 'education':{
        _all[year-1999].month[monthA-1].study-=a.num;
        _all[year-1999].month[monthA-1].sum-=a.num;
        _all[year-1999].sum-=a.num;
        _all[year-1999].study-=a.num;
      }
        break;
      case 'deposit':{
        _all[year-1999].month[monthA-1].save-=a.num;
        _all[year-1999].month[monthA-1].sum-=a.num;
        _all[year-1999].sum-=a.num;
        _all[year-1999].save-=a.num;
      }
        break;
      case 'daily':{
        _all[year-1999].month[monthA-1].daily-=a.num;
        _all[year-1999].month[monthA-1].sum-=a.num;
        _all[year-1999].sum-=a.num;
        _all[year-1999].daily-=a.num;
      }
        break;
      case 'income':{
        _all[year-1999].month[monthA-1].income-=a.num;
        _all[year-1999].income-=a.num;
      }
      break;
    }
      //print("after:"+_all[year-1999].month[monthA-1].income.toString());
      _bills.remove(a);
    });
//print("账单删除完成");
  }


  //删除账单消息框(长按单个账单可弹出)
  Future pushDelete(BillSolo toDe){
    //print("删除start");
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
          Container(
          margin:  const EdgeInsets.all(10.0),
              child: Column(
              children: <Widget>[
                RaisedButton(
                  child: Text("delete"),
                  onPressed: (){
                    setState(() {
                      toDelete(toDe);

                      Navigator.of(context).pop();
                      renewList(_bills);
                    });
                  },
                ),
                RaisedButton(
                    child: Text("modify"),
                    onPressed: () {
                      modified(toDe);
                    }
                ),
                RaisedButton(
                  child: Text("cancel"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                )
          ],
              )
          )
            ],
          );
        }
    );
   // print("删除eng");
  }

//用于判断并声成每个账单前面的圆形图标
  Icon ListText(BillSolo item){
    var kind = item.kind;
    var year = item.date.year;
    var month = item.date.month;
    var num = item.num;
      if(kind=='daily')
      {
        //return Text("LIFE");
        return Icon(Icons.home);
      }
      else if(kind=='education')
      {
       // return Text("STU");
        return Icon(Icons.school);
      }
      else if(kind=='amusement')
      {
        //return Text("ENT");
        return Icon(Icons.videogame_asset);
      }
      else if(kind=="deposit")
      {
        //return Text("SAVE");
        return Icon(Icons.save);
      }
      else if(kind=="income")
        {
         // return Text("INC");
          return Icon(Icons.work);
        }
      else{
        //return Text("NA");
        return Icon(Icons.help);
      }
  }

  //用于判断是收入还是支出（比如收入100，则显示“+100”，否则为“-100”）
  Text PlusOrSub(var k,double a)
  {
    if(k=='daily'||k=='amusement'||k=='deposit'||k=='education')
    {
      return Text(
          "-"+a.toString(),
          style: TextStyle(
          fontSize: 17,
              color: Colors.red
      ),
      );
    }
    else if(k=='income'){
      return Text(
          "+"+a.toString(),
          style: TextStyle(
          fontSize: 17,
            color: Colors.green
      ),
      );
    }
  }

  //饼图绘制函数
  PieShow(int year,int month)
  {
    return
      Column(
        children: <Widget>[
          Text(
            _selectedyear.toString()+"."+_selectedmonth.toString()+" Billing statistics",
            style: TextStyle(
                fontSize: 22.0
            ),
          ),
  AspectRatio(
  aspectRatio: 1.3,
  child: Card(
  color: Colors.white,
  child: Row(
  children: <Widget>[
  const SizedBox(
  height: 18,
  ),
  Expanded(
  child: AspectRatio(
  aspectRatio: 1,
  child: PieChart(
  PieChartData(
  pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
  setState(() {
  if (pieTouchResponse.touchInput is FlLongPressEnd ||
  pieTouchResponse.touchInput is FlPanEnd) {
  touchedIndex = -1;
  } else {
  touchedIndex = pieTouchResponse.touchedSectionIndex;
  }
  });
  }),
  borderData: FlBorderData(
  show: false,
    ),
    sectionsSpace: 0,
    centerSpaceRadius: 40,
    sections: showingSections()),
    ),
    )
    ),
    Column(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const <Widget>[
    Indicator(
    color: Color(0xff0293ee),
    text: 'daily',
    isSquare: true,
    ),
    SizedBox(
    height: 4,
    ),
    Indicator(
    color: Color(0xfff8b250),
    text: 'amusement',
    isSquare: true,
    ),
    SizedBox(
  height: 4,
  ),
  Indicator(
  color: Color(0xff845bef),
  text: 'education',
  isSquare: true,
  ),
  SizedBox(
    height: 4,
    ),
    Indicator(
    color: Color(0xff13d38e),
  text: 'deposit',
  isSquare: true,
  ),
  SizedBox(
  height: 18,
  ),
  ],
  ),
  const SizedBox(
  width: 28,
  ),
  ],
    ),
    ),
    )
        ],
      );

  }
  BarShow(){
    return
      Column(
        children: <Widget>[
          Text(
            _selectedyear.toString()+" Monthly total bill",
            style: TextStyle(
                fontSize: 22.0
            ),
          ),
          LineChartSample3()
        ],
      );
  }

  //总统计图绘制函数
  sumShow(){
  return Column(
    children: <Widget>[
      Text(
          "￥"+_monthSum.toString()+" spent this month",
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 20
        ),
      ),
      Text(
          "amusement:￥"+_selectEntert.toString(),
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 17
      ),
      ),
      Text(
          "education:￥"+_selectStu.toString(),
        textAlign: TextAlign.left,
        style: TextStyle(
            fontSize: 17
        ),
      ),
      Text(
          "daily:￥"+_selectLife.toString(),
        textAlign: TextAlign.left,
        style: TextStyle(
            fontSize: 17
        ),
      ),
      Text(
          "deposit:￥"+_selectSave.toString(),
        textAlign: TextAlign.left,
        style: TextStyle(
            fontSize: 17
        ),
      ),

    ],
  );
  }


  //以下八个状态是绘制饼图的必要条条件，_select开头的为对应种类的总和，Per结尾的为对应的比率
double _selectLife;
  double _selectStu;
  double _selectSave;
double _selectEntert;
double _selectIncome;
double _monthSum;
  String _LifePer;
  String _StuPer;
  String _SavePer;
  String _EntertPer;


  bool _isEmpty = false;
  bool _yearEmpty = false;


//数据处理核心函数，计算上述状态的值并绘制饼图
  DataProcess(int year,int selectMonth){
    //("数据处理完成  "+year.toString()+" "+selectMonth.toString());
    setState(() {
      for(int i=0;i<12;i++)
        {
          monthlySum[i]=_all[year-1999].month[i].sum;
        }
      monthTotal item = _all[year-1999].month[selectMonth-1];
      _selectLife = item.daily;
      _selectStu = item.study;
      _selectSave = item.save;
      _selectEntert = item.entert;
      _selectIncome = item.income;
      //print("xax:"+ _selectLife .toString()+" "+_selectStu.toString()+" "+_selectSave .toString()+" "+_selectEntert .toString());
      double sum = _selectLife+_selectStu+_selectEntert+ _selectSave;
      _monthSum = sum;
      if(_all[year-1999].sum==0)
        {
          _yearEmpty = true;
        }
      if(sum==0)
      {
        print("本月和为0");
        _LifePer = '0';
        _StuPer = '0';
        _EntertPer = '0';
        _SavePer='0';
        _isEmpty=true;
      }
      //计算比率（精确到小数点后2位）
      else{
        _LifePer = ((_selectLife /sum)*100).toStringAsFixed(2);
        _StuPer = ((_selectStu/sum)*100).toStringAsFixed(2);
        _EntertPer = ((_selectEntert/sum)*100).toStringAsFixed(2);
        _SavePer=((_selectSave/sum)*100).toStringAsFixed(2);
        //print("xax:"+_LifePer.toString()+" "+_StuPer .toString()+" "+ _SavePer .toString()+" "+_EntertPer .toString());
      }
    });
  }

  //数据可视化日期选择界面
  DateSelecter()
    {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              Row(
                children: <Widget>[
                  chooseDatePicker(),
                RaisedButton(
                  child: Text("done"),
                  onPressed: (){
                    setState(() {
                      //print('选中年份:'+_selectedyear.toString()+" 选中月份:"+_selectedmonth.toString());
                      Navigator.of(context).pop();
                      //print("选择完成:"+_selectedyear.toString()+" "+_selectedmonth.toString());
                      DataProcess(_selectedyear,_selectedmonth);
                      renewPieChart();
                    });
                  },
                )
                ],
              ),
            ],
          );
        }
          );
  }

  //数据可视化统计界面
  getStatic(){
    _conInfo=null;
    return
      SingleChildScrollView(
        child:
       Center(
         child: Column(
      children: <Widget>[

     RaisedButton(
       child: Text("choose date"),
       onPressed: (){
        DateSelecter();
       }
     ),

        PieView,

        BarView,
        SumView,

        Text(
          "total income: ￥"+_selectIncome.toString(),
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 20
          ),
        ),

    ],
    )
       )
      );
  }

  //饼图绘制part
  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 60 : 50;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: _selectLife,
            title: _LifePer.toString(),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: _selectEntert,
            title: _EntertPer.toString(),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: _selectStu,
            title: _StuPer.toString(),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: _selectSave,
            title: _SavePer.toString(),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        default:
          return null;
      }
    });
  }

var _currentValue =4;
  List<BillSolo> EmptyList=[];
  //实时更新账单列表
  renewList(List<BillSolo> showbills){
    print("更新状态，当前列表中共有"+_bills.length.toString()+"个元素");
    if(showbills.length==0)
      {
        curentShow = Center(
          child: Column(
            children: <Widget>[

          Text(_conInfo==null?"no conditions":_conInfo),
          Text("no data，what about changing the conditions？"),
          ]
        )
        );
      }
    else{
      print("正在载入，共有"+showbills.length.toString()+"个元素");
      curentShow = this.BillList(showbills);
    }
  }
DataModified(BillSolo m){
  int indexF = _bills.indexOf(m);
  //print("indexF:"+indexF.toString());
  var target = _bills[indexF];
  int year = target.date.year;
  int month = target.date.month;
  switch(target.kind)
  {
    case 'amusement':{
      _all[year-1999].month[month-1].entert-=m.num;
      _all[year-1999].month[month-1].sum-=m.num;
      _all[year-1999].sum-=m.num;
      _all[year-1999].entert-=m.num;
    }
    break;
    case 'education':{
      _all[year-1999].month[month-1].study-=m.num;
      _all[year-1999].month[month-1].sum-=m.num;
      _all[year-1999].sum-=m.num;
      _all[year-1999].study-=m.num;
    }
    break;
    case 'deposit':{
      _all[year-1999].month[month-1].save-=m.num;
      _all[year-1999].month[month-1].sum-=m.num;
      _all[year-1999].sum-=m.num;
      _all[year-1999].save-=m.num;
    }
    break;
    case 'daily':{
      _all[year-1999].month[month-1].daily-=m.num;
      _all[year-1999].month[month-1].sum-=m.num;
      _all[year-1999].sum-=m.num;
      _all[year-1999].daily-=m.num;
    }
    break;
    case 'income':{
      _all[year-1999].month[month-1].income-=m.num;
      _all[year-1999].income-=m.num;
    }
    break;
  }

  target.kind = _mbillKind;
  target.num = mbillCount;
  target.date = _mtime;
  target.name = mbillName;
  year = target.date.year;
  month = target.date.month;
  switch(target.kind)
  {
    case 'amusement':{
      _all[year-1999].month[month-1].entert+=mbillCount;
      _all[year-1999].month[month-1].sum += mbillCount;
      _all[year-1999].entert+=mbillCount;
      _all[year-1999].sum+=mbillCount;
    }
    break;
    case 'education':{
      _all[year-1999].month[month-1].study+=mbillCount;
      _all[year-1999].month[month-1].sum += mbillCount;
      _all[year-1999].sum+=mbillCount;
      _all[year-1999].study+=mbillCount;
    }
    break;
    case 'deposit':{
      _all[year-1999].month[month-1].save+=mbillCount;
      _all[year-1999].month[month-1].sum += mbillCount;
      _all[year-1999].sum+=mbillCount;
      _all[year-1999].save-=mbillCount;
    }
    break;
    case 'daily':{
      _all[year-1999].month[month-1].daily+=mbillCount;
      _all[year-1999].month[month-1].sum += mbillCount;
      _all[year-1999].sum+=mbillCount;
      _all[year-1999].daily-=mbillCount;
    }
    break;
    case 'income':{
      _all[year-1999].month[month-1].income+=mbillCount;
      _all[year-1999].income+=mbillCount;
    }
    break;
  }

}
  final GlobalKey<FormState> _modifiKey = GlobalKey<FormState>();
  modified(BillSolo m)
  {
    _mtime=null;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return SimpleDialog(
            children: <Widget>[
              Container(
              margin:  const EdgeInsets.all(10.0),
                child:   Column(
                  children: <Widget>[
                    Text(
                      "modifiy",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                    Form(
                        key:_modifiKey,
                        child: Column(
                            children:<Widget>[
                              TextFormField(
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText:"bill name",
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                  ),

                                  hintText:"such as'GTA5'",
                                ),
                                validator: (v){
                                  return v.trim().length >0 ? null : "the name of the bill can't be null";
                                },
                                onChanged: (val){
                                  mbillName = val;
                                },
                              ),
                              TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText:"Amount of bill",
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                    ),

                                  ),
                                  validator: (v){
                                  if(v.trim().length==0)
                                    {
                                      return "Amount can't be null";
                                    }
                                    double a;
                                    try{
                                    a =  double.parse(v.trim());
                                  }catch(e){
                                    return "please enter a valid number!";
                                  }
                                    if(a<0)
                                    {
                                      print("负数错误");
                                      return "Amount can't be negative";
                                    }
                                    else {
                                      print("正确");
                                      return null;
                                    }
                                  },
                                  onChanged: (val){
                                    mbillCount = double.parse(val);
                                  }
                              )
                            ]
                        )
                    ),
                    RaisedButton(
                      child: Text((_mtime== null )? 'choose the date' : _mtime.toString()),
                      onPressed: () => _MshowDataPicker(),
                    ),
                    DropdownButton(
                      hint: Text("type of bill"),
                      items: [
                        DropdownMenuItem(child:Text('life'),value: 'daily'),
                        DropdownMenuItem(child:Text('education'),value: 'education'),
                        DropdownMenuItem(child:Text(' amusement'),value: 'amusement'),
                        DropdownMenuItem(child:Text('deposit'),value: 'deposit'),
                        DropdownMenuItem(child:Text('income'),value: 'income'),
                      ],
                      onChanged: (value){
                        this._mbillKind=null;
                        this._mbillKind = value;
                      },
                    ),
                    Text(_errInfo),
                    FlatButton(
                      child: Text("done"),
                      onPressed: () {
                        setState(() {
                          print("11111111");
                          if (_modifiKey.currentState.validate()) {

                            if(billName == null||billCount==null||_mtime==null) {
                            }
                            else{
                              _merrInfo=" ";
                              show = m;
                              DataModified(m);
                              Navigator.of(context).pop();
                              renewList(_bills);
                            }
                          }
                          else{
                            print("很明显不合法");
                          }

                        });
                      },
                    ),
                    FlatButton(
                      child: Text("cancel"),
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                )
              )

            ],
          );
        }
    );
  }


  String kindText(var a)
  {
    if(a=='amusement')
    {
      return 'amusement';
    }
   else if(a=='daily')
    {
      return 'daily';
    }
    else if(a=='deposit')
    {
      return 'deposit';
    }
    else if(a=='education')
    {
      return 'education';
    }
    else if(a=='income')
      {
        return 'income';
      }
    else{
      return 'NA';
    }
  }

  //获取特定列表中的所有账单条目并形成一组listtile
  getList(List<BillSolo> target) {
    Iterable<Widget> listTitles = target.map((BillSolo item) {
      return new
      Container(
          margin:  const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
      color: Colors.amberAccent,
      border: Border.all(width :3),
      borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: ListTile(
        isThreeLine: true,
        dense: false,

        leading: new CircleAvatar(child: ListText(item)),
        title: new Text(item.name),
        subtitle: new Text(item.date.year.toString()+"."+item.date.month.toString()+"."+item.date.day.toString()+" "+kindText(item.kind)),
        trailing:  PlusOrSub(item.kind,item.num),
        enabled: true,
        onTap: (){
          show=item;
          Navigator.of(context).push(
              new MaterialPageRoute(
                  builder: (context){
                    return Scaffold(
                      appBar: AppBar(title: Text("details"),backgroundColor: Colors.orange[300]),
                      body:
                      Center(
                      child:  Column(
                                  children: <Widget>[
                      Container(
                      margin: const EdgeInsets.all(10.0),
                        child:
                                    Column(
                                        children: <Widget>[
                                          Text("name : " +show.name,
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text("Amount : "+show.num.toString(),
                                            style: TextStyle(
                                              fontSize: 20,

                                            ),
                                          ),
                                          Text("type : "+(show.kind==null?"unknown":kindText(show.kind)),
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text("date : "+show.date.year.toString()+"."+show.date.month.toString()+"."+show.date.day.toString(),
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ]
                                    ),
                      ),

                                    RaisedButton(
                                        child: Text("back"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }
                                    )
                                  ],
                                )

                            ),


                    );
                  }
              )
          );
        },
        onLongPress: (){
          pushDelete(item);
        },
      )
      );
    });
    return listTitles.toList();
  }



  int atten = 0;
  //用于将getList(target)中形成的一组listtile插入到Listview中
  BillList(List<BillSolo> target){
    List<Widget> ta = this.getList(target);
    ta.insert(0, Center(child:Text(_conInfo==null?"no conditions":_conInfo) ));
    return  ListView(
      children:  ta,
    );
  }

  //新建账单操作
void dataPlus(BillSolo item){
  var kind = item.kind;
  var year = item.date.year;
  var month = item.date.month;
  var num = item.num;
  if(kind=='daily')
  {
    _all[year-1999].daily+=num;
    _all[year-1999].month[month-1].sum += num;
    _all[year-1999].sum+=num;
    _all[year-1999].month[month-1].daily+=num;
  }
  else if(kind=='education')
  {
    _all[year-1999].study+=num;
    _all[year-1999].month[month-1].sum += num;
    _all[year-1999].sum+=num;
    _all[year-1999].month[month-1].study+=num;
  }
  else if(kind=='amusement')
  {
    _all[year-1999].entert+=num;
    _all[year-1999].month[month-1].sum += num;
    _all[year-1999].sum+=num;
    _all[year-1999].month[month-1].entert+=num;
  }
  else if(kind=="deposit")
  {
    _all[year-1999].save+=num;
    _all[year-1999].month[month-1].sum += num;
    _all[year-1999].sum+=num;
    _all[year-1999].month[month-1].save+=num;
  }
  else if(kind=="income"){
    _all[year-1999].income+=num;
    _all[year-1999].month[month-1].income+=num;
  }
}
  final GlobalKey<FormState> _addKey = GlobalKey<FormState>();

  //新建账单消息款
  void _addBill()
  {
    _time=null;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return SimpleDialog(

            children: <Widget>[
              Container(
                margin:  const EdgeInsets.all(10.0),
                child: Column(
                children: <Widget>[
                  Text(
                      "add bill",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  Form(
                      key: _addKey,
                      child: Column(
                          children:<Widget>[
                            TextFormField(
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText:"bill name",
                                hintText:"such as 'ps4'",

                              ),
                              validator: (v){
                                return v.trim().length >0 ? null : "the name of the bill can't be null";
                              },
                              onChanged: (val){
                                billName = val;
                              },
                            ),
                            TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText:"amount of bill"
                                ),
                                validator: (v){  print("验证中");
                                if(v.trim().length==0)
                                {
                                  return "Amount can't be null";
                                }
                                double a;
                                try{
                                  a =  double.parse(v.trim());
                                }catch(e){
                                  return "please enter a valid number!";
                                }
                                if(a<0)
                                {
                                  return "Amount can't be negative";
                                }
                                else {
                                  return null;
                                }
                                },
                                onChanged: (val){
                                  billCount = double.parse(val);
                                }
                            )
                          ]
                      )
                  ),
                  RaisedButton(
                    child: Text((_time== null )? 'choose the date' : _time.toString()),
                    onPressed: () => _showDataPicker(),
                  ),
                  AddListDialogPage(),
                  FlatButton(
                    child: Text("done"),
                    onPressed: () {
                      setState(() {

                        _errInfo = "";
                        if (_addKey.currentState.validate()) {
                          if(billName == null||billCount==null||_time==null) {

                            if (billName == null) {
                            }
                            if (billCount == null) {
                            }
                            if (_time == null) {
                              _errInfo = "date can't be null";
                            }
                          }
                          else{
                            _errInfo=" ";
                            Navigator.of(context).pop();
                            //print("Name:"+billName+" billCount:"+billCount.toString()+" billSelectTime:"+_time.toString());
                            BillSolo newGuy =new BillSolo(billName, billCount,_time,_billKind);
                            _bills.add(newGuy);
                            dataPlus(newGuy);
                            renewList(_bills);
                          }
                        }

                      });
                    },
                  ),
                  RaisedButton(
                    child: Text("cancel"),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  )],
              ),
              )

            ],
          );
        }
    );
  }
}
//筛选条件消息框中的部分动态组件
class DialogPage extends StatefulWidget {
  @override
  createState() => new DialogPageState();
}

class DialogPageState extends State<DialogPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            NumberPicker.integer(
                initialValue: _selectedyear,
                minValue: 1999,
                maxValue: 2025,
                itemExtent: 50,
                infiniteLoop: false,
                onChanged: (n) {
                  setState(() {
                    //print(" _selectedyear :" +
                        //_selectedyear.toString());
                    //print("n:" + n.toString());
                    _selectedyear = n;
                    //print(" _selectedyear :" +
                        //_selectedyear.toString());
                  });
                }),
            NumberPicker.integer(
                initialValue: _selectedmonth,
                minValue: 1,
                maxValue: 12,
                onChanged: (n) {
                  setState(() {
                    _selectedmonth = n;
                  });
                }),
          ],
        ),
        new CheckboxListTile(
          secondary: const Icon(Icons.home),
          title: const Text('daily'),
          value: _wlife,
          onChanged: (bool value) {
            setState(() {
              _wlife = !_wlife;
            });
          },
        ),
        new CheckboxListTile(
          secondary: const Icon(Icons.school),
          title: const Text('education'),
          value: _wstu,
          onChanged: (bool) {
            setState(() {
              _wstu = !_wstu;
              print(_wstu);
            });
          },
        ),
        new CheckboxListTile(
          secondary: const Icon(Icons.videogame_asset),
          title: const Text('amusement'),
          value: _went,
          onChanged: (bool value) {
            setState(() {
              _went = !_went;
            });
          },
        ),
        new CheckboxListTile(
          secondary: const Icon(Icons.save),
          title: const Text('deposit'),
          value: _wsave,
          onChanged: (bool value) {
            setState(() {
              _wsave = !_wsave;
            });
          },
        ),
      ],
    );
  }
}


//添加账单消息框中的部分组件
class AddListDialogPage extends StatefulWidget {
  @override
  createState() => new AddListDialogPageState();
}

class AddListDialogPageState extends State<AddListDialogPage> {
  @override
  Widget build(BuildContext context) {
  return Column(
    children: <Widget>[
      Text("the date can't be null"),
      DropdownButton(
        hint: Text(_billKind==null? "type of bill": _billKind.toString()),

        items: [
          DropdownMenuItem(child:Text('daily'),value: 'daily'),
          DropdownMenuItem(child:Text('education'),value: 'education'),
          DropdownMenuItem(child:Text('amusement'),value: 'amusement'),
          DropdownMenuItem(child:Text('deposit'),value: 'deposit'),
          DropdownMenuItem(child:Text('income'),value: 'income'),
        ],
        onChanged: (value){
          setState(() {
            _billKind = value;
          });
        },
      ),
    ],
  );
  }
}



class chooseDatePicker extends StatefulWidget{
  @override
  createState() => new chooseDatePickerState();
}

class chooseDatePickerState extends State<chooseDatePicker>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      children: <Widget>[
        NumberPicker.integer(
            initialValue: _selectedyear,

            minValue: 1999,
            maxValue: 2025,
            itemExtent: 50,
            infiniteLoop: false,
            onChanged: (n) {
              setState(() {
                //print(" _selectedyear :"+ _selectedyear .toString());
                //print("n:"+n.toString());
                _selectedyear = n;
               // print(" _selectedyear :"+ _selectedyear .toString());
              });


            }),
        NumberPicker.integer(
            initialValue: _selectedmonth,
            minValue: 1,
            maxValue: 12,
            onChanged: (n) {
              setState(() {
                _selectedmonth=n;
              });

            }),
      ],
    );
  }
}
//单个账单长按之后进入的页面中的显示部分

class LineChartSample3 extends StatelessWidget {
  final weekDays = [
    'take',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[

        const SizedBox(
          height: 18,
        ),
        SizedBox(
          width: 300,
          height: 140,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                  getTouchedSpotIndicator: (LineChartBarData barData,
                      List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      final FlSpot spot = barData.spots[spotIndex];
                      if (spot.x == 0 || spot.x == 6) {
                        return null;
                      }
                      return TouchedSpotIndicatorData(
                        FlLine(color: Colors.blue, strokeWidth: 4),
                        FlDotData(
                          dotSize: 8,
                          strokeWidth: 5,
                          getDotColor: (spot, percent, barData) => Colors.white,
                          getStrokeColor: (spot, percent, barData) =>
                          Colors.deepOrange,
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueAccent,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          if (flSpot.x == 0 ) {
                            return null;
                          }

                          return LineTooltipItem(
                            '${weekDays[flSpot.x.toInt()]}月 \n￥${flSpot
                                .y}',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      })),
              extraLinesData: ExtraLinesData(horizontalLines: [
                HorizontalLine(
                  y: 1.8,
                  color: Colors.green.withOpacity(0.8),
                  strokeWidth: 3,
                  dashArray: [20, 2],
                ),
              ]),
              lineBarsData: [
                LineChartBarData(
                  isStepLineChart: true,
                  spots: [

                    FlSpot(1,monthlySum[0]),
                    FlSpot(2, monthlySum[1]),
                    FlSpot(3, monthlySum[2]),
                    FlSpot(4, monthlySum[3]),
                    FlSpot(5, monthlySum[4]),
                    FlSpot(6, monthlySum[5]),
                    FlSpot(7, monthlySum[6]),
                    FlSpot(8, monthlySum[7]),
                    FlSpot(9, monthlySum[8]),
                    FlSpot(10, monthlySum[9]),
                    FlSpot(11, monthlySum[10]),
                    FlSpot(12, monthlySum[11]),

                  ],
                  isCurved: false,
                  barWidth: 4,
                  colors: [
                    Colors.purple,
                  ],
                  belowBarData: BarAreaData(
                    show: true,
                    colors: [
                      Colors.green.withOpacity(0.5),
                      Colors.purple.withOpacity(0.0),
                    ],
                    gradientColorStops: [0.5, 1.0],
                    gradientFrom: const Offset(0, 0),
                    gradientTo: const Offset(0, 1),
                    spotsLine: BarAreaSpotsLine(
                      show: true,
                      flLineStyle: FlLine(
                        color: Colors.blue,
                        strokeWidth: 2,
                      ),
                      checkToShowSpotLine: (spot) {
                        if (spot.x == 0 || spot.x == 6) {
                          return false;
                        }

                        return true;
                      },
                    ),
                  ),
                  dotData: FlDotData(
                      show: true,
                      getDotColor: (spot, percent, barData) => Colors.white,
                      dotSize: 6,
                      strokeWidth: 3,
                      getStrokeColor: (spot, percent, barData) =>
                      Colors.deepOrange,
                      checkToShowDot: (spot, barData) {
                        return spot.x != 0 ;
                      }),
                ),
              ],
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  if (value == 0) {
                    return FlLine(
                      color: Colors.deepOrange,
                      strokeWidth: 2,
                    );
                  } else {
                    return FlLine(
                      color: Colors.white10,
                      strokeWidth: 0.5,
                    );
                  }
                },
                getDrawingVerticalLine: (value) {
                  if (value == 0) {
                    return FlLine(
                      color: Colors.orange[300],
                      strokeWidth: 2,
                    );
                  } else {
                    return FlLine(
                      color: Colors.orange[300],
                      strokeWidth: 0.5,
                    );
                  }
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: SideTitles(

                  textStyle: const TextStyle(color: Colors.black, fontSize: 10),
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) {
                    return weekDays[value.toInt()];
                  },
                  textStyle: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}