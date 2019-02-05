import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:zgadula/components/screen_loader.dart';
import 'package:zgadula/screens/tutorial.dart';

import 'package:zgadula/store/category.dart';
import 'package:zgadula/store/question.dart';
import 'package:zgadula/screens/settings.dart';
import 'package:zgadula/screens/category_detail.dart';
import 'package:zgadula/components/category_list_item.dart';
import 'package:zgadula/store/tutorial.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() {
    return new HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    if (!isTutorialWatched()) {
      // Cannot navigate instantly
      // https://github.com/flutter/flutter/issues/19330
      Future.delayed(Duration(milliseconds: 10)).then((_) {
        Navigator.pushNamed(
          context,
          '/tutorial',
        );
      });
    }
  }

  bool isTutorialWatched() {
    return TutorialModel.of(context).isWatched;
  }

  Widget buildAppBar(context) {
    return SliverAppBar(
      titleSpacing: 16.0,
      floating: true,
      backgroundColor: Colors.black.withOpacity(0.7),
      title: Text(
        'Zgadula',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      actions: <Widget>[
        // action button
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/settings',
            );
          },
        ),
      ],
    );
  }

  Widget buildContentLoading() {
    return SliverFillRemaining(
      child: ScreenLoader(),
    );
  }

  Widget buildContentLoaded(
    BuildContext context,
    CategoryModel model,
    QuestionModel qModel,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate(
        <Widget>[
          GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.all(0.0),
            crossAxisSpacing: 0.0,
            mainAxisSpacing: 0.0,
            crossAxisCount: 2,
            children: model.categories
                .map(
                  (category) => CategoryListItem(
                        category: category,
                        isFavorite: model.favourites.contains(category.id),
                        onTap: () {
                          model.setCurrent(category);
                          qModel.generateSampleQuestions(category.id);

                          Navigator.pushNamed(
                            context,
                            '/category',
                          );
                        },
                        onFavoriteToggle: () => model.toggleFavorite(category),
                      ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget buildContent(context) {
    return ScopedModelDescendant<CategoryModel>(
        builder: (context, child, model) =>
            ScopedModelDescendant<QuestionModel>(
              builder: (context, child, qModel) {
                if (model.isLoading ||
                    qModel.isLoading ||
                    !isTutorialWatched()) {
                  return buildContentLoading();
                }

                return buildContentLoaded(context, model, qModel);
              },
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          buildAppBar(context),
          buildContent(context),
        ],
      ),
    );
  }
}
