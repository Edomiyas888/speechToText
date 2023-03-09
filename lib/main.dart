import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to text',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  State<SpeechScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SpeechScreen> {
  final Map<String, HighlightedWord> _highlights = {
    'Flutter': HighlightedWord(
        onTap: () => print('flutter'),
        textStyle:
            const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
    'Voice': HighlightedWord(
        onTap: () => print('Voice'),
        textStyle:
            const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
    'Bob ': HighlightedWord(
        onTap: () => print('bob'),
        textStyle:
            const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
    'pineApple': HighlightedWord(
        onTap: () => print('pineApple'),
        textStyle:
            const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
  };
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "press the button and start speaking";
  double _confidence = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
          reverse: true,
          child: Container(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 150),
            child: TextHighlight(
              text: _text,
              words: _highlights,
              textStyle: const TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          )),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'));
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          });
        });
      }
    } else {
      setState(() {
        _speech.stop();
      });
    }
  }
}
