// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unitalk/main.dart';
import '../models/chat_user.dart';
import '../../api/apis.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfile extends StatefulWidget {
  final ChatUser user;

  const EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
            ),
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
        backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
        ),
      
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width*0.05),
            child: SingleChildScrollView(
              child: Column(children: [
                //for adding some space
                SizedBox(width: mq.width, height: mq.height*.03,),
                Stack(
                  children: [

                    _image != null ? 
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height*.1),
                      child: Image.file(
                        File(_image!),
                        width: mq.height*.2,
                        height: mq.height*.2,
                        fit: BoxFit.cover,
                        ),
                    ) :


                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height*.1),
                      child: CachedNetworkImage(
                        width: mq.height*.2,
                        height: mq.height*.2,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                      ),
                    ),
                    
                    //edit button in the stack
                    
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                        elevation: 1,
                        onPressed: () {
                          _showBottomSheet();
                        },
                        shape: const CircleBorder(),
                        color: Colors.white,
                        child: const Icon(Icons.edit, color: Colors.blue,),
                      ),
                    )
                  ],
                ),
                    
                //for adding some space
                SizedBox(height: mq.height*.03,),
                    
                Text(widget.user.email, style: const
                  TextStyle(color: Colors.white, fontSize: 16),
                    
                ),
                //for adding some space
                SizedBox(height: mq.height*.03,),
                    
                TextFormField(
                  initialValue: widget.user.name,
                  onSaved: (val) => APIs.me.name = val ?? '',
                  validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                  style: TextStyle(color: Colors.white), // Set the text color to white
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'e.g. David Miller',
                    hintStyle: TextStyle(color: Colors.white70), // Optionally set the hint text color
                    label: const Text('Name', style: TextStyle(color: Colors.white)),
                  ),
                ),

                    
                //for adding some space
                SizedBox(height: mq.height*.02,),
                    
                TextFormField(
  initialValue: widget.user.about,
  onSaved: (val) => APIs.me.about = val ?? '',
  validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
  style: TextStyle(color: Colors.white), // Set the text color to white
  maxLines: null, // Make it multiline and expand according to content
  decoration: InputDecoration(
    prefixIcon: const Icon(Icons.info_outline, color: Colors.blue),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    hintText: 'e.g. enjoying the world!',
    hintStyle: TextStyle(color: Colors.white70), // Optionally set the hint text color
    label: const Text('Bio', style: TextStyle(color: Colors.white)),
  ),
),


                    
                //for adding some space
                SizedBox(height: mq.height*.05,),
                    
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    minimumSize: Size(mq.width*0.5, mq.height*0.06),
                    // Add color here
                    backgroundColor:  Colors.greenAccent[400], // Change to the color you desire
                  ),
                  onPressed: (){
                    FocusScope.of(context).unfocus();
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      APIs.updateUserInfo();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile Updated Successfully'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit, size: 25,),
                  label: const Text('UPDATE', style: TextStyle(fontSize: 16),),),
                    
              ],),
            ),
          ),
        ),
      ),
    );
  }

void _showBottomSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color.fromARGB(221, 56, 51, 51), // Set the background color to a dark color
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (_) {
      return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: mq.height * 0.03, bottom: mq.height * 0.05),
        children: [
          Stack(
            children: [
              const Center(
                child: Text(
                  'Pick Profile Picture',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white, // Set the text color to white
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: SizedBox(
                    width: 50, // Adjust the width as needed
                    height: 50, // Adjust the height as needed
                    child: Image.asset('images/delete.png'),
                  ),
                  onPressed: () {
                    // Handle delete action
                    Navigator.pop(context);
                    // Add your delete functionality here
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: mq.height * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800], // Dark button background
                  shape: const CircleBorder(),
                  fixedSize: Size(mq.width * 0.3, mq.height * .15),
                ),
                onPressed: () async {
                  File? pickedImage;
                  File? tempImage;
                  try {
                    final photo = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (photo == null) return null;
                    tempImage = File(photo.path);
                    tempImage = await _cropImage(imageFile: tempImage);
                    setState(() {
                      pickedImage = tempImage;
                    });
                  } catch (error) {
                    log(error.toString());
                  }
                  Navigator.pop(context);
                  if (tempImage != null) {
                    APIs.updateProfilePic(tempImage);
                  }
                },
                child: Image.asset('images/add_image.png'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800], // Dark button background
                  shape: const CircleBorder(),
                  fixedSize: Size(mq.width * 0.3, mq.height * .15),
                ),
                onPressed: () async {
                  // final ImagePicker picker = ImagePicker();
                  // // Pick an image.
                  // final XFile? image = await picker.pickImage(
                  //   source: ImageSource.camera,
                  //   imageQuality: 80,
                  // );
                  // if (image != null) {
                  //   Navigator.pop(context);
                  //   setState(() {
                  //     _image = image.path;
                  //   });
                  //   APIs.updateProfilePic(File(_image!));
                  // }
                  //
                  File? pickedImage;
                  File? tempImage;
                  try {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image == null) return null;
                    tempImage = File(image.path);
                    tempImage = await _cropImage(imageFile: tempImage);
                    setState(() {
                      pickedImage = tempImage;
                    });
                  } catch (error) {
                    log(error.toString());
                  }
                  Navigator.pop(context);
                  if (tempImage != null) {
                    APIs.updateProfilePic(tempImage);
                  }
                },
                child: Image.asset('images/camera.png'),
              ),
            ],
          ),
        ],
      );
    },
  );
}

}

Future<File?> _cropImage({required File imageFile}) async {
  try {
    CroppedFile? croppedImg = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressQuality: 100,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // Set aspect ratio to 1:1
    );
    if (croppedImg == null) {
      return null;
    } else {
      return File(croppedImg.path);
    }
  } catch (e) {
    print(e);
  }
  return null;
}
