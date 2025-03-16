import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MyPieChart extends StatelessWidget {
  final Color bgColor;
  final String title;
  final double chartValue;
  final bool isRatingChart;

  const MyPieChart(
      {Key? key,
      this.bgColor = Colors.white,
      required this.title,
      this.isRatingChart = false,
      required this.chartValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.1,
            backgroundColor: isRatingChart && chartValue == 0
                ? Colors.green
                : isRatingChart
                    ? chartValue <= 3
                        ? Colors.red
                        : Colors.green
                    : !isRatingChart && chartValue <= 75
                        ? Colors.red
                        : Colors.green,
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.1 - 2,
              backgroundColor: isRatingChart && chartValue == 0
                  ? Colors.grey.shade200
                  : bgColor,
              child: Text(
                isRatingChart && chartValue == 0
                    ? 'Not rated yet.'
                    : '${isRatingChart ? chartValue.toStringAsFixed(1) : chartValue.toInt()}${isRatingChart ? '' : '%'}',
                style: kInputStyle.copyWith(
                  fontSize: isRatingChart && chartValue == 0
                      ? MediaQuery.of(context).size.width * 0.03
                      : MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ).tr(),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Text(
            title,
            style: kInputStyle.copyWith(fontSize: 15),
            textAlign: TextAlign.center,
          ).tr(),
        ],
      ),
    );
  }
}
