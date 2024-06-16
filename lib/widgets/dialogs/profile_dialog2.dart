import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:unitalk/screens/view_profile_screen.dart";

import "../../main.dart";
import "../../models/chat_user.dart";

class ProfileDialog2 extends StatelessWidget {
  const ProfileDialog2({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .8,
        height: mq.height * .6,
        child: Stack(
          children: [

            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                // borderRadius: BorderRadius.circular(mq.height*.25),
                child: CachedNetworkImage(
                  width: mq.width*.7,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
                      ),
            ),

            Positioned(
              left: mq.width*.04,
              top: mq.height*0.02,
              width: mq.width*.55,

              child: Text(user.name, style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),),
            ),

          ],
        ),
      ),
    );
  }
}