import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Backend/movieData.dart';

class Movie extends StatefulWidget {
  final MovieData? movie; // Add a field to hold the movie data

  const Movie(this.movie, {Key? key}) : super(key: key);

  @override
  State<Movie> createState() => _MovieState();
}

class _MovieState extends State<Movie> {
  List<Color> colors = [
    const Color(0xFF15D2BC),
    const Color(0xFFCD9D0F),
    const Color(0xFF564CA3),
    const Color(0xFFE26CA5),
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth;
    double screenHeight;

    //Widget orientation = Column();
    double Width = MediaQuery.of(context).size.width;
    double Height = MediaQuery.of(context).size.height;

    print(Width);
    print(Height);

    bool autoRotate() {
      if (Width / Height >= 0.63) return true;
      return false;
    }

    Widget orientation(stack, padding) {
      return autoRotate()
          ? Row(children: [stack, padding])
          : Column(children: [stack, padding]);
    }

    if (autoRotate()) {
      screenWidth = Width * 0.48;
      screenHeight = screenWidth * .70;
    } else {
      screenWidth = Width;
      screenHeight = Height;
    }

    print(autoRotate());
    return Scaffold(
        body: orientation(
      Stack(
        alignment: Alignment.center,
        children: [
          // With Respect to the first one
          Container(
            width: screenWidth,
            height: screenWidth * 1.013,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.movie?.imageUrl ?? ''),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: screenWidth * 0.17,
            left: screenWidth * 0.066,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: screenWidth * 0.04,
                  ),
                ),
                const SizedBox(width: 25),
                Text(
                  'Watch',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: screenWidth * 0.0426,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          Positioned(
            bottom: autoRotate() ? screenWidth * 0.226 : screenWidth * 0.410,
            child: Text(
              'In theaters december 22, 2021',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: screenWidth * 0.0426,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Positioned(
            left: autoRotate() ? screenWidth * 0.03 : null,
            bottom: autoRotate() ? screenWidth * 0.053 : screenWidth * 0.25,
            child: SizedBox(
              width: autoRotate() ? screenWidth * 0.457 : screenWidth * 0.648,
              height: screenWidth * 0.133,
              //color: Colors.black,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.02), // Customize the border radius
                  ),
                  backgroundColor: const Color(
                      0xFF61C3F2), // Customize the button background color                         // Customize the button text color
                ),
                child: Text(
                  'Get Tickets',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: screenWidth * 0.037,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: autoRotate() ? screenWidth * 0.514 : null,
            bottom: autoRotate() ? screenWidth * 0.053 : screenWidth * 0.090,
            child: SizedBox(
              width: autoRotate() ? screenWidth * 0.455 : screenWidth * 0.648,
              height: screenWidth * 0.133,
              //color: Colors.black,
              child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          screenWidth * 0.02), // Customize the border radius
                    ),
                    side: const BorderSide(
                      color: Color(0xFF61C3F2),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: screenWidth * 0.042,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Watch Trailer',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: screenWidth * 0.037,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  )),
            ),
          )
        ],
      ),

      // Rotate on 515 screen widt
      // Bottom Side
      Padding(
        padding: autoRotate()
            ? EdgeInsets.only(left: screenWidth * 0.106)
            : EdgeInsets.symmetric(horizontal: screenWidth * 0.106),
        child: SizedBox(
          width: screenWidth - (screenWidth * 0.13),
          height: autoRotate()
              ? screenWidth * 0.75
              : screenHeight - (screenWidth * 1.3),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Genres',
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: screenWidth * 0.0426,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.movie?.genres
                              .toList(growable: false)
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final genre = entry.value;
                            return Container(
                              margin: EdgeInsets.only(right: screenWidth * 0.02),
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(screenWidth * 0.042),
                              ),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.016),
                                  child: Text(
                                    genre,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.032,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );

                          }).toList() ??
                          [],
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.058),
                  Container(
                    height: 1,
                    color: Colors.black26,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Text(
                    'Overview',
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: screenWidth * 0.0426,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: screenWidth * 0.0373),
                  SizedBox(
                    height: screenWidth * 0.3,
                    child: TextField(
                      enabled: false,
                      maxLines: 15,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: widget.movie?.description ?? '',
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: screenWidth * 0.032,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
