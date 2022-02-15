import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:productapp/models/product_model.dart';
import 'package:productapp/pages/add_product_page.dart';
import 'package:productapp/pages/edit_product_page.dart';
import 'package:productapp/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowProductPage extends StatefulWidget {
  const ShowProductPage({Key? key}) : super(key: key);

  @override
  _ShowProductPageState createState() => _ShowProductPageState();
}

class _ShowProductPageState extends State<ShowProductPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<Products>? products;

  @override
  void initState() {
    super.initState();
    getList();
  }

  Future<String?> getList() async {
    SharedPreferences prefs = await _prefs;
    products = [];
    var url =
        Uri.parse('https://laravel-backend-cs.herokuapp.com/api/products');
    var response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('token')}'
      },
    );
    // var jsonsString = jsonDecode(response.body);
    // products = jsonsString['payload']
    //     .map<Products>((json) => Products.fromJson(json))
    //     .toList();

    // print(products.toString());
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Products'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        children: [
          showButton(),
          showList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductPage(),
            ),
          ).then((value) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget showButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {});
      },
      child: const Text('แสดงรายการ'),
    );
  }

  Widget showList() {
    return FutureBuilder(
      future: getList(),
      builder: (context, snapshot) {
        List<Widget> myList;
        if (snapshot.hasData) {
          var jsonString = jsonDecode(snapshot.data.toString());
          List<Products>? products = jsonString['payload']
              .map<Products>((json) => Products.fromJson(json))
              .toList();
          myList = [
            Column(
              children: products!.map((item) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      print('${item.productId}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProductPage(id: item.productId),
                        ),
                      ).then((value) => setState(() {}));
                    },
                    title: Text('${item.productName}'),
                    subtitle: Text('${item.price}'),
                    trailing: IconButton(
                      onPressed: () {
                        var alertDialog = AlertDialog(
                          title: const Text('Confirmation for this delete'),
                          content: Text(
                              'คุณต้องการลบสินค้า ${item.productName} ใช่หรือไม่'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('ยกเลิก')),
                            TextButton(
                                onPressed: () {
                                  deleteProduct(item.productId)
                                      .then((value) => setState(() {}));
                                },
                                child: const Text(
                                  'ยืนยัน',
                                  style: TextStyle(color: Colors.red),
                                )),
                          ],
                        );

                        showDialog(
                          context: context,
                          builder: (context) => alertDialog,
                        );
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ];
        } else if (snapshot.hasError) {
          myList = [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('พบข้อผิดพลาด: ${snapshot.error}'),
            ),
          ];
        } else {
          myList = [
            const SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('อยู่ระหว่างการประมวลผล'),
            )
          ];
        }

        return Center(
          child: Column(
            children: myList,
          ),
        );
      },
    );
  }

  Future<void> deleteProduct(int? id) async {
    SharedPreferences prefs = await _prefs;
    var url =
        Uri.parse('https://laravel-backend-cs.herokuapp.com/api/products/$id');

    var response = await http.delete(url, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('token')}'
    });

    if (response.statusCode == 200) {
      Navigator.pop(context);
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await _prefs;
    var url = Uri.parse('https://laravel-backend-cs.herokuapp.com/api/logout');

    var response = await http.post(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('token')}'
    });

    if (response.statusCode == 200) {
      prefs.remove('user');
      prefs.remove('token');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }
}

class ProductsModel {}

class Product {}
