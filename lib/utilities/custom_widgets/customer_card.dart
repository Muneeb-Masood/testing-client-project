import 'package:test/screens/customer/customer_profile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/customer.dart';
import '../../networking/api_helper.dart';
import '../constants.dart';

class CustomerCard extends StatelessWidget {
  final int orderCount;

  const CustomerCard(
      {Key? key, required this.customer, required this.orderCount})
      : super(key: key);
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTextStyle(
      style: kInputStyle.copyWith(locale: context.locale, fontSize: 20),
      child: Card(
        color: kSkinColor,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: kOrangeColor, width: 0.35),
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerProfile(
                        customer: customer,
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: kOrangeColor,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(customer.profileImageUrl!),
                    backgroundColor: kLightSkinColor,
                    radius: 25,
                  ),
                ),
                title: FutureBuilder(
                    future: ApiHelper.translateText(customer.name),
                    builder: (_, st) {
                      return Text(
                        getTranslatedText(st.data ?? '..', customer.name),
                        style: kInputStyle,
                      );
                    }),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                        future: ApiHelper.translateText(
                            "${customer.address} ${customer.city}"),
                        builder: (_, st) {
                          return Text(
                            getTranslatedText(st.data ?? '..',
                                "${customer.address} ${customer.city}"),
                            style: kTextStyle.copyWith(fontSize: 12),
                            textAlign: TextAlign.start,
                          );
                        }),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text(
                      getTranslatedText(
                          "آرڈرس($orderCount)", "Orders($orderCount)"),
                      style: kInputStyle,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.12,
                          height: size.height * 0.038,
                          child: OutlinedButton(
                            style: kOutlinedButtonStyle,
                            onPressed: () {
                              final Uri callLaunchUri = Uri(
                                scheme: 'tel',
                                path: customer.phoneNumber,
                              );
                              launchUrl(callLaunchUri);
                            },
                            child: const Icon(Icons.call, size: 17),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05),
                        SizedBox(
                          width: size.width * 0.12,
                          height: size.height * 0.038,
                          child: OutlinedButton(
                            style: kOutlinedButtonStyle,
                            onPressed: () {
                              final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: customer.email,
                                query: encodeQueryParameters(<String, String>{
                                  'subject': 'Update about your dress',
                                  'body': 'Type your message here...',
                                }),
                              );

                              launchUrl(emailLaunchUri);
                            },
                            child: const Icon(Icons.email, size: 17),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
