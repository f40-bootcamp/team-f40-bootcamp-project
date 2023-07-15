import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'feed_screen.dart';

class FavoriteBooksScreen extends StatefulWidget {
  @override
  State<FavoriteBooksScreen> createState() => _FavoriteBooksScreenState();
}

class _FavoriteBooksScreenState extends State<FavoriteBooksScreen> {
  late String userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }
  Future<void> removeBookFromFavorites(String bookId) async {
    await FirebaseFirestore.instance
        .collection('favoriteBooks')
        .doc(bookId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kitap favorilerden kaldırıldı'),
        backgroundColor: Colors.grey[800],
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userId = currentUser.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(150, 155, 210, 1.0),
        title: Text('Favori Kitaplarım',textAlign: TextAlign.center,),
      ),
      body: Container(
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
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('favoriteBooks')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Text('Veri Yok'),
              );
            } else {
              final books = snapshot.data!.docs;
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final bookName =
                  (books[index].data() as Map<String, dynamic>)['bookName'];
                  final bookId = books[index].id;
                  return ListTile(
                    leading: IconButton(onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                      content: Text('Kitap kütüphaneye eklendi'),
                      backgroundColor: Colors.grey[800],
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                      label: 'Geri al',
                      onPressed: () {
                      // Code to undo the action
                      },
                      ),
                      ),
                      );
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FeedPage(bookTitle: bookName)),
                  );
                  }, icon: Icon(FontAwesomeIcons.bookBookmark, color: Color.fromRGBO(82, 87, 124, 1.0),size: 18,)),
                    trailing: IconButton(onPressed: () => removeBookFromFavorites(bookId), icon: Icon(FontAwesomeIcons.trashCan, size: 18,color: Color.fromRGBO(
                        51, 91, 90, 1.0),)),

                    title: Text(bookName, style: TextStyle(color: Color.fromRGBO(
                        71, 76, 121, 1.0),fontWeight: FontWeight.w700,fontStyle: FontStyle.italic, fontSize: 15),),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
