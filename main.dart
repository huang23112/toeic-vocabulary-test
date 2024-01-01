import 'dart:html';
import 'dart:js_util';

import 'package:flutter/material.dart';
import 'dart:convert'; // 為了使用 LineSplitter()，直接將題庫一行一行拆成字串陣列
import 'dart:async';

int iTestLevel = 0;

// source from https://mochidemy.com/test/result/e-002/g-017#
// Test 07
const String questionBank_advance =
'''1. (1) It is_______ that you do not reveal your password to anyone. ①essential ②essence ③expert ④exact。
2. (1) The state government today ________ a study showing that the standard of living across society has improved markedly over the last 2 years. ①released ②enticed ③avoided ④grasped。
3. (3) The bank has confirmed that it will take neccesary measures to _______ another computer system failure. ①upgrade ②encourage ③prevent ④improve。
4. (1) Tom was a highly ______ teacher who took his duties seriously but he had neither the personality nor ability to achieve much success. ①conscientious ②efficient ③capable ④talented。
5. (1) The sale of PDAs is __________ to continue to rise for the remainder of the fiscal year. ①expected ②effected ③affected ④exceeded。
6. (1) Located in the Quezon province of the Philippines. Villa Escudero is a nice hacienda-style resort with cozy rooms and a(n) _____ atmosphere. ①exotic ②eccentric ③exclusive ④receptive。
7. (2) Following the introduction of an enhanced benefits package, employee morale was raised ________. ①gratefully ②dramatically ③closely ④lastly。
8. (4) He's been __________ computer software applications and databases for nine years for his own company. ①discrediting ②distressing ③delineating ④developing。
9. (4) Officials __________ the improvement in service to a software upgrade that makes the system run faster. ①apply ②devote ③attribute ④concede。
10. (3) According to the proposal, a large block of rooms in the east wing of the new building will be __________ for storage.①retained ②designated ③qualified ④signified。''';

// source https://mochidemy.com/test/vocabulary/e-002/g-011
// Test 01
const String questionBank_basic =
'''1. (3) I_______ I can take a month's leave of absence this year. ①want ②wish ③hope ④desire。
2. (4) Patent laws guarantee that Salman's Precision Engineering has _____ rights to the cutting-edge technology it developed for robotic surgical equipment.  ①crucial ②viable ③manufactured ④exclusive。
3. (3) Ms. Carson and the other managers do not consider Michael Poulter to be a _______ employee. ①conceivable ②various ③reliable ④simultaneous。
4. (2) The mileage you have accrued is ________ for two years from the date of first use. ①fail ②valid ③neutral ④level。
5. (2) In order to ensure your access to our services, please keep us _____ of any alterations in your membership profile, such as change of address. ①assured ②updated ③disposed ④composed。
6. (3) If you have a ______ to make about the food, I am willing to listen. ①dislike ②trouble ③complaint ④confidence。
7. (4) The freelance journalist will email a ________ draft of the artical to The International Roundup's editor, Lesley Haggis. ①fundamental ②traditional ③chief ④preliminary。
8. (2) Be sure to read the directions _______ before installing the software program. ①heavily ②thoroughly ③increasingly ④readily。
9. (1) The operations department has been working on a more effective way to measure our overall ______. ①output ②tension ③insight ④lack。
10. (3) Even though the finance executive didn't personally authorize the illegal purchase, he is ________ responsible for the actions of everyone on his team. ①ambiguously ②temporarily ③indirectly ④thickly。''';

const String questionBank_basic_text =
'''1. (3) I_______ I can take a month's leave of absence this year. ①want ②wish ③hope ④desire。
2. (1) The state government today ________ a study showing that the standard of living across society has improved markedly over the last 2 years. ①released ②enticed ③avoided ④grasped。
10. (3) Even though the finance executive didn't personally authorize the illegal purchase, he is ________ responsible for the actions of everyone on his team. ①ambiguously ②temporarily ③indirectly ④thickly。''';

class Question {
  /// 題目內容
  late final String _content;

  /// 題目選項
  late final List<String> _options;

  /// 題目答案
  late final int _answer;

  // ignore: unused_element
  Question._(); // 避免使用者呼叫預設建構式

  Question.empty() // 建構空題目
  {
    _content = '沒題目了，請回上頁結束測驗。'; // 題目
    _options = ['', '', '', '']; // 選項
    _answer = 0; // 答案
  }

