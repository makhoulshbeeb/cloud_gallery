import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final ImagePicker _imagePicker = ImagePicker();
  final supabase = Supabase.instance.client;

  final DocumentReference _reference = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  String username = '';
  String _currentFolder = "Images";
  _getUsername() async {
    var docSnapshot = await _reference.get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data()! as Map<String, dynamic>;
      setState(() {
        username = data['Username'];
      });
    }
  }

  Future _pickImageFromGallery() async {
    final imageResult = await FilePicker.platform.pickFiles(
      withReadStream: true,
      type: FileType.image,
      withData: true,
    );
    Uint8List? imageToUpload;
    if (!kIsWeb) {
      XFile? image = XFile(imageResult!.files.single.path!);
      imageToUpload = await image.readAsBytes();
    } else {
      imageToUpload = imageResult?.files.single.bytes;
    }
    await _uploadFile(imageToUpload, "Images");
  }

  Future _pickVideoFromGallery() async {
    final imageResult = await FilePicker.platform.pickFiles(
      withReadStream: true,
      type: FileType.video,
      withData: true,
    );
    Uint8List? imageToUpload;
    if (!kIsWeb) {
      XFile? image = XFile(imageResult!.files.single.path!);
      imageToUpload = await image.readAsBytes();
    } else {
      imageToUpload = imageResult?.files.single.bytes;
    }
    await _uploadFile(imageToUpload, "Videos");
  }

  Future _pickAudioFromGallery() async {
    final imageResult = await FilePicker.platform.pickFiles(
      withReadStream: true,
      type: FileType.audio,
      withData: true,
    );
    Uint8List? imageToUpload;
    if (!kIsWeb) {
      XFile? image = XFile(imageResult!.files.single.path!);
      imageToUpload = await image.readAsBytes();
    } else {
      imageToUpload = imageResult?.files.single.bytes;
    }
    await _uploadFile(imageToUpload, "Audio");
  }

  Future _pickDocumentFromGallery() async {
    final imageResult = await FilePicker.platform.pickFiles(
      withReadStream: true,
      type: FileType.custom,
      withData: true,
      allowedExtensions: [
        'doc',
        'docx',
        'eps',
        'css',
        'xls',
        'psd',
        'dll',
        'ppt',
        'txt',
        'htm',
        'html',
        'pdf',
        'zip'
      ],
    );
    Uint8List? imageToUpload;
    if (!kIsWeb) {
      XFile? image = XFile(imageResult!.files.single.path!);
      imageToUpload = await image.readAsBytes();
    } else {
      imageToUpload = imageResult?.files.single.bytes;
    }
    await _uploadFile(imageToUpload, "Documents");
  }

  Future _pickImageFromCamera() async {
    XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    Uint8List? imageToUpload = await image!.readAsBytes();
    await _uploadFile(imageToUpload, "Images");
  }

  Future _uploadFile(Uint8List? file, String folder) async {
    if (file == null) return;

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    await supabase.storage.from(folder.toLowerCase().trim()).uploadBinary(folder.toLowerCase().trim()+"/"+uniqueFileName, file);
    List<dynamic> url = [
      supabase.storage.from(folder.toLowerCase().trim()).getPublicUrl(uniqueFileName)
    ];
    await _reference.update({folder: FieldValue.arrayUnion(url)});
  }

  Future _deleteFile(List<dynamic> updatedList, String folder) async {
    await _reference.update({folder: updatedList});
  }

  _activeFolder(String thisFolder) {
    if (thisFolder == _currentFolder) {
      return LinearGradient(
          colors: [Colors.deepPurple.shade300, Colors.purple.shade300]);
    } else {
      return null;
    }
  }

  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    _getUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text(
            'Cloud Gallery',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: Colors.white60),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.deepPurple.shade400,
              Colors.purple.shade300
            ])),
          ),
          iconTheme: const IconThemeData(color: Colors.white60),
        ),
        drawer: Drawer(
          backgroundColor: Colors.grey[800],
          surfaceTintColor: Colors.white54,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountEmail:
                    Text(FirebaseAuth.instance.currentUser!.email.toString()),
                accountName: Text(
                  username,
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Colors.purple.shade300,
                  Colors.deepPurple.shade400
                ])),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    gradient: _activeFolder("Images"),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentFolder = "Images";
                      });
                    },
                    leading: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white54,
                    ),
                    title: const Text(
                      'Images',
                      style: TextStyle(fontSize: 16.0, color: Colors.white60),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    gradient: _activeFolder("Videos"),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentFolder = "Videos";
                      });
                    },
                    leading: const Icon(
                      Icons.video_collection_outlined,
                      color: Colors.white54,
                    ),
                    title: const Text(
                      'Videos',
                      style: TextStyle(fontSize: 16.0, color: Colors.white60),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    gradient: _activeFolder("Audio"),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentFolder = "Audio";
                      });
                    },
                    leading: const Icon(
                      Icons.my_library_music_outlined,
                      color: Colors.white54,
                    ),
                    title: const Text(
                      'Audio',
                      style: TextStyle(fontSize: 16.0, color: Colors.white60),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    gradient: _activeFolder("Documents"),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentFolder = "Documents";
                      });
                    },
                    leading: const Icon(
                      Icons.file_copy_outlined,
                      color: Colors.white54,
                    ),
                    title: const Text(
                      'Documents',
                      style: TextStyle(fontSize: 16.0, color: Colors.white60),
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: ListTile(
                  trailing: IconButton(
                      onPressed: _signOut,
                      icon: const Icon(
                        Icons.logout_outlined,
                        color: Colors.white54,
                      )),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: SpeedDial(
          closeManually: false,
          gradientBoxShape: BoxShape.circle,
          gradient: LinearGradient(colors: [
            Colors.purple.shade300,
            Colors.deepPurple.shade400,
          ]),
          icon: Icons.add,
          activeIcon: Icons.close,
          iconTheme: const IconThemeData(color: Colors.white54),
          backgroundColor: Colors.deepPurple[300],
          overlayColor: Colors.black,
          overlayOpacity: 0.4,
          animationCurve: Curves.slowMiddle,
          children: [
            SpeedDialChild(
              shape: const CircleBorder(),
              labelStyle: const TextStyle(color: Colors.white54),
              labelBackgroundColor: Colors.grey[800],
              backgroundColor: Colors.deepPurple[200],
              label: 'Camera',
              child: GestureDetector(
                  onTap: _pickImageFromCamera,
                  child: const Icon(
                    Icons.camera_alt,
                  )),
            ),
            SpeedDialChild(
              shape: const CircleBorder(),
              labelStyle: const TextStyle(color: Colors.white54),
              labelBackgroundColor: Colors.grey[800],
              backgroundColor: Colors.deepPurple[200],
              label: 'Image',
              child: GestureDetector(
                onTap: _pickImageFromGallery,
                child: const Icon(
                  Icons.photo,
                ),
              ),
            ),
            SpeedDialChild(
              shape: const CircleBorder(),
              labelStyle: const TextStyle(color: Colors.white54),
              labelBackgroundColor: Colors.grey[800],
              backgroundColor: Colors.deepPurple[200],
              label: 'Video',
              child: GestureDetector(
                onTap: _pickVideoFromGallery,
                child: const Icon(
                  Icons.ondemand_video_rounded,
                ),
              ),
            ),
            SpeedDialChild(
              shape: const CircleBorder(),
              labelStyle: const TextStyle(color: Colors.white54),
              labelBackgroundColor: Colors.grey[800],
              backgroundColor: Colors.deepPurple[200],
              label: 'Audio',
              child: GestureDetector(
                onTap: _pickAudioFromGallery,
                child: const Icon(
                  Icons.audiotrack,
                ),
              ),
            ),
            SpeedDialChild(
              shape: const CircleBorder(),
              labelStyle: const TextStyle(color: Colors.white54),
              labelBackgroundColor: Colors.grey[800],
              backgroundColor: Colors.deepPurple[200],
              label: 'Document',
              child: GestureDetector(
                onTap: _pickDocumentFromGallery,
                child: const Icon(
                  Icons.description_outlined,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<DocumentSnapshot>(
            stream: _reference.snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Text('No data available');
              }
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              List<dynamic> imageURLs = data[_currentFolder];
              return _buildImageGrid(imageURLs);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<dynamic> imageURLs) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: imageURLs.length,
      itemBuilder: (
        context,
        index,
      ) {
        String imageURL = imageURLs[index];
        if (_currentFolder == "Images") {
          return GestureDetector(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                      "Are you sure you want to delete?",
                      style: TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.grey[800],
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, 'Cancel');
                            imageURLs.remove(imageURL);
                            _deleteFile(imageURLs, _currentFolder);
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white54),
                          )),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, 'Cancel');
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black26,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0)),
                    child: Image.network(imageURL)),
              ),
            ),
          );
        } else if (_currentFolder == "Videos") {
          late VideoPlayerController controller =
              VideoPlayerController.networkUrl(Uri.parse(imageURL));
          late Future<void> initializeVideoPlayerFuture =
              controller.initialize();
          return GestureDetector(
            onTap: () {
              setState(() {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              });
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                      "Are you sure you want to delete?",
                      style: TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.grey[800],
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, 'Cancel');
                            imageURLs.remove(imageURL);
                            _deleteFile(imageURLs, _currentFolder);
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white54),
                          )),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, 'Cancel');
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black26,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
                  child: FutureBuilder(
                    future: initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        }
        return null;
      },
    );
  }
}
