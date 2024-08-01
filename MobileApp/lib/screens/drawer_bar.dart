import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:start/models/profile_data.dart';
import 'package:start/newscreen.dart';
import 'package:start/qrscan/scan_code_page.dart';
import 'package:start/screens/home_screen.dart';
import 'package:start/screens/loginscreen.dart';

class DrawerNaviagtion extends StatefulWidget {
  const DrawerNaviagtion({
    super.key,
    required this.profileData,
  });
  final ProfileData profileData;

  @override
  State<DrawerNaviagtion> createState() => _DrawerNaviagtionState();
}

class _DrawerNaviagtionState extends State<DrawerNaviagtion> {
  @override
  Widget build(BuildContext context) {
    Future<void> onLogout(BuildContext context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('access_token');

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Loginscreen()));
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              widget.profileData.userProfile!.firstName!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(widget.profileData.userProfile!.email!,
                style: TextStyle(fontSize: 15)),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image(
                  image: NetworkImage(
                      widget.profileData.userProfile!.profilePicture!),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    image: AssetImage('assets/images/kfueit_logo.jpg'),
                    colorFilter:
                        ColorFilter.mode(Colors.black45, BlendMode.darken),
                    fit: BoxFit.cover)),
          ),
          ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.green,
              ),
              title: Text("Home"),
              onTap: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SecondScreen()))
                  }),
          ListTile(
              leading: Icon(
                Icons.attribution,
                color: Colors.brown,
              ),
              title: Text("Attendance"),
              onTap: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Myhome()))
                  }),
          ListTile(
            leading: Icon(
              Icons.mark_chat_read_sharp,
              color: Colors.purple,
            ),
            title: Text("Mark Attendance"),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScanCodePage()),
              ),
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.logout_outlined,
              color: Colors.red,
            ),
            title: Text("Logout"),
            onTap: () => {
              onLogout(context),
            },
          ),
        ],
      ),
    );
  }
}
