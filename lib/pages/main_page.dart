import 'package:dr_drugs/pages/add_meds_page.dart';
import 'package:dr_drugs/pages/contact_page.dart';
import 'package:dr_drugs/pages/schedule_page.dart';
import 'package:dr_drugs/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:dr_drugs/widgets/custom_bottom_navbar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    SchedulePage(),
    AddMedsPage(),
    ContactPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: pages[currentIndex],

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}