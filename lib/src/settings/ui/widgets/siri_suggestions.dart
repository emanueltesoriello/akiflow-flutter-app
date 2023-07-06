import 'package:flutter/material.dart';
import 'package:flutter_siri_suggestions/flutter_siri_suggestions.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';

class SiriSuggestions extends StatefulWidget {
  const SiriSuggestions({super.key});

  @override
  State<SiriSuggestions> createState() => _SiriSuggestionsState();
}

class _SiriSuggestionsState extends State<SiriSuggestions> {
  String _text = 'added mainActivity, beerActivity suggestions 🙋‍♂️';
  @override
  void initState() {
    super.initState();
    initSuggestions();
  }

  void initSuggestions() async {
    FlutterSiriSuggestions.instance.configure(onLaunch: (Map<String, dynamic> message) async {
      debugPrint('[FlutterSiriSuggestions] [onLaunch] $message');
      //Awaken from Siri Suggestion
      ///// TO DO : do something!
      String __text;

      debugPrint("[FlutterSiriSuggestions] Called by ${message['key']} suggestion.");

      switch (message["key"]) {
        case "mainActivity":
          __text = "redirect to mainActivity";
          break;
        case "beerActivity":
          __text = "redirect to beerActivity";
          break;
        case "searchActivity":
          __text = "redirect to searchActivity";
          break;
        case "talkActivity":
          __text = "redirect to talkActivity";
          break;
        default:
          __text = "hmmmm...... made a typo";
      }

      setState(() {
        _text = __text;
      });
    });

    await FlutterSiriSuggestions.instance.registerActivity(const FlutterSiriActivity(
        "mainActivity Suggestion in Akiflow", "mainActivity",
        isEligibleForSearch: true,
        isEligibleForPrediction: true,
        contentDescription: "Open mainActivity in Akiflow",
        suggestedInvocationPhrase: "open Akiflow",
        userInfo: {"info": "sample"}));

    await FlutterSiriSuggestions.instance.registerActivity(const FlutterSiriActivity(
      "beerActivity Suggestion",
      "beerActivity",
      isEligibleForSearch: true,
      isEligibleForPrediction: true,
      contentDescription: "Open beerActivity 🍺",
      suggestedInvocationPhrase: "coooooool",
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: const AppBarComp(
          title: "Siri suggestions",
          showBack: true,
        ),
        body: Builder(builder: (context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Center(
                    child: Text(_text),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextButton(
                      child: const Text(
                        "add searchActivity Suggestion\n(key: searchActivity)",
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () async {
                        FlutterSiriSuggestionsResult result =
                            await FlutterSiriSuggestions.instance.registerActivity(const FlutterSiriActivity(
                          "rder a coffee with Akiflow",
                          "rder a coffee with Akiflow",
                          isEligibleForSearch: true,
                          isEligibleForPrediction: true,
                          contentDescription: "Open searchActivity 🧐",
                          suggestedInvocationPhrase: "order a coffee with Akiflow",
                        ));

                        showSnackBar(
                            "${result.key} suggestion added.\n(key: ${result.key}, persistentIdentifier: ${result.persistentIdentifier})",
                            context: context);
                      },
                    ),
                    TextButton(
                      child: const Text("remove searchActivity Suggestion by key\n(key: searchActivity)",
                          style: TextStyle(fontSize: 12)),
                      onPressed: () async {
                        FlutterSiriSuggestions.instance
                            .deleteSavedUserActivitiesWithPersistentIdentifier("searchActivity");

                        showSnackBar("removed searchActivity suggestion.", context: context);
                      },
                    ),
                    TextButton(
                      child: const Text(
                        "add talkActivity Suggestion\n(key: talkActivity, persistentIdentifier: customID)",
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () async {
                        FlutterSiriSuggestionsResult result = await FlutterSiriSuggestions.instance.registerActivity(
                            const FlutterSiriActivity("meditation in Akiflow", "meditation in Akiflow",
                                isEligibleForSearch: true,
                                isEligibleForPrediction: true,
                                contentDescription: "meditation in Akiflow",
                                suggestedInvocationPhrase: "meditation in Akiflow",
                                persistentIdentifier: "meditation in Akiflow",
                                userInfo: {"value": "ordina un akiflow"}));

                        showSnackBar(
                            "${result.key} suggestion added.\n(key: ${result.key}, persistentIdentifier: ${result.persistentIdentifier})",
                            context: context);
                      },
                    ),
                    TextButton(
                      child: const Text(
                          "remove talkActivity Suggestion by PersistentIdentifier\n(persistentIdentifier: customID)",
                          style: TextStyle(fontSize: 12)),
                      onPressed: () async {
                        FlutterSiriSuggestions.instance.deleteSavedUserActivitiesWithPersistentIdentifier("customID");

                        showSnackBar("removed searchActivity suggestion.", context: context);
                      },
                    ),
                    TextButton(
                      child: const Text("remove all Suggestions", style: TextStyle(fontSize: 12)),
                      onPressed: () async {
                        FlutterSiriSuggestions.instance.deleteAllSavedUserActivities();

                        showSnackBar("removed all suggestion.", context: context);
                      },
                    ),
                  ],
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  void showSnackBar(String text, {required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: const TextStyle(fontSize: 12))),
    );
  }
}
