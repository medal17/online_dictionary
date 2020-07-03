import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _url="https://owlbot.info/api/v4/dictionary/";
  String _token= "fbb718c4b1d3b7e36e3d15aaf4f6e51074ca618b";

  TextEditingController _controller = TextEditingController();
  StreamController _streamController;
  Stream _stream;

  Timer time;
  _search() async{
    if(_controller.text.isEmpty || _controller.text.length==0){
      _streamController.add(null);
      return;
    }
    _streamController.add("waiting");
    Response response= await get(_url + _controller.text.trim(), headers: {"Authorization":"Token " + _token});
    _streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('My Dictionary'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58.0),
          child: Container(

            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    //padding: EdgeInsets.only(bottom: 10),
                    height:MediaQuery.of(context).size.height*0.07,
                    width: MediaQuery.of(context).size.width*0.8,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                        color: Colors.white
                    ),
                    child: TextFormField(
                      onChanged: (String text){
                        if(time.isActive ?? false) time.cancel();
                        time= Timer(Duration(milliseconds: 1000), (){
                          _search();
                        });
                      },
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your Word",
                        contentPadding: EdgeInsets.only(left: 20.0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: (){
                    _search();
                  },
                )
              ],
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext cxt, AsyncSnapshot snapshot){
            if(snapshot.data == null){
              return Center(child: Text('Input a text'));
            }
            if(snapshot.data=="waiting"){
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data["definitions"].length,
                itemBuilder: (
                BuildContext context, int index){
              return ListBody(
                children: <Widget>[
                  Container(
                    color:
                    Colors.grey[300],
                    child: ListTile(
                      leading: snapshot.data["definitions"][index]["image_url"]==null
                          ? null :
                      CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data["definitions"][index]["image_url"]),
                      ),
                      title: Text(_controller.text.trim() +  "{" + snapshot.data["definitions"][index]["type"] +"}",
                        style:TextStyle(fontWeight: FontWeight.w600,fontFamily: "Montserrat") ,),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue.withOpacity(0.2),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),

                        child: Text(snapshot.data["definitions"][index]["definition"])
                    ),
                  )
                ],
              );
            });
          },
        ),
      ),
    );
  }
}
