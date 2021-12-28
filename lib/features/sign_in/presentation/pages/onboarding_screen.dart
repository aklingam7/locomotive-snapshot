import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    _pageController.addListener(() {
      if (_pageController.page! % 1 == 0) setState(() {});
    });
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.55,
      height: MediaQuery.of(context).size.height * 0.55,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: PageView(
              controller: _pageController,
              children: const [
                SingleOnboardingPage(
                  text:
                      "Create trains for tasks like your upcoming history exam or your summer project",
                  image: "assets/images/onboarding_1.png",
                ),
                SingleOnboardingPage(
                  text:
                      "Add 'coal' to a train's car on a specific day to allocate time to work on it",
                  image: "assets/images/onboarding_2.png",
                ),
                SingleOnboardingPage(
                  text:
                      "Tap on the train's locomotive to see and change its details",
                  image: "assets/images/onboarding_3.png",
                ),
                SingleOnboardingPage(
                  text:
                      "Scroll through the trains to see how much time you are spending on your tasks and when",
                  image: "assets/images/onboarding_4.png",
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: _pageController.hasClients && _pageController.page == 3
                ? ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Get Started!"),
                  )
                : ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: const Text("Next"),
                  ),
          ),
        ],
      ),
    );
  }
}

class SingleOnboardingPage extends StatelessWidget {
  const SingleOnboardingPage({
    Key? key,
    required this.text,
    required this.image,
    //required this.button,
  }) : super(key: key);

  final String text;
  final String image;
  //final Widget button;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          image,
          fit: BoxFit.contain,
        ),
        Positioned(
          top: 20,
          right: 25,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Card(
                elevation: 9,
                color: Theme.of(context).cardColor.withAlpha(160),
                shadowColor: const Color(0xA0000000),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
