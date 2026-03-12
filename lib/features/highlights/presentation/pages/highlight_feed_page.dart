import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/highlight_bloc.dart';
import '../bloc/highlight_event.dart';
import '../bloc/highlight_state.dart';
import '../widgets/video_feed_item.dart';
import '../../../../core/theme/app_colors.dart';
import 'upload_highlight_page.dart';

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

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.primaryGreen,
          elevation: 8,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadHighlightPage()),
          ),

          label: Icon(Icons.add_box_rounded, color: Colors.black, size: 22),
        ),
      ),
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
                  const Icon(
                    Icons.blur_on_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  Text(
                    "DISCOVER",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      fontSize: 12,
                    ),
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
        ],
      ),
    );
  }
}