  Question.set(String question) // 以輸入字串建構題目
  {
    String removeEndWithPeriod(String s) {
      return s.endsWith("。") ? s.substring(0, s.length-1) : s;
    }

    int idxAns = question.indexOf("(") + 1;
    int idxContentStart = question.indexOf(")") + 1;
    int idxOptionOne = question.indexOf("①");
    int idxOptionTwo = question.indexOf("②");
    int idxOptionThree = question.indexOf("③");
    int idxOptionFour = question.indexOf("④");

    _content = question.substring(idxContentStart, idxOptionOne).trim(); // 題目
    int originalAnswer =
    int.parse(question.substring(idxAns, idxAns + 1)); // 原答案

    // 將選項洗牌
    List<String> s = [];
    s.add(removeEndWithPeriod(question.substring(idxOptionOne + 1, idxOptionTwo).trim())); // 原選項 1
    s.add(removeEndWithPeriod(question.substring(idxOptionTwo + 1, idxOptionThree).trim())); // 原選項 2
    s.add(removeEndWithPeriod(
        question.substring(idxOptionThree + 1, idxOptionFour).trim())); // 原選項 3
    s.add(removeEndWithPeriod(question.substring(idxOptionFour + 1).trim())); // 原選項 4
    List<int> t = [0, 1, 2, 3];
    t.shuffle();

    _options = [];
    for (int i = 0; i < 4; i++) {
      _options.add(s[t[i]]); // 加入亂序後的選項
      if (originalAnswer == t[i] + 1) {
        _answer = i;
      }
    }
  }

  @override
  String toString() =>
      "(${_answer + 1}) $_content ①${_options[0]} ②${_options[1]} ③${_options[2]} ④${_options[3]}";

  /// 取得題目內容
  String getContent() {
    return _content;
  }

  /// 取得題目選項
  List<String> getOptions() {
    return _options;
  }

  /// 取得題目答案
  int getAnswer() {
    return _answer;
  }
}

class ExamSimulator {
  //---------------------------------
  // 成員變數

  /// 空題目，無題目需顯示時用
  final Question emptyQuestion = Question.empty();
  /// 題目清單
  List<Question> questions = [];
  /// 目前要顯示的題目索引
  int currentIndex = 0;

  //--------------------------------
  // 成員方法

  /// 取得目前要顯示的題目索引
  int getCurrentIndex() {
    return currentIndex;
  }

  /// 取得題目清單長度
  int getNumberOfQuestions() {
    return questions.length;
  }

  Question getQuestion(int index)
  {
    return questions[index];
  }

  /// 取得目前要顯示的題目。若目前索引已大於題目清單長度，則顯示空題目。否則顯示目前題目。
  Question getCurrentQuestion() {
    return currentIndex >= questions.length
        ? emptyQuestion
        : questions[currentIndex];
  }

  bool lastQuestion() {
    if (currentIndex >= 0) {
        currentIndex--;
        return true;
    } else {
        return false;
    }
}


  /// 設定顯示下一題
  bool nextQuestion() {
    if (currentIndex < questions.length) {
      currentIndex++;
      return true;
    } else {
      return false;
    }
  }

  void setnextQuestionIndex(int nextQuestionIndex)
  {
      currentIndex = nextQuestionIndex;
  }

  /// 準備考題
  void prepareExamBasic() {
    // 將題庫依行拆成單一題
    List<String> lineQuestions = const LineSplitter().convert(questionBank_basic);
    // 將題目清空
    questions.clear();
    // 將題目清單的所有題目，逐一加入題目陣列中
    for (int i = 0; i < lineQuestions.length; i++) {
      questions.add(Question.set(lineQuestions[i])); // 解析題目內容，取得題目、選項、答案
    }
    // 將題目洗牌
    questions.shuffle();
    // 歸零目前要顯示的題目索引
    currentIndex = 0;

    // display
    //print("prepareExamBasic - questions = questions");
  }

  void prepareExamAdvance() {
    // 將題庫依行拆成單一題
    List<String> lineQuestions = const LineSplitter().convert(questionBank_advance);
    // 將題目清空
    questions.clear();
    // 將題目清單的所有題目，逐一加入題目陣列中
    for (int i = 0; i < lineQuestions.length; i++) {
      questions.add(Question.set(lineQuestions[i])); // 解析題目內容，取得題目、選項、答案
    }
    // 將題目洗牌
    questions.shuffle();
    // 歸零目前要顯示的題目索引
    currentIndex = 0;
  }


}

