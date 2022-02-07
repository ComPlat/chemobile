import 'dart:io';

import 'package:chemobile/components/MultiLineAppBar.dart';
import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/models/eln_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({Key? key, required this.title, required this.image}) : super(key: key);
  final String title;
  final File image;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MultiLineAppBar(
        title: widget.title,
        subtitle: currentUser(context)!.fullName,
      ),
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 3.0,
          child: Image.file(widget.image, fit: BoxFit.cover),
        ),
      ),
    );
  }

  ElnUser? currentUser(BuildContext context) {
    return BlocProvider.of<AuthCubit>(context).state.currentElnUser;
  }
}
