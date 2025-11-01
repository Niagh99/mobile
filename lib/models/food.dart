class Food {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final List<String> extraImages;
  final List<String> ingredients;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.extraImages,
    required this.ingredients,
  });

  // Convert từ Firestore Map -> Object
  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      extraImages: map['extraImages'] != null
          ? List<String>.from(map['extraImages'])
          : [],
      ingredients: map['ingredients'] != null
          ? List<String>.from(map['ingredients'])
          : [],
    );
  }

  // Convert Object -> Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'extraImages': extraImages,
      'ingredients': ingredients,
    };
  }
}
