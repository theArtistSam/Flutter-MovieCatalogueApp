import 'dart:math';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:movies/Backend/movieData.dart';
import 'package:movies/Frontend/movie.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Search extends StatefulWidget {
  Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  
  bool _isSearching = false;
  bool _isCompleted = false;
  late int _totalResults = 0;
  final TextEditingController _textEditingController = TextEditingController();
  
  // Your API Key here 
  String apiKey = 'API_KEY';
  

  Future<List<MovieData>> searchMovies(String movieTitle) async {
  final queryParameters = {'api_key': apiKey, 'query': movieTitle};
  final url = Uri.https('api.themoviedb.org', '/3/search/movie', queryParameters);
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body);
    final List<MovieData> movies = [];

    for (var movieData in decodedData['results']) {
      final title = movieData['title'];
      final imageUrl = 'https://image.tmdb.org/t/p/w500${movieData['poster_path']}';
      final rating = movieData['vote_average'].toDouble();
      final genreIds = List<int>.from(movieData['genre_ids']);

      final genres = await fetchGenre(genreIds);
      print(genres);
      final description = movieData['overview'];

      movies.add(MovieData.fromDefault(title: title, imageUrl: imageUrl, rating: rating, genres: genres, description: description));
    }
    //print(  "len${movies.length}" );
    _totalResults = movies.length;

    return movies;
  } else {
    throw Exception('Failed to load movies');
  }
}

Future<List<String>> fetchGenre(List<int> genreIds) async {
  if (genreIds.isEmpty) {
    return [];
  }

  final url = Uri.https('api.themoviedb.org', '/3/genre/movie/list', {'api_key': apiKey});
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body);
    final genres = decodedData['genres'];
    final genreNames = <String>[];

    for (var genreData in genres) {
      final id = genreData['id'];
      final name = genreData['name'];

      if (genreIds.contains(id)) {
        genreNames.add(name);
      }
    }

    return genreNames;
  }

  return [];
}



Future<List<MovieData>> fetchGenres() async {
  final url = Uri.https('api.themoviedb.org', '/3/genre/movie/list', {'api_key': apiKey});
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body);
    final List<MovieData> genres = [];

    for (var genreData in decodedData['genres']) {
      final genreId = genreData['id'];
      List<String> genreName= [];
      genreName.add(genreData['name']);

      final genreImageUrl = await getRandomMovieImageUrlByGenre(genreId);

      genres.add(MovieData.fromGenre(id: genreId, genres: genreName, imageUrl: genreImageUrl));
    }

    return genres;
  } else {
    throw Exception('Failed to load genres');
  }
}

