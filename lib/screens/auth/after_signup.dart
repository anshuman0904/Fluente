import 'dart:developer';

import 'package:flutter/material.dart';
import '../../api/apis.dart';
import '../home_screen.dart';

class AfterSU extends StatefulWidget {
  const AfterSU({super.key});

  @override
  State<AfterSU> createState() => _AfterSUState();
}

class _AfterSUState extends State<AfterSU> {
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  final TextEditingController _dobController = TextEditingController();

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
        log(_dobController.text);
      });
    }
  }

  String? targetLanguage;
  String? nativeLanguage;
  final List<String> languages = ['English', 'Spanish', 'German', 'French', 'Arabic', 'Hindi'];

  final TextEditingController _controller = TextEditingController();
  String _aboutText = '';
  final int _maxLength = 1000;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'We wanna know you better...',
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
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                          controller: _dobController,
                          // decoration: const InputDecoration(
                          //   labelText: 'Date of Birth',
                          //   labelStyle: TextStyle(color: Colors.white),
                          //   hintText: 'YYYY-MM-DD',
                          //   hintStyle: TextStyle(color: Colors.white),
                          //   suffixIcon: Icon(Icons.calendar_today, color: Colors.white,),
                          // ),
                          decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black, // Black background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white), // White border
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white), // White border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white), // White border
                        ),
                        hintText: 'YYYY-MM-DD',
                        hintStyle: const TextStyle(color: Colors.white), // White hint text
                        labelText: 'Date of Birth',
                        labelStyle: const TextStyle(color: Colors.white), // White label text
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        suffixIcon: Icon(Icons.calendar_today, color: Colors.white,),
                      ),
                      style: const TextStyle(color: Colors.white), 
                          readOnly: true,
                          onTap: () => _selectDate(context),
                        ),
                    const Text(
                      "Select your native language:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18, // Increased font size
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Native Language',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            value: nativeLanguage,
                            dropdownColor: const Color.fromARGB(255, 73, 71, 71),
                            items: languages.where((language) => language != targetLanguage).map((language) {
                              return DropdownMenuItem(
                                value: language,
                                child: Text(
                                  language,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                nativeLanguage = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Note: Native language once selected can never be changed.",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 70),
                    const Text(
                      "Select your target language:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18, // Increased font size
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Target Language',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            value: targetLanguage,
                            dropdownColor: const Color.fromARGB(255, 73, 71, 71),
                            items: languages.where((language) => language != nativeLanguage).map((language) {
                              return DropdownMenuItem(
                                value: language,
                                child: Text(
                                  language,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                targetLanguage = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Note: Target language once selected can be updated only after 48 hours.",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 70),

                    // About box
                    TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white), // White text
                      maxLines: 10, // Allows the textbox to expand to 10 lines
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black, // Black background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white), // White border
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white), // White border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white), // White border
                        ),
                        hintText: 'Tell us about yourself',
                        hintStyle: const TextStyle(color: Colors.white), // White hint text
                        labelText: 'Bio',
                        labelStyle: const TextStyle(color: Colors.white), // White label text
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        counterText: '${_controller.text.length}/$_maxLength',
                        counterStyle: const TextStyle(color: Colors.white), // White counter text
                      ),
                      onChanged: (text) {
                        setState(() {
                          if (text.length <= _maxLength) {
                            _aboutText = text;
                          } else {
                            _controller.text = _aboutText;
                            _controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: _maxLength),
                            );
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 70),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 213, 132, 250),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Adjust padding
                        minimumSize: const Size(200, 50), // Minimum size of the button
                        textStyle: const TextStyle(fontSize: 18), // Text size
                      ),
                      onPressed: () async {
                        // Check if target language is selected
                        if (targetLanguage != null && nativeLanguage != null && _aboutText != "" && _dobController.text!="") {
                          await APIs.CreateUser(nativeLanguage!, targetLanguage!, _aboutText, _dobController.text).then((value) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All the fields are mandatory'),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../../api/apis.dart';
// import '../home_screen.dart';

// class AfterSU extends StatefulWidget {
//   const AfterSU({super.key});

//   @override
//   State<AfterSU> createState() => _AfterSUState();
// }

// class _AfterSUState extends State<AfterSU> {
//   @override
//   void initState() {
//     super.initState();
//     APIs.getSelfInfo();
//   }

//   String? targetLanguage;
//   String? nativeLanguage;
//   final List<String> languages = ['English', 'Spanish', 'German', 'French', 'Arabic', 'Hindi'];

//   final TextEditingController _controller = TextEditingController();
//   String _aboutText = '';
//   final int _maxLength = 1000;

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text(
//               'We wanna know you better...',
//               style: TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//             iconTheme: const IconThemeData(
//               color: Colors.white,
//             ),
//             backgroundColor: Colors.black,
//           ),
//           backgroundColor: Colors.black,
//           body: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Select your native language:",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18, // Increased font size
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: DropdownButtonFormField<String>(
//                             decoration: const InputDecoration(
//                               labelText: 'Native Language',
//                               labelStyle: TextStyle(color: Colors.white),
//                               enabledBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.white),
//                               ),
//                             ),
//                             value: nativeLanguage,
//                             dropdownColor: Color.fromARGB(255, 73, 71, 71),
//                             items: languages.where((language) => language != targetLanguage).map((language) {
//                               return DropdownMenuItem(
//                                 value: language,
//                                 child: Text(
//                                   language,
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 nativeLanguage = value;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     const Text(
//                       "Note: Native language once selected can never be changed.",
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 70),
//                     const Text(
//                       "Select your target language:",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18, // Increased font size
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: DropdownButtonFormField<String>(
//                             decoration: const InputDecoration(
//                               labelText: 'Target Language',
//                               labelStyle: TextStyle(color: Colors.white),
//                               enabledBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.white),
//                               ),
//                             ),
//                             value: targetLanguage,
//                             dropdownColor: Color.fromARGB(255, 73, 71, 71),
//                             items: languages.where((language) => language != nativeLanguage).map((language) {
//                               return DropdownMenuItem(
//                                 value: language,
//                                 child: Text(
//                                   language,
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 targetLanguage = value;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     const Text(
//                       "Note: Target language once selected can be updated only after 48 hours.",
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 70),
                
                
//                     //about box
//                     TextField(
//                 controller: _controller,
//                 style: TextStyle(color: Colors.white), // White text
//                 maxLines: 10, // Allows the textbox to expand to 10 lines
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.black, // Black background
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.white), // White border
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.white), // White border
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.white), // White border
//                   ),
//                   hintText: 'Tell us about yourself',
//                   hintStyle: TextStyle(color: Colors.white), // White hint text
//                   labelText: 'Bio',
//                   labelStyle: TextStyle(color: Colors.white), // White label text
//                   floatingLabelBehavior: FloatingLabelBehavior.always,
//                   counterText: '${_controller.text.length}/$_maxLength',
//                   counterStyle: TextStyle(color: Colors.white), // White counter text
//                 ),
//                 onChanged: (text) {
//                   setState(() {
//                     if (text.length <= _maxLength) {
//                       _aboutText = text;
//                     } else {
//                       _controller.text = _aboutText;
//                       _controller.selection = TextSelection.fromPosition(
//                         TextPosition(offset: _maxLength),
//                       );
//                     }
//                   });
//                 },
//               ),
                
                
//                     SizedBox(height: 70),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color.fromARGB(255, 213, 132, 250),
//                         padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Adjust padding
//                         minimumSize: Size(200, 50), // Minimum size of the button
//                         textStyle: TextStyle(fontSize: 18), // Text size
//                       ),
//                       onPressed: () async {
//                         // Check if target language is selected
//                         if (targetLanguage != null && nativeLanguage!=null && _aboutText!= "") {
//                           await APIs.CreateUser(nativeLanguage!, targetLanguage!, _aboutText).then((value) {
//                             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
//                           });
//                         } 
//                         else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('All the fields are mandatory'),
//                             ),
//                           );
//                         }
//                       },
//                       child: const Text(
//                         'Done',
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }