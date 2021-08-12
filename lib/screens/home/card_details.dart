import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
// import 'package:chart_components/bar_chart_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finshare/core/customized_chart.dart';
import 'package:finshare/models/card_data.dart';
import 'package:finshare/screens/home/add_credit_card.dart';
import 'package:finshare/screens/home/add_new_user.dart';
import 'package:finshare/screens/home/user_details.dart';
import 'package:finshare/util/colors.dart';
import 'package:finshare/util/data_repo.dart';
import 'package:finshare/util/my_credit_card.dart';
import 'package:finshare/util/my_svg_painter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';

class CardDetails extends StatefulWidget {
  const CardDetails({Key? key, required this.card_number, required this.color}) : super(key: key);
  final String? card_number;
  final Color color;

  @override
  _CardDetailsState createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  List<double> data = [];
  List<String> labels = [];
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    DataRepository.clearData();
    _loadData();
  }

  List<Color> _userColors = [
    Color.fromRGBO(225, 230, 233, 1),
    Color.fromRGBO(197, 204, 255, 1),
    Color.fromRGBO(1, 1, 1, 1),
    Color.fromRGBO(252, 217, 228, 1),
    Color.fromRGBO(233, 250, 245, 1),
    Color.fromRGBO(248, 242, 210, 1)
  ];

  void _loadData() {
    setState(() {
      if (!loaded) {
        data = DataRepository.getData();
        loaded = true;
      } else {
        data[data.length - 1] = (math.Random().nextDouble() * 700).round() / 100;
      }
      labels = DataRepository.getLabels();
    });
  }

  Future<CardData> _getCard() async {
    DocumentSnapshot _ds = await FirebaseFirestore.instance.collection('cards').doc(widget.card_number).get();
    CardData _cardData = CardData.fromJson(jsonDecode(jsonEncode(_ds.data())));
    return _cardData;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('cards').doc(widget.card_number).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData == false)
              return Container(
                  constraints: BoxConstraints.expand(),
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Colors.black,
                    backgroundColor: AppColors.background,
                  )));

            CardData? _cardData = CardData.fromJson(jsonDecode(jsonEncode(snapshot.data?.data())));

            return ListView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 44),
              children: [
                Hero(
                    transitionOnUserGestures: true,
                    tag: _cardData.cARDNUMBER ?? "",
                    child: Material(
                        type: MaterialType.transparency, // likely needed
                        child: MyCreditCard(color: widget.color.withAlpha(400), card_number: _cardData.cARDNUMBER))),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                SizedBox(
                  height: screenWidth / 4.5,
                  child: ListView.builder(
                      padding: const EdgeInsets.only(right: 16.0),
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      itemCount: (_cardData.members?.length ?? 0) + 2,
                      itemBuilder: (context, index) {
                        return (index < (_cardData.members?.length ?? 0) + 2 - 1)
                            ? InkWell(
                                onTap: () {
                                  if (index != 0)
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => UserDetails(
                                              index: index - 1,
                                              cardNumber: _cardData.cARDNUMBER,
                                              memData: _cardData.members![index - 1],
                                            )));
                                },
                                child: Container(
                                  height: screenWidth / 4.5,
                                  width: screenWidth / 4.5,
                                  margin: EdgeInsets.only(left: 16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02, vertical: screenWidth * 0.02),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: CircleAvatar(
                                              child: (index == 0)
                                                  ? Text(
                                                      "Y",
                                                      style: TextStyle(color: Colors.white),
                                                    )
                                                  : MyAva(members: _cardData.members![index - 1]),
                                              backgroundColor: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            (index == 0) ? "You" : _cardData.members![index - 1]!.name ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => AddNewUser(
                                            cardData: _cardData,
                                          )));
                                },
                                child: Container(
                                  height: screenWidth / 4.5,
                                  width: screenWidth / 4.5,
                                  margin: EdgeInsets.only(left: 16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Colors.blue.withAlpha(300),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.black,
                                            size: 34.0,
                                          ),
                                          Text(
                                            "Add new user",
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                      }),
                ),
                // SizedBox(
                //   height: 16.0,
                // ),
                // SizedBox(
                //   height: screenHeight * 0.1,
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: Container(
                //           margin: EdgeInsets.only(left: 16.0, right: 8.0),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(7),
                //             color: Colors.white,
                //           ),
                //           child: Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [
                //                 Text(
                //                   "Card balance",
                //                   style: TextStyle(fontSize: 16.0),
                //                 ),
                //                 Text(
                //                   "\$1,804.3",
                //                   style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w900),
                //                 ),
                //                 Text(
                //                   "\$16,804.3 available",
                //                   style: TextStyle(fontSize: 11.0, color: Colors.grey, fontWeight: FontWeight.w900),
                //                 )
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         child: Container(
                //           margin: EdgeInsets.only(left: 8.0, right: 16.0),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(7),
                //             color: Colors.white,
                //           ),
                //           child: Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [
                //                 Text(
                //                   "Permissions",
                //                   style: TextStyle(fontSize: 16.0),
                //                 ),
                //                 FloatingActionButton.extended(
                //                     elevation: 0.0, onPressed: () {}, label: Icon(Icons.arrow_forward))
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: 16.0),
                Container(
                  height: screenHeight * 0.32,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 0, left: 8, right: 8, top: 8),
                        child: Column(
                          children: [
                            Text(
                              "Total Spending",
                              style: TextStyle(fontSize: 12.0, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "\$1,804.3",
                              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: BarChart(
                          users: 3,
                          data: [
                            [30.49, 72.42, 12.76],
                            [5.49, 90.42, 76.76],
                            [40.0, 40.0, 20]
                          ],
                          labels: labels,
                          labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          valueStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                          displayValue: true,
                          reverse: true,
                          userColors: List.generate(3, (index) => _userColors[index % _userColors.length]).toList(),

                          // getIcon: DataRepository.getIcon,
                          barWidth: 24,
                          barSeparation: 14,
                          animationDuration: Duration(milliseconds: 800),
                          animationCurve: Curves.easeInOutSine,
                          itemRadius: 3.5,
                          iconHeight: 22,
                          footerHeight: 24,
                          headerValueHeight: 16,
                          roundValuesOnText: false,
                          lineGridColor: AppColors.background,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),

                SizedBox(
                  height: 16.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Latest Transactions",
                        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w900, color: AppColors.text),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      (_cardData.allTransactions?.length ?? 0) > 0
                          ? ListBody(
                              children: List.generate(
                                  _cardData.allTransactions?.length ?? 0,
                                  (index) => TransactionCard(
                                        title: "La Colombe Coffee",
                                        subTitle: "\$18.50",
                                        leading: CircleAvatar(
                                          child: Text(
                                            "A",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.black,
                                        ),
                                        time: "Yesterday",
                                        onPressed: () {},
                                      )),
                            )
                          : Container(
                              height: 56.0,
                              child: Center(
                                child: Text(
                                  "No Recent transactions found",
                                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                                ),
                              ))
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class MyAva extends StatefulWidget {
  const MyAva({Key? key, required this.members}) : super(key: key);
  final Members? members;
  @override
  _MyAvaState createState() => _MyAvaState();
}

class _MyAvaState extends State<MyAva> {
  DrawableRoot? _svgRoot;
  Future<dynamic> _getSvg() async {
    await svg
        .fromSvgString(widget.members!.avatarCode ?? "", widget.members!.avatarCode ?? "")
        .then((value) => _svgRoot = value);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getSvg(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData == false) return SizedBox.expand();
        return CircleAvatar(
            child: CustomPaint(
          painter: MyPainter(_svgRoot, Size(20.0, 20.0)),
          child: Container(),
        ));
      },
    );
  }
}

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.onPressed,
    required this.leading,
    required this.time,
  }) : super(key: key);

  final String title;
  final String subTitle;
  final Function onPressed;
  final Widget leading;
  final String time;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.09,
      child: Card(
        elevation: .2,
        shadowColor: AppColors.shadow,
        margin: EdgeInsets.only(top: 2.5),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(flex: 2, child: this.leading),
              Expanded(
                  flex: 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            this.title,
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900, color: AppColors.text),
                          ),
                          Text(
                            this.subTitle,
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Chicago, IL",
                                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: Colors.grey),
                              ),
                              Text(
                                this.time,
                                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: Colors.grey),
                              ),
                            ],
                          ),
                          Text(
                            "2%",
                            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  )),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    this.onPressed;
                  },
                  child: Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
