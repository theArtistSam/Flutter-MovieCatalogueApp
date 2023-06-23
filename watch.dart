// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:movies/Backend/movieData.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:movies/Frontend/search.dart';

class Watch extends StatefulWidget {
  const Watch({Key? key}) : super(key: key);

  @override
  State<Watch> createState() => _WatchState();
}

class _WatchState extends State<Watch> {
  String apiKey = '40ed3d8787e7fc3de73f7ebaf3602080';

  // Future<List<MovieData>> fetchMovies() async {
  //   final url = Uri.https('api.themoviedb.org', '/3/movie/popular', {'api_key': apiKey});
  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final decodedData = json.decode(response.body);
      
  //     final List<MovieData> movies = [];

  //     for (var movieData in decodedData['results']) {
  //       final title = movieData['title'];
  //       //print(title);
  //       final imageUrl = 'https://image.tmdb.org/t/p/w500${movieData['poster_path']}';
  //       final rating = movieData['vote_average'].toDouble();

  //       movies.add(MovieData(title: title, imageUrl: imageUrl, rating: rating));
  //     }

  //     return movies;
  //   } else {
  //     throw Exception('Failed to load movies');
  //   }
  // }
    Future<List<MovieData>> fetchMovies() async {
    final url = Uri.https('api.themoviedb.org', '/3/movie/popular', {'api_key': apiKey});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final List<MovieData> movies = [];

      for (var movieData in decodedData['results']) {
        final title = movieData['title'];
        final imageUrl = 'https://image.tmdb.org/t/p/w500${movieData['poster_path']}';
        final rating = movieData['vote_average'].toDouble();

        // Fetch additional movie details using the movie ID
        final movieId = movieData['id'];
        final movieDetailsUrl = Uri.https('api.themoviedb.org', '/3/movie/$movieId', {'api_key': apiKey});
        final detailsResponse = await http.get(movieDetailsUrl);

        if (detailsResponse.statusCode == 200) {
          final detailsData = json.decode(detailsResponse.body);
          final description = detailsData['overview'];
          final genresData = detailsData['genres'];
          final genres = genresData.map((genre) => genre['name']).toList().cast<String>();

          movies.add(MovieData.fromDefault(id: movieId, title: title, imageUrl: imageUrl, rating: rating, description: description, genres: genres));
        } else {
          throw Exception('Failed to fetch movie details');
        }
      }

      return movies;
    } else {
      throw Exception('Failed to load movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth;
    double screenHeight;
    
    //Widget orientation = Column();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final topBarHeight = MediaQuery.of(context).padding.top;
    //print(topBarHeight);
    // Check if screen requires Auto Rotate
    bool autoRotate(){
      if (width / height >= 0.63) return true;
      return false;
    }

    // Change Screen Resulation if requires Auto Rotate
    if (autoRotate()){
      screenWidth = width * 0.48;
      screenHeight = screenWidth * .70;
    }
    else{
      screenWidth = width;
      screenHeight = height;
    }

    int gridCount(double width) {
      if (width > 375) {
        return (width ~/ 375).toInt();
      }
      return 1;
    }


    print(width);
    print(height);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
       body: Center(
        child: Column(
          
          children: [
            Container(
                width: width,
                // const? screenWidth * 0.296
                height: 111 + topBarHeight ,
                color: const Color(0xFFF6F6FA),
                child: Padding(
                  //padding: EdgeInsets.fromLTRB(screenWidth * 0.066, screenWidth * 0.146, screenWidth * 0.066, screenWidth * 0.02),
                  padding: EdgeInsets.fromLTRB(25, 25 + topBarHeight, 25, 25),                  
                  child: Row(
                    children: [
                      
                      Text(
                        'Watch',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w500
                        )
                      ),
                      const Expanded(child:  SizedBox()),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  Search()),
                          );
                        },
                        icon: const Icon(
                                                  
                          Icons.search_sharp,
                          color: Colors.black,
                          //size: screenWidth * 0.04,
                          semanticLabel: 'Text to announce in accessibility modes',
                          
                        ),
                      ),
                    ]                    
                  ),
                ),
              ),            
            // Customized code goes here
            SizedBox(
              width: width,
              height: height - 111 - topBarHeight, 
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: FutureBuilder<List<MovieData>>(
                  future: fetchMovies(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final movies = snapshot.data!;
                      return SingleChildScrollView(                        
                        physics: const BouncingScrollPhysics(),
                          child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: gridCount(width),
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                    childAspectRatio: 1.86
                                  ),
                                  itemCount: movies.length,
                                  itemBuilder: (context, index) {
                                    final movie = movies[index];
                                    return movieTile(width, movie.title, movie.imageUrl);
                                  },
                                ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


Widget movieTile(double width, String movieName, String imgURL) {
  return Container(
    width: width < 335 ? width * 0.893 : 335,
    height: width < 335 ? width * 0.48 : 180,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(imgURL),
        fit: BoxFit.cover,
      ),
      color: Colors.black26,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          left:  0,
          child: Container(
            width: 335,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black, Colors.black.withOpacity(0.0)],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            movieName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
}