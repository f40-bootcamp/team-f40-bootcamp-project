import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'feed_screen.dart';

class BookPage extends StatefulWidget {
  const BookPage({Key? key}) : super(key: key);

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  late TextEditingController _controller;
  late TextEditingController _controllerB;
  late TextEditingController _controllerC;
  String userId = '';
  List<Widget> bookList = [];

  @override
  void initState() {
    _controller = TextEditingController();
    _controllerB = TextEditingController();
    _controllerC = TextEditingController();
    _getCurrentUser();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerB.dispose();
    _controllerC.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userId = currentUser.uid;
      });
    }
  }

  void bookAddition(String bookName, int spentTime, String comment) {
    _addBookToFirestore(bookName, spentTime, comment);
  }

  final CollectionReference _usersBookCollection =
  FirebaseFirestore.instance.collection('userBooks');

  Future<void> _addBookToFirestore(
      String bookName,
      int spentTime,
      String comment,
      ) async {
    await _usersBookCollection.add({
      'userId': userId,
      'bookName': bookName,
      'spentTime': spentTime,
      'comment': comment,
    });
  }

  Future<void> _updateBookInFirestore(
      String bookId,
      String bookName,
      int spentTime,
      String comment,
      ) async {
    await _usersBookCollection.doc(bookId).update({
      'bookName': bookName,
      'spentTime': spentTime,
      'comment': comment,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kitap güncellendi')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kitap güncellenirken bir hata oluştu')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Kitaplar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Color.fromRGBO(82, 87, 124, 1.0),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all(const Color.fromRGBO(149, 157, 224, 1.0)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 9.0, horizontal: 12),
              ),
              textStyle: MaterialStateProperty.all(
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.16),
                ),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Color.fromRGBO(
                      255, 255, 255, 0.8156862745098039),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0))),

                  title: const Text(
                    'Kitap Ekle', textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600,color: Color.fromRGBO(135, 142, 205, 1)),
                  ),
                  content: Container( decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(185, 187, 223, 1),
                        Color.fromRGBO(187, 198, 240, 1),
                        Color.fromRGBO(183, 220, 218, 1),
                      ],),),
                    width: 400,
                    padding: EdgeInsets.all(40),
                    margin: EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                              labelText: 'Kitap İsmi', labelStyle: TextStyle(color:Color.fromRGBO(82, 87, 124, 1.0),)
                          ),
                        ),
                        SizedBox(height: 10,),
                        TextField(
                          controller: _controllerB,
                          decoration: const InputDecoration(
                              labelText: 'Harcanan Zaman',labelStyle: TextStyle(color:Color.fromRGBO(82, 87, 124, 1.0),)
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 10,),
                        TextField(
                          controller: _controllerC,
                          decoration: const InputDecoration(
                              labelText: 'Notunuz',labelStyle: TextStyle(color:Color.fromRGBO(82, 87, 124, 1.0),)
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(const Color.fromRGBO(135, 142, 205, 1)),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 9.0, horizontal: 15.0),
                        ),
                        textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(51.16),
                          ),
                        ),
                      ),
                      onPressed: () {
                        final bookName = _controller.text.trim();
                        final spentTimeText = _controllerB.text.trim();
                        final comment = _controllerC.text.trim();
                        int spentTime = 0;

                        if (spentTimeText.isNotEmpty) {
                          spentTime = int.parse(spentTimeText);
                        }

                        if (bookName.isNotEmpty) {
                          bookAddition(bookName, spentTime, comment);
                          _controller.clear();
                          _controllerB.clear();
                          _controllerC.clear();
                        }

                        Navigator.pop(context);
                      },
                      child: const Text('Ekle'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'İptal',
                        style: TextStyle(color: Color.fromRGBO(135, 142, 205, 1)),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Icon(Icons.add, size: 20),
          ),
          SizedBox(height: 20),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(10),
              child: StreamBuilder<QuerySnapshot>(
                stream: _usersBookCollection
                    .where('userId', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          Text('Veriler Yükleniyor'),
                        ],
                      ),
                    );
                  }

                  final documents = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 5,
                    ),
                    padding: const EdgeInsets.all(6),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final bookId = documents[index].id;
                      final bookName = documents[index].get('bookName');
                      final spentTime = documents[index].get('spentTime');
                      final comment = documents[index].get('comment');

                      return UserBookCard(
                        bookId: bookId,
                        bookName: bookName,
                        spentTime: spentTime,
                        comment: comment,
                        onUpdate: _updateBookInFirestore,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserBookCard extends StatefulWidget {
  final String bookId;
  final String bookName;
  final int spentTime;
  final String comment;
  final Function(String, String, int, String) onUpdate;

  const UserBookCard({
    required this.bookId,
    required this.bookName,
    required this.spentTime,
    required this.comment,
    required this.onUpdate,
  });

  @override
  _UserBookCardState createState() => _UserBookCardState();
}

class _UserBookCardState extends State<UserBookCard> {
  late String updatedBookName;
  late int updatedSpentTime;
  late String updatedComment;

  @override
  void initState() {
    updatedBookName = widget.bookName;
    updatedSpentTime = widget.spentTime;
    updatedComment = widget.comment;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            title: const Text('Kitap Düzenle',style: TextStyle(color: Color.fromRGBO(135, 142, 205, 1))),
            content: Container(
              width: 300,
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        updatedBookName = value;
                      });
                    },
                    decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),border: OutlineInputBorder(),
                      labelText: 'Kitap İsmi',labelStyle: TextStyle(fontSize:14,color:Color.fromRGBO(82, 87, 124, 1.0),),
                      hintText: updatedBookName,
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        updatedSpentTime = int.tryParse(value) ?? 0;
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),border: OutlineInputBorder(),
                      labelText: 'Harcanan Zaman', labelStyle: TextStyle(color:Color.fromRGBO(82, 87, 124, 1.0),),
                      hintText: updatedSpentTime.toString(),
                    ), style: TextStyle(fontSize: 14, color:Color.fromRGBO(82, 87, 124, 1.0),),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        updatedComment = value;
                      });
                    },
                    decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),border: OutlineInputBorder(),
                      labelText: 'Notunuz',labelStyle: TextStyle( fontSize:14,color:Color.fromRGBO(82, 87, 124, 1.0),),
                      hintText: updatedComment,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(const Color.fromRGBO(135, 142, 205, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 9.0, horizontal: 15.0),
                  ),
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(51.16),
                    ),
                  ),
                ),
                onPressed: () {
                  widget.onUpdate(widget.bookId, updatedBookName, updatedSpentTime, updatedComment);
                  Navigator.pop(context);
                },
                child: const Text('Kaydet'),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('İptal', style:TextStyle(color:Color.fromRGBO(82, 87, 124, 1.0),),)
              ),
            ],
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          padding: const EdgeInsets.only(bottom: 10,right: 10,left: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(185, 187, 223, 1),
                Color.fromRGBO(187, 198, 240, 1),
                Color.fromRGBO(183, 220, 218, 1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(183, 220, 218, 1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    minimumSize: Size(40, 20),
                    maximumSize: Size(50, 30),
                    textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),),
                    elevation: 4),
                  onPressed:() {Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => FeedPage(bookTitle: updatedBookName)),
                  );},
                  child: const Text('oku'),),
                Text(
                  '${widget.spentTime} dakika',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color.fromRGBO(72, 86, 215, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.bookName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color.fromRGBO(70, 75, 121, 1.0),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.comment,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color.fromRGBO(82, 87, 124, 1.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }}