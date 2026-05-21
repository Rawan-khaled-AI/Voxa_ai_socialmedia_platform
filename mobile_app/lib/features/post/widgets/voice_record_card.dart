import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class VoiceRecordCard extends StatefulWidget {
  final bool isRecording;
  final bool isPlaying;

  final String duration;

  final VoidCallback? onDelete;
  final VoidCallback? onPrimary;
  final VoidCallback? onDone;

  const VoiceRecordCard({
    super.key,
    required this.isRecording,
    required this.isPlaying,
    required this.duration,
    this.onDelete,
    this.onPrimary,
    this.onDone,
  });

  @override
  State<VoiceRecordCard> createState() =>
      _VoiceRecordCardState();
}

class _VoiceRecordCardState
    extends State<VoiceRecordCard>
    with SingleTickerProviderStateMixin {

  late final AnimationController controller;

  final random = Random();

  late List<double> bars;

  @override
  void initState() {

    super.initState();

    bars = List.generate(
      14,
      (_) => 20,
    );

    controller =
        AnimationController(

      vsync: this,

      duration:
          const Duration(
        milliseconds: 180,
      ),
    );

    controller.addListener(() {

      if (
          !widget
              .isRecording) {
        return;
      }

      for (
          int i = 0;
          i <
              bars.length;
          i++) {

        bars[i] = (

          14 +

          random.nextInt(
            26,
          )

        ).toDouble();
      }

      if (
          mounted &&
          controller
                  .value >
              .8) {

        setState(() {});
      }
    });

    controller.repeat();
  }

  @override
  void dispose() {

    controller.dispose();

    super.dispose();
  }

  IconData get _primaryIcon {

    if (
        widget
            .isRecording) {

      return Icons.stop;
    }

    if (
        widget
            .isPlaying) {

      return Icons.pause;
    }

    return Icons.play_arrow;
  }

  String get _title {

    if (
        widget
            .isRecording) {

      return
          'Recording Active';
    }

    if (
        widget
            .isPlaying) {

      return
          'Playing Voice';
    }

    return 'Voice Ready';
  }

  @override
  Widget build(
      BuildContext context) {

    return Container(

      margin:
          const EdgeInsets.only(
        top: 16,
        bottom: 16,
      ),

      padding:
          const EdgeInsets.all(
        22,
      ),

      decoration:
          BoxDecoration(

        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black
                    .withOpacity(
              .03,
            ),

            blurRadius:
                18,

            offset:
                const Offset(
              0,
              6,
            ),
          ),
        ],
      ),

      child: Column(

        children: [

          Text(

            _title,

            style:
                const TextStyle(

              fontSize:
                  18,

              fontWeight:
                  FontWeight.bold,

              color:
                  AppColors
                      .textDark,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          SizedBox(

            height: 46,

            child: Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .center,

              children:
                  List.generate(

                bars.length,

                (index) {

                  return Padding(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal:
                          2,
                    ),

                    child:
                        AnimatedContainer(

                      duration:
                          const Duration(
                        milliseconds:
                            120,
                      ),

                      width: 5,

                      height:

                          widget
                                  .isRecording

                              ? bars[
                                  index]

                              : 20,

                      decoration:
                          BoxDecoration(

                        gradient:
                            const LinearGradient(

                          colors: [

                            Color(
                              0xFFC77DFF,
                            ),

                            Color(
                              0xFFAF69FF,
                            ),
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          999,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Text(

            widget.duration,

            style:
                const TextStyle(

              fontSize:
                  24,

              fontWeight:
                  FontWeight.bold,

              color:
                  AppColors
                      .primary,
            ),
          ),

          const SizedBox(
            height: 26,
          ),

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceEvenly,

            children: [

              GestureDetector(

                onTap:
                    widget
                        .onDelete,

                child:
                    _smallCircle(

                  Icons
                      .delete_outline,

                  Colors.red,
                ),
              ),

              GestureDetector(

                onTap:
                    widget
                        .onPrimary,

                child:
                    Container(

                  width: 72,

                  height: 72,

                  decoration:
                      const BoxDecoration(

                    shape:
                        BoxShape.circle,

                    gradient:
                        LinearGradient(

                      colors: [

                        Color(
                          0xFFC77DFF,
                        ),

                        Color(
                          0xFFAF69FF,
                        ),
                      ],
                    ),
                  ),

                  child: Icon(

                    _primaryIcon,

                    color:
                        Colors.white,

                    size: 34,
                  ),
                ),
              ),

              GestureDetector(

                onTap:
                    widget
                        .onDone,

                child:
                    _smallCircle(

                  Icons.check,

                  AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallCircle(
    IconData icon,
    Color color,
  ) {

    return Container(

      width: 56,

      height: 56,

      decoration:
          const BoxDecoration(

        shape:
            BoxShape.circle,

        color:
            Color(
          0xFFF3E8FF,
        ),
      ),

      child: Icon(
        icon,
        color: color,
      ),
    );
  }
}