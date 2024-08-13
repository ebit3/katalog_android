import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServiceStore {
  // buat collection kategori
  final CollectionReference Kategori =
      FirebaseFirestore.instance.collection('kategori');

  // buat collection kategori
  final CollectionReference Produk =
      FirebaseFirestore.instance.collection('produk');

  //tambah kategori
  Future<void> tambahKategori(String namaKategori) async {
    try {
      await Kategori.add({'nama': namaKategori});
    } catch (e) {
      print("Kategori gagal ditambahkan" + e.toString());
    }
  }

  //hapus kategori
  Future<void> hapusKategori(String idKategori) async {
    try {
      await Kategori.doc(idKategori).delete();
    } catch (e) {
      print("Kategori gagal dihapus" + e.toString());
    }
  }

  // ambil kategori
  Stream<QuerySnapshot> getKategori() {
    return Kategori.snapshots();
  }

  // ambil produk
  Stream<QuerySnapshot> getProduk() {
    return Produk.snapshots();
  }

  // tambah produk
  Future<void> tambahProduk(
      String namaProduk, String kategori, int stok, int harga) {
    return Produk.add({
      'namaProduk': namaProduk,
      'kategori': kategori,
      'stok': stok,
      'harga': harga
    });
  }

  // search produk
  Stream<QuerySnapshot> searchProduk(String query) {
    return Produk.where('namaProduk', isGreaterThanOrEqualTo: query)
        .snapshots();
  }
}
