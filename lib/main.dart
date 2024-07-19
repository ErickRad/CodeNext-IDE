import 'dart:io';
import 'package:codenext/properties.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:process_run/shell.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

TextEditingController code = TextEditingController();
TextEditingController terminalOutput = TextEditingController();
File? file;
final shell = Shell();

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
  String currentFilePath = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      terminalOutput.text = "PS $currentFilePath>";
    });
  }

  Future<void> runPythonCode() async {
    if (file == null) {
      setState(() {
        terminalOutput.text = 'Error: No file selected';
      });
      return;
    } else {
      saveFile();
    }

    try {
      var result = await shell.run('python ${file!.path}');

      setState(() {
        terminalOutput.text = "PS $currentFilePath> ${result.outText}";
      });
    } catch (e) {
      setState(() {
        terminalOutput.text = "PS $currentFilePath> $e";
      });
    }
  }

  Future<void> openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['py'],
    );

    if (result != null) {
      file = File(result.files.single.path!);
      String contents = await file!.readAsString();
      setState(() {
        code.text = contents;
        currentFilePath = file!.path;
        terminalOutput.text = "PS $currentFilePath>";
      });
    }
  }

  Future<void> saveFile() async {
    if (currentFilePath.isEmpty) {
      await saveFileAs();
    } else {
      File fileToSave = File(currentFilePath);
      await fileToSave.writeAsString(code.text);
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
      file = File(outputPath);
      await file!.writeAsString(code.text);
      setState(() {
        currentFilePath = file!.path;
      });
    }
  }

  Widget buildDirectoryTree(String rootPath) {
    Directory rootDir = Directory(rootPath);
    List<FileSystemEntity> entities = rootDir.listSync();

    return ListView.builder(
      itemCount: entities.length,
      itemBuilder: (context, index) {
        FileSystemEntity entity = entities[index];
        return ListTile(
          title: Text(
            p.basename(entity.path),
            style: TextStyle(color: Colors.white),
          ),
          onTap: () async {
            if (entity is File) {
              String contents = await entity.readAsString();
              setState(() {
                code.text = contents;
                file = entity;
                currentFilePath = entity.path;
                terminalOutput.text = "PS $currentFilePath>";
              });
            }
          },
        );
      },
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
          height: 40,
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
                      color: Colors.purpleAccent,
                      size: 30,
                    ),
                  ),
                  TextButton(
                    onPressed: openFile,
                    child: Text(
                      "Open",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: saveFile,
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: saveFileAs,
                    child: Text(
                      "Save As",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
                      color: Colors.green,
                    ),
                  ),
                  IconButton(
                    onPressed: runPythonCode,
                    icon: Icon(
                      Icons.stop,
                      size: 20,
                      color: Color.fromARGB(255, 180, 14, 14),
                    ),
                  ),
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
                  child: buildDirectoryTree(Directory.current.path),
                ),
                Container(
                  width: 6,
                  color: Colors.grey[700],
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
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 6,
          color: Color.fromARGB(255, 50, 50, 50),
        ),
        Container(
          height: 200,
          color: WIDGETS,
          child: SingleChildScrollView(
            child: TextField(
              controller: terminalOutput,
              readOnly: false,
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
