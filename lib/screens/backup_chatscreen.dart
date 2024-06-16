import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../helper/get_date.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';
import 'view_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        statusBarColor: Colors.black,
      ));
  }

  //for storing messages
  List<Message> _list = [];

  //for handing message text changes
  final _textController = TextEditingController();

  bool _showEmoji = false;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = false;
              });
              return Future.value(false);
            }
            else {
              return Future.value(true);
            }
          },
          // canPop: !_showEmoji,
          // onPopInvoked: (_) async {
          //   if (_showEmoji) {
          //     setState(() => _showEmoji = !_showEmoji);
          //   } else {
          //     Navigator.of(context).pop();
          //   }
          // },
          child: Scaffold(

            appBar: AppBar(
              //to remove default back button
              automaticallyImplyLeading: false,
              title: _appBar(),
              backgroundColor: Colors.black,
            ),

            backgroundColor: Colors.black,
        
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                  
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();
                      
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                        
                  
                        if (_list.isNotEmpty)
                        {
                          return ListView.builder(
                          reverse: true,
                          itemCount: _list.length,
                          padding: EdgeInsets.only(top: mq.height*0.01),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return MessageCard(
                              message: _list[index]);
                          });
                        }
                        else
                        {
                          return const Center(
                            child: Text('Say Hi!! 👋',
                              style: TextStyle(color: Colors.white, fontSize: 20),),
                          );
                        }
                    }
                  },
                  ),
                ),
      
                // Progress indicator
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Set the color to white
                      ),
                    ),
                  ),
      
        
                _chatInput(),
        
                //icon stuff
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: 
                      Container(
                        color: Colors.black,
                        child: EmojiPicker(
                            textEditingController: _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                            config: Config(                     
                                checkPlatformCompatibility: true,
                                emojiViewConfig: EmojiViewConfig(
                                // Issue: https://github.com/flutter/flutter/issues/28894
                                emojiSizeMax: 28 *
                                (Platform.isIOS
                                    ?  1.30
                                    :  1.0),
                                ),
                            ),
                        ),
                      )
                    ),
              ],
            ),
         
          ),
          )
        )
      )
        );

  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        setState(() {
                _showEmoji = false;
        });
        Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
          return Row(
        children: [
          //back button
          IconButton(onPressed: () => Navigator.pop(context),
            icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          )),
      
          //user profile picture
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height*.3),
            child: CachedNetworkImage(
              width: mq.height*.04,
              height: mq.height*.04,
              imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
              // placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
      
          const SizedBox(width: 10,),
      
          //name
      
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(list.isNotEmpty ? list[0].name : widget.user.name, style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),),
      
            const SizedBox(height: 10,),
            
            Text(list.isNotEmpty ? 
            list[0].isOnline ? 'Online' :
            Date.lastActiveTime(list[0].lastActive) : 
            Date.lastActiveTime(widget.user.lastActive), 
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),)
          ],)
        ],
      );
        },
      ),
    );
  }


Widget _chatInput() {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: mq.height * 0.01, horizontal: mq.width * 0.025),
    child: Row(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                _emojiButton(),
                _textInputField(),
                _imagePickerButton(),
                _cameraButton(),
                SizedBox(width: mq.width * 0.02),
              ],
            ),
          ),
        ),
        _sendMessageButton(),
      ],
    ),
  );
}
Widget _emojiButton() {
    return IconButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
        setState(() => _showEmoji = !_showEmoji);
      },
      icon: const Icon(Icons.emoji_emotions, color: Colors.blueAccent, size: 25),
    );
  }

  Widget _textInputField() {
    return Expanded(
      child: TextField(
        controller: _textController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        onTap: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = false;
            });
          }
        },
        decoration: const InputDecoration(
          hintText: 'Type something...',
          hintStyle: TextStyle(color: Colors.blueAccent),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _imagePickerButton() {
    return IconButton(
      onPressed: () async {
        final ImagePicker picker = ImagePicker();
        final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);

        if (images.isNotEmpty) {
          setState(() {
            _isUploading = true;
          });
          for (var image in images) {
            await APIs.sendChatImage(widget.user, File(image.path));
          }
          setState(() {
            _isUploading = false;
          });
        }
      },
      icon: const Icon(Icons.image, color: Colors.blueAccent, size: 26),
    );
  }

  Widget _cameraButton() {
    return IconButton(
      onPressed: () async {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
        if (image != null) {
          setState(() {
            _isUploading = true;
          });
          await APIs.sendChatImage(widget.user, File(image.path));
          setState(() {
            _isUploading = false;
          });
        }
      },
      icon: const Icon(Icons.camera_alt_rounded, color: Colors.blueAccent, size: 26),
    );
  }

  Widget _sendMessageButton() {
    return MaterialButton(
      onPressed: () {
        if (_textController.text.isNotEmpty) {
          if (_list.isEmpty) {
            APIs.sendFirstMessage(widget.user, _textController.text, Type.text);
          } else {
            APIs.sendMessage(widget.user, _textController.text, Type.text);
          }
          _textController.clear();
        }
      },
      minWidth: 0,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      shape: const CircleBorder(),
      color: Colors.green,
      child: const Icon(
        Icons.send,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}