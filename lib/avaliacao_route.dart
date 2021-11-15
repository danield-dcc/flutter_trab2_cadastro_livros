import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:livros/home_page.dart';

class AvaliacaoRoute extends StatefulWidget {
  const AvaliacaoRoute({
    Key? key,
    required this.data,
    required this.foto,
    required this.titulo,
    required this.autorEPreco,
    required this.id,
  }) : super(key: key);

  final data;
  final foto;
  final titulo;
  final autorEPreco;
  final id;
  @override
  _AvaliacaoRouteState createState() => _AvaliacaoRouteState();
}

class _AvaliacaoRouteState extends State<AvaliacaoRoute> {
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Avaliação"),
      ),
      body: _body(context),
    );
  }

  Column _body(context) {
    return Column(
      children: <Widget>[
        _itemAvaliado(context),
        SizedBox(
          height: 40,
        ),
        //botaoAvaliar(context),
        _ranting(context),
        SizedBox(
          height: 50,
        ),
        _btSalvarAvaliacao(context)
      ],
    );
  }

  Card _itemAvaliado(context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            children: <Widget>[
              Image(
                image: widget.foto,
                width: 100,
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.book),
            // leading: CircleAvatar(
            //   backgroundImage: widget.foto,
            // ),
            title: widget.titulo,
            subtitle: widget.autorEPreco,
            isThreeLine: true,
          ),
          Container(
            child: Align(
              alignment: Alignment(-0.35, 0.60),
              child: showRating(),
            ),
          )
        ],
      ),
    );
  }

//UPDATE
  Future<void> _saveUpdate() async {
    

    CollectionReference cfLivros =
        FirebaseFirestore.instance.collection("livros");

    await cfLivros
        .doc(widget.id)
        .update({'avaliacao': rating})
        .then((value) => print("Livro Atualizado"))
        .catchError((error) => print("Failed to update user: $error"));

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Avaliação Concluida!'),
            content: Text(
                'Avaliação de ${widget.titulo.toString()} foi salva com sucesso!.'),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {

                 // Navigator.of(context).pop(HomePage());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                    //Navigator.pop(context);
                  },
                  child: Text('Ok!')),
            ],
          );
        });
  }

  Widget _btSalvarAvaliacao(context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: _saveUpdate,
        child: Text(
          "Salvar",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

//PRINCIPAL
  Container _ranting(context) {
    return Container(
      child: RatingBar.builder(
        initialRating: 3,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        updateOnDrag: true,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) => setState(() {
          this.rating = rating;
          print(rating);
        }),
      ),
    );
  }

//método mostar rating na card
  Widget showRating() => RatingBar.builder(
        initialRating: rating,
        itemSize: 20,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        ignoreGestures: true,
        itemCount: 5,
        updateOnDrag: true,
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) => setState(() {
          this.rating = rating;
          print(rating);
        }),
      );
}
