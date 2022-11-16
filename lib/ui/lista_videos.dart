import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_api/youtube_api.dart';

class ListaVideos extends StatefulWidget {
  final Map<String, dynamic> datos;
  const ListaVideos(this.datos, {Key? key}) : super(key: key);

  @override
  State<ListaVideos> createState() => _ListaVideosState();
}

class _ListaVideosState extends State<ListaVideos> {
  get datos => widget.datos;
  static String apiKey = 'AIzaSyCII9AIKLCH7bWwb5ziG6VcU1W0BCNj2Gs';
  YoutubeAPI youtube = YoutubeAPI(apiKey, type: 'Video');
  Future<List<YouTubeVideo>> buscarVideos(String txt) async {
    List<YouTubeVideo> videos = await youtube.search(txt, type: 'Video');
    return videos;
  }

  Future<void> abreVideo(BuildContext context, String url) async {
    if (!await launch(url)) {
      SnackBar snack = const SnackBar(
        content: Text('No se pudo abrir el video'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos acerca de ${datos['nombre_contacto']}'),
      ),
      body: FutureBuilder(
        future: buscarVideos(datos['nombre_contacto']),
        builder: (BuildContext context,
            AsyncSnapshot<List<YouTubeVideo>> respuesta) {
          if (respuesta.hasData) {
            return scroll(respuesta.data);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget scroll(videos) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            listaVideos(videos),
          ],
        ),
      ),
    );
  }

  Widget listaVideos(videos) {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) => ListTile(
              leading: IconButton(
                onPressed: () {
                  String url = videos[index].url;
                  abreVideo(context, url);
                },
                icon: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    'https://img.youtube.com/vi/${Uri.parse(videos[index].url).queryParameters['v']}/0.jpg',
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) {
                        return child;
                      }
                      return frame == null
                          ? const Icon(
                              Icons.video_library,
                              size: 28,
                              color: Colors.blue,
                            )
                          : child;
                    },
                  ),
                ),
                iconSize: 100,
              ),
              title: Text(videos[index].title),
            ),
        separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
            ),
        itemCount: videos.length);
  }
}
