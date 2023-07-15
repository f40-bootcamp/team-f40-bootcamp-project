import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../navigation/bottom_navigation_bar.dart';
import '../notification_demo_screen.dart';
import 'message_screen.dart';
import 'timer_screen.dart';

class FeedPage extends StatelessWidget {
  final String bookTitle;
  const FeedPage({super.key, String? bookTitle}) : bookTitle = bookTitle ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Consumer<CoinProvider>(
              builder: (context, coinProvider, _) {
                int coin = coinProvider.coin;
                return Text(
                  'Coin: $coin',
                  style: TextStyle(color: Color.fromRGBO(54, 56, 84, 1.0)),
                );
              },
            ),
          ),
          IconButton(
              onPressed: () {},
              icon: Icon(FontAwesomeIcons.fire,size: 18, color:Color.fromRGBO(
                  82, 87, 124, 1.0))
          ),
        ],
        leading: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationsScreen()),
                      );
                    },
                    icon: Icon(FontAwesomeIcons.solidBell ,size: 18, color:Color.fromRGBO(
                        82, 87, 124, 1.0) ,)),
              ),
              SizedBox(height:5,),
              Expanded(
                child: IconButton(onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserListPage()),
                  );
                },
                    icon: Icon(FontAwesomeIcons.message, size: 18, color:Color.fromRGBO(
                        82, 87, 124, 1.0) ,)),
              ) ,
            ],
          ),
        ),

      ),
      body: Container(
        child: BottomNavigationBarPage(titleOfBook: bookTitle),
      ),
    );
  }
}