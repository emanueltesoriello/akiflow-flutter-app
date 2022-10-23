import 'package:flutter/material.dart';
import 'package:mobile/src/updates/domain/model/post_model_response.dart';

// The Card used in the Posts page
class PostCard extends StatelessWidget {
  final PostModelResponse postModel;

  const PostCard({
    Key? key,
    required this.postModel,
  }) : super(key: key);

  _buildUserSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  postModel.creatorName,
                  overflow: TextOverflow.clip,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  "${"translation.postCard.postedOn" + " " + postModel.postDate}",
                  overflow: TextOverflow.clip,
                  style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(color: Colors.blue),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserSection(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(postModel.title,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(postModel.caption,
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white.withOpacity(0.7))),
            ),
            // _buildBottomSection(context),
            // SizedBox(height: Dimension.padding),
          ],
        ),
      ),
    );
  }
}
