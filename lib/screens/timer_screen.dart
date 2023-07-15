//import 'dart:js_interop';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';


class TimerPage extends StatefulWidget {
  final String bookName;
  const TimerPage({super.key, String? bookName}) : bookName = bookName ?? '';

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RotatingImages(bookName: widget.bookName),
      ),
      //bottomNavigationBar: BottomNavigationBarPage(),
    );
  }
}

class RotatingImages extends StatefulWidget {
  final String bookName;

  const RotatingImages({super.key, String? bookName})
      : bookName = bookName ?? '';
  _RotatingImagesState createState() => _RotatingImagesState();
}

class _RotatingImagesState extends State<RotatingImages>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isRotating = false;
  late int totalReadingTime;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? timer;
  bool _isRunning = false;
  int hours1 = 0;
  int minutes1 = 0;
  int _elapsedTime = 0;
  String choose = '0';
  int choosen = 0;
  bool ifchoosen = false;



  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..addListener(() {
      setState(() {});
    });

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    //In order to get the logined user's current coin value when the page is opened;
    if (user != null) {
      CoinProvider coinProvider =
      Provider.of<CoinProvider>(context, listen: false);
      coinProvider.getUsersCoin();
    }
  }

  //called whenever the dependencies of the widget change, which includes when the page is first loaded or when the page is revisited;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    fetchTodaysReadingTime();
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  //Fetchs the total reading time in a day;
  Future<void> fetchTodaysReadingTime() async {
    try {
      //print(user?.uid);
      totalReadingTime = 0;
      DateTime today = DateTime.now();
      DateTime todayStart = DateTime(today.year, today.month, today.day);
      DateTime todayEnd = todayStart.add(const Duration(days: 1));

      // Create a collection reference for the bookReadingTimes collection
      CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('bookReadingTimes');

      // Create a query to fetch the documents for today
      QuerySnapshot querySnapshot = await collectionRef
          .where('userId', isEqualTo: user?.uid)
          .where('date', isGreaterThanOrEqualTo: todayStart)
          .where('date', isLessThan: todayEnd)
          .get();

      //print(querySnapshot);

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
          Map<String, dynamic> readingTimeData =
          docSnapshot.data() as Map<String, dynamic>;
          int readingTime = readingTimeData['readingTime'];
          setState(() {
            totalReadingTime += readingTime;
          });
        }
      } else {
        print('No reading time data available for today');
      }
    } catch (e) {
      print('Error fetching total reading time: $e');
    }
  }

  void _toggleRotation() {
    setState(() {
      if (_isRotating) {
        _animationController.stop();
      } else {
        _animationController.repeat();
      }
      _isRotating = !_isRotating;
    });
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
      _stopwatch.start();
      _elapsedTime++;
    });
  }

  void _stopStopwatch() {
    setState(() {
      _isRunning = false;
      _stopwatch.stop();
    });
  }

  void _resetStopwatch() {
    setState(() {
      _isRunning = false;
      _stopwatch.reset();
      _elapsedTime = 0;
    });
  }


  TextEditingController  controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String? userId;
    if (user != null) {
      userId = user!.uid;
    }

    CollectionReference userBooksCollection =
    FirebaseFirestore.instance.collection('userBooks');

    Future<void> addUserBook() {
      return userBooksCollection
          .add({
        'bookName': widget.bookName,
        'comment': '',
        'spentTime': minutes1, //timer durduruldugunda alinan sure gelecek
        'userId': userId
      })
          .then((value) => print('User book record is added successfully'))
          .catchError(
              (error) => print('Failed to add user book record: $error'));
    }

    Future<void> updateUserBook(DocumentSnapshot bookDoc) {
      Map<String, dynamic> bookData = bookDoc.data() as Map<String, dynamic>;
      int oldSpentTimeVal = bookData['spentTime'];
      int updatedSpentTime = oldSpentTimeVal +
          minutes1; //timer durduruldugunda alinan sure eklenecek...

      DocumentReference userBookDocRef = bookDoc.reference;
      return userBookDocRef
          .update({'spentTime': updatedSpentTime})
          .then((value) => print('userBook data is updated successfully'))
          .catchError(
              (error) => print('Failed to update userBook data: $error'));
    }

    //Bu metodu timer durduruldugunda cagirman gerekiyor. Boylece login olan kullanici icin mevcut olarak okunan kitapla ilgili
    //Firestore'da kayit varsa, bu kayittaki kitap icin okunan sure guncellenir veya bununla ilgili yeni kayit eklenir.
    Future<void> addOrUpdateUserBook() async {
      QuerySnapshot querySnapshot = await userBooksCollection
          .where('userId', isEqualTo: userId)
          .where('bookName', isEqualTo: widget.bookName)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot bookDocument = querySnapshot.docs.first;
        await updateUserBook(bookDocument);
      } else {
        // User record doesn't exist, add a new record
        await addUserBook();
      }
    }

    //Adds read related records to get the read logs of the user in each day to show the reading time in a day;
    Future<void> addReadRecords(int readingTime) {
      CollectionReference bookReadingCol =
      FirebaseFirestore.instance.collection('bookReadingTimes');
      return bookReadingCol
          .add({
        'userId': userId,
        'date': DateTime.now(),
        'readingTime': readingTime
      })
          .then((value) =>
          print('Reading time of the user is added successfully'))
          .catchError((error) =>
          print('Failed to add reading time of the user record: $error'));
    }

    //In order to update related fiels under the users collection on Db;
    Future<void> updateReadInfos(int spentMin) async {
      try {
        CollectionReference userBooksCollection =
        FirebaseFirestore.instance.collection('users');
        QuerySnapshot querySnapshot =
        await userBooksCollection.where('userId', isEqualTo: userId).get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;
          int oldTotalTimeVal = userData['totalTime'];
          int updatedTotalTime = oldTotalTimeVal +
              spentMin; //timer durduruldugunda alinan sure eklenecek...

          // Update the related fields
          DocumentReference userBookDocRef = userDoc.reference;
          return userBookDocRef
              .update({
            'lastReadDate': DateTime.now(),
            'totalTime': updatedTotalTime
          })
              .then((value) => print('User data is updated successfully'))
              .catchError(
                  (error) => print('Failed to update user data: $error'));
        } else {
          print('User record does not exist.');
        }
      } catch (e) {
        print('Error retrieving user data: $e');
      }
    }

    String getTimerText() {
      int milliseconds = _stopwatch.elapsedMilliseconds;
      int seconds = (milliseconds / 1000).floor() % 60;
      int minutes = (milliseconds / (1000 * 60)).floor() % 60;
      int hours = (milliseconds / (1000 * 60 * 60)).floor();

      String hoursStr = (hours < 10) ? '0$hours' : hours.toString();
      String minutesStr = (minutes < 10) ? '0$minutes' : minutes.toString();
      String secondsStr = (seconds < 10) ? '0$seconds' : seconds.toString();

      return '$hoursStr:$minutesStr:$secondsStr';
    }
    String getTimerTextasMin() {
      int milliseconds = _stopwatch.elapsedMilliseconds;
      int seconds = (milliseconds / 1000).floor() % 60; // deneme iÃ§in
      String secondsStr = (seconds < 10) ? '0$seconds' : seconds.toString();
      int minutes = (milliseconds / (1000 * 60)).floor() % 60;
      String min = (minutes < 10) ? '0$minutes' : minutes.toString();

      return '$secondsStr';
    }

    Duration duration = _stopwatch.elapsed;
    int second = duration.inSeconds;
    int minutes = duration.inMinutes;
    int hours = duration.inHours;


    return Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(185, 187, 223, 1),
              Color.fromRGBO(223, 244, 243, 1),
              Color.fromRGBO(185, 187, 223, 1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                getTimerText(),
                style: const TextStyle(
                  fontSize: 36,
                  color: Color.fromRGBO(82, 87, 124, 1.0),
                ),
              ),
              IconButton( onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          title: const Text('SÃ¼re Ekle', style: TextStyle(
                              color: Color.fromRGBO(135, 142, 205, 1)),),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  labelText: 'SÃ¼re SeÃ§imi(dk)',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all(
                                    const Color.fromRGBO(135, 142, 205, 1)),
                                foregroundColor: MaterialStateProperty.all(
                                    Colors.white),
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      vertical: 9.0, horizontal: 15.0),
                                ),
                                textStyle: MaterialStateProperty.all(
                                  const TextStyle(fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        51.16),
                                  ),
                                ),
                              ),

                              onPressed: () {
                                setState(() {
                                  choose = controller.text.toString();
                                  choosen = int.parse(choose);
                                  ifchoosen = true;
                                  _stopStopwatch();
                                  _resetStopwatch();
                                });
                                print(choosen);
                                print(ifchoosen);
                                Navigator.pop(context);
                              },
                              child: const Text('Tut'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Ä°ptal', style: TextStyle(
                                  color: Color.fromRGBO(
                                      135, 142, 205, 1)),),
                            ),
                          ],
                        )
                );

              }, icon: const Icon(FontAwesomeIcons.clockRotateLeft, color: Color.fromRGBO(82, 87, 124, 1.0),),
              ),
              GestureDetector(
                onTap: () {
                  //ZamanlayÄ±cÄ±
                  if(choosen != 0){
                    _startStopwatch();
                    _toggleRotation();
                    CoinProvider coinProvider =
                    Provider.of<CoinProvider>(context, listen: false);
                    print('timer started');
                    timer = Timer.periodic(Duration(seconds: choosen), (timer) {
                      setState(() {
                        timer.cancel();
                        _animationController.stop();
                        _stopStopwatch();
                        int passedTime = int.parse(getTimerTextasMin());
                        print(passedTime);
                        int hourtime = (passedTime/60).toInt();
                        _resetStopwatch();
                        _isRotating = false;

                        if (!(userId != null && widget.bookName == "")) {
                          if(passedTime >= 1 && passedTime < 20){
                            coinProvider.increaseCoin(5);
                          } else if(passedTime >= 20 && passedTime < 40){
                            coinProvider.increaseCoin(30);
                          }
                          else if(passedTime >= 40 && passedTime < 60){
                            coinProvider.increaseCoin(80);
                          }
                          else if(passedTime >= 60){
                            coinProvider.increaseCoin(hourtime*100);
                          }
                          addOrUpdateUserBook(); //*
                          updateReadInfos(passedTime);
                          addReadRecords(passedTime);
                          fetchTodaysReadingTime(); //*
                        }
                      });
                    });

                    print('timer finished');

                  }

                  //Kronometre
                  else {
                    if (_isRunning && _isRotating) {
                      _stopStopwatch();
                      _resetStopwatch();
                      _isRotating = false;
                      _animationController.stop();


                      CoinProvider coinProvider =
                      Provider.of<CoinProvider>(context, listen: false);

                      if (hours < 0) {
                        coinProvider.increaseCoin(0);
                      }

                      if (second >= 1) {
                        minutes = minutes +
                            (hours *
                                60); //to get the hours+minutes value for reading a book which will be pushed to db.
                      }
                      minutes1 = minutes;


                      if (!(userId != null && widget.bookName == "")) {
                        //*hours olacak, kontrol amacli 'minutes' yapilabilir.
                        if(second >= 1 && second < 20){
                          coinProvider.increaseCoin(5);
                        } else if(minutes >= 20 && minutes < 40){
                          coinProvider.increaseCoin(30);
                        }
                        else if(minutes >= 40 && minutes < 60){
                          coinProvider.increaseCoin(80);
                        }
                        else if(minutes >= 60){
                          coinProvider.increaseCoin(hours*100);
                        }

                        addOrUpdateUserBook(); //*
                        updateReadInfos(
                            minutes1); //* minutes1 / 60 => saat cinsinden aktarilacaksa
                        addReadRecords(minutes1);
                        fetchTodaysReadingTime(); //*
                      }
                    } else {
                      _toggleRotation();
                      _startStopwatch();
                    }
                  }


                },
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: RotationTransition(
                            turns: _animation,
                            child: Image.asset(
                              'lib/assets/halka2.png',
                              width: 285,
                              height: 280,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: RotationTransition(
                            turns: _animation,
                            child: Image.asset(
                              'lib/assets/halka1.png',
                              width: 330,
                              height: 330,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'lib/assets/timer.png',
                            width: 230,
                            height: 230,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                //'En son geÃ§en sÃ¼re: ${hours1} s ${minutes1} dk ',
                'Bugün $totalReadingTime dakika boyunca kitap okudunuz', //TODO:users altindan toplam sure ve son okuma tarihine gore cekilip farkina gore gosterilecek.
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Color.fromRGBO(84, 90, 128, 1.0)),
              ),
            ],
          ),
        ));
  }
}

