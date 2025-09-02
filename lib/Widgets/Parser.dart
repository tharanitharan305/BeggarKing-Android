//import 'package:beggarking/Widgets/Command.dart';

import 'Command.dart';

class Parser {
  List<Comments> CommentGetParser(var comment) {
    List<Comments> parsed = [];
    int i = 0;
    for (String x in comment) {
      if (i != 0) {
        Comments comment = new Comments(
            user: x.split(";")[0],
            comment: x.split(";")[1],
            time: DateTime.parse(x.split(";")[2]));
        parsed.add(comment);
      }
      i++;
    }
    return parsed;
  }
}
