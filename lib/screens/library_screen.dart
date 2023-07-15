import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:read_reminder/book_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String userId = '';
  bool favButtonStatus = false;

  Random random = Random();

  final CollectionReference _favoritesCollection =
  FirebaseFirestore.instance.collection('favoriteBooks');

  List<Book> favoritesBooks = [];

  @override
  void initState() {
    super.initState();
    _loadFavoritesBooks();
  }

  Future<void> _loadFavoritesBooks() async {
    var favoritesList = await getFavoritesBooks();
    setState(() {
      favoritesBooks = favoritesList;
      if (favButtonStatus) {
        favButtonStatus = false;
      } else {
        favButtonStatus = true;
      }
    });
  }

  Future<void> addToFavorites(String title, String author) async {
    var userId = await _getCurrentUser();
    var bookName = '$title by $author';

    var isBookExist = await _checkIfBookExists(userId, bookName);
    if (!isBookExist) {
      await _favoritesCollection.add({
        'userId': userId,
        'bookName': bookName,
      });

      _loadFavoritesBooks();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kitap favorilere eklendi'),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Geri al',
            onPressed: () {
              removeFromFavorites(title, author);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Kitap favorilerden kaldırıldı'),
                  backgroundColor: Colors.grey[800],
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kitap favorilerde mevcut'),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> removeFromFavorites(String title, String author) async {
    var userId = await _getCurrentUser();
    var bookName = '$title by $author';

    var querySnapshot = await _favoritesCollection
        .where('userId', isEqualTo: userId)
        .where('bookName', isEqualTo: bookName)
        .get();

    querySnapshot.docs.forEach((doc) {
      doc.reference.delete();
    });

    _loadFavoritesBooks();
  }

  Future<List<Book>> getFavoritesBooks() async {
    var userId = await _getCurrentUser();

    var querySnapshot =
    await _favoritesCollection.where('userId', isEqualTo: userId).get();

    var favoritesList = querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        var bookName = data['bookName'];
        var title = bookName.split(' by ')[0];
        var author = bookName.split(' by ')[1];
        return Book(title, author);
      } else {
        throw Exception('Data is null or has an invalid format!!!');
      }
    }).toList();

    return favoritesList;
  }

  Future<String> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userId = currentUser.uid;
      });
    }
    return userId;
  }

  Future<List<dynamic>> getBookList() async {
    var url =
        'https://www.googleapis.com/books/v1/volumes?q=subject:fiction&langRestrict=tr&maxResults=30&&key=AIzaSyDSVaR4VzkyF4ZNW3f8gzYIO_KzEAQckJc';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var items = data['items'] as List<dynamic>;

      return items;
    } else {
      throw Exception(
          'API çağrısı başarısız oldu. Hata kodu: ${response.statusCode}');
    }
  }

  Future<bool> _checkIfBookExists(String userId, String bookName) async {
    var snapshot = await _favoritesCollection
        .where('userId', isEqualTo: userId)
        .where('bookName', isEqualTo: bookName)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  bool isBookInFavorites(String title, String author) {
    return favoritesBooks.contains(Book(title, author));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.star,
                        color: Color.fromRGBO(98, 217, 217, 1.0),
                      ),
                      SizedBox(
                        width: 14,
                      ),
                      Text(
                        'Hızlı Kitap Önerisi',
                        style: TextStyle(
                          color: Color.fromRGBO(98, 217, 217, 1.0),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        FontAwesomeIcons.star,
                        color: Color.fromRGBO(98, 217, 217, 1.0),
                      ),
                    ],
                  ),
                  FutureBuilder<List<dynamic>>(
                    future: getBookList(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var bookList = snapshot.data;
                        var randomBookIndex = random.nextInt(bookList!.length);
                        var randomBook = bookList[randomBookIndex];
                        var randomBookTitle =
                        randomBook['volumeInfo']['title'];
                        var randomBookAuthor =
                            randomBook['volumeInfo']['authors'][0] ??
                                'Yazar bilgisi mevcut değil';
                        var randomImageLinks =
                        randomBook['volumeInfo']['imageLinks'] != null
                            ? randomBook['volumeInfo']['imageLinks']
                        ['smallThumbnail']
                            : 'https://placekitten.com/600/800';

                        return Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    randomBookTitle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    randomBookAuthor,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Image.network(
                                randomImageLinks,
                                height: 50,
                                width: 50,
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Hata: ${snapshot.error}');
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Scrollbar(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Haftanın Kitap Önerileri',
                      style: TextStyle(
                        color: Color.fromRGBO(69, 74, 113, 1.0),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(5),
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: FutureBuilder<List<dynamic>>(
                        future: getBookList(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var bookList = snapshot.data;
                            return ListView.builder(
                              itemCount: bookList!.length,
                              itemBuilder: (context, index) {

                                var book = bookList[index];
                                var title = book['volumeInfo']['title'];
                                var subtitle =
                                    book['volumeInfo']['authors'][0] ??
                                        'Yazar bilgisi mevcut değil';
                                favButtonStatus = isBookInFavorites(title, subtitle);
                                IconButton button = IconButton(
                                  icon: favButtonStatus
                                      ? const Icon(Icons.favorite_border)
                                      : const Icon(Icons.favorite),
                                  onPressed: () {
                                    if (isBookInFavorites(title, subtitle)) {
                                      removeFromFavorites(title, subtitle);
                                    } else {
                                      addToFavorites(title, subtitle);
                                    }
                                  },
                                );
                                var imageLinks =
                                book['volumeInfo']['imageLinks'] != null
                                    ? book['volumeInfo']['imageLinks']
                                ['smallThumbnail']
                                    : 'https://placekitten.com/600/800';

                                return ListTile(
                                  leading: button,
                                  title: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(54, 56, 84, 1.0),
                                    ),
                                  ),
                                  subtitle: Text(subtitle),
                                  trailing: Image.network(imageLinks),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => BookDetails(
                                          index: index,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Text('Hata: ${snapshot.error}');
                          }
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Veriler Yükleniyor'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}