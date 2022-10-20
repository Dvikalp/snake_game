import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/snake_pixel.dart';

import 'blank_pixel.dart';
import 'food_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction{UP,DOWN,RIGHT,LEFT}

class _HomePageState extends State<HomePage> {
  int rowSize=10;
  int totalNumberOfSquare=100;
  int currentScore=0;
  int highestscore=0;
  bool gameHasStarted=false;
  final _nameController=TextEditingController();
  List<int> snakePos=[
    0,
    1,
    2,
  ];
  var currentDirection=snake_Direction.RIGHT;
  int foodPos=55;

  List<String> highscore_DocIds=[];
  late final Future? letsGetDocIds;

  @override
  void initState(){
    letsGetDocIds=getDocId();
    super.initState();
  }
  Future getDocId() async{
    await FirebaseFirestore.instance
        .collection("highscore")
        .orderBy("score",descending: true)
        .limit(10)
        .get()
        .then((value)=>value.docs.forEach((element) {
          highscore_DocIds.add(element.reference.id);
    }));
  }

  void eatFood(){
    currentScore++;
    if(currentScore>highestscore){
      highestscore=currentScore;
    }
    while(snakePos.contains(foodPos)){
      foodPos=Random().nextInt(totalNumberOfSquare);
    }
  }

  bool gameOver(){
    List<int> bodySnake=snakePos.sublist(0,snakePos.length-1);
    if(bodySnake.contains(snakePos.last)){
      return true;
    }
    return false;
  }

  void submitScore(){
    var database=FirebaseFirestore.instance;
    database.collection('highscores').add({
      "name":_nameController.text,
      "score":currentScore,
    }
    );
  }

  void startGame(){
    gameHasStarted=true;
    Timer.periodic(Duration(milliseconds: 200),(timer)=>{
      setState((){
        if(snakePos.last==foodPos){
          eatFood();
        }
        else{
          snakePos.removeAt(0);
        }
        switch (currentDirection){
          case snake_Direction.RIGHT:
            {
              if(snakePos.last%rowSize==9){
                snakePos.add(snakePos.last+1-rowSize);
              }
              else{
                snakePos.add(snakePos.last+1);
              }
            }
            break;
          case snake_Direction.LEFT:
          {
            if(snakePos.last%rowSize==0){
              snakePos.add(snakePos.last-1+rowSize);
            }
            else{
              snakePos.add(snakePos.last-1);
            }
          }
          break;
          case snake_Direction.UP:
          {
            if(snakePos.last<rowSize){
              snakePos.add(snakePos.last-rowSize+totalNumberOfSquare);
            }
            else{
              snakePos.add(snakePos.last-rowSize);
            }
          }
          break;
          case snake_Direction.DOWN:
          {
            if(snakePos.last+rowSize>totalNumberOfSquare){
                snakePos.add(snakePos.last+rowSize-totalNumberOfSquare);
            }
            else{
              snakePos.add(snakePos.last+rowSize);
            }
          }
          break;
        }
        if(gameOver()){
          timer.cancel();
          showDialog(context: context, builder: (context){
            return AlertDialog(
              title: Text('Game Over'),
              content: Column(
                  children: [
                    Text('Your score is : '+currentScore.toString()),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: 'Enter name'),
                  ),
                  ],
              ),
              actions: [
                MaterialButton(onPressed: (){
                  Navigator.pop(context);
                  submitScore();
                  newGame();
                },
                child: Text('Submit'),
                color: Colors.pink,
                )
              ],
            );
          });
        }
      }),

    });
  }
  void newGame(){
    setState(() {
      snakePos=[
        0,
        1,
        2,
      ];
      currentDirection=snake_Direction.RIGHT;
      foodPos=55;
      currentScore=0;
      gameHasStarted=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body:RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event){
          if(event.isKeyPressed(LogicalKeyboardKey.keyS)&&currentDirection!=snake_Direction.UP){
            currentDirection=snake_Direction.DOWN;
          }
          else if(event.isKeyPressed(LogicalKeyboardKey.keyW)&&currentDirection!=snake_Direction.DOWN){
            currentDirection=snake_Direction.UP;
          }
          else if(event.isKeyPressed(LogicalKeyboardKey.keyA)&&currentDirection!=snake_Direction.RIGHT){
            currentDirection=snake_Direction.LEFT;
          }
          else if(event.isKeyPressed(LogicalKeyboardKey.keyD)&&currentDirection!=snake_Direction.LEFT){
            currentDirection=snake_Direction.RIGHT;
          }
        },
        child: SizedBox(
          width: screenWidth>400?400:screenWidth,
          child: Column(
            children:[
              Expanded(
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Current Score',style: TextStyle(color:Colors.white)),
                        Text(
                          currentScore.toString(),
                          style: TextStyle(fontSize: 25,color: Colors.white),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Highest Score',style: TextStyle(color:Colors.white),),
                        Text(
                          highestscore.toString(),
                          style: TextStyle(fontSize: 25,color: Colors.white),
                        )
                      ],
                    ),
                    ]
                )),
                    /*Expanded(child: gameHasStarted?
                      Container(): FutureBuilder(
                        future: letsGetDocIds,
                        builder: (context,snapshot){
                          return ListView.builder(
                              itemCount: highscore_DocIds.length,
                              itemBuilder: ((context,index){
                            return HighScoreTile(
                              documentId:highscore_DocIds[index]

                            );
                          }));
                        },
                      ),
                    )
                    //Text('Highscore..',style: TextStyle(color:Colors.white)),
                  ],
                ),
              ),*/

              Expanded(
                  flex:3,
                  child:GestureDetector(
                    onVerticalDragUpdate: (details){
                      if(details.delta.dy>0&&currentDirection!=snake_Direction.UP){

                        currentDirection=snake_Direction.DOWN;
                      }
                      else if(details.delta.dy<0&&currentDirection!=snake_Direction.DOWN){
                        currentDirection=snake_Direction.UP;
                      }
                    },
                    onHorizontalDragUpdate: (details){
                      if(details.delta.dx>0&&currentDirection!=snake_Direction.LEFT){
                        currentDirection=snake_Direction.RIGHT;
                      }
                      else if(details.delta.dx<0&&currentDirection!=snake_Direction.RIGHT){
                        currentDirection=snake_Direction.LEFT;
                      }
                    },
                    child: GridView.builder(
                      itemCount: totalNumberOfSquare,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: rowSize),
                      itemBuilder: (context,index){
                      if(snakePos.contains(index)){
                        return const SnakePixel();
                      }
                      else if(index==foodPos){
                        return const FoodPixel();
                      }
                      else{
                        return const BlankPixel();
                      }

                    }
                    ),
                  ),
              ),
              Expanded(
                  child:Container(
                    child: Center(
                      child: MaterialButton(
                        child: Text('Play'),
                        color: gameHasStarted?Colors.grey:Colors.pink,
                        onPressed: gameHasStarted?(){}:startGame,
                      ),
                    ),
                  ),
              )
            ]
          ),
        ),
      )
    );
  }
}
