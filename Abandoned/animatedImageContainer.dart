import 'package:flutter/material.dart';
import '../Classes/KhinsiderAlbums.dart';
import 'package:marquee/marquee.dart';

class Animatedimagecontainer extends StatefulWidget {
  final Album album;
  final Function(Album) onAlbumSelected;

 const Animatedimagecontainer({super.key, required this.onAlbumSelected, required this.album});

  @override
  State <Animatedimagecontainer> createState() =>  AnimatedimagecontainerState();
}


class  AnimatedimagecontainerState extends State <Animatedimagecontainer> {
    double scale = 1.0;
  @override
  Widget build(BuildContext context) {
    const TextStyle styleCont = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 1.0,
      shadows: [
        Shadow(
          offset: Offset(-1, -1),
          color: Colors.black,
        ),
        Shadow(
          offset: Offset(1, -1),
          color: Colors.black,
        ),
        Shadow(
          offset: Offset(1, 1),
          color: Colors.black,
        ),
        Shadow(
          offset: Offset(-1, 1),
          color: Colors.black,
        ),
      ],
    );
  
    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          scale =0.9;
                        });
                         await Future.delayed(const Duration(milliseconds: 20), () {
                          setState(() {
                            scale  = 1.0;
                          });
                        });
                                                                         widget.onAlbumSelected(widget.album);
                      },
                      onLongPressStart: (_) {
                        setState(() {
                          scale  = 0.9; // Shrink on long press start
                        });
                      },
                      onLongPressEnd: (_) {
                        setState(() {
                          scale  =
                              1.0; // Return to original size on long press end
                        });
                      },
                      child:
                      Transform(
        alignment: Alignment.center, // Scale from the center
        transform: Matrix4.identity()..scale(scale),
                      
                     child: AnimatedContainer(            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,

            
                      child:Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3), // Shadow color
        blurRadius: 5, // Spread of the shadow
        spreadRadius: 2, // Extent of the shadow
        offset: const Offset(4, 4), // Shadow offset
      ),
    ],
                                image: DecorationImage(
                                    image: NetworkImage(widget.album.image),
                                    fit: BoxFit.fill)),

                         
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              // Measure text width based on constraints
                              final textPainter = TextPainter(
                                text: TextSpan(
                                  text: widget.album.album,
                                  style: styleCont,
                                ),
                                maxLines: 1,
                                textDirection: TextDirection.ltr,
                              )..layout(maxWidth: double.infinity);

                              if (textPainter.width > constraints.maxWidth) {
                                // Use Marquee for long text
                                return Container(
                                  decoration: const BoxDecoration(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(16), // Bottom-left corner
      bottomRight: Radius.circular(16),
      ),
      color: Colors.black54),

                                  height: 30,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  width: constraints.maxWidth,
                                  child: Marquee(
                                    text: widget.album.album,
                                    style: styleCont,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    blankSpace: 20.0, // Space between repeats
                                    velocity: 15.0, // Speed of the text
                                    pauseAfterRound: const Duration(
                                        seconds: 1), // Pause between scrolls
                                    startPadding: 10.0, // Padding at the start
                                    accelerationDuration: const Duration(
                                        seconds: 1), // Acceleration time
                                    accelerationCurve: Curves.easeIn,
                                    decelerationDuration: const Duration(
                                        milliseconds: 500), // Deceleration time
                                    decelerationCurve: Curves.easeOut,
                                  ),
                                );
                              } else {
                                // Render static text for short text
                                return Container(
                                    height: 30,
                                     decoration: const BoxDecoration(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(16), // Bottom-left corner
      bottomRight: Radius.circular(16),
      ),
      color: Colors.black54),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    width: constraints.maxWidth,
                                    child: Text(
                                      maxLines: 1,
                                      widget.album.album,
                                      overflow: TextOverflow.fade,
                                      style: styleCont,
                                      textAlign: TextAlign.left,
                                    ));
                              }
                            }),
                          )
                        ],
                      ) ,
                      ) ));
  }
}