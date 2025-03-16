import 'package:test/models/cloth.dart';
import 'package:test/models/customer.dart';
import 'package:test/models/order.dart';
import 'package:test/models/tailor.dart';
import 'package:test/networking/api_helper.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/customer_profile.dart';
import 'package:test/screens/customer/deposit_remaining.dart';
import 'package:test/screens/customer/rate_tailor_for_order.dart';
import 'package:test/screens/tailor/tailor_main_screen.dart';
import 'package:test/utilities/custom_widgets/tailor_Card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';

import '../../models/measurement.dart';
import '../../models/notification.dart';
import '../../networking/notification_helper.dart';
import '../../utilities/constants.dart';
import '../order_measurements_page.dart';

class OrderInfoPage extends StatefulWidget {
  const OrderInfoPage(
      {Key? key, required this.order, required this.isTailorView})
      : super(key: key);
  final DresssewOrder order;
  final bool isTailorView;
  @override
  State<OrderInfoPage> createState() => _OrderInfoPageState();
}

class _OrderInfoPageState extends State<OrderInfoPage> {
  Tailor? tailor;
  bool isLoading = false;

  Review? review;

  Customer? customer;

  final helper = FireStoreHelper();

  @override
  void initState() {
    super.initState();
    loadCustomer();
    print("Order id: ${widget.order.orderId}");
    loadTailor();
  }

