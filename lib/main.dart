import 'package:flutter/material.dart';  // 卡片风格

import './pages/index_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: '百姓生活家',
        debugShowCheckedModeBanner: false,  // 去除debug的图标
        theme: ThemeData(  // 主题色
          primaryColor: Colors.pink,
        ),
        home: IndexPage()
      ),
    );
  }
}