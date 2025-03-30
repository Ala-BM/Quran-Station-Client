import 'package:flutter/material.dart';

class Switchscreen extends StatefulWidget {
  const Switchscreen({super.key});
  _SwitchState createState ()=> _SwitchState();}

class _SwitchState extends State<Switchscreen> {
  @override
  Widget build(BuildContext context){
      return  Container(
            color:const Color.fromARGB(255, 4, 0, 255),
            child: BottomNavigationBar(
              
              items: [
              BottomNavigationBarItem(
                  icon:IconButton(
                  onPressed: () {/*gjfkl*/},
                  icon:const  Icon(Icons.music_note)),
                  label: "Listen",),
              BottomNavigationBarItem(
                  icon:IconButton(
                  onPressed: () {/*gjfkl*/},
                  icon:const  Icon(Icons.compass_calibration)),
                  label: "Browse",),
              BottomNavigationBarItem(
                  icon:IconButton(
                  onPressed: () {/*gjfkl*/},
                  icon:const  Icon(Icons.settings)),
                  label: "Settings",),
              ],
          

            ),


      );
  }
}
