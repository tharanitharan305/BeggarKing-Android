//import 'package:beggarking/Firebase/Insert_King.dart';
//import 'package:beggarking/Widgets/CommandBox.dart';
//import 'package:beggarking/Widgets/Parser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Firebase/Insert_King.dart';
import 'CommandBox.dart';
import 'Parser.dart';

class CommandsView extends StatefulWidget {
  const CommandsView({super.key, required this.comments, required this.uuid});
  final List<dynamic> comments;
  final String uuid;

  State<CommandsView> createState() => _CommandsState();
}

class _CommandsState extends State<CommandsView> {
  String written_comment = "";
  final key = GlobalKey<FormState>();
  Future<void> onComment() async {
    if (key.currentState!.validate()) {
      key.currentState!.save();
      String newcomment =
          "${FirebaseAuth.instance.currentUser!.email};${written_comment};${DateTime.now()}";
      print(widget.comments);
      widget.comments.add(newcomment);

      print(widget.comments);
      await Insert_King().updatecomments(widget.comments, widget.uuid);
      key.currentState!.reset();
    }
  }

  Widget build(context) {
    var comment = widget.comments;
    return Column(
      children: [
        if (comment.length <= 1) Center(child: Text("No comments found")),
        if (comment.length > 1)
          SingleChildScrollView(
            child: Column(
              children: [
                ...Parser()
                    .CommentGetParser(widget.comments)
                    .map(
                      (e) => CommentBox(
                        command: e.comment,
                        userName: e.user,
                        time: e.time,
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        Spacer(),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Form(
            key: key,
            child: TextFormField(
              validator: (value) {
                if (value == null || value.length < 1 || value.isEmpty)
                  return "Write Something...";
                return null;
              },
              onSaved: (value) {
                setState(() {
                  written_comment = value!;
                });
              },
              decoration: InputDecoration(
                labelText: "comments.....",
                prefixIcon: Icon(Icons.message_rounded, color: Colors.black12),
                suffixIcon: IconButton(
                  onPressed: onComment,
                  icon: Icon(Icons.send_rounded),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    // return ListView.builder(
    //     itemCount: comment.length,
    //     itemBuilder: (context, index) => Container(
    //           width: double.infinity,
    //           child: SingleChildScrollView(
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               mainAxisAlignment: MainAxisAlignment.end,
    //               children: [
    //                 CommandBox(
    //                     command: comment.elementAt(index).comment,
    //                     userName: "world",
    //                     time: DateTime.now().subtract(Duration(days: 1))),
    //               ],
    //             ),
    //           ),
    //         ));
  }
}
