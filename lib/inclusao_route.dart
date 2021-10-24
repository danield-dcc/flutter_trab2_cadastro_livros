import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class InclusaoRoute extends StatefulWidget {
  const InclusaoRoute({Key? key}) : super(key: key);

  @override
  _InclusaoRouteState createState() => _InclusaoRouteState();
}

class _InclusaoRouteState extends State<InclusaoRoute> {
  var _edTitulo = TextEditingController();
  var _edAutor = TextEditingController();
  var _edPreco = TextEditingController();
  var _edFoto = TextEditingController();
  double _edAvaliacao = 0;// avaliação é adicionada depois na avaliação_route

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inclusão de Livros'),
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        tooltip: 'Voltar',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

//unsando um Expanded
  Container _body() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: _edTitulo,
              keyboardType: TextInputType.name,
              style: TextStyle(
                fontSize: 20,
              ),
              decoration: InputDecoration(labelText: "Título"),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _edAutor,
              keyboardType: TextInputType.name,
              style: TextStyle(
                fontSize: 20,
              ),
              decoration: InputDecoration(labelText: "Autor"),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _edPreco,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 20,
              ),
              decoration: InputDecoration(labelText: "Preço R\$"),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: _getImage,
                  icon: Icon(Icons.photo_camera),
                  color: Colors.blue,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _edFoto,
                    keyboardType: TextInputType.url,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(labelText: "URL da foto"),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: _imageFile == null
                ? const Text("Clique no botão da camêra para fotografar")
                : Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.cover,
                  ),
          ),
          Row(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: uploadFile,
                  child: Text(
                    "Salvar imagem",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: _gravados,
                  child: Text(
                    "Cadastrar",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _getImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      print("Erro...acesso à camera negado");
    }
  }

  Future<firebase_storage.UploadTask?> uploadFile() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Fotografe a imagem a ser salva'),
      ));
      return null;
    }

    firebase_storage.UploadTask uploadTask;

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child(DateTime.now().microsecondsSinceEpoch.toString()+".jpg");


    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': _imageFile!.path});

      //_imageFile! a esclamação é uma garantia de que a car não vai ser null
      uploadTask = ref.putFile(File(_imageFile!.path), metadata);
    
    //capturando a url da imagem salva
    var imageURL = await (await uploadTask).ref.getDownloadURL();
    _edFoto.text = imageURL.toString();

    return Future.value(uploadTask);
  }

  Future<void> _gravados() async {
    if (_edAutor.text == "" ||
        _edTitulo.text == "" ||
        _edPreco.text == "" ||
        _edFoto.text == "") {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Atenção'),
              content: Text('Por Favor, preencha todos os dados'),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Ok!')),
              ],
            );
          });
      return;
    }

    CollectionReference cfLivros =
        FirebaseFirestore.instance.collection("livros");
    _edAvaliacao = 0;
    await cfLivros.add({
      "titulo": _edTitulo.text,
      "autor": _edAutor.text,
      "preco": double.parse(_edPreco.text),
      "foto": _edFoto.text,
      "avaliacao": (_edAvaliacao)
    });

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Cadastro realizado com Sucesso!'),
            content: Text(' ${_edTitulo.text} foi inserido na base de dados.'),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Ok!')),
            ],
          );
        });

    _edAutor.text = "";
    _edTitulo.text = "";
    _edPreco.text = "";
    _edFoto.text = "";
  }

  // Container _body() {
  //   return Container(
  //     padding: EdgeInsets.all(16),
  //     child: Expanded(
  //       child: Column(
  //         children: <Widget>[
  //           TextFormField(
  //             controller: _edTitulo,
  //             keyboardType: TextInputType.name,
  //             style: TextStyle(
  //               fontSize: 20,
  //             ),
  //             decoration: InputDecoration(labelText: "Título"),
  //           ),
  //           TextFormField(
  //             controller: _edAutor,
  //             keyboardType: TextInputType.name,
  //             style: TextStyle(
  //               fontSize: 20,
  //             ),
  //             decoration: InputDecoration(labelText: "Autor"),
  //           ),
  //           TextFormField(
  //             controller: _edPreco,
  //             keyboardType: TextInputType.number,
  //             style: TextStyle(
  //               fontSize: 20,
  //             ),
  //             decoration: InputDecoration(labelText: "Preço R\$"),
  //           ),
  //           TextFormField(
  //             controller: _edFoto,
  //             keyboardType: TextInputType.url,
  //             style: TextStyle(
  //               fontSize: 20,
  //             ),
  //             decoration: InputDecoration(labelText: "Foto"),
  //           ),
  //           SizedBox(
  //             height: 10,
  //           ),
  //           Container(
  //             height: 40,
  //             decoration: BoxDecoration(
  //               color: Colors.blue.withOpacity(0.8),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: ElevatedButton(
  //               onPressed: () {},
  //               child: Text(
  //                 "Cadastrar",
  //                 style: TextStyle(color: Colors.white, fontSize: 18),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
