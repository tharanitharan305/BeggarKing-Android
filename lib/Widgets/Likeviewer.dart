//import 'package:beggarking/Firebase/Insert_King.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Firebase/Insert_King.dart';

final userAuth = FirebaseAuth.instance;

class LikeManager extends StatefulWidget {
  const LikeManager({
    super.key,
    required this.like,
    required this.dislike,
    required this.uuid,
  });
  final dynamic like;
  final dynamic dislike;
  final String uuid;

  State<LikeManager> createState() => _LikeManagerState();
}

class _LikeManagerState extends State<LikeManager> {
  bool liked = false;
  bool disliked = false;

  void likeState() {
    setState(() {
      liked = widget.like.contains(userAuth.currentUser!.email);
      disliked = widget.dislike.contains(userAuth.currentUser!.email);
    });
  }

  Future<void> onlike() async {
    var dislist = widget.dislike;
    var likelist = widget.like;
    var user = FirebaseAuth.instance.currentUser!.email!;
    if (likelist.contains(user)) {
      likelist.remove(user);
      await Insert_King().updateLike(likelist, widget.uuid);
    } else if (dislist.contains(user)) {
      dislist.remove(user);
      await Insert_King().updatedisLike(dislist, widget.uuid);
      likelist.add(user);
      await Insert_King().updateLike(likelist, widget.uuid);
    } else {
      likelist.add(user);
      await Insert_King().updateLike(likelist, widget.uuid);
    }
    likeState();
  }

  void ondislike() async {
    var dislist = widget.dislike;
    var likelist = widget.like;
    var user = FirebaseAuth.instance.currentUser!.email!;
    if (dislist.contains(user)) {
      dislist.remove(user);
      await Insert_King().updatedisLike(dislist, widget.uuid);
    }
    if (likelist.contains(user)) {
      likelist.remove(user);
      await Insert_King().updateLike(likelist, widget.uuid);
      dislist.add(user);
      await Insert_King().updatedisLike(dislist, widget.uuid);
    } else {
      dislist.add(user);
      await Insert_King().updatedisLike(dislist, widget.uuid);
    }
    likeState();
  }

  int parse(int n, int t) {
    while (t > 0) {
      n = (n / 10).toInt();
      t--;
    }
    return n;
  }

  String getLike(int like) {
    String ans = "";
    if (like > 999) {
      setState(() {
        ans = parse(like, 3).toString() + "K";
      });
    } else if (like > 99999) {
      setState(() {
        ans = parse(like, 5).toString() + "L";
      });
    } else {
      return like.toString();
    }
    return ans;
  }

  Widget build(context) {
    likeState();
    return Row(
      children: [
        IconButton(
          onPressed: onlike,
          icon: Icon(
            Icons.thumb_up_alt_rounded,
            color: liked ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        Text(getLike(widget.like.length - 1)),
        Row(
          children: [
            IconButton(
              onPressed: ondislike,
              icon: Icon(
                Icons.thumb_down_alt_rounded,
                color: disliked ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            Text(getLike(widget.dislike.length - 1)),
          ],
        ),
      ],
    );
  }
}
