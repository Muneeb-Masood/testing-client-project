import 'package:test/main.dart';
import 'package:test/models/measurement.dart';
import 'package:test/models/order.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/custom_widgets/rate_input_text_field.dart';
import 'package:test/utilities/custom_widgets/rectangular_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';

class OrderMeasurementsPage extends StatefulWidget {
  final bool isTailorView;
  final DresssewOrder order;
  const OrderMeasurementsPage({
    Key? key,
    required this.order,
    this.isTailorView = false,
  }) : super(key: key);
  @override
  State<OrderMeasurementsPage> createState() => _OrderMeasurementsPageState();
}

class _OrderMeasurementsPageState extends State<OrderMeasurementsPage> {
  bool isEditMode = false;
  bool isUpdatingMeasurements = false;
  String unit = 'in';
  List<Measurement> measurements = List.generate(
    totalMeasurements.length,
    (index) => Measurement(
      title: capitalizeText(
          spaceSeparatedText(totalMeasurements.keys.elementAt(index))),
      measure: 0,
    ),
  );
  final measurementsControllers = List.generate(
      totalMeasurements.length, (index) => TextEditingController(text: '0'));

  final helper = FireStoreHelper();

  setEditMode() {
    //will be editable only if it has been opened by customer but order has
    // online measurements or tailor has opened it but order has not
    // online measurements.
    //once order is started then no editable
    if (widget.order.measurements == null &&
        ((widget.order.status == OrderStatus.notStartedYet &&
                widget.order.measurementChoice == MeasurementChoice.online &&
                !widget.isTailorView) ||
            (widget.order.status == OrderStatus.notStartedYet &&
                widget.order.measurementChoice != MeasurementChoice.online &&
                widget.isTailorView))) {
      isEditMode = true;
    } else {
      isEditMode = false;
    }
    print(
        'Value: ${widget.order.status == OrderStatus.notStartedYet && widget.order.measurementChoice == MeasurementChoice.online && !widget.isTailorView}');
    print(
        "Value: ${widget.order.status == OrderStatus.notStartedYet && widget.order.measurementChoice != MeasurementChoice.online && widget.isTailorView}");
    if (mounted) setState(() {});
  }

