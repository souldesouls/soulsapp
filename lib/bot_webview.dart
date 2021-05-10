import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:souls/addons_shop.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// final String piAdd20Points = 'fatumbot.addons.c.add_20_points.v4';
// final String piAdd20PointsOld = 'get_points';
//
// final String piAdd60Points = 'fatumbot.addons.c.add_60_points.v4';
// final String piAdd60PointsOld = 'get_more_points';
//
// final String piInfinitePoints = 'fatumbot.addons.nc.infinite_points.v4';
// final String piInfinitePointsOld = 'infinte_points';
//
// final String piExtendRadius20km = 'fatumbot.addons.nc.extend_radius_20km.v4';
// final String piExtendRadius20kmOld = 'extend_radius';
//
// final String piMapsPack = 'fatumbot.addons.nc.maps_pack.v2';
//
// final String piSkipWaterPack = 'fatumbot.addons.nc.skip_water_pack.v2';
// final String piSkipWaterPackOld = 'skip_water_points';
//
// final String piEverythingPack = 'fatumbot.addons.nc.everything_pack.v4';

class BotWebView extends StatelessWidget {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  WebViewController webView;

  //
  // camrng
  //
  static const platform = const MethodChannel('energy.souls.app');

  // flutter->ios(swift) (used to load the TrueEntropy Camera RNG view controller)
  Future<void> _navToCamRNG() async {
    print("loading CamRNG");
    try {
      if (Platform.isAndroid) {
        // Flutter->Android (Java/Kotlin) (used to load an implementation of awasisto's camrng - https://github.com/awasisto/camrng/)
        await platform.invokeMethod('gotoCameraRNG', 256);
      } else if (Platform.isIOS) {
        // Flutter->Android (Swift) (used to load the a camrng implementation done with vault12's TrueEntropy - https://github.com/vault12/TrueEntropy)
        await platform.invokeMethod('goToTrueEntropy', 256);
      }
    } on PlatformException catch (e) {
      print("Failed to load CamRNG: '${e.message}'.");
    }
  }

  //
  // Add-ons shop
  //
  // C# Fatumbot -> javascript/html webbot client front end -> javascript/flutter bridge -> flutter native IAP screen
  Future<void> _navToShop(BuildContext context, String userId) async {
    // final result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) =>
    //             AddonsShop(_available, products, purchases, userId)));
    //
    // if (result != null && result != '') {
    //   if (result.productID == piAdd20PointsOld ||
    //       result.productID == piAdd60PointsOld) {
    //     // consume any left over unconsumed get points/get more points from the old pre-bot Android app
    //     print("[IAP] Consuming " + result.productID);
    //     _iap.consumePurchase(result);
    //     purchases.remove(result);
    //   }
    //
    //   // flutter->javascript (send to bot the in-app purchase details)
    //   var json = _purchaseDetails2Json(result);
    //   var eval = "sendIAPToBot('" + json + "');";
    //   webView.evaluateJavascript(eval);
    //   Toast.show("Enabling feature...", context,
    //       duration: Toast.LENGTH_LONG,
    //       gravity: Toast.BOTTOM,
    //       textColor: Colors.white,
    //       backgroundColor: Color.fromARGB(255, 88, 136, 226));
    // }
  }

