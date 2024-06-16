// ignore_for_file: unnecessary_const

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import "../helper/get_date.dart";
import '../main.dart';
import '../models/message.dart';

// for showing single message details
class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        _showContextMenu(context, details.globalPosition, isMe);
      },
      onTap: () async {
        showTranslatedMsg(context, widget.message.msg);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  // sender or another user message
Widget _blueMessage() {
  // Update last read message if sender and receiver are different
  if (widget.message.read.isEmpty) {
    APIs.updateMessageReadStatus(widget.message);
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Message content
      Flexible(
        child: Container(
          padding: EdgeInsets.all(widget.message.type == Type.image
              ? mq.width * .02
              : mq.width * .04),
          margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04, vertical: mq.height * .01),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 131, 7, 161),
              border: Border.all(color: const Color.fromARGB(255, 240, 126, 255)),
              // Making borders curved
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          child: widget.message.type == Type.text
              ? // Show text
              Text(
                  widget.message.msg,
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                )
              : // Show image with size constraints
              ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: mq.width * 0.6,
                      maxHeight: mq.height * 0.4,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
                ),
        ),
      ),

      // Message time
      Padding(
        padding: EdgeInsets.only(right: mq.width * .04),
        child: Text(
          Date.getMessageTime(widget.message.sent),
          style: const TextStyle(fontSize: 13, color: Colors.white),
        ),
      ),
    ],
  );
}

  // our or user message
Widget _greenMessage() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Message time and status
      Row(
        children: [
          // Adding some space
          SizedBox(width: mq.width * .04),

          // Double tick blue icon for message read
          if (widget.message.read.isNotEmpty)
            const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),

          // Adding some space
          const SizedBox(width: 2),

          // Sent time
          Text(
            Date.getMessageTime(widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
      ),

      // Message content
      Flexible(
        child: Container(
          padding: EdgeInsets.all(widget.message.type == Type.image
              ? mq.width * .02
              : mq.width * .04),
          margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04, vertical: mq.height * .01),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 28, 189, 36),
              border: Border.all(color: Colors.lightGreen),
              // Making borders curved
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30))),
          child: widget.message.type == Type.text
              ? // Show text
              Text(
                  widget.message.msg,
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                )
              : // Show image with size constraints
              ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: mq.width * 0.6,
                      maxHeight: mq.height * 0.4,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
                ),
        ),
      ),
    ],
  );
}



  Future<void> showTranslatedMsg(BuildContext context, String original) async {
    try {
      final String translatedText = await APIs.translateText(original, APIs.me.transLang);
      log(APIs.me.transLang);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 59, 59, 59),
          title: const Text("Translation", style: TextStyle(fontSize: 20, color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Original Message', style: TextStyle(fontSize: 18, color: Colors.white)),
                const SizedBox(height: 10),
                Text(
                  original,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text('Translated Message', style: TextStyle(fontSize: 18, color: Colors.white)),
                const SizedBox(height: 10),
                Text(
                  translatedText,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

  } catch (error) {
    
    // Handle error if necessary
    const Text('Unable to translate', style: TextStyle(fontSize: 20, color: Colors.white));

  }
  }


   void _showContextMenu(BuildContext context, Offset offset, bool isMe) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size   // Bigger rect, the entire screen
      ),
      items: [
        widget.message.type == Type.text ? 
        const PopupMenuItem(
          value: 'copy',
          child: ListTile(
            leading: Icon(Icons.copy_all_rounded, color: Colors.blue, size: 26),
            title: Text('Copy Text', style: TextStyle(color: Colors.white),),
          ),
        )
        :
        const PopupMenuItem(
          value: 'save',
          child: ListTile(
            leading: Icon(Icons.download_rounded, color: Colors.blue, size: 26),
            title: Text('Save Image', style: TextStyle(color: Colors.white)),
          ),
        )
        ,
        if (isMe)
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red, size: 26),
              title: Text('Delete Message', style: TextStyle(color: Colors.white)),
            ),
          ),
          if (widget.message.type==Type.text && isMe)
            const PopupMenuItem(
              value: 'translate',
              child: ListTile(
                leading: Icon(Icons.translate, color: Color.fromARGB(255, 251, 255, 0), size: 26),
                title: Text('Translation', style: TextStyle(color: Colors.white)),
              ),
            ),
          if (widget.message.type==Type.text && !isMe)
          const PopupMenuItem(
            value: 'translate',
            child: ListTile(
              leading: Icon(Icons.translate, color: Color.fromARGB(255, 251, 255, 0), size: 26),
              title: Text('Translation', style: TextStyle(color: Colors.white)),
            ),
          ),
        PopupMenuItem(
          value: 'sentTime',
          child: ListTile(
            leading: const Icon(Icons.remove_red_eye, color: Colors.blue, size: 26,),
            title: Text('Sent At: ${Date.getMessageTime(widget.message.sent)}', style: const TextStyle(color: Colors.white)),
          ),
        ),
        PopupMenuItem(
          value: 'readTime',
          child: ListTile(
            leading: const Icon(Icons.remove_red_eye, color: Colors.green, size: 26,),
            title: widget.message.read.isEmpty
                      ? const Text('Read At: Not seen yet')
                      : Text('Read At: ${Date.getMessageTime(widget.message.read)}', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
      elevation: 30,
      color: const Color.fromARGB(255, 48, 47, 47),
      shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
    ).then((value) async {
      if (value == null) return;

      // Handle the selected action
      switch (value) {
        case 'copy':
          // Handle copy action
          await Clipboard.setData(
                ClipboardData(text: widget.message.msg))
            .then((value) {
          Dialogs.showSnackbar(context, 'Text Copied!');
        });                    
          break;
        case 'save':
          // Handle save action
          try {
            log('Image Url: ${widget.message.msg}');
            await GallerySaver.saveImage(widget.message.msg,
                    albumName: 'We Chat')
                .then((success) {
              //for hiding bottom sheet
              if (success != null && success) {
                Dialogs.showSnackbar(
                    context, 'Image Successfully Saved!');
              }
            });
          } catch (e) {
            log('ErrorWhileSavingImg: $e');
          }
          break;
        case 'delete':
          // Handle delete action
          await APIs.deleteMessage(widget.message);
          break;
        case 'translate':
          showTranslatedMsg(context, widget.message.msg);
          break;
        case 'sentTime':
          
          break;
        case 'readTime':
          
          break;
      }
    });
  }

}