  setControllerValuesToOrders() async {
    // if()
    // widget.customer.measurements.forEach((element) { });
    if (widget.order.measurements != null &&
        widget.order.measurements!.isNotEmpty) {
      setMeasurementsToThese(widget.order.measurements!);
    } else {
      //that means measurements are being added first time
      //if via online then load customer's own measurements
      //and also a customer has opened this page
      if (widget.order.measurementChoice == MeasurementChoice.online &&
          !widget.isTailorView) {
        setMeasurementsToThese(currentCustomer!.measurements);
        // measurements = currentCustomer!.measurements;
        Future.delayed(const Duration(milliseconds: 100))
            .then((value) => Fluttertoast.showToast(
                  msg: getTranslatedText(".پروفائل سے میری پیمائش لوڈ کی",
                      "Loaded my measurements from profile."),
                  gravity: ToastGravity.CENTER,
                  textColor: Colors.white,
                  backgroundColor: kOrangeColor,
                ));
      }
      //if via physical/agent then load customer's previous order's measurements
      //and also a tailor has opened this page
      else if (widget.order.measurementChoice != MeasurementChoice.online &&
          isEditMode &&
          widget.isTailorView) {
        //loads inProgress,justStarted and completed orders
        final orders = await helper.loadOrdersOfTailorForCustomer(
            widget.order.tailorId, widget.order.customerId);

        if (orders.isNotEmpty) {
          orders.sort((o1, o2) {
            return o1.expectedDeliveryDate!.compareTo(o2.expectedDeliveryDate!);
          });
          final lastOrder = orders.last;
          print("Last Order on: ${lastOrder.expectedDeliveryDate}");
          setMeasurementsToThese(lastOrder.measurements!);
          Fluttertoast.showToast(
            gravity: ToastGravity.CENTER,
            msg: getTranslatedText(
                "گاہک کے آخری آرڈر سے کامیابی سے لوڈ کیا گیا.",
                "loaded from customer's last order successfully."),
            textColor: Colors.white,
            backgroundColor: kOrangeColor,
          );
        } else {
          print("previous orders: empty list");
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    setEditMode();
    setControllerValuesToOrders();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        // if (widget.order.measurements == measurements) {
        //   widget.order.measurements = null;
        // }
        // if (mounted) {
        //   setState(() {});
        // }
        return true;
      },
      child: LoadingOverlay(
        isLoading: isUpdatingMeasurements,
        progressIndicator: kSpinner(context),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(size.width * 0.05, 0,
                        size.width * 0.05, size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: size.width * 0.01,
                        ),
                        Text(
                          //means user is just viewing measurements
                          '${isEditMode && widget.isTailorView ? getTranslatedText("ایڈٹ کریں", "Edit") : isEditMode && !widget.isTailorView ? getTranslatedText("شامل کریں", "Add") : ''} ${getTranslatedText("پیمائش", "Measurements")}',
                          textAlign: TextAlign.center,
                          style: kTitleStyle.copyWith(
                              fontSize: isEditMode ? 25 : 30),
                        ),
                        SizedBox(
                          height: size.width * 0.01,
                        ),
                        Text(
                          getTranslatedText(
                              "${catgKeyVals[getCategory(widget.order.dressCategory)]} کے لئے",
                              'for ${getCategory(widget.order.dressCategory)}'),
                          textAlign: TextAlign.center,
                          style: kInputStyle.copyWith(fontSize: 20),
                        ),
                        SizedBox(
                          height: size.width * 0.02,
                        ),
                        if (isEditMode)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    getTranslatedText("یونٹ", 'Unit'),
                                    style: kInputStyle,
                                  ),
                                  const SizedBox(),
                                  DropdownButton<String>(
                                    value: unit == "in"
                                        ? getTranslatedText("انچ", 'inches')
                                        : getTranslatedText(
                                            "سینٹی میٹر", 'centimeters'),
                                    style: kBoldTextStyle(),
                                    iconEnabledColor: kOrangeColor,
                                    dropdownColor: kLightSkinColor,
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        if ((unit == 'in' &&
                                                (newValue == 'inches' ||
                                                    newValue == "انچ")) ||
                                            (unit == 'cm' &&
                                                (newValue == 'centimeters' ||
                                                    newValue ==
                                                        "سینٹی میٹر"))) {
                                          return;
                                        }
                                        unit = (newValue == 'inches' ||
                                                newValue == "انچ")
                                            ? 'in'
                                            : "cm";
                                      }
                                      setState(() {});
                                      print(unit);
                                    },
                                    items: [
                                      getTranslatedText("انچ", 'inches'),
                                      getTranslatedText(
                                          "سینٹی میٹر", 'centimeters'),
                                    ].map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: size.width * 0.01,
                              ),
                            ],
                          ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: List.generate(
                                measurements.length,
                                (i) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: size.height * 0.03),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildMeasureItemPic(size, i),
                                        const SizedBox(),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            buildMeasureItemName(i),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            RateInputField(
                                              enabled: isEditMode,
                                              suffixText: unit == "in"
                                                  ? getTranslatedText(
                                                      "انچ", 'inches')
                                                  : getTranslatedText(
                                                      "سینٹی میٹر",
                                                      'centimeters'),
                                              onChanged: (val) {
                                                if (val != null &&
                                                    val.isNotEmpty) {
                                                  try {
                                                    measurements[i].measure =
                                                        double.parse(val);
                                                    if (mounted) {
                                                      setState(() {});
                                                    }
                                                  } catch (e) {
                                                    print(
                                                        'Exception parsing :$e');
                                                  }
                                                }
                                              },
                                              validateField: false,
                                              controller:
                                                  measurementsControllers[i],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.width * 0.02),
                        if (isEditMode)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: RectangularRoundedButton(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              buttonName: 'Update order',
                              onPressed: () {
                                widget.order.measurements = measurements;
                                for (var element
                                    in widget.order.measurements!) {
                                  element.unit = unit;
                                }
                                if (mounted) setState(() {});
                                if (isEditMode) {
                                  if (mounted) {
                                    setState(() {
                                      isUpdatingMeasurements = true;
                                    });
                                  }
                                  helper
                                      .updateOrder(widget.order)
                                      .then((value) {
                                    if (value) {
                                      if (mounted) {
                                        setState(() {
                                          isUpdatingMeasurements = false;
                                        });
                                      }
                                      Fluttertoast.showToast(
                                        msg: getTranslatedText(
                                            "پیمائش کامیابی سے اپ ڈیٹ کی گئی ہے.",
                                            "Measurements updated successfully."),
                                        gravity: ToastGravity.CENTER,
                                        textColor: Colors.white,
                                        backgroundColor: kOrangeColor,
                                      );
                                      Navigator.pop(context);
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        if (!isEditMode &&
                            !widget.isTailorView &&
                            widget.order.measurementChoice !=
                                MeasurementChoice.online)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: RectangularRoundedButton(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              buttonName: 'Make these as my measurements',
                              fontSize: size.width * 0.04,
                              onPressed: () {
                                currentCustomer!.measurements = measurements;
                                if (mounted) setState(() {});
                                if (mounted) {
                                  setState(() {
                                    isUpdatingMeasurements = true;
                                  });
                                }
                                helper
                                    .updateCustomer(currentCustomer!)
                                    .then((value) {
                                  if (value) {
                                    if (mounted) {
                                      setState(() {
                                        isUpdatingMeasurements = false;
                                      });
                                    }
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                      msg: getTranslatedText(
                                          "پیمائش کامیابی سے اپ ڈیٹ کی گئی ہے.",
                                          "Measurements updated successfully."),
                                      textColor: Colors.white,
                                      backgroundColor: kOrangeColor,
                                    );
                                  }
                                });
                                print(measurements);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onMeasurementImageTapped(String imageUrl) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      image: DecorationImage(
        image: AssetImage(imageUrl),
        fit: BoxFit.fill,
      ),
    );
    showDialog(
      context: context,
      builder: (context) => Container(
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.18,
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        decoration: decoration.copyWith(),
      ),
    );
  }

  Widget buildMeasureItemName(int index) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        capitalizeText(
          spaceSeparatedText(totalMeasurements.keys.elementAt(index)),
        ).tr(),
        style: kInputStyle,
      ),
    );
  }

  Widget buildMeasureItemPic(size, int i) {
    return SizedBox(
      width: size.width * 0.4,
      height: size.height * 0.1,
      child: Align(
          alignment:
              isUrduActivated ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onTap: () =>
                onMeasurementImageTapped(totalMeasurements.values.elementAt(i)),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(totalMeasurements.values.elementAt(i))),
          )),
    );
  }

  void setMeasurementsToThese(List<Measurement> measures) {
    for (int i = 0; i < measures.length; i++) {
      String val = measures[i].measure.toString();
      measurementsControllers[i].text = val;
      measurements[i].measure = measures[i].measure;
    }
    unit = measures[0].unit;
    if (mounted) {
      setState(() {});
    }
  }
}
