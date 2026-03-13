import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/highlight_bloc.dart';
import '../bloc/highlight_event.dart';
import '../bloc/highlight_state.dart';
import '../widgets/video_feed_item.dart';
import '../../../../core/theme/app_colors.dart';

class HighlightFeedPage extends StatefulWidget {
  const HighlightFeedPage({super.key});
  @override
  State<HighlightFeedPage> createState() => _HighlightFeedPageState();
}

class _HighlightFeedPageState extends State<HighlightFeedPage> {
  @override
  void initState() {
    super.initState();
    context.read<HighlightBloc>().add(GetHighlightsFeedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<HighlightBloc, HighlightState>(
        builder: (context, state) {
          if (state is HighlightLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            );
          }
          if (state is HighlightLoaded) {
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: state.highlights.length,
              itemBuilder: (context, index) =>
                  VideoFeedItem(highlight: state.highlights[index]),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
