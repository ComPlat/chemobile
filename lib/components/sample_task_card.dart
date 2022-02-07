import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/models/sample_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jovial_svg/jovial_svg.dart';

class SampleTaskCard extends StatefulWidget {
  final SampleTask sampleTask;
  final Function()? onTap;

  const SampleTaskCard({Key? key, required this.sampleTask, this.onTap}) : super(key: key);

  @override
  State<SampleTaskCard> createState() => _SampleTaskCardState();
}

class _SampleTaskCardState extends State<SampleTaskCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          buildSvgImage(),
          ListTile(
            trailing: widget.onTap != null ? const Icon(Icons.chevron_right, size: 36) : null,
            title: Text(widget.sampleTask.title(), textAlign: TextAlign.left, maxLines: 1),
            subtitle: Text(remainingScansText(), textAlign: TextAlign.left, textScaleFactor: 0.8),
            onTap: widget.onTap,
          ),
        ],
      ),
    );
  }

  Widget buildSvgImage() {
    if (widget.sampleTask.sampleSvgFile != null) {
      String svgBaseUrl = BlocProvider.of<AuthCubit>(context).state.currentElnUser!.elnUrl;
      return ScalableImageWidget.fromSISource(
        onLoading: (BuildContext context) => Container(
          padding: const EdgeInsets.all(5.0),
          child: const CircularProgressIndicator(),
        ),
        si: ScalableImageSource.fromSvgHttpUrl(
          widget.sampleTask.sampleSvgUrl(svgBaseUrl),
        ),
      );
    } else {
      return Container();
    }
  }

  String remainingScansText() {
    int remaining = widget.sampleTask.requiredScanResults - widget.sampleTask.scanResults.length;
    if (remaining == 1) {
      return "1 more scan required";
    } else {
      return "$remaining more scans required";
    }
  }
}