void main() {
  // MaterialApp 的屬性 debugShowCheckedModeBanner 設為 false，在畫面右上角就不會顯示一個 debug 圖案
  runApp(const MaterialApp(home:SafeArea(child: WelcomePage()), debugShowCheckedModeBanner: false));
}

// 入口頁面
class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Column(children: [
      const SizedBox(height: 50,),
      const Text("歡迎來到多益英文單字練習器\n你可選擇基礎或進階測驗\n開始測驗後，題目共十題，答題完點擊題目(或下一題按鍵)進行下一題。",
        softWrap: true,
        style: TextStyle(fontSize: 20),
      ),
      const Divider(
        height: 20,
        thickness: 5,
        indent: 20,
        endIndent: 20,
        color: Colors.orange,),


      // Basic
      const SizedBox(height: 10,),
      ElevatedButton(
        onPressed: () { 
          iTestLevel = 0;
          //print("WelcomePage : Navigator.push");
          Navigator.push(
            context,
            MaterialPageRoute( builder: (context) { return const QuestionPage(); } )
          );},
        child: const Text("開始基礎測驗", style: TextStyle(fontSize: 30))),

      // Advance
      const SizedBox(height: 10,),
      ElevatedButton(
        onPressed: () { 
          iTestLevel = 1;
          Navigator.push(
            context,
            MaterialPageRoute( builder: (context) { return const QuestionPage(); } )
          );},
        child: const Text("開始進階測驗", style: TextStyle(fontSize: 30))),


    ])));
  }
}

// 測驗頁面
class QuestionPage extends StatefulWidget {
  const QuestionPage({Key? key}) : super(key: key);
  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

// 測驗頁面的狀態內容
class _QuestionPageState extends State<QuestionPage> {
  late ExamSimulator examSimulator; // 測驗模擬器
  late Question currentQuestion; // 目前的問題
  int correctAnswerCount = 0; // 回答正確題數
  int totalQuestionCount = 0; // 總題數
  int currentQuestionIndex = 0; // 現顯示題目
  int answeredCount = 0; // 已完成題數
  int currentSelectedAnswerIndex = -1; // 選擇的答案
  List<int> selectedAnswerIndex = <int>[];
  bool isExamEnd = false; // 是否測驗結束
  //bool isAnswered = false; // 是否已回答完問題
  bool isTimeout = false;
  // 選項按鈕的預設背景色
  static const List<Color> optionDefaultColors = <Color>[
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white
  ];
  late List<Color> optionCurrentColors;

  // timer related

  // 設定計時時間（三分鐘）
  final timeLimit = Duration(minutes: 2);

  // 計時器
  late Timer _timer;

  // 剩餘秒數
  int remainingSeconds = 0;

