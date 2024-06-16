import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:unitalk/models/chat_user.dart';
import 'package:unitalk/models/message.dart';
import 'package:http/http.dart';
import '../helper/get_date.dart';
import 'access_firebase_token.dart';


class APIs{
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  //for storing self information
  static late ChatUser me;

  //for checking if user exists or not
  static Future<bool> userExists() async {
    return (
      await firestore
      .collection('users')
      .doc(user.uid)
      .get())
      .exists;  
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
      await firestore
      .collection('users')
      .doc(user.uid)
      .get().then((user) async {
        if (user.exists)
        {
          me = ChatUser.fromJson(user.data()!);
          await getFirebaseMessagingToken();
          APIs.updateActiveStatus(true);
        }
        else {
          await CreateUser("", "", "", "").then((value) => getSelfInfo());
        }
      });
  }


  //for new user
  static Future<void> CreateUser(String Native, String Target, String About, String DOB) async {
    final time = DateTime.now().toUtc().toIso8601String();
    log(time);
    final chatuser = ChatUser(
      image: "https://firebasestorage.googleapis.com/v0/b/unitalk-cae71.appspot.com/o/profile_pictures%2Fnodp.png?alt=media&token=f957ce36-536c-4eb4-ad75-d958d22b31c5",
      about: About,
      name: user.displayName.toString(),
      createdAt: time,
      isOnline: false,
      id: user.uid,
      lastActive: time,
      email: user.email.toString(),
      pushToken: '',
      target: Target,
      native: Native,
      transLang: Target,
      dob: DOB,
    );

    return await firestore
      .collection('users')
      .doc(user.uid)
      .set(chatuser.toJson());
  }


  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for finding new people to connect
  static Future<QuerySnapshot<Map<String, dynamic>>> findPeople() async {
  DateTime now = DateTime.now();
  DateTime eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
  String eighteenYearsAgoString = DateFormat('yyyy-MM-dd').format(eighteenYearsAgo);
  log('${eighteenYearsAgoString}');

  if (Date.getAge(me) >= 18) {
    return await firestore
      .collection('users')
      .where('native', isEqualTo: me.target)
      .where('dob', isLessThanOrEqualTo: eighteenYearsAgoString)
      .orderBy('last_active', descending: true)
      .get();
  } else {
    return await firestore
      .collection('users')
      .where('native', isEqualTo: me.target)
      .where('dob', isGreaterThan: eighteenYearsAgoString)
      .orderBy('last_active', descending: true)
      .get();
  }
}


  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  //for modifying in firebase
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name' : me.name,
      'about' : me.about,
    });
  }

  static Future<void> updateTarget(String Target) async {
    await firestore.collection('users').doc(user.uid).update({
      'target' : Target
    });
    me.target = Target;
  }
  static Future<void> updateTransLang(String transLang) async {
    await firestore.collection('users').doc(user.uid).update({
      'transLang' : transLang
    });
    me.transLang = transLang;
  }

  //firebase messaging (notifications)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for firebase messageing token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });

  }
  

  //update profile picture

  static Future<void> updateProfilePic(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image' : me.image
    });
  }

  static Future<void> removeProfilePic() async {
    me.image = "https://firebasestorage.googleapis.com/v0/b/unitalk-cae71.appspot.com/o/profile_pictures%2Fnodp.png?alt=media&token=f957ce36-536c-4eb4-ad75-d958d22b31c5";
    await firestore.collection('users').doc(user.uid).update({
      'image' : me.image
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo (ChatUser chatUser) {
    return firestore.collection('users').where('id', isEqualTo: chatUser.id).snapshots();
  }

    // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

   // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async
  {
    firestore
    .collection('users')
    .doc(user.uid)
    .update({'is_online': isOnline, 'last_active': DateTime.now().toUtc().toIso8601String(), 'push_token': me.pushToken},    
    );
  }

static Future<void> sendPushNotification(ChatUser chatUser, String msg) async {
  AccessFirebaseToken accessToken = AccessFirebaseToken();
  String bearerToken = await accessToken.getAccessToken();
  final body = {
    "message": {
      "token": chatUser.pushToken,
      "notification": {
        "title": me.name,
        "body": msg,
      },
      "android": {
        "notification": {
          "channel_id": "chats"
        }
      },
      "data": {
        "some_data": "User ID: ${me.id}",
      },
    }
  };
  try {
    var res = await post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/unitalk-cae71/messages:send'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $bearerToken'
      },
      body: jsonEncode(body),
    );
    print("Response statusCode: ${res.statusCode}");
    print("Response body: ${res.body}");
  } catch (e) {
    print("\nsendPushNotification: $e");
  }
}
  //for getting conversation ID
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //chat screen related APIs
  //for getting all messages of a specific conversation

  //harsh's code
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
  //   return firestore.collection('chats/${getConversationID(user.id)}/messages').snapshots();
  // }

  //chatgpt code
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
  return firestore
      .collection('chats/${getConversationID(user.id)}/messages')
      .orderBy('sent', descending: true)
      .snapshots();
  }

  //chats (collection) --> conversation_id (doc) --> messages (collection) -->message (doc)
  //for sending a message
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async
  {

    // final time = DateTime.now().millisecondsSinceEpoch.toString(); (as per harsh's video)
    final time = DateTime.now().toUtc().toIso8601String();  

    final Message message = Message(toId: chatUser.id, msg: msg, read: '', type: type, fromId: user.uid, sent: time);

    final ref = firestore.collection('chats/${getConversationID(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser, type == Type.text ? msg : 'Image'));
  }


  static Future<void> updateMessageReadStatus(Message message) async {
    final querySnapshot = await firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .where('sent', isEqualTo: message.sent)
        .get();

    final documents = querySnapshot.docs;

    if (documents.isNotEmpty) {
        // Found the document, update it
        final docRef = documents.first.reference;
        await docRef.update({'read': DateTime.now().toUtc().toIso8601String()});
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
  return firestore
      .collection('chats/${getConversationID(user.id)}/messages')
      .orderBy('sent', descending: true)
      .limit(1)
      .snapshots();
}

  static Future<void> sendChatImage(ChatUser chatUser, File file) async
  {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    final imageURL = await ref.getDownloadURL();
    await sendMessage(chatUser, imageURL, Type.image);
  }

//update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

static Future<void> deleteMessage(Message message) async {
    try {
      // Get the document reference
      DocumentReference docRef = firestore
          .collection('chats/${getConversationID(message.toId)}/messages')
          .doc(message.sent);

      // Check if the document exists
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        log('Deleting message: ${message.sent}');

        // Delete the document
        await docRef.delete();

        // If the message is an image, delete it from storage
        if (message.type == Type.image) {
          await storage.refFromURL(message.msg).delete();
        }

        log('Message deleted successfully');
      } else {
        log('Message does not exist: ${message.sent}');
      }
    } catch (e) {
      log('Error deleting message: $e');
      throw e;
    }
  }


  static Future<String> translateText(String text, String targetLanguage) async {
    final url = Uri.parse('http://ethanburke.pythonanywhere.com/translate');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'text': text, 'target_language': targetLanguage});

    try {
      final response = await post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      final translatedText = responseData['translated_text'];
      log(translatedText);
      return translatedText;
    } catch (error) {
      log('Error translating text: $error');
      return ''; // Return an empty string in case of an error
    }
  }

}