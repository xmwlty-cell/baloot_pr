// lib/main.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(BalootApp());
}

class BalootApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baloot Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: SplashScreen(),
    );
  }
}

/* ------------------ Splash Screen ------------------ */
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainMenu()));
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0B0216), Color(0xFF12002F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _anim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), boxShadow: [
                    BoxShadow(color: Colors.purpleAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 1)
                  ]),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.casino, size: 56, color: Colors.white),
                  ),
                ),
                SizedBox(height: 18),
                Text('Baloot Pro', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 8),
                Text('Luxury Baloot scorekeeper', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------ Main Menu ------------------ */
class MainMenu extends StatelessWidget {
  Widget _menuButton(BuildContext c, String title, Color color, VoidCallback onTap) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 8
    ),
    onPressed: onTap,
    child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(28),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0B0216), Color(0xFF1B0630)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.casino, size: 110, color: Colors.purpleAccent),
            SizedBox(height: 14),
            Text('Baloot Pro', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
            SizedBox(height: 34),
            _menuButton(context, 'Start Game', Colors.deepPurpleAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerSetupPage()));
            }),
            SizedBox(height: 18),
            _menuButton(context, 'Custom Phrases (record)', Colors.blueAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CustomSoundsPage()));
            }),
            SizedBox(height: 18),
            _menuButton(context, 'About / Settings', Colors.grey.shade800, () {
              showAboutDialog(context: context, applicationName: 'Baloot Pro', applicationVersion: '1.0');
            }),
          ],
        ),
      ),
    );
  }
}

/* ------------------ Player Setup Page ------------------ */
class PlayerSetupPage extends StatefulWidget {
  @override
  _PlayerSetupPageState createState() => _PlayerSetupPageState();
}
class _PlayerSetupPageState extends State<PlayerSetupPage> {
  final List<TextEditingController> _names = List.generate(4, (_) => TextEditingController());
  final List<File?> _images = List.generate(4, (_) => null);
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int index) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _images[index] = File(picked.path);
      });
    }
  }

  Future<void> _takePhoto(int index) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _images[index] = File(picked.path);
      });
    }
  }

  Widget _playerRow(int i) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showImageOptions(i),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Colors.deepPurple,
              backgroundImage: _images[i] != null ? FileImage(_images[i]!) : null,
              child: _images[i] == null ? Text((_names[i].text.isEmpty ? 'P${i+1}' : _names[i].text[0]).toUpperCase(), style: TextStyle(fontSize: 22)) : null,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _names[i],
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Player ${i + 1} name',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showImageOptions(int index) {
    showModalBottomSheet(context: context, builder: (ctx) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: Icon(Icons.photo_camera), title: Text('Take photo'), onTap: () { Navigator.pop(ctx); _takePhoto(index); }),
            ListTile(leading: Icon(Icons.photo_library), title: Text('Choose from gallery'), onTap: () { Navigator.pop(ctx); _pickImage(index); }),
            ListTile(leading: Icon(Icons.close), title: Text('Cancel'), onTap: () => Navigator.pop(ctx)),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _names.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            Text('Enter players (tap avatar to add photo)', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 12),
            _playerRow(0),
            _playerRow(1),
            _playerRow(2),
            _playerRow(3),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () {
                final names = _names.map((c) => c.text.trim().isEmpty ? 'Player' : c.text.trim()).toList();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ScorePage(players: names, playerImages: _images)));
              },
              child: Text('Start Game', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

/* ------------------ Custom Sounds Page ------------------ */
class CustomSoundsPage extends StatefulWidget {
  @override
  _CustomSoundsPageState createState() => _CustomSoundsPageState();
}

class _CustomSoundsPageState extends State<CustomSoundsPage> {
  final List<String> phrases = ['mabrook', 'khasartu', 'san', 'hokm', 'double'];
  final List<String> display = ['مبروك', 'خسرتوا', 'صن', 'حكم', 'دبل'];
  final Record _recorder = Record();
  final AudioPlayer _player = AudioPlayer();
  Map<String, String> _paths = {};

  @override
  void initState() {
    super.initState();
    _initPaths();
  }

  Future<void> _initPaths() async {
    final dir = await getApplicationDocumentsDirectory();
    Map<String, String> map = {};
    for (var p in phrases) {
      map[p] = '${dir.path}/$p.m4a';
    }
    setState(() { _paths = map; });
  }

  Future<void> _startRecord(String key) async {
    if (await _recorder.hasPermission()) {
      await _recorder.start(path: _paths[key]);
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Microphone permission denied')));
    }
  }
  Future<void> _stopRecord() async {
    await _recorder.stop();
    setState(() {});
  }
  Future<void> _play(String key) async {
    final p = _paths[key]!;
    if (File(p).existsSync()) {
      await _player.stop();
      await _player.play(DeviceFileSource(p));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No recording found for $key')));
    }
  }
  Widget _row(int idx) {
    final key = phrases[idx];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(display[idx], style: TextStyle(fontSize: 18)),
        subtitle: Text('Tap mic to record, then stop, then play', style: TextStyle(fontSize: 12)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: Icon(Icons.mic, color: Colors.red), onPressed: () => _startRecord(key)),
          IconButton(icon: Icon(Icons.stop, color: Colors.orangeAccent), onPressed: _stopRecord),
          IconButton(icon: Icon(Icons.play_arrow, color: Colors.greenAccent), onPressed: () => _play(key)),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Baloot Phrases'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children: [
          Text('Record your own voice for important phrases', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 12),
          Expanded(child: ListView.builder(itemCount: phrases.length, itemBuilder: (_, i) => _row(i))),
          SizedBox(height: 8),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Back'))
        ]),
      ),
    );
  }
}

