import 'package:flutter/material.dart';
import 'package:mobile/src/updates/ui/viewmodel/updates_page_view_model_main.dart';
import 'package:mobile/src/updates/ui/widget/custom_circular_progress_indicator.dart';
import 'package:mobile/src/updates/ui/widget/paginated_list.dart';
import 'package:mobile/src/updates/ui/widget/post_card.dart';

class UpdatesPage extends StatefulWidget {
  final UpdatesPageViewModelMain viewModel;
  final Function()? onPop;

  const UpdatesPage({
    required this.viewModel,
    required this.onPop,
  });

  @override
  _UpdatesPageState createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  ScrollController scrollControllerUpdates = ScrollController();
  ScrollController scrollControllerUsers = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void _showSnackbar(BuildContext context, String message) {
    if (message.isNotEmpty) {
      SnackBar snackBar = SnackBar(content: Text(message), behavior: SnackBarBehavior.floating);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.viewModel.showSnackBar = (message) => _showSnackbar(context, message);
    return WillPopScope(
      onWillPop: () => widget.onPop!(),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: ListView(
                    shrinkWrap: true,
                    controller: scrollControllerUpdates,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "Frankenstain test",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      PaginatedList(
                        key: const Key('PostsList'),
                        cardsLength: widget.viewModel.postsList.length,
                        initFunction: () => widget.viewModel.updatePosts(),
                        scrollNextPageFunc: () => widget.viewModel.scrollNextPagePosts(),
                        showPageLoader: widget.viewModel.showPageLoader,
                        maxCardsLenght: widget.viewModel.maxPostsNum,
                        externalScrollController: scrollControllerUpdates,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Center(
                              child: Column(
                            children: [
                              Container(height: 100, color: Colors.blue),
                              Container(
                                //  color: Colors.red,
                                height: 10,
                              )
                            ],
                          ));
                        },
                      ),
                    ],
                  ))
                ],
              ),
              if (widget.viewModel.showPageLoader) CustomCircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
  }
}