  void buildAnswerCount()
  {
        correctAnswerCount = 0;
        for(int i=0;i<answeredCount;i++)
        {
          Question tempQuestion;

          tempQuestion = examSimulator.getQuestion(i);
          if (selectedAnswerIndex[i] == tempQuestion.getAnswer()) 
          {
              correctAnswerCount++;
          }
        }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // 更新剩餘秒數
      setState(() {
        remainingSeconds = timeLimit.inSeconds - timer.tick;
      });

      // 到達三分鐘後跳轉到最後一頁
      if (timer.tick >= timeLimit.inSeconds) {
        timer.cancel();
        //print("二分鐘已經過，跳轉到最後一頁");
     
        // 在這裡添加你的跳轉到最後一頁的程式碼
        answeredCount = 10;
        isExamEnd = true;
        isTimeout = true;
        examSimulator.setnextQuestionIndex(answeredCount);
        buildAnswerCount();

      }
    });
  }

  @override
  initState() {
    // 建立測驗模擬器
    examSimulator = ExamSimulator();
    if (iTestLevel == 0)
    {
      examSimulator.prepareExamBasic();
    }
    else
    {
      examSimulator.prepareExamAdvance();
    }
    
    currentQuestion = examSimulator.getCurrentQuestion();
    //print("initState : currentQuestion = $currentQuestion");

    // 初始化答題狀態
    correctAnswerCount = 0; // 回答正確題數
    totalQuestionCount = examSimulator.getNumberOfQuestions(); // 總題數
    for(int i=0;i<totalQuestionCount;i++)
    {
      selectedAnswerIndex.add(-1);
    }
    answeredCount = 0; // 已完成題數
    currentSelectedAnswerIndex = -1; // 選擇的答案
    isExamEnd = false; // 是否測驗結束
    //isAnswered = false; // 是否已回答完問題
    optionCurrentColors = optionDefaultColors.toList(); // 預設選項的背景色
    currentQuestionIndex = 0;
    super.initState();
    startTimer();
  }

  // 按下選項按鈕的反應
  void handleOptionButtonOnPress(int selectedOptionIndex) {
    // 還沒回答問題，選項按鈕才有反應。回答完就不反應。考完試也不反應。
    //if (isExamEnd == false && isAnswered == false) 
    {
      //print("handleOptionButtonOnPress : answeredCount = $answeredCount, selectedOptionIndex = $selectedOptionIndex");
      setState(() {
        currentSelectedAnswerIndex = selectedOptionIndex;

        if (selectedAnswerIndex[currentQuestionIndex] == -1)
        {
          answeredCount++;
        }
        selectedAnswerIndex[currentQuestionIndex] = currentSelectedAnswerIndex;

        //isAnswered = true;
        // 依選擇的答案，設定按鈕背景色，以及答對題數
        //optionCurrentColors[currentQuestion.getAnswer()] = Colors.greenAccent;

        //if (selectedOptionIndex == currentQuestion.getAnswer()) {
        //  correctAnswerCount++;
        //  optionCurrentColors[selectedOptionIndex] = Colors.green; 
        //} else {
        //  optionCurrentColors[selectedOptionIndex] = Colors.red;
        //}
        optionCurrentColors = optionDefaultColors.toList(); // 預設選項的背景色
        optionCurrentColors[selectedOptionIndex] = Colors.yellow;

      });
    }
  }

  // 按下螢幕畫面的反應
  void handleScreenOnTap() {
    //print("handleScreenOnTap : isExamEnd = $isExamEnd,isAnswered = $isAnswered ");
  }

void handleQuestionLastButtonOnPress() {
    //print("handleQuestionLastButtonOnPress");
   if (currentQuestionIndex > 0) 
   {
      setState(() {
      currentQuestionIndex--;  // currentQuestionIndex = currentQuestionIndex -1;
      examSimulator.lastQuestion();
      currentQuestion = examSimulator.getCurrentQuestion();

      optionCurrentColors = optionDefaultColors.toList(); // 預設選項的背景色
      optionCurrentColors[selectedAnswerIndex[currentQuestionIndex]] = Colors.yellow;

//        isAnswered = false;
//        examSimulator.lastQuestion();
//        isExamEnd = answeredCount >= totalQuestionCount ? true : false;
//        currentQuestion = examSimulator.getCurrentQuestion();
        //print("handleQuestionLastButtonOnPress : currentQuestion = $currentQuestion");
//        optionCurrentColors = optionDefaultColors.toList(); // 預設選項的背景色
      });
    }

  }