class CoinProvider with ChangeNotifier {
  int coin = 0;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  //To get the user's coin data from the db;
  Future<int> fetchCoinData() async {
    int coinOfUser = 0;
    try {
      CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
      QuerySnapshot querySnapshot =
      await usersCollection.where('userId', isEqualTo: userId).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        coinOfUser = userData['currentPoint'];
      } else {
        print('No document found for the given userId.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    return coinOfUser;
  }

  //In order to update related fiels under the users collection on Db;
  Future<void> updateUserCoin(int coin) async {
    try {
      CollectionReference userBooksCollection =
      FirebaseFirestore.instance.collection('users');
      QuerySnapshot querySnapshot =
      await userBooksCollection.where('userId', isEqualTo: userId).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        // Update the related fields
        DocumentReference userBookDocRef = userDoc.reference;
        return userBookDocRef
            .update({
          'currentPoint': coin,
        })
            .then((value) => print('Coin data is updated successfully'))
            .catchError((error) => print('Failed to update the coin: $error'));
      } else {
        print('User record does not exist.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  //To get the user's coin data from the db when the timer page is initialized(called in initState);
  void getUsersCoin() async {
    coin = await fetchCoinData();
    notifyListeners();
  }

  void increaseCoin(int amount) {
    coin += amount;
    updateUserCoin(coin);
    notifyListeners();
  }
}
class TimeProvider with ChangeNotifier {
  int time = 0;

  void increaseTime(int amount) {
    time += amount;
    notifyListeners();
  }
}