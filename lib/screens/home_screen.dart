import 'package:flutter/material.dart';
import 'package:news_app/common/common_colors.dart';
import 'package:news_app/data/category_list.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/screens/category_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NewsProvider>().getTrendingNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("World", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
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
        child: Column(
          spacing: 20,
          children: [
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoryScreen(categoryName: categories[index]),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Colors.redAccent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        width: 150,
                        height: 100,
                        child: Center(
                          child: Text(
                            categories[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Trending news!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: Consumer<NewsProvider>(
                builder: (context, provider, child) {
                  return provider.isTrendingNewsLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: provider.trendingNews.length,
                          itemBuilder: (context, index) =>
                              NewsCard(article: provider.trendingNews[index]),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
