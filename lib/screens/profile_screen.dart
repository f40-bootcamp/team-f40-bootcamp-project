import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:read_reminder/screens/donateList_screen.dart';
import 'favorite_book_screen.dart';
import 'login_screen.dart';
import 'timer_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //String userEmail = '';
  String username = "";
  int totalFocusedTime = 0;
  int donationCount = 0;
  int orderOfUser = 0;

  int coinOfUser = 0;
  bool isDonationEnabled = false;
  User? user = FirebaseAuth.instance.currentUser;

  //File? _selectedImage;
  String? profileImageURL;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        profileImageURL =
            pickedImage.path; // Reset the profile image URL while uploading
      });
      final File imageFile = File(pickedImage.path);
      await _uploadProfileImage(imageFile);
    }
  }

  Future<void> _uploadProfileImage(File file) async {
    try {
      String? userId = user?.uid;
      if (userId != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${DateTime.now().microsecondsSinceEpoch}.jpg');
        await storageRef.putFile(file!);
        final downloadURL = await storageRef.getDownloadURL();
        CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
        QuerySnapshot querySnapshot =
        await usersCollection.where('userId', isEqualTo: userId).get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          DocumentReference userDocRef = userDoc.reference;
          await userDocRef.update({'profileImage': downloadURL});
          //To show the selected and saved profile image immediately;
          setState(() {
            profileImageURL = downloadURL;
          });
        }
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserInfos();
  }

  Future<void> _getUserInfos() async {
    String? userId = user?.uid;
    if (userId != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        int fetchedOrder = await _getUserOrder();
        setState(() {
          username = userData['username'];
          totalFocusedTime = (userData['totalTime'] / 60).toInt();
          donationCount = userData['donationCount'];
          coinOfUser = userData['currentPoint'];
          orderOfUser = fetchedOrder;
          profileImageURL = userData['profileImage'];
        });
        _checkDonationCondition(); //to assign the availability of making a donation.
      } else {
        print("Related record does not exist for the logined user!");
      }
    }
  }

  //Gets the user order for the donation list;
  Future<int> _getUserOrder() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    int userOrder = 0;
    if (userId != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('donationList')
          .where('userId', isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot donationDoc = querySnapshot.docs.first;
        Map<String, dynamic> donationData =
        donationDoc.data() as Map<String, dynamic>;
        userOrder = donationData['listOrder'];
      } else {
        print("Related record does not exist for the logined user!");
      }
    }
    return userOrder;
  }

  //Making a donation if the coin of user is sufficient;
  Future<void> makeDonation() async {
    String? userId = user?.uid;
    if (userId != null) {
      CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
      try {
        QuerySnapshot querySnapshot =
        await usersCollection.where('userId', isEqualTo: userId).get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;
          int currentDonationCount = userData['donationCount'];
          int currentCoin = userData['currentPoint'];
          DocumentReference userDocRef = userDoc.reference;
          userDocRef.update({
            'donationCount': currentDonationCount + 1,
            'currentPoint': (currentCoin - 2000)
          });
          CoinProvider coinProvider =
          Provider.of<CoinProvider>(context, listen: false);
          coinProvider
              .getUsersCoin(); //updated coin value from the db will be fetched.
          await _getUserInfos(); //to fetch the updated user infos.
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Bağış yapıldı!'),
              backgroundColor: Colors.grey[800],
              duration: Duration(seconds: 2)),
        );
      } catch (error) {
        print(error);
      }
    }
  }

  //Checks the current coin of user to decide whether suitable to make a donation or not;
  void _checkDonationCondition() {
    if (coinOfUser < 2000) {
      print('$coinOfUser deneme123!!!');
      setState(() {
        isDonationEnabled = false;
      });
    } else {
      setState(() {
        isDonationEnabled = true;
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _goToDonate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => donateListPage()),
    );
  }


  void _goToFav() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoriteBooksScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    int hourtime = (totalFocusedTime / 60).toInt();
    int minutetime = totalFocusedTime - hourtime * 60;

    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    _pickImage();
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImageURL != null
                        ? NetworkImage(profileImageURL!)
                        : null,
                    child: profileImageURL == null
                        ? Icon(Icons.add_a_photo,
                        size: 50, color: Colors.grey[300])
                        : null,
                    //AssetImage('lib/assets/background/bg_profile.png',)
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                    username,
                    style: TextStyle(
                      color: Color.fromRGBO(54, 56, 84, 1.0),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )),),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Odaklanılan Süre',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromRGBO(69, 74, 113, 1.0),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Colors.grey,
                                    blurRadius: 2,
                                    offset: Offset(3, 3),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5,),
                            Icon(
                              FontAwesomeIcons.clock,
                              size: 14,
                              color: Color.fromRGBO(54, 56, 84, 1.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Text(
                          '$hourtime s $minutetime dk',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromRGBO(69, 74, 113, 1.0),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),


                      ],
                    ),
                  ),
                  SizedBox(width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.1,),
                  Container(
                    height: 100,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Yapılan Bağışlar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromRGBO(69, 74, 113, 1.0),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Colors.grey,
                                    blurRadius: 2,
                                    offset: Offset(3, 3),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5,),
                            Icon(
                              FontAwesomeIcons.book,
                              size: 14,
                              color: Color.fromRGBO(69, 74, 113, 1.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          '$donationCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color.fromRGBO(69, 74, 113, 1.0),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 80,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.40,
                    color: Colors.transparent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Liste Sıralaması',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromRGBO(69, 74, 113, 1.0),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.grey,
                                  blurRadius: 2,
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$orderOfUser.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color.fromRGBO(69, 74, 113, 1.0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _goToDonate();
                                },
                                icon: const Icon(
                                  FontAwesomeIcons.caretRight,
                                  size: 24,
                                  color: Color.fromRGBO(117, 125, 185, 1),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 80,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.40,
                    color: Colors.transparent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Favoriler',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromRGBO(69, 74, 113, 1.0),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.grey,
                                  blurRadius: 2,
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              IconButton(
                                onPressed: () {
                                  _goToFav();
                                },
                                icon: const Icon(
                                  FontAwesomeIcons.heartCircleCheck,
                                  size: 18,
                                  color: Color.fromRGBO(117, 125, 185, 1),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40,),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromRGBO(135, 142, 205, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(
                        vertical: 13.0, horizontal: 35.0),
                  ),
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(51.16),
                    ),
                  ),
                ),
                onPressed: () {
                  isDonationEnabled
                  ? makeDonation()
                      : ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                  content: Text(
                  'Bağış yapmak için yeterli coininiz bulunmamaktadır!'),
                  backgroundColor: Colors.grey[800],
                  duration: Duration(seconds: 2)),
                  );
                  },

                child: const Text(
                  'BAĞIŞ YAP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromRGBO(69, 74, 113, 1.0),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              TextButton(
                onPressed: () {
                  _signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Icon(
                  Icons.exit_to_app,
                  color: Color.fromRGBO(135, 142, 205, 1),
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}