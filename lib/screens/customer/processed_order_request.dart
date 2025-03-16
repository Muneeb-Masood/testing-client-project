// ignore_for_file: use_build_context_synchronously

import 'package:test/models/order.dart';
import 'package:test/networking/api_helper.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/steps_screen.dart';
import 'package:test/screens/tailor/tailor_profile.dart';
import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ProcessedOrderRequestPage extends StatefulWidget {
  ProcessedOrderRequestPage({Key? key, required this.orderRequests})
      : super(key: key);
  final List<AcceptedOrDeclinedOrderRequest> orderRequests;

  @override
  State<ProcessedOrderRequestPage> createState() =>
      _ProcessedOrderRequestPageState();
}

class _ProcessedOrderRequestPageState extends State<ProcessedOrderRequestPage> {
  final helper = FireStoreHelper();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    helper.makeOrderRequestsSeen(widget.orderRequests);
    helper.deleteOrderRequestsIfOlderThanMonth(widget.orderRequests);
    return LoadingOverlay(
      isLoading: isLoading,
      progressIndicator: kSpinner(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('My Order requests').tr(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.orderRequests.isEmpty
              ? Center(
                  child: Text(
                    'No requests made.',
                    style: kTextStyle.copyWith(
                        color: Colors.grey.shade400, fontSize: 20),
                  ).tr(),
                )
              : ListView.separated(
                  itemCount: widget.orderRequests.length,
                  separatorBuilder: (context, index) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01),
                  itemBuilder: (context, index) => Card(
                    color: kSkinColor,
                    margin: const EdgeInsets.all(5),
                    elevation: 3.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        isThreeLine: true,
                        // onTap: () {},
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.orderRequests[index].isCustomizationOnly)
                              Text("customization order request",
                                      style: kBoldTextStyle())
                                  .tr(),
                            if (widget.orderRequests[index].isCustomizationOnly)
                              const Divider(
                                color: kDarkOrange,
                                endIndent: 20,
                              ),
                            Text(
                              getCategory(
                                  widget.orderRequests[index].dressItem),
                              style: const TextStyle(fontSize: 20),
                            ).tr(),
                          ],
                        ),
                        subtitle: DefaultTextStyle(
                          style: const TextStyle(color: Colors.black),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: size.height * 0.005),
                              SizedBox(
                                height: size.height * 0.03,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  onPressed: () async {
                                    if (mounted) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                    }
                                    final tailor =
                                        await helper.getTailorWithDocId(widget
                                            .orderRequests[index].tailorDocId);
                                    if (mounted) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TailorProfile(tailor: tailor!),
                                      ),
                                    );
                                  },
                                  child: FutureBuilder(
                                      future: ApiHelper.translateText(widget
                                          .orderRequests[index].tailorShopName),
                                      builder: (_, st) {
                                        return Text(
                                          getTranslatedText(
                                              st.data ?? '..',
                                              widget.orderRequests[index]
                                                  .tailorShopName),
                                          style: reminderButtonStyle,
                                        );
                                      }),
                                ),
                              ),
                              SizedBox(height: size.height * 0.005),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('status: ').tr(),
                                  widget.orderRequests[index].status == 0
                                      ? Text(
                                          getTranslatedText(
                                              "رد ہو گئی ہے", 'Declined'),
                                          style: kBoldTextStyle().copyWith(
                                              color: Colors.red.shade400),
                                        )
                                      : Text(
                                          getTranslatedText(
                                              "قبول ہو گئی ہے", 'Accepted'),
                                          style: kBoldTextStyle().copyWith(
                                              color: Colors.green.shade400),
                                        ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.005),
                              FutureBuilder(
                                  future: ApiHelper.translateText(Jiffy.parse(widget
                                          .orderRequests[index].requestDate)
                                      .yMMMMEEEEd),
                                  builder: (_, st) {
                                    final dt = Jiffy.parse(widget
                                            .orderRequests[index].requestDate)
                                        .yMMMMEEEEd;
                                    return Text(
                                        '${getTranslatedText("جمع کروانے کی تاریخ: ", "submitted on:")} ${getTranslatedText(st.data ?? '..', dt)}');
                                  }),
                              SizedBox(height: size.height * 0.005),
                              widget.orderRequests[index].status == 0
                                  ? FutureBuilder(
                                      future: ApiHelper.translateText(widget
                                          .orderRequests[index]
                                          .reasonIfDeclined!),
                                      builder: (_, st) {
                                        return Text(
                                          getTranslatedText(
                                              "وجہ: ${st.data ?? '..'}",
                                              "reason: ${widget.orderRequests[index].reasonIfDeclined}"),
                                          style: TextStyle(
                                              color: Colors.grey.shade700),
                                        );
                                      })
                                  : TextButton(
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero),
                                      onPressed: () async {
                                        if (mounted) {
                                          setState(() {
                                            isLoading = true;
                                          });
                                        }
                                        final order = await helper
                                            .getOrderWithOrderId(widget
                                                .orderRequests[index]
                                                .orderIdIfAccepted!);
                                        if (mounted) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                        //if order has been placed => if customer has already placed order that means he has performd steps screen
                                        if (order?.cloth != null) {
                                          helper.deleteOrderRequest(
                                              widget.orderRequests[index]);
                                          Fluttertoast.showToast(
                                            textColor: Colors.white,
                                            backgroundColor: kOrangeColor,
                                            msg: getTranslatedText(
                                                "آرڈر پہلے ہی دیا جا چکا ہے، آرڈر کی درخواست ڈلیٹ کر دی گئی ہے۔",
                                                'Order already placed, deleting order request.'),
                                          );
                                          Navigator.pop(context);
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StepsScreen(order: order!),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        "Proceed order",
                                        style: reminderButtonStyle,
                                      ).tr(),
                                    ),
                            ],
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(5),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FutureBuilder(
                                future: ApiHelper.translateText(
                                    Jiffy.parse(widget.orderRequests[index].createdOn)
                                        .fromNow()),
                                builder: (_, st) {
                                  return Text(
                                    getTranslatedText(
                                        st.data ?? '..',
                                        Jiffy.parse(widget
                                                .orderRequests[index].createdOn)
                                            .fromNow()),
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  );
                                }),
                            SizedBox(
                              height: size.height * 0.04,
                              child: InkWell(
                                child: Icon(Icons.delete,
                                    color: Colors.red.shade400),
                                onTap: () async {
                                  if (mounted) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                  }
                                  await helper.deleteOrderRequest(
                                      widget.orderRequests[index]);
                                  await Future.delayed(
                                      const Duration(seconds: 1));
                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
