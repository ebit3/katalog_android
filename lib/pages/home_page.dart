import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/services/firebase_service.dart';

import 'add_produk.dart';
import 'detail_produk.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // kategori
  final TextEditingController kategoriController = TextEditingController();

  // search
  final TextEditingController searchController = TextEditingController();

  // firestore
  FirebaseServiceStore firestoreServices = FirebaseServiceStore();

  String? dropdownValue;
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selamat Datang'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ProdukSearchDelegate());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestoreServices.getKategori(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<DropdownMenuItem<String>> items = [];
                        for (var kategori in snapshot.data!.docs) {
                          items.add(
                            DropdownMenuItem(
                              value: kategori['nama'],
                              child: Row(
                                children: [
                                  Expanded(child: Text(kategori['nama'])),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      firestoreServices
                                          .hapusKategori(kategori.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                          ),
                          value: dropdownValue,
                          items: items,
                          onChanged: (value) {
                            setState(() {
                              dropdownValue = value;
                              selectedCategory = value;
                            });
                          },
                        );
                      } else if (snapshot.hasError) {
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Error'),
                            ),
                          ],
                          onChanged: (value) {},
                        );
                      } else {
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Loading...'),
                            ),
                          ],
                          onChanged: (value) {},
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TambahProduk()),
                    );
                  },
                  child: Text('Tambah Produk'),
                ),
              ],
            ),
            SizedBox(height: 8.0), // Mengatur jarak antara tombol
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Tambah Kategori'),
                    content: TextFormField(
                      controller: kategoriController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Kategori'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await firestoreServices
                              .tambahKategori(kategoriController.text);
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                          kategoriController.clear();
                        },
                        child: Text('Simpan'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Tambah Kategori'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedCategory = null;
                });
              },
              child: Text('Reset Filter'),
            ),
            SizedBox(height: 16.0),
            StreamBuilder<QuerySnapshot>(
              stream: firestoreServices.getProduk(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> filteredProducts =
                      selectedCategory == null
                          ? snapshot.data!.docs
                          : snapshot.data!.docs.where((doc) {
                              return doc['kategori'] == selectedCategory;
                            }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(child: Text('Produk tidak ada'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var product = filteredProducts[index].data()
                          as Map<String, dynamic>;

                      return Card(
                        margin: EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(product['namaProduk']),
                          subtitle: Text('Kategori: ${product['kategori']}'
                              '\n'
                              'Harga: ${product['harga']}'
                              '\n'
                              'Stok: ${product['stok']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Aksi edit produk
                                  _editProduct(context,
                                      filteredProducts[index].id, product);
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Color(0xFFF44336),
                                ),
                                onPressed: () {
                                  // Aksi hapus produk
                                  firestoreServices.Produk.doc(
                                          filteredProducts[index].id)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailPage(produk: product),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editProduct(BuildContext context, String productId,
      Map<String, dynamic> productData) {
    // controller text input
    TextEditingController namaProdukController =
        TextEditingController(text: productData['namaProduk']);
    TextEditingController hargaController =
        TextEditingController(text: productData['harga'].toString());
    TextEditingController stokController =
        TextEditingController(text: productData['stok'].toString());
    String? kategoriValue = productData['kategori'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Produk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaProdukController,
                  decoration: InputDecoration(labelText: 'Nama Produk'),
                ),
                TextFormField(
                  controller: hargaController,
                  decoration: InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: stokController,
                  decoration: InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: firestoreServices.getKategori(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Kategori'),
                        value: kategoriValue,
                        items: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          return DropdownMenuItem<String>(
                            value: document['nama'],
                            child: Text(document['nama']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          kategoriValue = value;
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error loading categories');
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Update the product in Firestore
                await firestoreServices.Produk.doc(productId).update({
                  'namaProduk': namaProdukController.text,
                  'harga': int.parse(hargaController.text),
                  'stok': int.parse(stokController.text),
                  'kategori': kategoriValue,
                });
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

class ProdukSearchDelegate extends SearchDelegate {
  final FirebaseServiceStore firestoreServices = FirebaseServiceStore();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreServices.searchProduk(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final results = snapshot.data!.docs.where((DocumentSnapshot a) =>
              a['namaProduk']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()));

          if (results.isEmpty) {
            return Center(child: Text('Produk tidak ada'));
          }

          return ListView(
            children: results.map<Widget>((DocumentSnapshot document) {
              var product =
                  document.data() as Map<String, dynamic>; // Ambil data produk

              return ListTile(
                title: Text(product['namaProduk']),
                subtitle: Text('Kategori: ${product['kategori']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(produk: product),
                    ),
                  );
                },
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreServices.searchProduk(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final suggestions = snapshot.data!.docs.where((DocumentSnapshot a) =>
              a['namaProduk']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()));

          if (suggestions.isEmpty) {
            return Center(child: Text('Produk tidak ada'));
          }

          return ListView(
            children: suggestions.map<Widget>((DocumentSnapshot document) {
              return ListTile(
                title: Text(document['namaProduk']),
                subtitle: Text('Kategori: ${document['kategori']}'),
                onTap: () {
                  query = document['namaProduk'];
                  showResults(context);
                },
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