  // ios(swift)->flutter (used as a callback so we are given the GID of entropy generated and uploaded to the libwrapper)
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "entropy":
        debugPrint(call.arguments);
        // flutter->javascript (send to bot the gid)
        webView.evaluateJavascript('sendEntropyFromYourSoul("${call.arguments}");');
        return new Future.value("");
    }
  }

  _launchURL(String url) async {
    await launch(url);
  }

  _initWebBot() async {
    // String udid = "TODO:UDIDHERE";
    // webView.evaluateJavascript('initWebBot("${udid}");');
  }

  _initPushNotifications() async {
    // OneSignal.shared.init("da21a078-babf-4e22-a032-0ea22de561a7", iOSSettings: {
    //   OSiOSSettings.autoPrompt: true,
    //   OSiOSSettings.inAppLaunchUrl: true
    // });
    //
    // OneSignal.shared
    //     .setInFocusDisplayType(OSNotificationDisplayType.notification);
    // OneSignal.shared.setLocationShared(false);
    //
    // var status = await OneSignal.shared.getPermissionSubscriptionState();
    // webView.evaluateJavascript(
    //     'sendPushIdToBot("${status.subscriptionStatus.userId}");');
  }

  ///
  /// In-app purchase stuff >>>
  /// https://fireship.io/lessons/flutter-inapp-purchases/
  ///
  /// Fatumbot User ID
  String userID = "";

  /// Is the API available on the device
  bool _available = false;

  // /// The In App Purchase plugin
  // InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;
  //
  // /// Products for sale
  // Map<String, ProductDetails> products = new Map<String, ProductDetails>();
  //
  // /// Past purchases
  // List<PurchaseDetails> purchases = [];
  //
  // /// Updates to purchases
  // StreamSubscription _subscription;

  /// Get all products available for sale
  void _getProducts() async {
    // Set<String> ids = Set.from([
    //   piAdd20Points,
    //   piAdd20PointsOld,
    //   piAdd60Points,
    //   piAdd60PointsOld,
    //   piInfinitePoints,
    //   piInfinitePointsOld,
    //   piExtendRadius20km,
    //   piExtendRadius20kmOld,
    //   piMapsPack,
    //   piSkipWaterPack,
    //   piSkipWaterPackOld,
    //   piEverythingPack
    // ]);
    // ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    //
    // for (var product in response.productDetails) {
    //   if (product.id == piAdd20Points) {
    //     products[piAdd20Points] = product;
    //   } else if (product.id == piAdd60Points) {
    //     products[piAdd60Points] = product;
    //   } else if (product.id == piInfinitePoints) {
    //     products[piInfinitePoints] = product;
    //   } else if (product.id == piExtendRadius20km) {
    //     products[piExtendRadius20km] = product;
    //   } else if (product.id == piMapsPack) {
    //     products[piMapsPack] = product;
    //   } else if (product.id == piSkipWaterPack) {
    //     products[piSkipWaterPack] = product;
    //   } else if (product.id == piEverythingPack) {
    //     products[piEverythingPack] = product;
    //   }
    // }
  }

  /// Gets past purchases
  void _getPastPurchases() async {
    // QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    //
    // for (PurchaseDetails purchase in response.pastPurchases) {
    //   print("[IAP] Past purchase: " +
    //       purchase.productID +
    //       " => status is: " +
    //       purchase.status.toString());
    //   InAppPurchaseConnection.instance
    //       .completePurchase(purchase, developerPayload: userID);
    // }
    //
    // purchases = response.pastPurchases;
  }

  // void _enablePurchase(PurchaseDetails purchase) {
    // if (purchase != null && purchase.status == PurchaseStatus.purchased) {
    //   print("[IAP] Verified purchase of " + purchase.productID);
    //
    //   // flutter->javascript (send to bot the in-app purchase details)
    //   var json = _purchaseDetails2Json(purchase);
    //   var eval = "sendIAPToBot('" + json + "');";
    //   webView.evaluateJavascript(eval);
    //   Toast.show("Thank you. Enabling now...", context,
    //       duration: Toast.LENGTH_LONG,
    //       gravity: Toast.BOTTOM,
    //       textColor: Colors.white,
    //       backgroundColor: Color.fromARGB(255, 88, 136, 226));
    //
    //   for (PurchaseDetails oldPurchase in purchases) {
    //     if (oldPurchase.productID == purchase.productID) {
    //       // Update record in memory
    //       if (purchases.remove(oldPurchase)) {
    //         purchases.add(purchase);
    //       }
    //     }
    //   }
    // }
  // }

  // String _purchaseDetails2Json(PurchaseDetails purchaseDetails) {
