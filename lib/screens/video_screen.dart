import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_youtube_api/models/TimeStamp.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:screenshot/screenshot.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoScreen extends StatefulWidget {

  final String id;

  VideoScreen({this.id});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {

  YoutubePlayerController _controller;
  ScreenshotController screenshotController = ScreenshotController();
  List<TimeStamp> timeStamp = List();
  String name ="Hello...";

  getDataStamp() async{
    String path = await NativeScreenshot.takeScreenshot();
    File imgFile = File(path);
    timeStamp.add(TimeStamp(_controller.value.position,imgFile));
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.id,
      flags: YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          hideControls: false,
          hideThumbnail: false,
          isLive: true
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Screenshot(
            controller: screenshotController,
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              bottomActions: [
                CurrentPosition(),
                ProgressBar(isExpanded: true),
                RemainingDuration(),
              ],
              onReady: () {
                print('Player is ready.');
              },
            ),
          ),
          RaisedButton(child: Icon(Icons.photo_camera),onPressed: () {
            print(_controller.value.position);
            _controller.pause();

            setState(()  {
              getDataStamp();
//              screenshotController.capture(delay: Duration(milliseconds: 10)).then((File image) async {
//                //print("Capture Done")
//                timeStamp.add(TimeStamp(_controller.value.position,image));
//              });

            });

            _controller.play();
          },),
          // Text(name.toString().substring(0,4)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                ...Iterable.generate(timeStamp.length).map((i) {
                  return Row(
                      children:<Widget>[
                        InkWell(
                          onTap:(){
                            _controller.seekTo(timeStamp[i].timeStamp);
                          },
                          child: Card(
                              elevation:1,
                              child: Container(
                                  padding: EdgeInsets.all(1),
                                  child: Row(
                                    children: <Widget>[
                                      Image.file(timeStamp[i].image,height: 50,width: 100,),
                                      Text("${timeStamp[i].timeStamp.toString().substring(3,7)} "),
                                    ],
                                  )
                              )
                          ),
                        ),
                        SizedBox(width: 10)
                      ]
                  );

                }),

              ],
            ),
          )



        ],
      ),

    );
  }
}