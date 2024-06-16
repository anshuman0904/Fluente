import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unitalk/main.dart';
import '../models/chat_user.dart';
import '../screens/view_profile_screen.dart';

class NewUserCard extends StatefulWidget {
  final ChatUser user;

  const NewUserCard({super.key, required this.user});

  @override
  State<NewUserCard> createState() => _NewUserCardState();
}

class _NewUserCardState extends State<NewUserCard> {
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
              MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)),
            );
          },
          child: ListTile(
            contentPadding: EdgeInsets.all(8),
            leading: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.3),
                child: CachedNetworkImage(
                  width: mq.height * 0.04,
                  height: mq.height * 0.04,
                  imageUrl: widget.user.image,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
            ),
            title: Text(
              widget.user.name,
              style: TextStyle(color: Colors.white), // White text color
            ),
            subtitle: Row(
              children: [
                Text(
                  '${widget.user.native}',
                  style: TextStyle(color: Colors.white), // White text color
                ),
                Icon(
                  Icons.arrow_right_alt,
                  color: Colors.white, // White icon color
                ),
                Text(
                  widget.user.target,
                  style: TextStyle(color: Colors.white), // White text color
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}