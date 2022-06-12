import 'dart:ui';

import 'package:finacash/Helper/MyDatabaseHelper.dart';
import 'package:finacash/Widgets/AnimatedBottomNavBar.dart';
import 'package:finacash/Widgets/CardMoneyItem.dart';
import 'package:finacash/Widgets/CustomDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String saldoAtual = "";
  var total;
  var width;
  var height;
  bool recDesp = false;
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  MySqlDataBaseHelper movHelper = MySqlDataBaseHelper();
  TextEditingController _valorController = TextEditingController();
  CalendarController calendarController;
  MySqlDataBaseHelper movimentacoesHelper = MySqlDataBaseHelper();
  List<MoneyItem> listmoneyitem = List();
  List<MoneyItem> ultimaTarefaRemovida = List();

  var dataAtual = new DateTime.now();
  var formatter = new DateFormat('dd-MM-yyyy');
  var formatterCalendar = new DateFormat('MM-yyyy');
  String dateFormatada;

  String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  _addValor() {
    String valor = _valorController.text;
    setState(() {
      saldoAtual = valor;
    });
  }

  _saldoTamanho(String conteudo) {
    if (conteudo.length > 8) {
      return width * 0.08;
    } else {
      return width * 0.1;
    }
  }

  _salvar() {
    dateFormatada = formatter.format(dataAtual);
    MoneyItem mov = MoneyItem();
    mov.valor = 20.50;
    mov.transactionType = "r";
    mov.date = "10-03-2020"; //dataFormatada;
    mov.description = "CashBack";
    MySqlDataBaseHelper movimentacoesHelper = MySqlDataBaseHelper();
    movimentacoesHelper.saveMoneyItem(mov);
    mov.toString();
  }

  _allMov() {
    movimentacoesHelper.getAllMoneyItem().then((list) {
      setState(() {
        listmoneyitem = list;
      });
      print("All Mov: $listmoneyitem");
    });
  }

  _allMovMes(String data) {
    movimentacoesHelper.getAllMoneyItems(data).then((list) {
      if (list.isNotEmpty) {
        setState(() {
          listmoneyitem = list;
          //total =listmovimentacoes.map((item) => item.valor).reduce((a, b) => a + b);
        });
        total =
            listmoneyitem.map((item) => item.valor).reduce((a, b) => a + b);
        saldoAtual = format(total).toString();
      } else {
        setState(() {
          listmoneyitem.clear();
          total = 0;
          saldoAtual = total.toString();
        });
      }

      //print("TOTAL: $total");
      //print("All MovMES: $listmovimentacoes");
    });
  }

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calendarController = CalendarController();
    if (DateTime.now().month != false) {
      //saldoAtual = "1259";
    }
    //_salvar();
    dateFormatada = formatterCalendar.format(dataAtual);
    print(dateFormatada);
    _allMovMes(dateFormatada);

    //_allMov();
  }

  _dialogAddRecDesp() {
    showDialog(
        context: context,
        builder: (context) {
          return CustomDialog();
        });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    _allMovMes(dateFormatada);
    return Scaffold(
      key: _scafoldKey,
      body: SingleChildScrollView(
        primary: false,
        physics: NeverScrollableScrollPhysics(),
        //physics: ClampingScrollPhysics(),
        //height: height,
        //width: width,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: height * 0.334, //300,
                  color: Colors.white,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                      width: double.infinity,
                      height: height * 0.28, //250,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[700], //Colors.indigo[400],
                      )),
                ),
                Positioned(
                  top: width * 0.15, //70
                  left: width * 0.07, //30,
                  child: Text(
                    "FinaCash",
                    style: TextStyle(
                        color: Colors.white, fontSize: width * 0.074 //30
                        ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: width * 0.07, // 30,
                  right: width * 0.07, // 30,
                  child: Container(
                    height: height * 0.21, //150,
                    width: width * 0.1, // 70,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey[400],
                              blurRadius: 5,
                              offset: Offset(0, 2))
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.05,
                            top: width * 0.04,
                            bottom: width * 0.02,
                          ),
                          child: Text(
                            "Total",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: width * 0.05),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: width * 0.05),
                              child: Container(
                                width: width * 0.6,
                                
                                child: Text(
                                saldoAtual,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors
                                        .lightBlue[700], //Colors.indigo[400],
                                    fontWeight: FontWeight.bold,
                                    fontSize: _saldoTamanho(saldoAtual),
                                        //width * 0.1 //_saldoTamanho(saldoAtual)
                                    ),
                              ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: width * 0.04),
                              child: GestureDetector(
                                onTap: () {
                                  _dialogAddRecDesp();
                                  /* Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddReceita()));
                                 */
                                },
                                child: Container(
                                  width: width * 0.12,
                                  height: width * 0.12, //65,
                                  decoration: BoxDecoration(
                                      color: Colors
                                          .lightBlue[700], //Colors.indigo[400],
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 7,
                                          offset: Offset(2, 2),
                                        )
                                      ]),
                                  child: Icon(
                                    Icons.add,
                                    size: width * 0.07,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: height * 0.008,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            TableCalendar(
              calendarController: calendarController,
              headerStyle: HeaderStyle(
                formatButtonShowsNext: false,
                formatButtonVisible: false,
                centerHeaderTitle: true,
              ),
              calendarStyle: CalendarStyle(outsideDaysVisible: false),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.transparent),
                weekendStyle: TextStyle(color: Colors.transparent),
              ),
              rowHeight: 0,
              initialCalendarFormat: CalendarFormat.month,
              onVisibleDaysChanged: (dateFirst, dateLast, CalendarFormat cf) {
                print(dateFirst);

                dateFormatada = formatterCalendar.format(dateFirst);
                _allMovMes(dateFormatada);

                print("DATA FORMATADA CALENDAR $dateFormatada");

              },
            ),
            Padding(
                padding:
                    EdgeInsets.only(left: width * 0.04, right: width * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Movement",
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: width * 0.04),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: width * 0.02),
                      child: Icon(
                        Icons.sort,
                        size: width * 0.07,
                        color: Colors.grey[400],
                      ),
                    )
                  ],
                )),
            Padding(
              padding: EdgeInsets.only(
                  left: width * 0.04, right: width * 0.04, top: 0),
              child: SizedBox(
                width: width,
                height: height * 0.47,
                child: ListView.builder(
                  itemCount: listmoneyitem.length,
                  itemBuilder: (context, index) {
                    MoneyItem mov = listmoneyitem[index];
                    MoneyItem ultMov = listmoneyitem[index];
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          listmoneyitem.removeAt(index);
                        });
                        movHelper.deleteMoneyItem(mov);
                        final snackBar = SnackBar(
                          content: Container(
                            padding: EdgeInsets.only(bottom: width * 0.025),
                            alignment: Alignment.bottomLeft,
                            height: height * 0.05,
                            child: Text(
                              "Undo Action",
                              style: TextStyle(
                                  color: Colors.white,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: width * 0.05),
                            ),
                          ),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.orange[800],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15))),
                          action: SnackBarAction(
                            label: "Undo",
                            textColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                listmoneyitem.insert(index, ultMov);
                              });

                              movHelper.saveMoneyItem(ultMov);
                            },
                          ),
                        );
                        _scafoldKey.currentState.showSnackBar(snackBar);
                      },
                      key: ValueKey(mov.id),
                      background: Container(
                        padding: EdgeInsets.only(right: 10 ,top: width * 0.04),
                        alignment: Alignment.topRight,
                        color: Colors.red,
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: width * 0.07,
                        ),
                      ),
                      child: CardMoneyItem(
                        mov: mov,
                        lastItem: listmoneyitem[index] == listmoneyitem.last? true : false,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text( "SAMPLE TEXT PADDING"),
            )
          ],
        ),
      ),
    );
  }
}
