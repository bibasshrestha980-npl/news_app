import 'package:flutter/material.dart';
import 'package:news_app/common/common_colors.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;

  const CategoryScreen({super.key, required this.categoryName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NewsProvider>().getCategoryNews(widget.categoryName);
    });
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Consumer<NewsProvider>(
          builder: (context, provider, child) {
            if (provider.isCategoryNewsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.categoryNews.isEmpty) {
              return const Center(
                child: Text(
                  "No news found for this category.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.categoryNews.length,
              itemBuilder: (context, index) =>
                  NewsCard(article: provider.categoryNews[index]),
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
    // Retry through the image proxy if the publisher image cannot load.
    final proxyUrl =
        'https://images.weserv.nl/?url=${Uri.encodeComponent(originalUrl)}&w=$proxyWidth&h=$proxyHeight&fit=cover';

    Widget proxyImage() => Image.network(
      proxyUrl,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );

    return Image.network(
      originalUrl,
      // Browser image elements can display publisher images without CORS headers.
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
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

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final title = news['title']?.toString() ?? 'No Title';
    final description = news['description']?.toString() ?? '';
    final content = news['content']?.toString() ?? '';
    final author = news['author']?.toString();
    final sourceName = news['source'] is Map
        ? news['source']['name']?.toString()
        : null;
    final publishedAt = news['publishedAt']?.toString();
    final url = news['url']?.toString();
    final imageUrl = news['urlToImage'];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          sourceName ?? 'Article Details',
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (url != null && url.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_browser, color: AppColors.newsRed),
              tooltip: 'Open in browser',
              onPressed: () => openArticle(
                context,
                url,
                mode: LaunchMode.externalApplication,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: NewsImage(
                url: imageUrl?.toString(),
                height: 240,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (sourceName != null && sourceName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.newsRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sourceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (sourceName != null && sourceName.isNotEmpty)
                  const SizedBox(width: 10),
                if (publishedAt != null && publishedAt.isNotEmpty)
                  Text(
                    publishedAt.length >= 10
                        ? publishedAt.substring(0, 10)
                        : publishedAt,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            if (author != null && author.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'By $author',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

            const Divider(),
            const SizedBox(height: 12),
            if (description.isNotEmpty)
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 16),
            if (content.isNotEmpty && content != description)
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade800,
                ),
              ),
            const SizedBox(height: 32),
            if (url != null && url.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.newsRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.launch, color: Colors.white),
                  label: const Text(
                    'Read Full Article on Web',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => openArticle(
                    context,
                    url,
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
