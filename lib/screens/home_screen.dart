import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/chat_user_card.dart';
import '../widgets/new_user_card.dart';
import 'auth/after_signup.dart';
import 'auth/login_screen.dart';
import 'profile_screen.dart';
import 'target_lang.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> _list = [];
  List<ChatUser> _list2 = [];


  // for storing searched items
  final List<ChatUser> _searchList = [];
  // for storing search status
  bool _isSearching = false;

  // for storing current index of bottom navigation bar
  int _selectedIndex = 0;

  List<Color?> tabColors = [Color.fromARGB(255, 236, 104, 104), const Color.fromARGB(255, 209, 129, 223), const Color.fromARGB(255, 142, 241, 145)];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo().then((_) {
      if (APIs.me.native == "") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AfterSU()));
      }
    });

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen
      onTap: FocusScope.of(context).unfocus,
      child: PopScope(
        // onWillPop: () async {
        //   if (_isSearching) {
        //     setState(() {
        //       _isSearching = !_isSearching;
        //     });
        //     return false;
        //   } else {
        //     return true;
        //   }
        // },
        canPop: !_isSearching,
        onPopInvoked: (_) async {
          if (_isSearching) {
            setState(() => _isSearching = !_isSearching);
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          //bottom navigation bar
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: tabColors[_selectedIndex],
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chat_bubble_2_fill),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_2_fill),
                label: 'Find People',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.black,
            onTap: _onItemTapped,
          ),

          //body
          body: _getBodyWidget(_selectedIndex),
        ),
      ),
    );
  }

  Widget _getBodyWidget(int index) {
    switch (index) {
      case 0:
        return Scaffold(
                    appBar: AppBar(
            backgroundColor: Colors.black,
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Name, Email, ...', hintStyle: TextStyle(color: Colors.white)),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5, color: Colors.white),
                    //when search text changes then updated search list
                    onChanged: (val) {
                      //search logic
                      _searchList.clear();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                          setState(() {
                            _searchList;
                          });
                        }
                      }
                    },
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Fluente',
                      // style: TextStyle(color: Colors.white, fontFamily: 'Lobster', fontSize: 25),
                      style: GoogleFonts.lora(
                        textStyle: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    )
                  ),
            actions: [
              //search user button
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search, color: Colors.white,)),
            ],
          ),

          backgroundColor: Colors.black,
          //floating button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
                onPressed: () {
                  _addChatUserDialog();
                },
                child: const Icon(Icons.add_comment_rounded)),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
          
            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
          
                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
          
                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());
          
                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];
          
                          if (_list.isNotEmpty) {
                                // _list.sort((a, b) => fetchAndSetLastMessageTime(b).compareTo(a.fetchAndSetLastMessageTime(a)));
                                return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('No Connections Found!',
                                  style: TextStyle(fontSize: 20, color: Colors.white)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        );
      
      case 1:
        return Scaffold(
            appBar: AppBar(
            backgroundColor: Colors.black,
            title: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Fluente',
                      // style: TextStyle(color: Colors.white, fontFamily: 'Lobster', fontSize: 25),
                      style: GoogleFonts.lora(
                        textStyle: const TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    )
                  ),
            ),

          backgroundColor: Colors.black,
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: APIs.findPeople(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          } else {
            final data2 = snapshot.data!.docs;
            _list2 = data2
                .map((e) => ChatUser.fromJson(e.data()))
                .toList();

            return ListView.builder(
              itemCount: _list2.length,
              padding: EdgeInsets.only(top: mq.height * .01),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return NewUserCard(
                    user: _list2[index]);
              });
          }
        },
      ),
    );
 
      case 2:
      return Scaffold(
            appBar: AppBar(
            backgroundColor: Colors.black,
            title:Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Fluente',
                      // style: TextStyle(color: Colors.white, fontFamily: 'Lobster', fontSize: 25),
                      style: GoogleFonts.lora(
                        textStyle: const TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    )
                  ),
          ),

  backgroundColor: Colors.black,
  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        ListTile(
            leading: const Icon(Icons.person, color: Colors.white,),
            title: const Text('Profile', style: TextStyle(color: Colors.white),),
            subtitle: const Text('View and edit your profile', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(user: APIs.me)),
              );
            },
          ),
        const SizedBox(height: 20),
        ListTile(
            leading: const Icon(Icons.language_sharp, color: Colors.white,),
            title: const Text('Select Languages', style: TextStyle(color: Colors.white),),
            subtitle: const Text('Change your language settings', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TargetLanguage()),
              );
            },
          ),
          const SizedBox(height: 20),
        ListTile(
            leading: const Icon(Icons.logout, color: Colors.red,),
            title: const Text('Logout', style: TextStyle(color: Colors.red),),
            subtitle: const Text('See you soon :)', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () async {
              Dialogs.showProgressBar(context);
                  await APIs.auth.signOut().then((value) async {
                    await GoogleSignIn().signOut().then((value) {
      
                      //current stack : bottom to top (home -> profile -> progress button)
      
                      //for removing progress icon
                      Navigator.pop(context);
      
                      // //for moving to home screen
                      // Navigator.pop(context);
      
                      //home to Login Screen
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    });
                  });
            },
          ),
      ],
    ),
  ),
);
 
  
      default:
        return const Center(
          child: Text(
            'Index 0: Home',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        );
    }
  }

  // for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Color.fromARGB(255, 51, 50, 50),
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User', style: TextStyle(color: Colors.white),)
                ],
              ),

             //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email Id',
                  hintStyle: TextStyle(color: Colors.white), // Set hint text color to white
                  prefixIcon: const Icon(Icons.email, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),


              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.red, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackbar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ))
              ],
            ));
  }

  Future<DateTime> fetchAndSetLastMessageTime(ChatUser user) async {
  final lastMessageSnapshot = await APIs.getLastMessage(user).first;
  final data = lastMessageSnapshot.docs;
  final messages = data.map((e) => Message.fromJson(e.data())).toList();
  
  if (messages.isNotEmpty) {
    return DateTime.parse(messages[0].sent);
  } else {
    return DateTime(2000, 1, 1);
  }
}
}
