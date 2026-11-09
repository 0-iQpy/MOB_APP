class Product {
  const Product({
    required this.id,
    required this.name,
    required this.color,
    required this.category,
    required this.price,
    required this.tag,
    required this.imageUrl,
    required this.sizes,
  });

  final String id;
  final String name;
  final String color;
  final String category;
  final int price;
  final String tag;
  final String imageUrl;
  final List<String> sizes;
}
