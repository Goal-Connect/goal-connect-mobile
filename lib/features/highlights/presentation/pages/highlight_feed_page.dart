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
      body: Stack(
        children: [
          BlocBuilder<HighlightBloc, HighlightState>(
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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
                  Row(
                    children: [
                      _tabText("For You", true),
                      const SizedBox(width: 20),
                      _tabText("Following", false),
                    ],
                  ),
                  const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withOpacity(0),
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabText(String title, bool active) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: TextStyle(
          color: active ? Colors.white : Colors.white54,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          shadows: [
            if (active)
              const Shadow(color: AppColors.primaryGreen, blurRadius: 15),
          ],
        ),
      ),
      if (active)
        Container(
          margin: const EdgeInsets.only(top: 4),
          height: 2,
          width: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
    ],
  );
}
