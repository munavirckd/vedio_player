import 'package:flutter/material.dart';
import 'package:vedio_player/Authentication/enter_code_screen.dart';
import 'package:vedio_player/Authentication/registeration.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lilac Infotech Pvt. Ltd.',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 10),
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.login),
            title: Text('Logout'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
