class MovieData {
  final int id;
  final String title;
  final String imageUrl;
  final double rating;
  final String description;
  final List<String> genres;


  MovieData.fromDefault({required this.title, required this.imageUrl, required this.rating, this.id = 0, this.description = '', this.genres = const[]});

   MovieData.fromGenre({required this.id, required this.genres, required this.imageUrl, this.rating = 0.0, this.title = '', this.description = ''});

  MovieData.fromDescription({required this.id, required this.genres, required this.imageUrl, required this.description, this.rating = 0.0, this.title = ''});

}


// class MovieData {
//   final int id;
//   final String genre;
//   final String title;
//   final String imageUrl;
//   final double rating;

//   MovieData({required this.title, required this.imageUrl, required this.rating, this.id = 0, this.genre = ''});

//   MovieData.fromGenre({required this.id, required this.genre, required this.imageUrl, this.rating = 0.0, this.title = ''});
// }
