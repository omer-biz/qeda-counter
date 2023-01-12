import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qeda_counter/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qeda\' Counter' ,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Qeda\' Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double gap = 30;
  bool isReadOnly = true;
  bool enableNotfi = false;

  final fajrController = TextEditingController();
  final dhurController = TextEditingController();
  final asrController = TextEditingController();
  final magController = TextEditingController();
  final ishaController = TextEditingController();

  final AndroidNotificationDetails androidNotificationDetails = 
    const AndroidNotificationDetails(
        "qeda_counter_channel_1122", "qeda_counter_channel",
        channelDescription: "Reminding you to pray your qeda",
        importance: Importance.max,
        priority: Priority.high,
        ticker: "ticker",
    );

  late NotificationDetails platformChannelSpecifics;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late List<PendingNotificationRequest> pendingNotifcations;

  void initControllers(TextEditingController controller, String lsal) {
    controller.addListener(() {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt(lsal, int.parse(controller.text));
        setState(() {
        });
      });
    });
  }

  Future<void> initNotifications() async {
    var pref = await SharedPreferences.getInstance();
    enableNotfi = pref.getBool("enableNotfi") ?? false;
    debugPrint("\n\nHello from n    otifcation \n\n");

    if (enableNotfi == true) {
      pendingNotifcations = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      debugPrint("pending: ${pendingNotifcations.length}");

      if (pendingNotifcations.isEmpty || pendingNotifcations.length != 5) {
        debugPrint("\n\nHello from notifcation \n\n");
        initPrayerNotif(1, "Fajr");
        initPrayerNotif(2, "Dhur");
        initPrayerNotif(3, "'Asr");
        initPrayerNotif(4, "Maghrib");
        initPrayerNotif(5, "'Isha");
      }
    }
  }

  void initPrayerNotif(int id, String content) {
    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime pryerTime;
    switch (content) {
      case "Fajr": {pryerTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 4, 50);}
        break;
      case "Dhur": {pryerTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 12, 25);}
        break;
      case "'Asr": {pryerTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 15, 40);}
        break;
      case "Maghrib": {pryerTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18, 40);}
        break;
      case "'Isha": {pryerTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 19, 45);}
        break;
      default: { return; }
    }
    flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        "Did you pay your debt ?",
        "Did you pry your $content qeda'",
        pryerTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  void initState() {
    super.initState();
    platformChannelSpecifics = NotificationDetails(android: androidNotificationDetails);
    flutterLocalNotificationsPlugin = NotificationService().getFlnp();

    SharedPreferences.getInstance().then((pref) {
      enableNotfi = pref.getBool("enableNotfi") ?? false;
    });

    initNotifications();

    initControllers(fajrController, 'fajr');
    initControllers(dhurController, 'dhur');
    initControllers(asrController, 'asr');
    initControllers(magController, 'mag');
    initControllers(ishaController, 'isha');

    SharedPreferences.getInstance().then(((prefs) {
      fajrController.text = (prefs.getInt('fajr') ?? 0).toString();
      dhurController.text = (prefs.getInt('dhur') ?? 0).toString();
      asrController.text = (prefs.getInt('asr') ?? 0).toString();
      magController.text = (prefs.getInt('mag') ?? 0).toString();
      ishaController.text = (prefs.getInt('isha') ?? 0).toString();
    }));
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const ImageIcon(AssetImage("assets/img/logo.png")),
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Help'),
              content: const Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(child: Icon(Icons.notifications_active)),
                    TextSpan(text: ": Can be used to enable and disable notifications,"
                      "if enabled you will get daily notifications to remind to pry.\n\n"
                    ),

                    WidgetSpan(child: Icon(Icons.edit)),
                    TextSpan(text: ": Enables and/or disables the counter field, useful if you"
                        "want to manually fill the counter fields. simply tap it and you"
                        "can automatically edit your progress, not recommend though.\n\n"
                    ),

                    WidgetSpan(child: Icon(Icons.exit_to_app)),
                    TextSpan(text: ": To exit the application."),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.pop(context, 'OK')
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: (enableNotfi) ? const Icon(Icons.notifications_active) : const Icon(Icons.notifications_off),
            onPressed: () async {
              setState(() { 
                enableNotfi = (enableNotfi) ? false : true;
              });
              SharedPreferences.getInstance().then((pref) => {
                pref.setBool("enableNotfi", enableNotfi)
              });
              if (enableNotfi == false) {
                await flutterLocalNotificationsPlugin.cancelAll();
              } else {
                initPrayerNotif(1, "Fajr");
                initPrayerNotif(2, "Dhur");
                initPrayerNotif(3, "'Asr");
                initPrayerNotif(4, "Maghrib");
                initPrayerNotif(5, "'Isha");
                pendingNotifcations = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
                debugPrint("pending: ${pendingNotifcations.length}");
              }
            },
          ),
          IconButton(
            icon: (isReadOnly) ? const Icon(Icons.edit) : const Icon(Icons.block),
            onPressed: () {
              setState(() { 
                isReadOnly = (isReadOnly) ? false : true;
                if (isReadOnly == true) {
                  FocusScope.of(context).unfocus();
                }
              });
            }
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              SystemNavigator.pop();
            }
          ),
        ]
      ),
      body: Center(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              buildIntro(),
              SizedBox(height: gap),
              buildField("Fajr", fajrController, 'fajr'),
              SizedBox(height: gap),
              buildField("Dhur", dhurController, 'dhur'),
              SizedBox(height: gap),
              buildField("'Asr", asrController, 'asr'),
              SizedBox(height: gap),
              buildField("Maghrib", magController, 'mag'),
              SizedBox(height: gap),
              buildField("'Isha", ishaController, 'isha'),
              SizedBox(height: gap),
            ],
          ),
      ),
    );
  }

  Widget buildIntro() => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: const Text.rich(
      TextSpan(
        children: [
          TextSpan(text: "    An application to track your previous qeda'. May it be useful for those who wish to pay their debt."),
          TextSpan(text: "Tap the "),
          WidgetSpan(child: ImageIcon(AssetImage('assets/img/logo.png'))),
          TextSpan(text: " icon for help.")
        ]
      ),
    ),
  );

  void _saveQeda(String pref, int q) {
    SharedPreferences.getInstance().then(((prefs) {
      prefs.setInt(pref, q);
    }));
  }

  Widget buildField(String salat, TextEditingController controller, String lsala) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: salat,
        prefixIcon: Container(width: 5, 
          height: 5,  
          padding: const EdgeInsets.all(5), 
          child: Image(image: AssetImage("assets/img/$lsala.png"))
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.horizontal_rule),
              onPressed: () {
                int q = int.parse(controller.text) - 1;
                _saveQeda(lsala, q);
                setState(() {
                  controller.text = q.toString();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                int q = int.parse(controller.text) + 1;
                _saveQeda(lsala, q);
                setState(() {
                  controller.text = q.toString();
                });
              }
            ),
          ],
        ),
      ),
    );
  }
}
