import 'package:dr_drugs/pages/add_meds_page.dart';
import 'package:dr_drugs/pages/contact_page.dart';
import 'package:dr_drugs/pages/schedule_page.dart';
import 'package:dr_drugs/utils/colors.dart';
import 'package:dr_drugs/utils/navbar_page_transition.dart';
import 'package:flutter/material.dart';
import 'package:dr_drugs/widgets/custom_bottom_navbar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  int previousIndex = 0;

  final List<Widget> pages = [
    SchedulePage(),
    AddMedsPage(),
    ContactPage(),
  ];

  void changePage(int index) {
    if (index == currentIndex) return;

    setState(() {
      previousIndex = currentIndex;
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: NavbarPageTransition(
        currentIndex: currentIndex,
        previousIndex: previousIndex,
        child: pages[currentIndex],
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: changePage
      ),
    );
  }
}