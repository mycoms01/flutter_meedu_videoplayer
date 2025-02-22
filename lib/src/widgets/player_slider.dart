import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:flutter/semantics.dart';

class PlayerSlider extends StatelessWidget {
  const PlayerSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = MeeduPlayerController.of(context);
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        LayoutBuilder(builder: (ctx, constraints) {
          return RxBuilder(
            //observables: [_.buffered, _.duration],
            (__) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: Colors.white30,
                width: constraints.maxWidth * _.bufferedPercent.value,
                height: 3,
              );
            },
          );
        }),
        RxBuilder(
          //observables: [_.sliderPosition, _.duration],
          (__) {
            int value = _.sliderPosition.value.inSeconds;
            final double max = _.duration.value.inSeconds.toDouble();
            if (value > max || max <= 0) {
              return Container();
            }
            return Container(
              constraints: const BoxConstraints(
                maxHeight: 30,
              ),
              padding: const EdgeInsets.only(bottom: 8),
              alignment: Alignment.center,
              child: SliderTheme(
                data: SliderThemeData(
                  trackShape: MSliderTrackShape(),
                  thumbColor: _.colorTheme,
                  activeTrackColor: _.colorTheme,
                  trackHeight: 10,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 4.0),
                ),
                child: Semantics(
                  slider: true,
                  excludeSemantics: true,
                  onIncrease: () async {
                    value = (_.sliderPosition.value.inSeconds + 10);
                    _.seekTo(Duration(seconds: value));
                    await Future<void>.delayed(
                        const Duration(milliseconds: 300), () {
                      SemanticsService.announce(
                          "ตำแหน่งในการเล่น ${printDuration(Duration(seconds: value))}",
                          TextDirection.ltr);
                    });
                  },
                  onDecrease: () async {
                    value = (_.sliderPosition.value.inSeconds - 10);
                    _.seekTo(Duration(seconds: value));
                    await Future<void>.delayed(
                        const Duration(milliseconds: 300), () {
                      SemanticsService.announce(
                          "ตำแหน่งในการเล่น ${printDuration(Duration(seconds: value))}",
                          TextDirection.ltr);
                    });
                    // SemanticsService.announce(
                    //     "ตำแหน่งในการเล่น ${printDuration(Duration(seconds: value))}");
                  },
                  child: Slider(
                    min: 0,
                    divisions: _.duration.value.inSeconds,
                    value: value.toDouble(),
                    onChangeStart: (v) {
                      _.onChangedSliderStart();
                    },
                    onChangeEnd: (v) {
                      _.onChangedSliderEnd();
                      _.seekTo(
                        Duration(seconds: v.floor()),
                      );
                    },
                    label: printDuration(_.sliderPosition.value),
                    semanticFormatterCallback: (double newValue) {
                      return "ตำแหน่งในการเล่น ${printDuration(_.sliderPosition.value)}";
                    },
                    max: max,
                    onChanged: _.onChangedSlider,
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}

class MSliderTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData? sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 1;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2 + 4;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
