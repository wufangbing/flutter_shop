import 'package:flutter/material.dart';  // 卡片风格
import 'dart:convert';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/service_method.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{  // 添加缓存

  int page = 1;
  List<Map> hotGoodList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _gotHotFoods();
  }


  get formData => null;

  void _gotHotFoods() {
    var formPage = { 'page': page };
    request('homePageBelowConten', formData: formPage).then((val) {
      var data = json.decode(val.toString());
      List<Map> newGoodsList = (data['data'] as List).cast();
      setState(() {
        hotGoodList.addAll(newGoodsList);
        page++;
      });
    });
  }

  Widget hotTitle = Container(
    margin: EdgeInsets.only(top: 10.0),
    padding: EdgeInsets.all(5.0),
    alignment: Alignment.center,
    color: Colors.transparent,
    child: Text('火爆专区'),
  );

  Widget _wrapList() {
    if(hotGoodList.length != 0) {
      List<Widget> listWidget = hotGoodList.map((val) {
        return InkWell(
          onTap: () {},
          child: Container(
            width: ScreenUtil().setWidth(372),
            color: Colors.white,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(bottom: 3.0),
            child: Column(
              children: <Widget>[
                Image.network(val['image'], width: ScreenUtil().setWidth(370.0),),
                Text(
                  val['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: ScreenUtil().setSp(26.0)
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '￥${val['mallPrice']}',
                    ),
                    Text(
                      '￥${val['price']}',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.black26
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }).toList();
      // 流式布局
      return Wrap(
        spacing: 2,
        children: listWidget,
      );
    } else {
      return Text('加载中...');
    }
  }

  Widget _hotGoods() {
    return Container(
      child: Column(
        children: <Widget>[
          hotTitle,
          _wrapList(),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(title: Text('百姓生活+'),),
        body: FutureBuilder(
          future: request('homePageContent', formData: {'lon': '115.02932', 'lat': '35.76189' }),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              var data = json.decode(snapshot.data.toString());
              List<Map> swiper = (data['data']['slides'] as List).cast();
              List<Map> navigatorList = (data['data']['category'] as List).cast();
              String adPicture = data['data']['advertesPicture']['PICTURE_ADDRESS'];

              String leaderImage = data['data']['shopInfo']['leaderImage'];
              String leaderPhone = data['data']['shopInfo']['leaderPhone'];
              List<Map> recommendList = (data['data']['recommend'] as List).cast();
              String floor1Title = data['data']['floor1Pic']['PICTURE_ADDRESS'];
              List<Map> floor1 = (data['data']['floor1'] as List).cast();

              return SingleChildScrollView(
                child: Column(children: <Widget>[
                  SwiperDiy(swiperDataList: swiper),
                  TopNavigator(navigatorList: navigatorList),
                  AdBanner(adPicture: adPicture),
                  LeaderPhone(leaderImage: leaderImage, leaderPhone: leaderPhone),
                  Recommend(recommendList: recommendList),
                  FloorTitle(pictureAddress: floor1Title),
                  FloorContent(floorFoodsList: floor1),
                  _hotGoods(),
                ],),
              );
            } else {
              return Center(
                child: Text('加载中....'),
              );
            }
          },
        )
      )
    );
  }
}

// 轮播组件
class SwiperDiy extends StatelessWidget {
  final List swiperDataList ;

  SwiperDiy({Key key, this.swiperDataList}): super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      height: ScreenUtil().setHeight(333.0),
      width: ScreenUtil().setWidth(750.0),
      child: Swiper(
        itemBuilder: (BuildContext content, int index) {
          return Image.network(
            "${swiperDataList[index]['image']}",
            fit: BoxFit.fill,
          );
        },
        itemCount: swiperDataList.length,
        pagination: SwiperPagination(),
        autoplay: true,
      )
    );
  }

}

// 顶部导航
class TopNavigator extends StatelessWidget {
  final List navigatorList;

  TopNavigator({
    Key key,
    this.navigatorList
  }):super(key: key);

  Widget _gridViewItemUI(BuildContext context, item) {
    return InkWell(
      onTap: () {print('点击导航');},
      child: Column(
        children: <Widget>[
          Image.network(item['image'], width: ScreenUtil().setWidth(95.0),),
          Text(item['mallCategoryName'])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(navigatorList.length >10) {
      navigatorList.removeRange(10, navigatorList.length);
    }
    return Container(
      height: ScreenUtil().setWidth(320.0),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
        crossAxisCount: 5,
        padding: EdgeInsets.all(5.0),
        children: navigatorList.map((item) {
          return _gridViewItemUI(context, item);
        }).toList()
      ),
    );
  }

}

// 广告
class AdBanner extends StatelessWidget {
  final String adPicture;
  AdBanner({
    Key key,
    this.adPicture
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(adPicture),
    );
  }
}

// 店长电话
class LeaderPhone extends StatelessWidget {
  final String leaderImage;
  final String leaderPhone;

  LeaderPhone({
    Key key,
    this.leaderImage,
    this.leaderPhone
  }):super(key: key);

  // 发射请求打电话,email
  void _launchUrl() async {
    String url = 'tel:' + leaderPhone;
    if(await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'url不能进行访问';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launchUrl,
        child: Image.network(leaderImage),
      )
    );
  }
}

// 商品推荐类
class Recommend extends StatelessWidget {
  final List recommendList;
  Recommend({
    Key key,
    this.recommendList
  }) : super(key: key);

  Widget _titleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 0, 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 0.5, color: Colors.black12, style: BorderStyle.solid),
        )
      ),
      child: Text(
        '商品推荐',
        style: TextStyle(color: Colors.pink),
      ),
    );
  }

  // 商品单独项目
  Widget _item(index) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: ScreenUtil().setWidth(250.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(width: 1, color: Colors.black12, style: BorderStyle.solid),
          )
        ),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index]['image']),
            Text('￥${recommendList[index]['mallPrice']}'),
            Text(
              '￥${recommendList[index]['price']}',
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey
              ),
            )
          ],
        ),
      )
    );
  }

  // 横向列表方法
  Widget _recommendList() {
    return Container(
      height: ScreenUtil().setHeight(350.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendList.length,
        itemBuilder: (context, index) {
          return _item(index);
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(420.0),
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          _titleWidget(),
          _recommendList()
        ],
      ),
    );
  }}
  
