import 'package:expense_tracker/constants/app_constants.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import '../../constants/extension.dart';
import '../../router/route_name.dart';
import '../widgets/carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final List<String> _carouselImages = [
    ImagePathConstants.barGraph,
    ImagePathConstants.calculator,
    ImagePathConstants.coins,
    ImagePathConstants.money,
    ImagePathConstants.moneyManagement
  ];

  final List<String> _slogans = AppConstants.slogans;
  String item = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: "Home Page"),
      body: Column(
        children: [
          CustomCarousel(
            imagePaths: _carouselImages,
            carouselHeight: 50,
            autoPlay: true,
            showDot: true,
            headerBuilder: (index) {
              return SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    _slogans[index],
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),


          SizedBox(height: context.getPercentHeight(15)),
          Expanded(
            child: Center(
              child:Column(
                children: [
                  context.navigationButton(
                    text: "Sign In",
                    onBtnPress: () => context.goTo(RouteName.login),
                    canNavigate: true),
                  SizedBox(height: context.getPercentHeight(5)),
                  context.navigationButton(
                    text: "Registeration",
                    onBtnPress: () => context.goTo(RouteName.registeration),
                    canNavigate: true
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
