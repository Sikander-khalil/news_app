import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/NewsView.dart';
import 'package:news_app/newsmodel.dart';

import 'category.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> navBarItems = ["Top News", "Pakistan", "World", "Finance","Health"];
  TextEditingController searchController = new TextEditingController();
  List<NewsQueryModel> newsModelListCarousel = <NewsQueryModel>[];
  bool showMoreClicked = false;

  Future<NewsQueryModel> getNewsByQuery() async {
    try {
      String url = "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=d6007b9a20084c6c8e9d926d43627946";

      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return NewsQueryModel.fromJson(decoded);
      } else {
        throw Exception('Failed to load data. Status Code: ${response.statusCode}, Response Body: ${response.body}');
      }
    } catch (e) {
      // Rethrow the exception to propagate it
      print(e.toString());
      throw e;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewsByQuery();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: Text("News App",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(



        child: Column(

          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black, // Set background color to black
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if ((searchController.text).replaceAll("", "") == "") {
                        print("Blank search");
                      } else {
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => Search(searchController.text)));
                      }
                    },
                    child: Container(
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.fromLTRB(3, 0, 7, 0),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        if (value == "") {
                          print("Blank Search");
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Categories(Query: value)));
                        }
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search News",
                        hintStyle: TextStyle(color: Colors.white), // Add hint text color
                      ),
                      style: TextStyle(color: Colors.white), // Add text color
                    ),
                  )
                ],
              ),
            ),


            Container(
              height: 50,

              child: Stack(
                children: [

                  ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                      itemCount: navBarItems.length,
                      itemBuilder: (context, index){

                        return InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Categories(Query: navBarItems[index]
                            )
                            )
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(child: Text(navBarItems[index],style: TextStyle(fontSize: 19,color: Colors.white),)),
                          ),
                        );





                  }),

                ],
              ),
            ),


            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              height: 200,
              child: FutureBuilder(
                future: getNewsByQuery(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  } else if (snapshot.data == null) {
                    return Center(
                      child: Text("No data available"),
                    );
                  } else {
                    final newsdata = snapshot.data;

                    return CarouselSlider.builder(

                      itemCount: newsdata!.articles!.length,
                      itemBuilder: (BuildContext context, int index, int realIndex) {
                        return InkWell(
                          onTap: (){

                            Navigator.push(context, MaterialPageRoute(builder: (context) => NewsView(newsdata.articles![index].url.toString())));


                            },
                          child: Container(
                            child: Image.network(newsdata.articles![index].urlToImage.toString()),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        autoPlay: true,
                        height: 200,
                        enableInfiniteScroll: false,
                        viewportFraction: 0.8,
                        enlargeCenterPage: true,
                      ),
                    );
                  }
                },
              ),
            ),



            Container(
              child: Column(
                children: [
                  //Text("Latest News".toUpperCase(),style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),
                  FutureBuilder<NewsQueryModel>(
                    future: getNewsByQuery(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: ${snapshot.error}"),
                        );
                      } else if (snapshot.data == null) {
                        return Center(
                          child: Text("No data available"),
                        );
                      } else {
                        final newsdata = snapshot.data;

                        // Keep track of the total number of articles to be displayed
                        int itemCountToShow = newsdata!.articles!.length;

                        // If the user clicks "Show More," set the itemCountToShow to the total number of articles
                        if (showMoreClicked) {
                          itemCountToShow = newsdata.articles!.length;
                        }else{

                          itemCountToShow = newsdata.articles!.length > 4 ? 4 : newsdata.articles!.length;


                        }

                        return Column(
                          children: [
                            Text("Latest News".toUpperCase(),
                                style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                            SizedBox(height: 15),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: itemCountToShow,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 1.0,
                                    child: Stack(
                                      children: [
                                        Image.network(newsdata.articles![index].urlToImage.toString()),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                            child: Column(
                                              children: [
                                                Text(
                                                  newsdata.articles![index].title.toString(),
                                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            Container(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        showMoreClicked = !showMoreClicked; // Toggle the value
                                      });
                                    },
                                    child: Text(
                                      showMoreClicked ? "Show Less" : "Show More",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
      ]
    )
    )
    );
  }

  final List items = [Colors.blueAccent, Colors.red, Colors.amber];
}
