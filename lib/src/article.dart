class Article {
  final String url;
  final String image;
  final int rating;
  final String type;
  final String date;
  final String text;
  final String author;

  const Article({
    this.url,
    this.image,
    this.rating,
    this.type,
    this.date,
    this.text,
    this.author
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article (
      url: json["claimReview"]["url"],
      image: json["claimReview"]["image"]["url"],
      rating: json["claimReview"]["reviewRating"]["ratingValue"],
      type: json["@type"],
      date: json["claimReview"]["datePublished"],
      text: json["claimReview"]["description"],
      author: json["claimReview"]["author"]["name"],
    );
  }
}