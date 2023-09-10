import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'newsmodel.dart';
import 'package:http/http.dart' as http;

class Categories extends StatefulWidget {
  final String Query;
   Categories({super.key, required this.Query});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

  Future<NewsQueryModel> getNewsByQuery(String query) async {
    try {
      String url = "";
      if(query == "Top News" || query == "Pakistan"){


    url = "https://newsapi.org/v2/everything?q=tesla&from=2023-07-19&sortBy=publishedAt&apiKey=d6007b9a20084c6c8e9d926d43627946";



      }else{

        url = "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=d6007b9a20084c6c8e9d926d43627946";

      }



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
    getNewsByQuery(widget.Query);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        iconTheme: IconThemeData(

          color: Colors.white
        ),
        backgroundColor: Colors.black,

        title: Text(widget.Query,style: TextStyle(color: Colors.white),),
        centerTitle: true,

      ),

      body: FutureBuilder<NewsQueryModel>(
        future: getNewsByQuery(widget.Query),
        builder: (context,snapshot){

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );

          }else if(snapshot.hasError){

            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }else if(snapshot.data == null){

            return Center(
              child: Text("No data available"),
            );
          }else{

            final newsdata = snapshot.data;


            return ListView.builder(
                physics: BouncingScrollPhysics(),


                shrinkWrap: true,
                itemCount: newsdata!.articles!.length,
                itemBuilder: (context,index){

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    //  child: Image.network("https://media.istockphoto.com/id/1369150014/vector/breaking-news-with-world-map-background-vector.jpg?s=612x612&w=0&k=20&c=9pR2-nDBhb7cOvvZU_VdgkMmPJXrBQ4rB1AkTXxRIKM="),

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
                                      Text(newsdata.articles![index].title.toString(),style: TextStyle(color: Colors.white,fontSize: 18),),
                                      // Text(newsdata.articles![index].description!.length > 50 ? "${newsdata.articles![index].description!.substring(0, 55)}..." : newsdata.articles![index].description!,style: TextStyle(color: Colors.white,fontSize: 17),),
                                    ],
                                  ))),


                        ],
                      ),
                    ),
                  );



                });

          }


        },

      )





    );
  }
}
