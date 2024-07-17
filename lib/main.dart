import 'package:flutter/material.dart';


import 'package:codenext/properties.dart';
import 'package:window_manager/window_manager.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const CodeNext());}


class CodeNext extends StatelessWidget {
  const CodeNext({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeNext',
      home: const Home(),
      theme: Theme.of(context)
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      body: body(),
    );
  }

  Widget body(){
    return Expanded(
      child: Column(
        children: [
          Container(
            height: toolBarHeight,
            color: WIDGETS,
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Container(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.cookie,
                        color: Color.fromARGB(255, 209, 112, 209),
                        size: 30,
                      )
                    ),
                    
                    TextButton(
                      onPressed: (){}, 
                      child: Text("File",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      )
                    ),
                    TextButton(
                      onPressed: (){}, 
                      child: Text("Edit",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      )
                    ),
                    TextButton(
                      onPressed: (){}, 
                      child: Text("View",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      )
                    ),
                    TextButton(
                      onPressed: (){}, 
                      child: Text("Terminal",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      )
                    ),
                  ]
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: (){}, 
                      icon: Icon(
                        Icons.play_arrow,
                        size: 25,
                        color: Color.fromARGB(255, 65, 206, 47),
                      )
                    ),
                    IconButton(
                      onPressed: (){}, 
                      icon: Icon(
                        Icons.replay,
                        size: 20,
                        color: Color.fromARGB(255, 199, 147, 5),
                      )
                    ),      
                    IconButton(
                      onPressed: (){}, 
                      icon: Icon(
                        Icons.stop,
                        size: 25,
                        color: Color.fromARGB(255, 184, 19, 19),
                      )
                    )   
                  ],
                ),
              ],
            ),
          ),



          Container(
            height: MediaQuery.of(context).size.height - toolBarHeight,
            color: BACKGROUND,
            padding: EdgeInsets.only(left: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              
              children: [
                Text("Hello")
              ],
            ),
          )
        ],
      ),
    );
  }
}