/* ------------------ Score Page ------------------ */
class ScorePage extends StatefulWidget {
  final List<String> players;
  final List<File?> playerImages;
  ScorePage({required this.players, required this.playerImages});
  @override
  _ScorePageState createState() => _ScorePageState();
}
class _ScorePageState extends State<ScorePage> with SingleTickerProviderStateMixin {
  int ourScore = 0;
  int theirScore = 0;
  late AnimationController _numController;
  late Animation<double> _numAnim;
  final AudioPlayer _player = AudioPlayer();
  final List<String> phrases = ['mabrook', 'khasartu', 'san', 'hokm', 'double'];

  @override
  void initState() {
    super.initState();
    _numController = AnimationController(vsync: this, duration: Duration(milliseconds: 320), lowerBound: 0.8, upperBound: 1.15)
      ..addStatusListener((s) { if (s == AnimationStatus.completed) _numController.reverse(); });
    _numAnim = CurvedAnimation(parent: _numController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _numController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<String> _getPhrasePath(String key) async {
    final dir = await getApplicationDocumentsDirectory();
    final candidate = '${dir.path}/$key.m4a';
    if (File(candidate).existsSync()) return candidate;
    // fallback default assets
    switch (key) {
      case 'mabrook': return 'assets/sounds/win_default.mp3';
      case 'khasartu': return 'assets/sounds/lose_default.mp3';
      default: return 'assets/sounds/cardflip.mp3';
    }
  }

  Future<void> _playPhrase(String key) async {
    final path = await _getPhrasePath(key);
    await _player.stop();
    if (path.startsWith('assets/')) {
      await _player.play(AssetSource(path.replaceFirst('assets/', '')));
    } else {
      await _player.play(DeviceFileSource(path));
    }
  }

  void _updateScore(bool isUs, bool add) async {
    setState(() {
      if (isUs) ourScore = (ourScore + (add ? 10 : -10)).clamp(0, 999);
      else theirScore = (theirScore + (add ? 10 : -10)).clamp(0, 999);
    });
    // play card flip sound
    await _playPhrase('san'); // mapas as cardflip
    _numController.forward();
    _checkWinner();
  }

  void _checkWinner() async {
    if (ourScore >= 152) {
      await _playPhrase('mabrook');
      _showResult('${widget.players[0]} & ${widget.players[2]} won!');
    } else if (theirScore >= 152) {
      await _playPhrase('khasartu');
      _showResult('${widget.players[1]} & ${widget.players[3]} won!');
    }
  }

  void _showResult(String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.deepPurple.shade700,
      title: Center(child: Text(msg, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      actions: [TextButton(onPressed: () { Navigator.pop(context); }, child: Text('OK'))],
    ));
  }

  Widget _playerAvatar(int i) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: widget.playerImages[i] != null ? FileImage(widget.playerImages[i]!) : null,
          backgroundColor: Colors.deepPurple,
          child: widget.playerImages[i] == null ? Text(widget.players[i].isEmpty ? 'P' : widget.players[i][0].toUpperCase(), style: TextStyle(fontSize: 22)) : null,
        ),
        SizedBox(height: 6),
        Text(widget.players[i], style: TextStyle(fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget _scoreCard(String title, int score, Color color, bool isUs) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ScaleTransition(scale: _numAnim, child: Text('$score', style: TextStyle(fontSize: 52, fontWeight: FontWeight.w900))),
            SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _cardButton('♦️', color, () => _updateScore(isUs, true)),
              SizedBox(width: 16),
              _cardButton('♣️', Colors.grey, () => _updateScore(isUs, false)),
            ])
          ],
        ),
      ),
    );
  }

  Widget _cardButton(String symbol, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 140),
        curve: Curves.easeOut,
        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 18, spreadRadius: 2)]),
        child: CircleAvatar(radius: 30, backgroundColor: color, child: Text(symbol, style: TextStyle(fontSize: 26))),
      ),
    );
  }

  Future<void> _playCustom(String key) async {
    await _playPhrase(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baloot Scoreboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: () {
            setState(() {
              ourScore = 0; theirScore = 0;
            });
          })
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _playerAvatar(0),
              _playerAvatar(1),
              _playerAvatar(2),
              _playerAvatar(3),
            ]),
            SizedBox(height: 18),
            Expanded(child: SingleChildScrollView(
              child: Column(children: [
                _scoreCard('Our Team ♠️♥️', ourScore, Colors.blue, true),
                SizedBox(height: 18),
                _scoreCard('Their Team ♣️♦️', theirScore, Colors.red, false),
                SizedBox(height: 18),
                Card(
                  color: Colors.white10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text('Quick Phrases', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          children: [
                            ElevatedButton(onPressed: () => _playCustom('mabrook'), child: Text('مبروك')),
                            ElevatedButton(onPressed: () => _playCustom('khasartu'), child: Text('خسرتوا')),
                            ElevatedButton(onPressed: () => _playCustom('san'), child: Text('صن')),
                            ElevatedButton(onPressed: () => _playCustom('hokm'), child: Text('حكم')),
                            ElevatedButton(onPressed: () => _playCustom('double'), child: Text('دبل')),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32)
              ]),
            ))
          ],
        ),
      ),
    );
  }
}
