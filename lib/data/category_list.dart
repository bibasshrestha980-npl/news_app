class CategoryModel {
  final String categoryName;
  final String image;

  const CategoryModel({
    required this.categoryName,
    required this.image,
  });
}

const List<CategoryModel> categories = [
  CategoryModel(
    categoryName: "Technology",
    image:
        "https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=500&q=60",
  ),
  CategoryModel(
    categoryName: "Business",
    image:
        "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=500&q=60",
  ),
  CategoryModel(
    categoryName: "Sports",
    image:
        "https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=500&q=60",
  ),
  CategoryModel(
    categoryName: "Entertainment",
    image:
        "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=500&q=60",
  ),
  CategoryModel(
    categoryName: "Science",
    image:
        "https://images.unsplash.com/photo-1507668077129-56e32842fceb?auto=format&fit=crop&w=500&q=60",
  ),
  CategoryModel(
    categoryName: "Health",
    image:
        "https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=500&q=60",
  ),
  CategoryModel(
    categoryName: "General",
    image:
        "https://images.unsplash.com/photo-1495020689067-958852a7765e?auto=format&fit=crop&w=500&q=60",
  ),
];
