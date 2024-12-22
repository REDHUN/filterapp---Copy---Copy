import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_models/filter_view_model.dart';
import 'views/filter_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FilterViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Restaurant Filter',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const FilterScreen(),
      ),
    );
  }
}
