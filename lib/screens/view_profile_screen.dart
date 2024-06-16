import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unitalk/main.dart';
import '../api/apis.dart';
import '../helper/get_date.dart';
import '../models/chat_user.dart';
import '../widgets/dialogs/profile_dialog2.dart';
import 'chat_screen.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // For hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black, // Set the background color to dark
        appBar: AppBar(
          title: Text(widget.user.name, style: const TextStyle(color: Colors.white),),
          backgroundColor: Colors.grey[900],
          iconTheme: const IconThemeData(
              color: Colors.white,
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: FloatingActionButton.extended(
                backgroundColor: Colors.green,
                onPressed: () async {
                  await APIs.addChatUser(widget.user.email).then((value) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
                    );
                  });
                },
            icon: const Icon(Icons.chat_outlined), label: const Text('Message'),
          ),
        ),
        body: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // For adding some space
                      SizedBox(width: mq.width, height: mq.height * .03),
                      GestureDetector(
                        onTap: () {
                          showDialog(context: context, builder: (_) => ProfileDialog2(user: widget.user));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: CachedNetworkImage(
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.cover,
                            imageUrl: widget.user.image,
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(child: Icon(CupertinoIcons.person, color: Colors.white)), // Set icon color to white
                          ),
                        ),
                      ),

                      // For adding some space
                      SizedBox(height: mq.height * .03),
                      Text(
                        widget.user.email,
                        style: const TextStyle(
                          color: Colors.white, // Set text color to white
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      // For adding some space
                      SizedBox(height: mq.height * .02),

                      Text(
                'Age: ${Date.getAge(widget.user)}',
                style: const TextStyle(
                  color: Colors.white, // Set text color to white
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: mq.height * .02),

              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1, // Set flex factor for half the space
                      child: Center(
                        child: Text(
                          "Native: ${widget.user.native}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1, // Set flex factor for half the space
                      child: Center(
                        child: Text(
                          "Target: ${widget.user.target}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),



                  SizedBox(height: mq.height * .02),
                      const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Bio',
                    style: TextStyle(
                      color: Colors.white, // Set text color to white
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Add some space between 'About' and the content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.user.about,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
              ),
            ],
          ),

                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            SafeArea(child:
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Joined on: ',
                      style: TextStyle(
                        color: Colors.white, // Set text color to white
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      Date.creationTime(widget.user.createdAt),
                      style: const TextStyle(
                        color: Colors.white, // Set text color to white
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Date.lastActiveTime(widget.user.lastActive),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20), // Add some space at the bottom if needed
 
              ],
            ),
           
            )          
          ],
        ),
      ),
    );
  }
}
