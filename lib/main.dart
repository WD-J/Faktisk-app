import 'package:flutter/material.dart';
import 'src/article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:html/parser.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

// For when you come back: The api doesn't include all article types, and not the actual article either.
// What you've developed so far is the front page design.
// You'd also need to know how to integrate pagination.
// I believe this could be done just by chaning the url and running getData(); again. Url example: faktisk.no/page="2"


// Article Blue: 0xFF0461ff
// Header Blue:  0xFF1169ff

bool _GridToggle = true;

MaterialColor HeaderBlue = const MaterialColor(
  0xFF1169ff,
  <int, Color>{
    50: Color(0xFF1169ff),
    100: Color(0xFF1169ff),
    200: Color(0xFF1169ff),
    300: Color(0xFF1169ff),
    400: Color(0xFF1169ff),
    500: Color(0xFF1169ff),
    600: Color(0xFF1169ff),
    700: Color(0xFF1169ff),
    800: Color(0xFF1169ff),
    900: Color(0xFF1169ff),
  },
);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faktisk',
      theme: ThemeData(
        primarySwatch: HeaderBlue,
      ),
      home: MyHomePage(title: 'Faktisk'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List abody = List();
  void getBody() async {
    final response = await http.get('https://www.faktisk.no');
    if (response.statusCode == 200) {
      // print(response.body);
      var document = parse(response.body);
      var articleBody = document.querySelectorAll('p');
      for (var body in articleBody) {
        abody.add(body.innerHtml);
      }
      //setState(() {});
    }
  }

  Future<List<Article>> getData() async {
    List<Article> list;
    String link = "https://www.faktisk.no/api/claim-reviews";
    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      var rest = data["items"] as List;
      list = rest.map<Article>((json) => Article.fromJson(json)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    getBody();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            // action button
            IconButton(
              icon: (_GridToggle ? Icon(Icons.grid_on) : Icon(Icons.grid_off)),
              onPressed: _toggleGrid,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: FutureBuilder<List>(
              future: getData(),
              builder: (BuildContext build, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return new Padding(
                      padding: const EdgeInsets.all(0),
                      child: StaggeredGridView.count(
                        crossAxisCount: 4,
                        padding: const EdgeInsets.all(8),
                        children: List<Widget>.from(
                            snapshot.data.map(_buildItem).toList()),
                        staggeredTiles: snapshot.data
                            .map<StaggeredTile>(
                                (_) => StaggeredTile.fit(_GridToggle ? 2 : 4))
                            .toList(),
                        mainAxisSpacing: 0.0,
                        crossAxisSpacing: 0.0, // add some space
                      ));
                }
              }),
        ));
  }

  var colorInt = 0;
  Widget _buildItem(Article article) {
    articleColour(article);
    return new Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            child: InkWell(
              splashColor: Colors.blue.withAlpha(125),
              onTap: () async {
                final fakeUrl = "${article.url}";
                if (await canLaunch(fakeUrl)) {
                  launch(fakeUrl);
                }
              },
              child: Column(
                children: <Widget>[
                  new Container(
                    child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4)),
                        child: Image.network(("${article.image}"))),
                  ),
                  new Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(colorInt),
                        // color: Colors.black,
                        width: colorInt == 0 ? 0.0 : 4.0,
                        // width: 4.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 6, bottom: 4),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Text("${article.type}",
                                style: TextStyle(
                                    //color: "${article.type}" == "Artikkel" ?  Colors.white: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12),
                                textAlign: TextAlign.left)),
                        Expanded(
                            child: Text("${article.date}",
                                style: TextStyle(
                                    color: "${article.type}" == "Artikkel"
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12),
                                textAlign: TextAlign.right)),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, bottom: 6),
                        child: Text(
                          "${article.text}",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: "${article.type}" == "Artikkel"
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "boing",
                            //abody.first,
                            //"${article.author}",
                            style: TextStyle(
                                // use black 54 if not good.
                                color: "${article.type}" == "Artikkel"
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            // clipBehavior: Clip.antiAlias,
            color:
                "${article.rating}" == null ? Color(0xFF0461ff) : Colors.white,
          ),
        ],
      ),
    );
  }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 3));
    setState(() {});
  }

  void articleColour(Article article) {
    var decider = "${article.rating}";

    decider == "5" ? colorInt = 0xFF02FF86 : 0;
    decider == "4" ? colorInt = 0xFFFEE64F : 0;
    decider == "3" ? colorInt = 0xFFADC0C6 : 0;
    decider == "2" ? colorInt = 0xFFFDAA38 : 0;
    decider == "1" ? colorInt = 0xFFF84645 : 0;
  }

  void _toggleGrid() {
    setState(() {
      if (_GridToggle) {
        _GridToggle = false;
      } else {
        _GridToggle = true;
      }
    });
  }
}