  loadTailor() async {
    if (mounted) setState(() => isLoading = true);
    tailor = await helper.getTailorWithDocId(widget.order.tailorId);
    if (mounted) setState(() => isLoading = false);
    loadOrderReview();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Info').tr(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: DefaultTextStyle(
            style: kInputStyle.copyWith(color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.order.status != OrderStatus.completed &&
                    widget.order.status != OrderStatus.notStartedYet &&
                    widget.order.expectedDeliveryDate!
                            .compareTo(DateTime.now().toIso8601String()) ==
                        -1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 2),
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        Text(
                          'This order is late for its expected delivery date.',
                          style:
                              kTextStyle.copyWith(color: Colors.red.shade700),
                        ).tr(),
                        const Divider(),
                      ],
                    ),
                  ),
                if (widget.order.isCustomizationOnly)
                  Text("customization order", style: kBoldTextStyle()).tr(),
                if (widget.order.isCustomizationOnly)
                  const Divider(
                    color: kDarkOrange
                  ),
                buildCircledImage(size),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  getCategory(widget.order.dressCategory),
                  style: kTitleStyle.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ).tr(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  getTranslatedText(
                      "کل رقم:  ${widget.order.totalAmount} روپے۔",
                      "total amount: Rs. ${widget.order.totalAmount}"),
                  style: kInputStyle.copyWith(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // if (widget.order.status != OrderStatus.completed)
                    Text(
                      getTranslatedText(
                          "جمع کرائی گئی رقم:  ${widget.order.advanceDeposited} روپے۔",
                          "amount deposited: Rs. ${widget.order.advanceDeposited}"),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text(
                      getTranslatedText(
                          "باقی رقم:  ${widget.order.amountRemaining} روپے۔",
                          "amount remaining: Rs. ${widget.order.amountRemaining}"),
                    ),
                    if (widget.order.status == OrderStatus.completed &&
                        widget.order.amountRemaining != 0)
                      widget.isTailorView
                          ? SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.032,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero),
                                child: Text(
                                  'Send reminder',
                                  style: reminderButtonStyle,
                                ).tr(),
                                onPressed: () {
                                  //TODO add remaining deposit remainder implementation

                                  Fluttertoast.showToast(
                                    textColor: Colors.white,
                                    backgroundColor: kOrangeColor,
                                    msg: getTranslatedText(
                                        "یاد دہانی کامیابی کے ساتھ بھیج دی گئی۔",
                                        'Reminder sent successfully.'),
                                  );
                                },
                              ),
                            )
                          : SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.032,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero),
                                child: Text(
                                  'Pay dues',
                                  style: reminderButtonStyle,
                                ).tr(),
                                onPressed: () {
                                  navigateToScreen(DepositRemainingDuesOfOrder(
                                    order: widget.order,
                                  ));
                                },
                              ),
                            ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    if (widget.isTailorView)
                      Row(
                        children: [
                          const Text('customer: ').tr(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.032,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              child: customer == null
                                  ? const Text('..')
                                  : translatedTextWidget(
                                      customer?.name,
                                      style: reminderButtonStyle,
                                    ),
                              onPressed: () async {
                                if (customer == null) return;
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CustomerProfile(customer: customer!),
                                  ),
                                );
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    if (widget.isTailorView)
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                    FutureBuilder(
                      future: ApiHelper.translateText(
                          widget.order.tailorPaymentInfo.paymentMethod.name),
                      builder: (_, st) {
                        return Text(
                          "${widget.isTailorView ? getTranslatedText("میرا", 'my') : getTranslatedText("درزی کا", 'tailor')} ${getTranslatedText("اکاؤنٹ کی قسم", "account type")}: ${getTranslatedText(st.data ?? '..', capitalizeText(widget.order.tailorPaymentInfo.paymentMethod.name))}",
                        );
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text(
                      "${widget.isTailorView ? getTranslatedText("میرا", 'my') : getTranslatedText("درزی کا", 'tailor')} ${getTranslatedText("اکاؤنٹ", "account")}: ${zeroedPhoneNumber(widget.order.tailorPaymentInfo.accountNumber)}",
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    FutureBuilder(
                        future: ApiHelper.translateText(
                            capitalizeText(widget.order.paymentMethod.name)),
                        builder: (_, st) {
                          return Text(
                            getTranslatedText(
                              "ادائیگی کا طریقہ: ${st.data ?? '..'}",
                              "payment method: ${capitalizeText(widget.order.paymentMethod.name)}",
                            ),
                          );
                        }),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    RichText(
                      text: TextSpan(
                          text: getTranslatedText("آپشن کے ذریعے پیمائش: ",
                              "measurements submission via: "),
                          style: kInputStyle.copyWith(
                              color: Colors.black, fontSize: 13),
                          children: [
                            TextSpan(
                              text: urduMeasurement(
                                  widget.order.measurementChoice.name),
                              style: kBoldTextStyle(),
                            ),
                          ]),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    RichText(
                      text: TextSpan(
                        text: getTranslatedText("پیمائش: ", "measurements: "),
                        style: kInputStyle.copyWith(
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: widget.order.measurements != null
                                ? getTranslatedText(
                                    "شامل کی جا چکی ہے", "added")
                                : getTranslatedText(
                                    "ابھی تک شامل نہیں کی گئی ہے",
                                    "not added yet"),
                            style: kBoldTextStyle().copyWith(
                              color: widget.order.measurements == null
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          )
                        ],
                      ),
                    ),

                    (widget.order.status == OrderStatus.notStartedYet &&
                                widget.order.measurementChoice ==
                                    MeasurementChoice.online &&
                                !widget.isTailorView) ||
                            (widget.order.status == OrderStatus.notStartedYet &&
                                widget.order.measurementChoice !=
                                    MeasurementChoice.online &&
                                widget.isTailorView)
                        ? widget.order.measurements == null
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.032,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  child: Text(
                                    'Add Measurements',
                                    style: reminderButtonStyle,
                                  ).tr(),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderMeasurementsPage(
                                          order: widget.order,
                                          isTailorView: widget.isTailorView,
                                        ),
                                      ),
                                    );
                                    if (widget.order.measurements != null &&
                                        !widget.isTailorView) {
                                      NotificationHelper.sendNotification(
                                        widget.order,
                                        NotificationType
                                            .customerAddedMeasurements,
                                        customerName: customer!.name,
                                        sentByTailor: false,
                                      );
                                    }
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                              )
                            : SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.032,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  child: Text(
                                    'View measurements',
                                    style: reminderButtonStyle,
                                  ).tr(),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderMeasurementsPage(
                                          order: widget.order,
                                          isTailorView: widget.isTailorView,
                                        ),
                                      ),
                                    );
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                              )
                        : widget.order.measurements == null
                            //submission via online but customer haven't added yet measurements still not added
                            ? widget.order.measurementChoice ==
                                        MeasurementChoice.online &&
                                    //also if the steps were completed then option for Send reminder to tailor
                                    widget.isTailorView &&
                                    widget.order.cloth != null
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.032,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero),
                                      child: Text(
                                        'Send reminder',
                                        style: reminderButtonStyle,
                                      ).tr(),
                                      onPressed: () {
                                        NotificationHelper.sendNotification(
                                          widget.order,
                                          NotificationType.toSubmitMeasurements,
                                          customerName: customer!.name,
                                        ).then(
                                            (value) => Fluttertoast.showToast(
                                                  textColor: Colors.white,
                                                  backgroundColor: kOrangeColor,
                                                  msg: getTranslatedText(
                                                      "یاد دہانی کامیابی کے ساتھ بھیج دی گئی۔",
                                                      'Reminder sent successfully.'),
                                                ));
                                      },
                                    ),
                                  )
                                : const SizedBox()
                            : SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.032,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  child: Text(
                                    'View measurements',
                                    style: reminderButtonStyle,
                                  ).tr(),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderMeasurementsPage(
                                                order: widget.order,
                                                isTailorView:
                                                    widget.isTailorView),
                                      ),
                                    );
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    RichText(
                      text: TextSpan(
                        text: getTranslatedText(
                            "ڈریس کا کپڑا دینے کا آپشن: ", "cloth via: "),
                        style: kInputStyle.copyWith(
                            color: Colors.black, fontSize: 13),
                        children: [
                          TextSpan(
                            text: urduClothOption(
                                    widget.order.cloth?.delivery.name) ??
                                getTranslatedText(
                                    "ابھی تک شامل نہیں کیا گیا ہے",
                                    'not added'),
                            style: kBoldTextStyle().copyWith(
                              color: widget.order.cloth == null
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isTailorView)
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                    if (widget.isTailorView)
                      RichText(
                        text: TextSpan(
                          text: getTranslatedText(
                              "کپڑے کا اِسٹیٹَس: ", "cloth status: "),
                          style: kInputStyle.copyWith(
                              color: Colors.black, fontSize: 13),
                          children: [
                            TextSpan(
                              text: widget.order.clothReceivedByTailor
                                  ? getTranslatedText(
                                      "موصول ہو چکا ہے", 'received')
                                  : getTranslatedText(
                                      "ابھی تک موصول نہیں ہوا", 'not received'),
                              style: kBoldTextStyle().copyWith(
                                  color: !widget.order.clothReceivedByTailor
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                    if (widget.order.cloth?.delivery == DeliveryOption.mySelf &&
                        !widget.order.clothReceivedByTailor &&
                        widget.isTailorView)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.032,
                        child: TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            'Send reminder',
                            style: reminderButtonStyle,
                          ).tr(),
                          onPressed: () {
                            NotificationHelper.sendNotification(
                              widget.order,
                              NotificationType.customerToSubmitCloth,
                              customerName: customer!.name,
                            ).then((val) {
                              Fluttertoast.showToast(
                                textColor: Colors.white,
                                backgroundColor: kOrangeColor,
                                msg: getTranslatedText(
                                    "یاد دہانی کامیابی کے ساتھ بھیج دی گئی۔",
                                    'Reminder sent successfully.'),
                              );
                            });
                          },
                        ),
                      ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                    RichText(
                      text: TextSpan(
                          text: getTranslatedText(
                              "آرڈر اِسٹیٹَس: ", "order status: "),
                          style: kInputStyle.copyWith(color: Colors.black),
                          children: [
                            TextSpan(
                              text: urduOrderStatus(widget.order.status.name),
                              style: kBoldTextStyle().copyWith(
                                color:
                                    widget.order.status == OrderStatus.completed
                                        ? Colors.blue.shade700
                                        : widget.order.status ==
                                                OrderStatus.notStartedYet
                                            ? Colors.red.shade700
                                            : Colors.green.shade700,
                              ),
                            ),
                          ]),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    if (widget.order.status != OrderStatus.notStartedYet)
                      FutureBuilder(
                          future: ApiHelper.translateText(Jiffy.parse(
                                  widget.order.status == OrderStatus.completed
                                      ? widget.order.deliveredOn!
                                      : widget.order.expectedDeliveryDate!)
                              .yMMMMEEEEd),
                          builder: (_, st) {
                            final date = Jiffy.parse(
                                    widget.order.status == OrderStatus.completed
                                        ? widget.order.deliveredOn!
                                        : widget.order.expectedDeliveryDate!)
                                .yMMMMEEEEd;
                            return Text(
                              "${widget.order.status == OrderStatus.completed ? getTranslatedText("مکمل ہونے کی تاریخ: ", "delivered on: ") : getTranslatedText("متوقع مکمل ہونے کی تاریخ: ", "expected delivery date: ")} ${getTranslatedText(st.data ?? '..', date)}",
                            );
                          }),
                    if (widget.order.status == OrderStatus.completed &&
                        widget.order.status != OrderStatus.notStartedYet &&
                        widget.order.deliveredOn!.compareTo(
                                widget.order.expectedDeliveryDate!) ==
                            1)
                      Column(
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          if (getDifferenceInDays() >= kThresholdDeliveryDays)
                            Text(
                              getTranslatedText(
                                  'This order was delivered ${getDifferenceInDays()} day(s) late from expected date.',
                                  "یہ آرڈر متوقع تاریخ سے ${getDifferenceInDays()} دن کی تاخیر سے ڈلیورکیا گیا تھا۔"),
                              style: kTextStyle.copyWith(
                                  color: Colors.red, height: 1.2),
                            ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                        ],
                      ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                    if (widget.order.anyComments.trim().isNotEmpty)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslatedText(
                                "اضافی ہدایات: ${widget.order.anyComments}",
                                "additional instructions: ${widget.order.anyComments}"),
                            style: kInputStyle.copyWith(
                                color: Colors.grey.shade700, fontSize: 13),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                        ],
                      ),
                    if (!widget.isTailorView)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: const Text('tailor card:').tr(),
                          ),
                          isLoading
                              ? SizedBox(
                                  width: size.width,
                                  height: size.height * 0.22,
                                  child: Center(
                                      child: Text(
                                    'Loading tailor info...',
                                    style:
                                        kTextStyle.copyWith(color: Colors.grey),
                                  ).tr()),
                                )
                              : tailor == null
                                  ? SizedBox(
                                      width: size.width,
                                      height: size.height * 0.22,
                                      child: Center(
                                          child: Text(
                                        "Can't load data.",
                                        style: kTextStyle.copyWith(
                                            color: Colors.grey),
                                      ).tr()),
                                    )
                                  : TailorCard(
                                      tailor: tailor!,
                                    ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                        ],
                      ),
                    if (widget.order.status == OrderStatus.completed)
                      widget.order.rating == 0
                          //if haven't rated yet
                          ? FirebaseAuth.instance.currentUser!.email ==
                                  currentTailor?.email
                              //if tailor is viewing this page
                              //if dues aren't clear then tailor can't Send reminder for just rating
                              ? widget.order.amountRemaining != 0
                                  ? const SizedBox()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Not rated by customer yet.',
                                          style: TextStyle(color: Colors.grey),
                                        ).tr(),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.032,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero),
                                            child: Text(
                                              'Send reminder',
                                              style: reminderButtonStyle,
                                            ).tr(),
                                            onPressed: () {
                                              NotificationHelper
                                                  .sendNotification(
                                                widget.order,
                                                NotificationType.toAddReview,
                                                customerName: customer!.name,
                                              ).then((val) =>
                                                  Fluttertoast.showToast(
                                                    textColor: Colors.white,
                                                    backgroundColor:
                                                        kOrangeColor,
                                                    msg: getTranslatedText(
                                                        "یاد دہانی کامیابی کے ساتھ بھیج دی گئی۔",
                                                        'Reminder sent successfully.'),
                                                  ));
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                              //if customer is viewing this page
                              //if dues aren't clear then customer can't rate
                              : widget.order.amountRemaining != 0
                                  ? const SizedBox()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "You haven't rated yet.",
                                          style: TextStyle(color: Colors.grey),
                                        ).tr(),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.032,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero),
                                            child: Text(
                                              'Rate now',
                                              style: reminderButtonStyle,
                                            ).tr(),
                                            onPressed: () {
                                              navigateToScreen(
                                                  RateTailorForOrder(
                                                      order: widget.order));
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                          //if rated already
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentTailor != null ? getTranslatedText("کسٹمر نے درجہ بندی کی", "customer rated ") : getTranslatedText("آپ نے درجہ بندی کی ", "you rated ")}(${widget.order.rating.toString()})',
                                ),
                                Center(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: FittedBox(
                                      child: RatingBarIndicator(
                                        unratedColor: Colors.grey.shade400,
                                        rating: widget.order.rating,
                                        itemBuilder: (context, index) =>
                                            const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 15.0,
                                      ),
                                    ),
                                  ),
                                ),
                                if (review != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (review!.reviewsImageUrls.isNotEmpty)
                                        Text(
                                          getTranslatedText(
                                              "تصاویر(${review!.reviewsImageUrls.length})",
                                              'images(${review!.reviewsImageUrls.length})'),
                                          style: kTextStyle,
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Wrap(
                                            spacing: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            runSpacing: 5,
                                            children: List.generate(
                                              review!.reviewsImageUrls.length,
                                              (i) => buildShopImageItem(
                                                  review!.reviewsImageUrls[i]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Center buildCircledImage(Size size) {
    return Center(
      child: GestureDetector(
        onTap: () {
          final decoration = BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: (widget.order.dressImage.contains('assets')
                  ? AssetImage(widget.order.dressImage)
                  : NetworkImage(widget.order.dressImage) as ImageProvider),
              fit: BoxFit.fill,
            ),
          );
          showDialog(
            context: context,
            builder: (context) => Container(
              margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.15,
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              decoration: decoration,
            ),
          );
        },
        child: CircleAvatar(
          radius: size.width * 0.2,
          backgroundColor: kOrangeColor,
          child: CircleAvatar(
            backgroundImage: (widget.order.dressImage.contains('assets')
                ? AssetImage(widget.order.dressImage)
                : NetworkImage(widget.order.dressImage) as ImageProvider),
            backgroundColor: kLightSkinColor,
            radius: size.width * 0.2 - 1,
          ),
        ),
      ),
    );
  }

  loadCustomer() async {
    customer = await helper.getCustomerWithDocId(widget.order.customerId);
    if (mounted) setState(() {});
  }

  navigateToScreen(Widget screen) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    ).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void loadOrderReview() {
    if (tailor != null) {
      for (var value in tailor!.reviews) {
        if (value.orderId == widget.order.orderId) {
          review = value;
          break;
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget buildShopImageItem(String url) {
    // print('url: $url');
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      image: DecorationImage(
        image: NetworkImage(url),
        fit: BoxFit.fill,
      ),
    );
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Card(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.15,
              horizontal: MediaQuery.of(context).size.width * 0.04,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: decoration,
                ),
                Positioned(
                  right: 0,
                  child: SizedBox(
                    child: FloatingActionButton(
                      mini: true,
                      isExtended: false,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        height: MediaQuery.of(context).size.height * 0.12,
        decoration: decoration,
      ),
    );
  }

  int getDifferenceInDays() {
    return DateTime.parse(widget.order.deliveredOn!)
        .difference(DateTime.parse(widget.order.expectedDeliveryDate!))
        .inDays;
  }
}
