import 'dart:io';
import 'package:flutter/material.dart';
import 'package:codenext/properties.dart';
import 'package:window_manager/window_manager.dart';
import 'package:process_run/shell.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

TextEditingController code = TextEditingController();
TextEditingController terminalOutput = TextEditingController();

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

  runApp(const CodeNext());
}

class CodeNext extends StatelessWidget {
  const CodeNext({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeNext',
      home: const Home(),
      theme: ThemeData.dark(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String currentFilePath = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> runPythonCode() async {
    final tempDir = await getTemporaryDirectory();
    final pythonFile = File('${tempDir.path}/temp_code.py');
    await pythonFile.writeAsString(code.text);

    final shell = Shell();

    try {
      var result = await shell.run('python ${pythonFile.path}');

      setState(() {
        terminalOutput.text = result.outText;
      });
    } catch (e) {
      setState(() {
        terminalOutput.text = 'Error: $e';
      });
    }
  }

  Future<void> openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['py'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String contents = await file.readAsString();
      setState(() {
        code.text = contents;
        currentFilePath = file.path;
      });
    }
  }

  Future<void> saveFile() async {
    if (currentFilePath.isEmpty) {
      await saveFileAs();
    } else {
      File file = File(currentFilePath);
      await file.writeAsString(code.text);
    }
  }

  Future<void> saveFileAs() async {
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Python File',
      fileName: 'code.py',
      type: FileType.custom,
      allowedExtensions: ['py'],
    );

    if (outputPath != null) {
      File file = File(outputPath);
      await file.writeAsString(code.text);
      setState(() {
        currentFilePath = file.path;
      });
    }
  }

  Widget buildDirectoryTree() {
    // This function is a placeholder for building the directory tree
    // Implement this based on your specific requirements
    return Container(
      color: WIDGETS,
      child: Column(
        children: [
          Text('Directory Tree', style: TextStyle(color: Colors.white)),
          // Add directory tree structure here
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return Column(
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
                    onPressed: openFile, 
                    child: Text("File",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    )
                  ),
                  TextButton(
                    onPressed: saveFile, 
                    child: Text("Save",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    )
                  ),
                  TextButton(
                    onPressed: saveFileAs, 
                    child: Text("Save As",
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
                    onPressed: runPythonCode, 
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
        Expanded(
          child: Container(
            color: BACKGROUND,
            padding: EdgeInsets.only(left: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: buildDirectoryTree(),
                ),
                Container(
                  width: 6,
                  color: DIVISORS
                ),
                Expanded(
                  flex: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          child: TextField(
                            controller: code,
                            autocorrect: false,
                            maxLines: null,
                            cursorHeight: 20,
                            style: TextStyle(
                              color: Colors.white
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                          )
                        )
                      )
                    ],
                  )
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 6,
          color: DIVISORS,
        ),
        Container(
          height: 200,
          color: WIDGETS,
          child: SingleChildScrollView(
            child: TextField(
              controller: terminalOutput,
              readOnly: true,
              maxLines: null,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
