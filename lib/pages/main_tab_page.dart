import 'package:flutter/material.dart';
import 'home_page.dart';

class MainTabPage extends StatefulWidget {
  final TabController tabController;
  const MainTabPage({super.key, required this.tabController});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  final List<Tab> myTabs = const [
    Tab(text: 'Home'),
    Tab(text: 'Notices'),
    Tab(text: 'Blog'),
    Tab(text: 'Courses'),
    Tab(text: 'Model Questions'),
  ];

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: const [
        HomePage(),
      ],
    );
  }
}
