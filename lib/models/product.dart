class Product {
  final int id;
  final String name;
  final double price;
  final double originalPrice;
  final String image;
  final String category;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final bool isNew;
  final bool isSale;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice = 0,
    required this.image,
    required this.category,
    required this.rating,
    this.reviewCount = 0,
    this.description = '',
    this.sizes = const ['XS', 'S', 'M', 'L', 'XL'],
    this.colors = const ['White', 'Black', 'Gray'],
    this.isNew = false,
    this.isSale = false,
  });

  double get discount => originalPrice > 0
      ? ((originalPrice - price) / originalPrice * 100).roundToDouble()
      : 0;
}

final List<Product> sampleProducts = [
  const Product(
    id: 1,
    name: 'Classic White Tee',
    price: 29.99,
    originalPrice: 39.99,
    image: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&h=800&fit=crop',
    category: 'Tops',
    rating: 4.5,
    reviewCount: 128,
    description: 'A timeless classic crafted from premium 100% organic cotton. Perfect for everyday wear with its comfortable fit and breathable fabric.',
    sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
    colors: ['White', 'Off White', 'Light Gray'],
    isNew: false,
    isSale: true,
  ),
  const Product(
    id: 2,
    name: 'Denim Jacket',
    price: 89.99,
    image: 'https://images.unsplash.com/photo-1551028719-00167b16ebc5?w=600&h=800&fit=crop',
    category: 'Outerwear',
    rating: 4.8,
    reviewCount: 256,
    description: 'A premium denim jacket featuring a classic cut with modern proportions. Made from heavyweight denim with a lived-in look.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
    colors: ['Blue', 'Dark Blue', 'Black'],
    isNew: true,
  ),
  const Product(
    id: 3,
    name: 'Black Skinny Jeans',
    price: 59.99,
    originalPrice: 79.99,
    image: 'https://images.unsplash.com/photo-1542272604-787c62d465d1?w=600&h=800&fit=crop',
    category: 'Bottoms',
    rating: 4.6,
    reviewCount: 312,
    description: 'Sleek and slimming black skinny jeans with 4-way stretch for all-day comfort. A wardrobe essential that works for any occasion.',
    sizes: ['28', '30', '32', '34', '36'],
    colors: ['Black', 'Charcoal'],
    isSale: true,
  ),
  const Product(
    id: 4,
    name: 'Casual Summer Dress',
    price: 44.99,
    image: 'https://images.unsplash.com/photo-1572804419446-b8a89e42fc73?w=600&h=800&fit=crop',
    category: 'Dresses',
    rating: 4.7,
    reviewCount: 189,
    description: 'Effortlessly chic summer dress with a flattering A-line silhouette. Lightweight and breathable fabric keeps you cool all day.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
    colors: ['Floral', 'Coral', 'Sky Blue'],
    isNew: true,
  ),
  const Product(
    id: 5,
    name: 'Cozy Knit Sweater',
    price: 54.99,
    originalPrice: 69.99,
    image: 'https://images.unsplash.com/photo-1526768752127-fac6461fbe38?w=600&h=800&fit=crop',
    category: 'Tops',
    rating: 4.4,
    reviewCount: 97,
    description: 'Stay warm in style with this ultra-soft knit sweater. Made from a premium wool blend with a relaxed fit for ultimate comfort.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
    colors: ['Cream', 'Camel', 'Burgundy'],
    isSale: true,
  ),
  const Product(
    id: 6,
    name: 'Premium Blazer',
    price: 129.99,
    image: 'https://images.unsplash.com/photo-1591047990366-ebc4de28526d?w=600&h=800&fit=crop',
    category: 'Outerwear',
    rating: 4.9,
    reviewCount: 74,
    description: 'A sophisticated blazer designed for the modern professional. Tailored with precision using Italian fabric for a sharp, polished look.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
    colors: ['Navy', 'Charcoal', 'Beige'],
    isNew: true,
  ),
  const Product(
    id: 7,
    name: 'Linen Wide-Leg Pants',
    price: 49.99,
    image: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
    category: 'Bottoms',
    rating: 4.5,
    reviewCount: 143,
    description: 'Breezy wide-leg linen pants that are equal parts comfortable and stylish. Perfect for warm days and casual outings.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
    colors: ['Sand', 'White', 'Olive'],
  ),
  const Product(
    id: 8,
    name: 'Floral Midi Skirt',
    price: 39.99,
    originalPrice: 54.99,
    image: 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=600&h=800&fit=crop',
    category: 'Bottoms',
    rating: 4.6,
    reviewCount: 211,
    description: 'A romantic floral midi skirt with a flowing silhouette. Features an elastic waistband for a comfortable, adjustable fit.',
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
    colors: ['Floral Pink', 'Floral Blue'],
    isSale: true,
  ),
];
