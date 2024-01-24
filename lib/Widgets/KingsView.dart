import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KingsView extends StatefulWidget {
  @override
  State<KingsView> createState() => _KingsViewState();
}

class _KingsViewState extends State<KingsView> {
  bool settingImage = false;

  Image? KingImage;

  Image logo = Image.asset(
    "images/logo.png",
    height: 10,
    width: 10,
  );

  void setImage(String url) async {
    var image = NetworkImage(url);
    setState(() {
      KingImage = image as Image;
      settingImage = false;
    });
  }

  Widget build(context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('King details')
            .orderBy('Launched_at', descending: true)
            .snapshots(),
        builder: (((context, snapshot) {
          if (!snapshot.hasData) return Text('No Kings Found....');
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          if (snapshot.hasError) return Text(snapshot.error.toString());
          final King_List = snapshot.data!.docs;
          return ListView.builder(
              itemCount: King_List.length,
              itemBuilder: (ctx, i) {
                return Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          Image.network(
                            "${King_List[i].data()['King_url']}",
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                          Text('Address : ${King_List[i].data()['Address']}'),
                          Text(
                              'Found by : ${King_List[i].data()['Launched_at']}'),
                        ],
                      ),
                    ),
                  ],
                );
              });
        })));
  }
}
