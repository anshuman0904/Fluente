import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../main.dart';

import '../api/apis.dart';
import '../helper/get_date.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
import 'dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {

  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}
class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.white, width: 1.0), // White thin border
        ),
        color: Colors.black, // Black background color
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
            );
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
      
              if (list.isNotEmpty) {
                _message = list[0];
              }
      
              return ListTile(
                contentPadding: EdgeInsets.all(8),
                leading: InkWell(
                  onTap: () {
                    showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.3),
                    child: CachedNetworkImage(
                      width: mq.height * 0.04,
                      height: mq.height * 0.04,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),
                title: Text(
                  widget.user.name,
                  style: TextStyle(color: Colors.white), // White text color
                ),
                subtitle: Row(
                  children: [
                    if (_message != null && _message!.type == Type.image) Icon(Icons.image, color: Colors.white), // White icon color
                    Expanded(
                      child: Text(
                        _message != null ? (_message!.type == Type.image ? 'Image' : _message!.msg) : widget.user.about,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white), // White text color
                      ),
                    ),
                  ],
                ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.lightGreenAccent.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )
                        : Text(
                            Date.getLastMessageTime(_message!.sent),
                            style: TextStyle(color: Colors.white), // White text color
                          ),
              );
            },
          ),
        ),
      ),
    );
  }
}