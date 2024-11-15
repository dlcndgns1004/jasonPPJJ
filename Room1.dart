import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:selfproject/Chatting.dart';

class Room1 extends StatefulWidget {
  @override
  _Room1State createState() => _Room1State();
}

class _Room1State extends State<Room1> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> chatRooms = [];
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_sortChatRooms);
  }

  void _createNewChatRoom() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newRoomName = "";

        return AlertDialog(
          title: Text("Create New Chat Room"),
          content: TextField(
            onChanged: (value) {
              newRoomName = value;
            },
            decoration: InputDecoration(hintText: "Enter chat room name"),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Apply"),
              onPressed: () {
                if (newRoomName.isNotEmpty) {
                  setState(() {
                    chatRooms.add({
                      'name': newRoomName,
                      'date': DateTime.now(),
                      'isSticky': false,
                    });
                    _sortChatRooms();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _sortChatRooms() {
    setState(() {
      chatRooms.sort((a, b) {
        if (a['isSticky'] && !b['isSticky']) return -1;
        if (!a['isSticky'] && b['isSticky']) return 1;
        if (_tabController!.index == 0) {
          return a['name'].compareTo(b['name']);
        } else {
          return b['date'].compareTo(a['date']);
        }
      });
    });
  }

  void _toggleStickyStatus(int index) {
    setState(() {
      chatRooms[index]['isSticky'] = !chatRooms[index]['isSticky'];
      _sortChatRooms();
    });
  }

  void _showStickyDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sticky Chat"),
          content: Text("Do you want to mark this chat as sticky?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(chatRooms[index]['isSticky'] ? "Unstick" : "Stick"),
              onPressed: () {
                _toggleStickyStatus(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chatting'),
          actions: [
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
            IconButton(icon: Icon(Icons.chat_bubble_outline), onPressed: _createNewChatRoom),
            IconButton(icon: Icon(Icons.settings), onPressed: () {}),
          ],
        ),
        body: ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            //final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(chatRoom['date']);
            return ListTile(
              title: Text(chatRoom['name']),
              //subtitle: Text(formattedDate),
              trailing: chatRoom['isSticky'] ? Icon(Icons.push_pin, color: Colors.red) : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Chatting(roomName: chatRoom['name'])),
                );
              },
              onLongPress: () {
                _showStickyDialog(index);
              },
            );
          },
        ),
        bottomNavigationBar: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Sort by name"
            ),
            Tab(text: "Sort by date"
            ),
          ],
        ),
      ),
    );
  }
}
