import 'package:flutter/material.dart';
import 'package:theway/Providers/KhinsiderAlbums.dart';
import 'package:theway/Services/KhinsiderScrapper.dart';
import 'animatedImageContainer.dart';


//import '../widgets/MovingText.dart';

class Albumbrowse extends StatefulWidget {
  final Function(Album) onAlbumSelected;
  const Albumbrowse({super.key, required this.onAlbumSelected});

  @override
  _AlbumbrowseState createState() => _AlbumbrowseState();
}

class _AlbumbrowseState extends State<Albumbrowse> {
  int selectedCategoryIndex = 0;
  @override
  Widget build(BuildContext context) {
    //double screenheight = MediaQuery.of(context).size.height;
    //double screensize=screenheight*0.8;
    Future<List<Album>> albumList = fetchAlbums();
    
    //final List<String> extList=[];

    return FutureBuilder<List<Album>>(
        future: albumList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}')); // Show error if there's an issue _****Add Error Handling
          } else if (snapshot.hasData) {
            List<Album> albums = snapshot.data ?? [];
            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
                padding: const EdgeInsets.all(8.0),
                itemCount: albums.length, // to
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return Animatedimagecontainer(album: album,onAlbumSelected: widget.onAlbumSelected);
                });
          }
          return const Center(child: Text('No albums found.'));
        });

    /*ListView.builder(
            shrinkWrap: true,
              itemCount: extList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    //Load Ext Settings
                    setState(() {
                      selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical:8),
                    margin: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                    decoration: BoxDecoration(
                      color: selectedCategoryIndex == index
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),),
                    child: Center(
                      child: Text(
                        extList[index],
                        style: TextStyle(
                          color: selectedCategoryIndex == index
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                  ),
                  
                ));
              },
            );*/
  }
}