// 楼层标题
class FloorTitle extends StatelessWidget {
  final String pictureAddress;
  FloorTitle({
    Key key,
    this.pictureAddress
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Image.network(pictureAddress),
    );
  }
}

// 楼层商品列表
class FloorContent extends StatelessWidget {
  final List floorFoodsList;
  FloorContent({
    Key key,
    this.floorFoodsList
  }) : super(key: key);

  Widget _goodsItem(Map goods) {
    return Container(
      width: ScreenUtil().setWidth(375.0),
      child: InkWell(
        onTap: () {},
        child: Image.network(goods['image']),
      ),
    );
  }

  Widget _firstRow() {
    return Row(
      children: <Widget>[
        _goodsItem(floorFoodsList[0]),
        Column(
          children: <Widget>[
            _goodsItem(floorFoodsList[1]),
            _goodsItem(floorFoodsList[2]),
          ],
        )
      ],
    );
  }

  Widget _otherGoods() {
    return Row(
      children: <Widget>[
        _goodsItem(floorFoodsList[3]),
        _goodsItem(floorFoodsList[4]),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child:  Column(
          children: <Widget>[
            _firstRow(),
            _otherGoods()
          ],
        ),
      )
    );
  }
}

//// 热门商品
//class HotGoods extends StatefulWidget {
//  @override
//  _HotGoodsState createState() => _HotGoodsState();
//}
//
//class _HotGoodsState extends State<HotGoods> {
//  @override
//  void initState() {
//    request('homePageBelowConten', formData: {'page': 1}).then((val) {
//      print(val);
//    });
//    super.initState();
//  }
//  @override
//  Widget build(BuildContext context) {
//    return Text('wfb');
//  }
//}




