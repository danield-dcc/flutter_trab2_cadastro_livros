import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:livros/avaliacao_route.dart';
import 'package:livros/inclusao_route.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? filtro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Livros'),
        actions: [
          IconButton(
            onPressed: () {
              _showFilter(context);
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  filtro = null;
                });
              },
              icon: const Icon(Icons.list))
        ],
      ),
      body: _body(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InclusaoRoute()),
          );
        },
        //onPressed: adicionar,
        tooltip: 'Adicionar Livro',
        child: Icon(Icons.add),
      ),
    );
  }

  CollectionReference cfLivros =
      FirebaseFirestore.instance.collection("livros");

  Column _body(context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // stream: cfLivros.orderBy("titulo").snapshots(),
            stream: cfLivros.where("titulo", isEqualTo: filtro).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.requireData;
              var foto;
              var titulo;
              var autorEPreco;
              var id;
              var rating;

              return data.size > 0
                  ? ListView.builder(
                      itemCount: data.size,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      data.docs[index].get("foto")),
                                ),
                                title: Text(data.docs[index].get("titulo")),
                                subtitle: Text(data.docs[index].get("autor") +
                                    "\n" +
                                    NumberFormat.simpleCurrency(locale: "pt_BR")
                                        .format(data.docs[index].get("preco"))),
                                isThreeLine: true,
                                onTap: () {
                                  foto = NetworkImage(
                                      data.docs[index].get("foto"));
                                  titulo = Text(data.docs[index].get("titulo"));
                                  autorEPreco = Text(data.docs[index]
                                          .get("autor") +
                                      "\n" +
                                      NumberFormat.simpleCurrency(
                                              locale: "pt_BR")
                                          .format(
                                              data.docs[index].get("preco")));

                                  id = data.docs[index].id;

                                  //showRanting
                                  rating = data.docs[index].get("avaliacao");

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AvaliacaoRoute(
                                            data: data,
                                            foto: foto,
                                            titulo: titulo,
                                            autorEPreco: autorEPreco,
                                            id: id)),
                                  );
                                },
                                onLongPress: () {
                                  // print("Clicou");
                                  // print(data.docs[index].get("titulo"));
                                  // print(data.docs[index].id);
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Exclusão'),
                                        content: Text(
                                            'Comfirma a exclusão do livro ${data.docs[index].get("titulo")}?'),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            onPressed: () {
                                              cfLivros
                                                  .doc(data.docs[index].id)
                                                  .delete();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Sim'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Não'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              Container(
                                child: Align(
                                  alignment: Alignment(-0.35, 0.60),
                                  child: _mostarRating(data, index),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text("Livro não encontrado..."),
                    );
            },
          ),
        ),
      ],
    );
  }

  Container _mostarRating(QuerySnapshot<Object?> data, int index) {
    return data.docs[index].get("avaliacao") > 0
        ? Container(
            child: RatingBar.builder(
              initialRating: data.docs[index].get("avaliacao"),
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 20,
              ignoreGestures: true,
              tapOnlyMode: true,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(rating);
              },
            ),
          )
        : Container(
            child: (Text("")),
          );
  }

  Future<void> _showFilter(BuildContext context) async {
    String? valueText;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Filtro de Livros'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              decoration: InputDecoration(hintText: "Digite o titulo"),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text("Cancelar"),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    filtro = valueText;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}
