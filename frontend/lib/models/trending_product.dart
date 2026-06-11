class TrendingProduct {
  final String title;
  final String description;
  final String imageUrl;
  final String linkUrl;
  final String source;

  TrendingProduct({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.linkUrl,
    required this.source,
  });

  factory TrendingProduct.fromJson(Map<String, dynamic> json) => TrendingProduct(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        linkUrl: json['linkUrl'] ?? '',
        source: json['source'] ?? '',
      );
}
