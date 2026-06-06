import '../models/product.dart';

/// Daftar produk contoh untuk mengisi toko.
const List<Product> kProducts = [
  // Elektronik
  Product(
    id: 'e1',
    name: 'Wireless Headphone Pro',
    description:
        'Headphone nirkabel dengan active noise cancelling, baterai tahan 30 jam, dan suara bass yang dalam. Cocok untuk kerja maupun mendengarkan musik seharian.',
    price: 850000,
    oldPrice: 1100000,
    category: 'Elektronik',
    emoji: '🎧',
    rating: 4.8,
    sold: 1243,
    stock: 80,
  ),
  Product(
    id: 'e2',
    name: 'Smartphone X12 5G',
    description:
        'Layar AMOLED 6.7", chipset terbaru, kamera 108MP, dan pengisian cepat 67W. Performa kencang untuk multitasking dan gaming.',
    price: 4500000,
    category: 'Elektronik',
    emoji: '📱',
    rating: 4.7,
    sold: 856,
    stock: 35,
  ),
  Product(
    id: 'e3',
    name: 'Laptop UltraSlim 14"',
    description:
        'Laptop tipis ringan 1.2kg, prosesor Core i7, RAM 16GB, SSD 512GB. Ideal untuk produktivitas dan mobilitas tinggi.',
    price: 12500000,
    oldPrice: 13900000,
    category: 'Elektronik',
    emoji: '💻',
    rating: 4.9,
    sold: 432,
    stock: 18,
  ),
  Product(
    id: 'e4',
    name: 'Smartwatch Fit 5',
    description:
        'Pantau detak jantung, SpO2, dan tidur. Tahan air 5ATM dengan baterai hingga 14 hari. Lebih dari 100 mode olahraga.',
    price: 1250000,
    oldPrice: 1500000,
    category: 'Elektronik',
    emoji: '⌚',
    rating: 4.6,
    sold: 980,
    stock: 60,
  ),
  Product(
    id: 'e5',
    name: 'Keyboard Mekanik RGB',
    description:
        'Keyboard mekanik hot-swappable dengan lampu RGB, switch taktil, dan body aluminium. Pengalaman mengetik yang memuaskan.',
    price: 650000,
    category: 'Elektronik',
    emoji: '⌨️',
    rating: 4.7,
    sold: 541,
    stock: 45,
  ),
  Product(
    id: 'e6',
    name: 'Kamera Mirrorless M50',
    description:
        'Sensor APS-C 24MP, perekaman video 4K, dan layar putar. Ringan dan ringkas untuk konten kreator pemula maupun profesional.',
    price: 8900000,
    category: 'Elektronik',
    emoji: '📷',
    rating: 4.8,
    sold: 213,
    stock: 12,
  ),

  // Fashion
  Product(
    id: 'f1',
    name: 'Kaos Premium Cotton',
    description:
        'Kaos katun combed 30s yang adem dan nyaman dipakai harian. Jahitan rapi, tidak mudah melar, tersedia berbagai warna.',
    price: 120000,
    oldPrice: 150000,
    category: 'Fashion',
    emoji: '👕',
    rating: 4.5,
    sold: 3210,
    stock: 200,
  ),
  Product(
    id: 'f2',
    name: 'Sneakers Run Lite',
    description:
        'Sepatu lari dengan sol empuk responsif dan upper mesh breathable. Ringan untuk lari maupun aktivitas sehari-hari.',
    price: 480000,
    oldPrice: 599000,
    category: 'Fashion',
    emoji: '👟',
    rating: 4.6,
    sold: 1502,
    stock: 90,
  ),
  Product(
    id: 'f3',
    name: 'Hoodie Oversize',
    description:
        'Hoodie bahan fleece tebal dan hangat dengan potongan oversize kekinian. Cocok untuk gaya kasual maupun santai.',
    price: 250000,
    category: 'Fashion',
    emoji: '🧥',
    rating: 4.4,
    sold: 874,
    stock: 110,
  ),
  Product(
    id: 'f4',
    name: 'Tas Ransel Urban',
    description:
        'Ransel tahan air dengan kompartemen laptop 15", banyak kantong, dan port USB. Praktis untuk kerja dan traveling.',
    price: 320000,
    oldPrice: 420000,
    category: 'Fashion',
    emoji: '🎒',
    rating: 4.7,
    sold: 645,
    stock: 70,
  ),

  // Makanan
  Product(
    id: 'm1',
    name: 'Kopi Arabika 250gr',
    description:
        'Biji kopi arabika single origin, dipanggang medium dengan aroma cokelat dan caramel. Nikmat diseduh manual maupun espresso.',
    price: 85000,
    category: 'Makanan',
    emoji: '☕',
    rating: 4.9,
    sold: 2104,
    stock: 150,
  ),
  Product(
    id: 'm2',
    name: 'Cokelat Premium Bar',
    description:
        'Dark chocolate 70% cocoa tanpa pemanis berlebih. Lembut, sedikit pahit, dan kaya rasa. Camilan sehat untuk menemani harimu.',
    price: 45000,
    oldPrice: 55000,
    category: 'Makanan',
    emoji: '🍫',
    rating: 4.6,
    sold: 1820,
    stock: 300,
  ),

  // Rumah
  Product(
    id: 'h1',
    name: 'Lampu Meja Minimalis',
    description:
        'Lampu LED dengan 3 tingkat kecerahan dan pengaturan warna cahaya. Desain minimalis modern untuk meja kerja atau belajar.',
    price: 175000,
    category: 'Rumah',
    emoji: '💡',
    rating: 4.5,
    sold: 523,
    stock: 85,
  ),
  Product(
    id: 'h2',
    name: 'Kursi Kerja Ergonomis',
    description:
        'Kursi dengan sandaran mesh, penyangga pinggang, dan tinggi yang dapat diatur. Mendukung postur nyaman saat kerja lama.',
    price: 1850000,
    oldPrice: 2200000,
    category: 'Rumah',
    emoji: '🪑',
    rating: 4.7,
    sold: 234,
    stock: 22,
  ),

  // Kecantikan
  Product(
    id: 'b1',
    name: 'Serum Wajah Glow',
    description:
        'Serum dengan niacinamide dan vitamin C untuk mencerahkan dan meratakan warna kulit. Tekstur ringan, cepat meresap.',
    price: 159000,
    oldPrice: 199000,
    category: 'Kecantikan',
    emoji: '🧴',
    rating: 4.8,
    sold: 2640,
    stock: 130,
  ),
  Product(
    id: 'b2',
    name: 'Lipstik Matte Set',
    description:
        'Set 3 lipstik matte yang tahan lama dan tidak membuat bibir kering. Pigmentasi pekat dengan pilihan warna cantik.',
    price: 220000,
    category: 'Kecantikan',
    emoji: '💄',
    rating: 4.6,
    sold: 1408,
    stock: 95,
  ),

  // Olahraga
  Product(
    id: 's1',
    name: 'Matras Yoga Anti-slip',
    description:
        'Matras yoga tebal 8mm dengan permukaan anti-slip dan empuk di lutut. Dilengkapi tali pengikat untuk dibawa bepergian.',
    price: 199000,
    oldPrice: 249000,
    category: 'Olahraga',
    emoji: '🧘',
    rating: 4.7,
    sold: 762,
    stock: 100,
  ),
  Product(
    id: 's2',
    name: 'Dumbbell Set 10kg',
    description:
        'Sepasang dumbbell dengan beban yang dapat diatur, lapisan karet anti gores. Cocok untuk latihan kekuatan di rumah.',
    price: 350000,
    category: 'Olahraga',
    emoji: '🏋️',
    rating: 4.5,
    sold: 489,
    stock: 55,
  ),
];

/// Indeks produk berdasarkan id untuk pencarian cepat.
final Map<String, Product> _productsById = {
  for (final p in kProducts) p.id: p,
};

/// Mencari produk berdasarkan [id]. Mengembalikan `null` bila tidak ada.
///
/// Dipakai saat memuat ulang keranjang dari penyimpanan: yang disimpan hanya
/// id produk + jumlah, lalu objek produknya direkonstruksi dari sini.
Product? productById(String id) => _productsById[id];
