import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentBox extends StatelessWidget {
  CommentBox(
      {super.key,
      required this.command,
      required this.userName,
      required this.time});
  String command;
  String userName;
  DateTime time;
  String userNameParse(String email) {
    String uname = email.split("@")[0];
    return uname;
  }

  String timeParse(DateTime time) {
    String timeParsed = "";
    DateTime today = DateTime.now();
    int days = today.difference(time).inDays;
    int hours = today.difference(time).inHours;
    int minutes = today.difference(time).inMinutes;
    if (days > 0)
      timeParsed = '$days' + "days ago";
    else if (hours > 0)
      timeParsed = '$hours' + "hr ago";
    else if (minutes > 0)
      timeParsed = '$minutes' + "min ago";
    else
      timeParsed = "a sec ago";
    return timeParsed;
  }

  Widget build(context) {
    timeParse(time);
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "@" + userNameParse(userName),
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                timeParse(time),
                style: TextStyle(color: Colors.black54),
              )
            ],
          ),
          Column(
            children: [Text(command)],
          )
        ],
      ),
    );
  }
}