void handleQuestionNextButtonOnPress() {
    //print("handleQuestionNextButtonOnPress");
    //Navigator.of(context).pop();
    //if (isExamEnd == false && isAnswered == true) 
    
    setState(() {
    currentQuestionIndex++;
    if (currentQuestionIndex >= 10)
    {
      answeredCount = 10;
    }
    isExamEnd = answeredCount >= totalQuestionCount ? true : false;
    if (isExamEnd == true)
    {
        _timer.cancel();
        buildAnswerCount();
    }
    else
    {
      //isAnswered = false;
      examSimulator.nextQuestion();
      currentQuestion = examSimulator.getCurrentQuestion();
      //print("handleQuestionNextButtonOnPress : currentQuestion = $currentQuestion");
      optionCurrentColors = optionDefaultColors.toList(); // 預設選項的背景色
      optionCurrentColors[selectedAnswerIndex[currentQuestionIndex]] = Colors.yellow;

    }
    
    });

  }

  // 考試結果
  Widget buildExamResultLoop()
  {
    Column someColumn = Column(
      children: [],
    );

    //print("buildExamResultLoop : totalQuestionCount = $totalQuestionCount");

    for (int i = 0; i < totalQuestionCount; i++) {
    Row someRow = Row(
      children: [],
    );
    List<Color> optionColors = <Color>[
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    ];
      

    // Question
    someColumn.children.add(Align(alignment: Alignment.centerLeft,child:Padding(
            padding: const EdgeInsets.only(left : 70.0),
            child: Expanded(child:Text("(${i+1}). ${(examSimulator.getQuestion(i)).getContent()}", style: const TextStyle(fontSize: 20)))
          )));

    List<String> options = (examSimulator.getQuestion(i)).getOptions();

    if (selectedAnswerIndex[i] == (examSimulator.getQuestion(i)).getAnswer())
    {
      optionColors[selectedAnswerIndex[i]] = Colors.green;
    }
    else
    {
      if (selectedAnswerIndex[i] == -1)
      {
          for(int j=0;j<4;j++)
          {
            if (j == (examSimulator.getQuestion(i)).getAnswer())
            {
              optionColors[j] = Colors.green;
            }
            else
            {
              optionColors[j] = Colors.red;
            }
          }
      }
      else
      {
        optionColors[(examSimulator.getQuestion(i)).getAnswer()] = Colors.green;
        optionColors[selectedAnswerIndex[i]] = Colors.red;
      }
    }
    // Option 
    someRow.children.add(Expanded(child:Align(alignment: Alignment.centerLeft,child:Padding(
            padding: const EdgeInsets.only(left : 70.0),
            child: Text("①${options[0]}", style: TextStyle(fontSize: 20,color: optionColors[0]))
          ))));
    someRow.children.add(Expanded(child:Align(alignment: Alignment.centerLeft,child:Padding(
            padding: const EdgeInsets.only(left : 70.0),
            child: Text("②${options[1]}", style: TextStyle(fontSize: 20,color: optionColors[1]))
          ))));
    someRow.children.add(Expanded(child:Align(alignment: Alignment.centerLeft,child:Padding(
            padding: const EdgeInsets.only(left : 70.0),
            child: Text("③${options[2]}", style: TextStyle(fontSize: 20,color: optionColors[2]))
          ))));
    someRow.children.add(Expanded(child:Align(alignment: Alignment.centerLeft,child:Padding(
            padding: const EdgeInsets.only(left : 70.0),
            child: Text("④${options[3]}", style: TextStyle(fontSize: 20,color: optionColors[3]))
          ))));

    someColumn.children.add(Align(alignment: Alignment.centerLeft,child:Padding(
            padding: const EdgeInsets.only(left : 70.0),
            child: Expanded(child:someRow)
          )));
    }

    return someColumn;
    //return SingleChildScrollView(child: Expanded(child: ListBody(children: [Expanded(child:someColumn)])));
    //return SingleChildScrollView(child:someColumn);
  }


  // 
  Widget buildExamResult(){
    return Column(children: [
      Align(alignment: Alignment.centerLeft,child:Padding(
            padding: const EdgeInsets.only(left : 70.0),
            child: Text((examSimulator.getQuestion(0)).getContent(), style: const TextStyle(fontSize: 20))
          )),      
      Align(alignment: Alignment.centerLeft,child:Padding(
            padding: const EdgeInsets.only(left : 70.0),
            child: Text((examSimulator.getQuestion(1)).getContent(), style: const TextStyle(fontSize: 20))
          )),      

//      Align(alignment: Alignment.centerLeft,child:Text((examSimulator.getQuestion(0)).getContent(), style: const TextStyle(fontSize: 20)),),
//      Align(alignment: Alignment.centerLeft,child:Text((examSimulator.getQuestion(1)).getContent(), style: const TextStyle(fontSize: 20)),),
    ],);      
  }

  // 用函式建立題目
  Widget buildQuestion() {
    Widget DisplayItem;

    if (isExamEnd == false)
    {
      if (currentQuestionIndex == 9)
      {
      DisplayItem = Align(alignment: Alignment.centerLeft,child:Padding(
        padding: const EdgeInsets.only(left : 70.0), //EdgeInsets.all(left : 15.0),
        child: Text("*最後一題* (${currentQuestionIndex+1}). ${currentQuestion.getContent()}", style: const TextStyle(fontSize: 20))   // was fontSize: 16
        ));

      }
      else
      {
      DisplayItem = Align(alignment: Alignment.centerLeft,child:Padding(
        padding: const EdgeInsets.only(left : 70.0), //EdgeInsets.all(left : 15.0),
        child: Text("(${currentQuestionIndex+1}). ${currentQuestion.getContent()}", style: const TextStyle(fontSize: 20))   // was fontSize: 16
        ));
      }
    }
    else
    {
      if (isTimeout == true)
      {
      // Test finihsed. 
      DisplayItem = Align(alignment: Alignment.centerLeft,child:Padding(
        padding: const EdgeInsets.only(left : 70.0), //EdgeInsets.all(left : 15.0),
//        child: Text("作答結束,總分 ${(correctAnswerCount*100)/totalQuestionCount} 分,以下為作答結果,請回上頁結束測驗。", style: const TextStyle(fontSize: 20))   // was fontSize: 16
        child: Text("計時結束,總分 ${(correctAnswerCount*100)/totalQuestionCount} 分,以下為作答結果,請回上頁結束測驗。", style: const TextStyle(fontSize: 20))   // was fontSize: 16
        ));
      }
      else
      {
      // Test finihsed. 
      DisplayItem = Align(alignment: Alignment.centerLeft,child:Padding(
        padding: const EdgeInsets.only(left : 70.0), //EdgeInsets.all(left : 15.0),
//        child: Text("作答結束,總分 ${(correctAnswerCount*100)/totalQuestionCount} 分,以下為作答結果,請回上頁結束測驗。", style: const TextStyle(fontSize: 20))   // was fontSize: 16
        child: Text("總分 ${(correctAnswerCount*100)/totalQuestionCount} 分,以下為作答結果,請回上頁結束測驗。", style: const TextStyle(fontSize: 20))   // was fontSize: 16
        ));
      }
    }

    if (isExamEnd == false)
    {
    String temp;

    if (currentQuestionIndex == 9)
    {
      temp = '結束作答';
    }
    else
    {
      temp = '下一題';
    }
    
    DisplayItem = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      OutlinedButton(
        onPressed: () => handleQuestionLastButtonOnPress(), // 按下選項按鈕的反應
        style: OutlinedButton.styleFrom( // 選項按鈕的設計
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(600)), // 邊界形狀
        side: const BorderSide(color: Colors.black), // 邊界顏色
        foregroundColor: Colors.black),
        child: Align(alignment: Alignment.centerRight, child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("上一題", style: const TextStyle(fontSize: 16)))),
      ),
      Expanded(child: DisplayItem,),
      OutlinedButton(
        onPressed: () => handleQuestionNextButtonOnPress(), // 按下選項按鈕的反應
        style: OutlinedButton.styleFrom( // 選項按鈕的設計
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(600)), // 邊界形狀
        side: const BorderSide(color: Colors.black), // 邊界顏色
        foregroundColor: Colors.black),
        child: Align(alignment: Alignment.centerRight, child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(temp, style: const TextStyle(fontSize: 16)))),
      ),
    ],);
    }
    else
    {
    DisplayItem = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      Expanded(child: DisplayItem,),
    ],);

    }



    return DisplayItem;
  }

  // 用函式建立選項的Widget 
  Widget buildItem(String optionContent, int optionIndex) {
    Widget DisplayItem;
    //DisplayItem = Row(children: [Text(optionContent, style: const TextStyle(fontSize: 20)),],); 
    // currentQuestion.getAnswer()
    //    
    //print("buildItem : optionIndex = $optionIndex,currentQuestion.getAnswer() = $currentQuestion.getAnswer() ");
    //print("buildItem : optionIndex = $optionIndex");
    //print("buildItem : currentQuestionIndex = $currentQuestionIndex");
    //print("buildItem : selectedAnswerIndex[currentQuestionIndex] = $selectedAnswerIndex[currentQuestionIndex]");

    //if (isAnswered == true)
    {
      //if (optionIndex == currentQuestion.getAnswer())
      //{
      //  DisplayItem = Row(children: [Icon(Icons.thumb_up,color: Colors.black,size: 24.0,),   // or thumb_down , color: Colors.green, 
      //                  Text(optionContent, style: const TextStyle(fontSize: 20)),],);
      //}
      //else 
      //if (optionIndex == currentSelectedAnswerIndex)
      if (optionIndex == selectedAnswerIndex[currentQuestionIndex])
      {
        //DisplayItem = Row(children: [Icon(Icons.thumb_down,color: Colors.black,size: 24.0,),   // or thumb_down , color: Colors.green, 
        //                Text(optionContent, style: const TextStyle(fontSize: 20)),],);
        DisplayItem = Text(optionContent, style: const TextStyle(fontSize: 20));

      }
      else
      {
        DisplayItem = Text(optionContent, style: const TextStyle(fontSize: 20));
      }
    }
    //else
    //{
    //  DisplayItem = Text(optionContent, style: const TextStyle(fontSize: 20));
    //}

    return DisplayItem;
  }

  // 用函式建立選項
  Widget buildOptions() {
    // 取得選項內容
    List<String> options = currentQuestion.getOptions();
    // 用函式建立單一選項按鈕
    Widget buildOption(String optionContent, int optionIndex) {
      // 判斷選項內容是否加上題號
      optionContent = optionContent.isNotEmpty ? '${optionIndex + 1}. $optionContent' : optionContent;

      return Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: OutlinedButton(
        onPressed: () => handleOptionButtonOnPress(optionIndex), // 按下選項按鈕的反應
        style: OutlinedButton.styleFrom( // 選項按鈕的設計
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // 邊界形狀
          side: const BorderSide(color: Colors.lime), // 邊界顏色
          foregroundColor: Colors.indigo,
          // 以答對、答錯、是否已答題，來決定選項按鈕的背景顏色
          backgroundColor: optionCurrentColors[optionIndex]),
        child: Align(alignment: Alignment.centerLeft, child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: buildItem(optionContent,optionIndex),  ///replace by API : Text(optionContent, style: const TextStyle(fontSize: 20)),
          //child: Text(optionContent, style: const TextStyle(fontSize: 20)),
          //child : Row(children: [buildItem(optionContent)],)
          ))));
    }

    return Column(children: [
      buildOption(options[0], 0),
      const SizedBox(height: 10),
      buildOption(options[1], 1),
      const SizedBox(height: 10),
      buildOption(options[2], 2),
      const SizedBox(height: 10),
      buildOption(options[3], 3),
    ],);
  }

  // -------------------------------------
  // build : redraw parts
  // -------------------------------------
  @override
  Widget build(BuildContext context) 
  {
    // we can redraw according our requirement
    
    //print("build(redraw parts) : isExamEnd = $isExamEnd");
    if (isExamEnd == true)
    {
    //print("作答結束 總題數 : 答題數 : 正確數 = $totalQuestionCount : $answeredCount : $correctAnswerCount");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () 
          {
            // this is where push the first page and later will pop
            //print("_QuestionPageState build : answeredCount = $answeredCount,totalQuestionCount = $totalQuestionCount ");
            Navigator.of(context).pop();
          }
        ),
        title: Text("作答結束 總題數 : 答題數 : 答對數 = $totalQuestionCount : $answeredCount : $correctAnswerCount"),
        centerTitle: false),
      body: InkWell( // InkWell 與 GestureDetector 相比，多了點擊產生漣漪特效
        onTap: handleScreenOnTap,
        child: Column(children: [
          buildQuestion(),// 用函式建立題目
          const Divider(),
          buildExamResultLoop(),
        ],)
      )
    );

    }
    else
    {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () 
          {
            // this is where push the first page and later will pop
            //print("_QuestionPageState build : answeredCount = $answeredCount,totalQuestionCount = $totalQuestionCount ");
            Navigator.of(context).pop();
          }
        ),
        title: Text("作答中 剩餘時間：$remainingSeconds 秒, 總題數 : 答題數 = $totalQuestionCount : $answeredCount"),
        centerTitle: false),
      body: InkWell( // InkWell 與 GestureDetector 相比，多了點擊產生漣漪特效
        onTap: handleScreenOnTap,
        child: Column(children: [
          buildQuestion(),// 用函式建立題目
          const Divider(),
          buildOptions(),// 用函式建立選項
        ],)
      )
    );

    }
  }


  @override
  void dispose() {
    // 確保在頁面關閉時，計時器被取消
    _timer.cancel();
    super.dispose();
  }

}
