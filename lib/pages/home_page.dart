import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import '../models/product_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';

//var utama dari daftar product
List<ProductModel> products = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    loadProducts();
  }

//method unt menampilkan daftar produk
  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> productList = prefs.getStringList('products') ?? [];
    setState(() {
      products = productList
      .map((item) => ProductModel.frpmJson(item))
      .toList();
    });
  }

  Future<void> saveProduct() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = products.map((item) => item.toJson()).toList();
    await prefs.setStringList('products', productList);
  }

  Future<void> addProduct(ProductModel product) async {
    setState(() {
      products.add(product);
    });
    await saveProduct();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil ditambahkan')),
    );
  }

  Future<void> updateProduct(int index, ProductModel product) async {
    setState(() {
      products[index] = product;
    });
    await saveProduct();
    //ScaffoldMessenger.of(context).showSnackBar(
    //  const SnackBar(content: Text('Produk berhasil diperbarui')),
    //);
  }

  Future<void> deleteProduct(int index) async {
    setState(() {
      products.removeAt(index);
    });
    await saveProduct();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil dihapus')),
    );
  }

  void showForm({ProductModel? product, int? index}) {
    TextEditingController nameController = TextEditingController(text : product?.name ?? "");
    TextEditingController descriptionController = TextEditingController(text : product?.description ?? "");
    TextEditingController priceController = TextEditingController(text : product?.price.toString() ?? "");

    showDialog(
     context: context, 
      builder: (_) => AlertDialog(
       title: Text(product == null ? "Tambah Produk" : "Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           TextField(
             controller: nameController,
              decoration: InputDecoration(labelText: "Nama"),
           ),
           TextField(
             controller: descriptionController,
             decoration: InputDecoration(labelText: "Deskripsi"),
           ),
            TextField(
             controller: priceController,
             decoration: InputDecoration(labelText: "Harga"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
         ElevatedButton(
           onPressed: (){
             final newProduct = ProductModel(
                name: nameController.text,
                description: descriptionController.text,
                price: int.parse(priceController.text),
              );
              if(product == null) {
                addProduct(newProduct);
              } else {
                updateProduct(index!, newProduct);
              }
            },
            child: Text("Simpan")
          ),
        ]
      ),
    );
  
  }

  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString("username") ?? '';
    });
  }

  Future<void> Logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const .all(20),
            child: Column(
              children: [
                Container(
                  height: 100,
                  padding: .symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: .circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(100),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(
                          "https://picsum.photos/200"
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "Hai, Selamat Datang",
                              style: TextStyle(fontSize: 14, color: Colors.red),
                            ),
                            Row(
                              children: [
                                Text(
                                  username,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 22,
                                    fontWeight: .bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ],
                            )
                          ],
                        )
                      ),
                      Stack(
                        children: [
                          Container(
                            padding: .all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: .circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(100),
                                  blurRadius: 8,
                                )
                              ]
                            ),
                            child: const Icon(
                              Icons.logout,
                              size: 28,
                              color: Colors.red,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: products.isEmpty 
                  ? Center(child: const Text("Belum Ada Product"))
                  : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(15),
                          title: Text(
                            product.name, 
                            style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          subtitle: Column(
                            crossAxisAlignment: .start,
                            spacing: 5,
                            children: [
                              Text("Rp ${product.price}"),
                              Text(product.description),
                            ],
                          ),
                          leading: IconButton(
                            onPressed:  () => showForm(
                              product: product,
                              index: index,
                              ),
                            icon: const Icon(
                              Icons.edit, 
                              color: Colors.orange,
                              ),
                          ),
                          trailing: IconButton(
                            onPressed:  () => deleteProduct(index),
                            icon: const Icon(
                              Icons.delete, 
                              color: Colors.red,
                            )
                          ),
                        )
                      );
                    }
                  ) ,
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showForm(),
          child: const Icon(Icons.add),
        ),
      );
  }
}