import 'package:flutter/material.dart';
import 'package:news_app/common/common_colors.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;

  const CategoryScreen({super.key, required this.categoryName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<NewsProvider>().getCategoryNews(widget.categoryName);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.categoryName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            const Text(
              "News",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Consumer<NewsProvider>(
          builder: (context, provider, child) {
            if (_isLoading || provider.isCategoryNewsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.categoryNews.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "No news found for this category.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                        });
                        context
                            .read<NewsProvider>()
                            .getCategoryNews(widget.categoryName)
                            .then((_) {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            });
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<NewsProvider>().getCategoryNews(
                widget.categoryName,
              ),
              child: ListView.builder(
                itemCount: provider.categoryNews.length,
                itemBuilder: (context, index) =>
                    NewsCard(article: provider.categoryNews[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.article});

  final Map<String, dynamic> article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openArticle(context, article['url']?.toString()),
          child: Row(
            spacing: 15,
            children: [
              NewsImage(url: article['urlToImage']?.toString()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Text(
                        article['title']?.toString() ?? 'Unknown title',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        article['description']?.toString() ??
                            'Unknown description',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsImage extends StatelessWidget {
  const NewsImage({
    super.key,
    required this.url,
    this.height = 110,
    this.width = 110,
  });

  final String? url;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final rawUrl = url?.trim() ?? '';
    final originalUrl = rawUrl.startsWith('//') ? 'https:$rawUrl' : rawUrl;
    final uri = Uri.tryParse(originalUrl);
    final fallback = Image.asset(
      'assets/news_image.jpeg',
      height: height,
      width: width,
      fit: BoxFit.cover,
    );
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return fallback;
    }

    final proxyWidth = width.isFinite ? (width * 2).round() : 600;
    final proxyHeight = width.isFinite ? (height * 2).round() : 300;
    final proxyUrl =
        'https://images.weserv.nl/?url=${Uri.encodeComponent(originalUrl)}&w=$proxyWidth&h=$proxyHeight&fit=cover';

    Widget proxyImage() => Image.network(
      proxyUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );

    return Image.network(
      originalUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => proxyImage(),
    );
  }
}

Future<void> openArticle(
  BuildContext context,
  String? url, {
  LaunchMode mode = LaunchMode.platformDefault,
}) async {
  String message;
  if (url == null || url.trim().isEmpty) {
    message = 'No article URL available';
  } else {
    try {
      if (await launchUrl(Uri.parse(url.trim()), mode: mode)) return;
      message = 'Could not open article link';
    } catch (_) {
      message = 'Could not open article link';
    }
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
