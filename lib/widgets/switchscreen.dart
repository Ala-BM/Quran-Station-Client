import 'package:flutter/material.dart';
import 'package:theway/l10n/app_localizations.dart';

class Switchscreen extends StatefulWidget {
  const Switchscreen({super.key});
  _SwitchState createState ()=> _SwitchState();}

class _SwitchState extends State<Switchscreen> {
  @override
  Widget build(BuildContext context){
      return  Container(
            color:const Color.fromARGB(255, 4, 0, 255),
            child:Directionality(
            textDirection: TextDirection.ltr,
            child: BottomNavigationBar(
              
              items: [
              BottomNavigationBarItem(
                  icon:IconButton(
                  onPressed: () {/*gjfkl*/},
                  icon:const  Icon(Icons.music_note)),
                  label: AppLocalizations.of(context)!.translate("Fav"),),
              BottomNavigationBarItem(
                  icon:IconButton(
                  onPressed: () {/*gjfkl*/},
                  icon:const  Icon(Icons.compass_calibration)),
                  label: AppLocalizations.of(context)!.translate("Browse"),),
              BottomNavigationBarItem(
                  icon:IconButton(
                  onPressed: () {/*gjfkl*/},
                  icon:const  Icon(Icons.settings)),
                  label:AppLocalizations.of(context)!.translate("Settings") ,),
              ],
          

            ),


      ));
  }
}
