import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:unitalk/models/chat_user.dart';

//DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(widget.message.sent).toLocal()),

class Date{

  static String getMessageTime(String time) {
    final sentTime = DateTime.parse(time).toLocal();
    final currentTime = DateTime.now().toLocal();

    if (currentTime.day == sentTime.day &&
        currentTime.month == sentTime.month &&
        currentTime.year == sentTime.year) {
      return DateFormat('HH:mm').format(sentTime);
    } else {
      return DateFormat('yyyy-MM-dd HH:mm').format(sentTime);
    }
  }

  static String lastActiveTime(String time) {
    final sentTime = DateTime.parse(time).toLocal();
    final currentTime = DateTime.now().toLocal();

    if (currentTime.day == sentTime.day &&
        currentTime.month == sentTime.month &&
        currentTime.year == sentTime.year) {
      return 'Last seen today at ${DateFormat('HH:mm').format(sentTime)}';
    } else {
      return 'Last seen on ${DateFormat('yyyy-MM-dd HH:mm').format(sentTime)}';
    }
  }


  static String getLastMessageTime(String time) {
    final sentTime = DateTime.parse(time).toLocal();
    final currentTime = DateTime.now().toLocal();

    if (currentTime.day == sentTime.day &&
        currentTime.month == sentTime.month &&
        currentTime.year == sentTime.year) {
      return DateFormat('HH:mm').format(sentTime);
    } else {
      return DateFormat('yyyy-MM-dd').format(sentTime);
    }
  }

  static String creationTime(String time) {
    final ttime = DateTime.parse(time).toLocal();
    return DateFormat('yyyy-MM-dd').format(ttime);
  }

  static int getAge(ChatUser user) {
    // String DOB = user.dob;
    DateTime birthDate = DateTime.parse(user.dob);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    log('${age}');
    return age;
  }
}