Future<String> getRandomMovieImageUrlByGenre(int genreId) async {
  final url = Uri.https('api.themoviedb.org', '/3/discover/movie', {'api_key': apiKey, 'with_genres': genreId.toString()});
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body);
    final results = decodedData['results'];

    if (results.isNotEmpty) {
      final randomIndex = Random().nextInt(results.length);
      final movieData = results[randomIndex];
      final imageUrl = 'https://image.tmdb.org/t/p/w500${movieData['poster_path']}';
      return imageUrl;
    }
  }

  return ''; // Return an empty string if no movie image is found
}





  @override
  Widget build(BuildContext context) {
  
    double screenWidth;
    double screenHeight;
    
    //Widget orientation = Column();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final topBarHeight = MediaQuery.of(context).padding.top;
    
    print(width);
    print(height);
    
    bool autoRotate(){
      //
      if (width / height >= 0.63) return true;
      return false;
    }

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
        return (width ~/ 375).toInt() + 1;
      }
      return 1 + 1;
    }

    @override
    void dispose() {
      _textEditingController.dispose();
      super.dispose();
    }

    print(screenWidth);
    print(screenHeight);
    
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
        body: Center(
          // made changes in herr
        child: Column(
          children: [
            Container(
                width: width,
                // const ?
                height: 111 + topBarHeight,
                color: const Color(0xFFF6F6FA),
                child: Padding(
                 padding: EdgeInsets.fromLTRB(25, 25 + topBarHeight, 25, 25),                  
                //padding: EdgeInsets.fromLTRB(25, screenWidth * 0.133, screenWidth * 0.066, screenWidth * 0.066),
                  child: (_isSearching && _isCompleted) ? Expanded(
                      child: Row(
                        children: [
                          SizedBox.square(
                            child: IconButton(
                              onPressed: (){
                                setState(() {
                                  _textEditingController.clear();
                                  _isSearching = false;
                                  _isCompleted = false;
                                });
                              },
                              icon:  const Icon(
                                Icons.arrow_back_ios,
                                //size: screenWidth * 0.06,
                                color: Colors.black,
                              ) 
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04,),
                          Text(
                            '$_totalResults Results Found',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                            )
                          ),
                        ],
                      )
                    )
                    : Container(
                    width: width,
                    //height: screenWidth * 0.0138,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(50)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox.square(
                            child: IconButton(
                              onPressed: (){},
                              icon:  const Icon(
                                Icons.search,
                                //size: screenWidth * 0.06,
                              ) 
                            ),
                          ),
                          SizedBox(width: 2),
                          Expanded(                            
                            child: TextField(                                
                                controller: _textEditingController,
                                onChanged: (noUse) {
                                  setState(() {
                                    //print('here');
                                    _isSearching = true;                                 
                                  });
                                },
                                onSubmitted: (none) {
                                  setState(() {
                                    print('here');
                                    if (_isSearching){
                                      _isCompleted = true;  
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  
                                  hintText: 'TV shows, movies and more',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.black38,
                                    //fontSize: _screenWidth * 0.042,
                                    fontWeight: FontWeight.w400
                                  ),
                                  border: InputBorder.none,
                                ),
                    
                                
                              ),
                          ),
                          _isSearching ? SizedBox.square(
                            child: IconButton(
                              onPressed: (){
                                setState(() {
                                  _textEditingController.clear();
                                  _isSearching = false;
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                //size: screenWidth * 0.06,
                              )
                            ),
                          ) : const SizedBox(),
                          
                        ],
                      ),
                    )
                    // child: Padding(
                    //   padding: EdgeInsets.all(10),
                    // )
                  ),
                ),
              ),            
        
        
              // if is searching then
              _isSearching ? SizedBox(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),                
                      
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      Text(
                          'Top Results',
                          style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                        )
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: width,
                        height: 1,
                        color: Colors.black26,
                      )
                    ],
                  ),
                ),
              ) : const SizedBox(),
              _isSearching ? SizedBox(
              width: width,
              height: height - 111 - 55 - 40 - topBarHeight, 
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20,20,20,0),
                child: FutureBuilder<List<MovieData>>(
                  future: searchMovies(_textEditingController.text),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final movies = snapshot.data!;
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                          child: Column(
                          children: [
                            ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                              itemCount: movies.length,
                              separatorBuilder: (context, index) => SizedBox(height: screenWidth * 0.04), // Add spacing between tiles
                              itemBuilder: (context, index) {
                                final movie = movies[index];
                                //print(movie.title +  movie.genres.elementAt(0) + movie.imageUrl );
                                print(movies.length);
                                return searchTile(screenWidth,
                                movie.title,
                                movie.genres.isNotEmpty ? movie.genres.elementAt(0) : '',
                                movie.imageUrl,
                                (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>  Movie(movie)),
                                    );
                                  }
                                );
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
            ) : 
            SizedBox(
                width: width,
                height: height - 111 - topBarHeight,
                //color: Colors.amber,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FutureBuilder<List<MovieData>>(
                    future: fetchGenres(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final movies = snapshot.data!;
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                            child: Column(
                            children: [
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: gridCount(width),
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 1.63
                                ),
                                itemCount: movies.length,
                                itemBuilder: (context, index) {
                                  final movie = movies[index];
                                  return genreTile(
                                    width,
                                    movie.genres.isNotEmpty ? movie.genres.elementAt(0) : '',
                                    movie.imageUrl,                                    
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        print(snapshot.error);
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


  Widget searchTile(screenWidth, movieName, movieGenre, imgURL, onTap){
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Container(  
              // width: screenWidth * 0.344,
              // height: screenWidth * 0.266,
              width: 130,
              height: 100,
          
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imgURL),
                  fit: BoxFit.cover,
                ),
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10)
                
              ),            
            ),    
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movieName,
                      style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                    )
                  ),
                  const SizedBox(height: 8),
                  Text(
                      movieGenre,
                      style: GoogleFonts.poppins(
                      color: Colors.black26,
                      fontSize: 12,
                      fontWeight: FontWeight.w500
                    )
                  ),
                ], 
              ),
            ),        
          // const Expanded(
          //   child: SizedBox()
          // ),
          SizedBox.square(
              child: IconButton(
                onPressed: (){},
                icon:  Icon(
                  Icons.more_horiz_sharp,
                  size: screenWidth * 0.06,
                  color: const Color.fromARGB(100, 97, 195, 240),
                ) 
              ),
            ),
        ],
      ),
    );
  }

  Widget genreTile(screenWidth, movieName, imgURL){
    return Container(
    
        // width: screenWidth * 0.434,
        // height: screenWidth * 0.266,
        width: 163,
        height: 100,
    
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imgURL),
            fit: BoxFit.cover,
          ),
          color: Colors.black26,
          borderRadius: BorderRadius.circular(10)
          
        ),            
        child: Stack(
          children: [              
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                width: 163,
                height: 50,
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
              left: 10,
              child: Text(
              movieName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500
              )
            ),
          ),
          
          
        ],
      ),
    );
  }
}

