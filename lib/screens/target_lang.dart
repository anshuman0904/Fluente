import 'package:flutter/material.dart';

import '../api/apis.dart';

class TargetLanguage extends StatefulWidget {
  const TargetLanguage({super.key});

  @override
  State<TargetLanguage> createState() => _TargetLanguageState();
}

class _TargetLanguageState extends State<TargetLanguage> {
  String? targetLanguage = APIs.me.target;
  String nativeLanguage = APIs.me.native;
  String? translationLang = APIs.me.transLang;
  final List<String> languages = ['English', 'Spanish', 'Greek', 'French', 'Dutch', 'Hindi'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Target Language',
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Select your target language:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Increased font size
                  ),
                ),
                SizedBox(height: 20),
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
                        dropdownColor: Color.fromARGB(255, 73, 71, 71),
                        items: languages
                            .where((language) => language != nativeLanguage)
                            .map((language) {
                          return DropdownMenuItem(
                            value: language,
                            child: Text(
                              language,
                              style: TextStyle(color: Colors.white),
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
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 213, 132, 250),
                  ),
                  onPressed: () {
                    // Check if target language is selected
                    if (targetLanguage != null) {
                      APIs.updateTarget(targetLanguage!);
                      APIs.me.target = targetLanguage!;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Target Language updated successfully'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a language.'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Change Target Language',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 20),
                const Text(
                  "Note: Target language once changed can't be changed for the next 48 hours.",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 50,),


                const Text(
                  "Select your translation language:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Increased font size
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Translation Language',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        value: translationLang,
                        dropdownColor: Color.fromARGB(255, 73, 71, 71),
                        items: languages
                            .map((language1) {
                          return DropdownMenuItem(
                            value: language1,
                            child: Text(
                              language1,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            translationLang = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 213, 132, 250),
                  ),
                  onPressed: () {
                    // Check if target language is selected
                    if (translationLang != null) {
                      APIs.updateTransLang(translationLang!);
                      APIs.me.transLang = translationLang!;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Translation Language updated successfully'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a language.'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Change Translation Language',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 20),
                const Text(
                  "Note: Translation of messages will be done in this language.",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