//     return '{' +
//         '"purchaseID":"' +
//         purchaseDetails.purchaseID +
//         '",' +
//         '"productID":"' +
//         purchaseDetails.productID +
//         '",' +
// //        '"localVerificationData":"' +  purchaseDetails.verificationData.localVerificationData + '",' + // This was causing issues on Android coz it was a Json object and wasn't escaping nicely
//         '"serverVerificationData":"' +
//         purchaseDetails.verificationData.serverVerificationData +
//         '",' +
//         '"source":"' +
//         purchaseDetails.verificationData.source.toString() +
//         '",' +
//         '"transactionDate":"' +
//         purchaseDetails.transactionDate +
//         '",' +
// //            '"skPaymentTransaction":"' +   purchaseDetails.skPaymentTransaction + '",' +
// //            '"billingClientPurchase":"' +  purchaseDetails.billingClientPurchase. + '",' +
//         '"status":"' +
//         purchaseDetails.status.toString() +
//         '"' +
//         '}';
//   }

  _initIAP() async {
    // // Check availability of In App Purchases
    // _available = await _iap.isAvailable();
    //
    // if (_available) {
    //   await _getProducts();
    //   await _getPastPurchases();
    //
    //   // Listen to new purchases
    //   _subscription = _iap.purchaseUpdatedStream.listen((purchaseDetailsList) {
    //     for (PurchaseDetails purchase in purchaseDetailsList) {
    //       print('[IAP] New purchase: ' + purchase.productID);
    //       _iap.completePurchase(purchase);
    //       _enablePurchase(purchase);
    //     }
    //     purchases.addAll(purchaseDetailsList);
    //   }, onDone: () {
    //     print("[IAP] onDone");
    //     _subscription.cancel();
    //   }, onError: (error) {
    //     // handle error here.
    //     print("[IAP] error: " + error);
    //     Toast.show("Purchase error: " + error, context,
    //         duration: Toast.LENGTH_LONG,
    //         gravity: Toast.BOTTOM,
    //         textColor: Colors.red[600],
    //         backgroundColor: Colors.black);
    //   });
    // }
  }

  ///
  /// <<< In-app purchase stuff
  ///
  BuildContext context;

  BotWebView();

  @override
  Widget build(BuildContext context) {
    this.context = context;

    var botUrl = "https://app.souls.energy/";
    // var botUrl = "http://192.168.44.5/";

    // _initIAP();

    platform.setMethodCallHandler(
        _handleMethod); // for handling javascript->flutter callbacks
    return Scaffold(
//        appBar: AppBar(
//          title: Text("Souls"),
//        ),
        body: WebView(
            initialUrl: botUrl,
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: Set.from([
              JavascriptChannel(
                  name: 'flutterChannel_loadCamRNG',
                  onMessageReceived: (JavascriptMessage message) {
                    _navToCamRNG(); // open swift TrueEntropy Camera RNG view
                  }),
              JavascriptChannel(
                  name: 'flutterChannel_loadNativeShop',
                  onMessageReceived: (JavascriptMessage message) {
                    userID = message.message;
                    _navToShop(context,
                        message.message); // open Flutter in-app purchase shop
                  }),
              // JavascriptChannel(
              //     name: 'flutterChannel_getCurrentLocation',
              //     onMessageReceived: (JavascriptMessage message) {
              //       //TODO:CALLBACKS like _getCurrentLocation();
              //     }),
              // we can have more than one channels
            ]),
            onWebViewCreated: (WebViewController webViewController) {
              webView = webViewController;
              _controller.complete(webViewController);
            },
            onPageFinished: (String page) {
              _initWebBot();
              _initPushNotifications();
            },
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith("https://www.open†hiswebviewinside.com/pworh")) {
                _launchURL(request.url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            }));
  }
}
