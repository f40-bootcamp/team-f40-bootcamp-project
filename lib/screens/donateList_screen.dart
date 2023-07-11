import 'package:flutter/material.dart';

class donateListPage extends StatelessWidget {
  final List<int> numbers = List.generate(20, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(185, 187, 223, 1),
                  Color.fromRGBO(223, 244, 243, 1),
                  Color.fromRGBO(185, 187, 223, 1),
                ],
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top), // Status bar yüksekliği kadar boşluk bırakır
              SizedBox(height: 75), // Bağış Sıralaması yazısını 125 birim aşağı indirmek için
              Image.asset(
                'lib/assets/sıralamakedisi.png',
                width: 250,
                height: 250,
              ),
              SizedBox(height: 75), // PNG'yi 100 birim aşağı indirmek için
              Text(
                'Bağış Sıralaması',
                style: TextStyle(fontSize: 28, color: Color.fromRGBO(54, 56, 84, 1.0)),
              ),
              SizedBox(height: 16), // Çubuklar ile yazı arasına bir boşluk eklemek için
              Expanded(
                child: ListView.builder(
                  itemCount: numbers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(185, 187, 223, 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          if (index == 0) // 1. kutu için birincilik.png eklenir
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Image.asset(
                                'lib/assets/birincilikk.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          if (index == 0) // 1. kutu için Duman Kedi => 94 yazısı eklenir
                            Positioned(
                              top: 0,
                              left: 30,
                              child: Text(
                                'Duman Kedi                                 94',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                          if (index == 1) // 2. kutu için ikincilik.png eklenir
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Image.asset(
                                'lib/assets/ikincilikk.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          if (index == 1) // 2. kutu için Miskin Kedi => 87 yazısı eklenir
                            Positioned(
                              top: 0,
                              left: 30,
                              child: Text(
                                'Miskin Kedi                                  87',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                          if (index == 2) // 3. kutu için üçüncülük.png eklenir
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Image.asset(
                                'lib/assets/üçüncülükk.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          if (index == 2) // 3. kutu için Miya Kedi => 78 yazısı eklenir
                            Positioned(
                              top: 0,
                              left: 30,
                              child: Text(
                                'Miya Kedi                                     78',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                          if (index == 3) // 4. kutu için Bal Kedi => 76 yazısı eklenir
                            Positioned(
                              top: 0,
                              left: 30,
                              child: Text(
                                'Bal Kedi                                       76',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                          if (index == 4) // 5. kutu için Yumoş Kedi => 72 yazısı eklenir
                            Positioned(
                              top: 0,
                              left: 30,
                              child: Text(
                                'Yumoş Kedi                                  72',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                          if (index == 5) // 6. kutu için Şirin Kedi => 68 yazısı eklenir
                            Positioned(
                              top: 0,
                              left: 30,
                              child: Text(
                                'Şirin Kedi                                      68',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                          Text(
                            '${index + 1}.',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top, // Status bar yüksekliği kadar üste yerleşir
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}