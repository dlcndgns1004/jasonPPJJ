import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Chatting extends StatefulWidget {
  final String roomName;

  Chatting({required this.roomName});

  @override
  _ChattingState createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  List<Map<String, String>> messages = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('messages_${widget.roomName}');
    if (data != null) {
      setState(() {
        messages = List<Map<String, String>>.from(json.decode(data));
      });
    }
  }

  void _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('messages_${widget.roomName}', json.encode(messages));
  }

  Future<void> _sendMessage(String text) async {
    final response = await http.post(
      Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer YOUR_API_KEY"
      },
      body: json.encode({
        "model": "llama3-8b-8192",
        "messages": [
          {"role": "user", "content": text}
        ]
      }),
    );

    if (response.statusCode == 200) {
      var reply = json.decode(response.body)['choices'][0]['message']['content'];
      setState(() {
        messages.add({"role": "user", "content": text});
        messages.add({"role": "assistant", "content": reply});
      });
      _saveMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.roomName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message['content']!),
                  subtitle: Text(message['role'] == 'user' ? 'You' : 'Assistant'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Input message here',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
