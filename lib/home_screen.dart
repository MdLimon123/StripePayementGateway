
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_payment_app/keys.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  double amount = 156;
  Map<String, dynamic>? intentPaymentData;


  makeIntentForPayment(amountToBeCharge, currency)async{
    try{

      Map<String, dynamic> paymentInfo = {
        "amount" : (int.parse(amountToBeCharge) * 100).toString(),
        "currency" : currency,
        "payment_method_types[]" : "card"
      };

      var responseFromStripeAPI = await http.post(Uri.parse(
        "https://api.stripe.com/v1/payment_intents"),
      body: paymentInfo,
      headers: {
        "Authorization": "Bearer $Secretkey",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      
      print("response from api " + responseFromStripeAPI.body);

      return jsonDecode(responseFromStripeAPI.body);


    }catch(errorMsg, s){
      if(kDebugMode){
        print(s);
      }
      print(errorMsg.toString());
    }
  }

  showPaymentSheet() async{

    try{

      await Stripe.instance.presentPaymentSheet().then((val){
        intentPaymentData = null;
        
      }).onError((error, sTrace){
        if(kDebugMode){
          print(error.toString() + sTrace.toString());
        }
      });

    }
    on StripeException catch(error){
      if(kDebugMode){
        print(error);
      }
      showDialog(
          context: context,
          builder: (c)=> const AlertDialog(
            content: Text("Cancelled"),
          ));
    }
    catch(errorMsg){
      if(kDebugMode){
        print(errorMsg);
      }
      print(errorMsg.toString());
    }
  }

  paymentSheetInitilization(amountToBeCharge, currency)async{

    try{

    intentPaymentData = await makeIntentForPayment(amountToBeCharge, currency);
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        allowsDelayedPaymentMethods: true,
        paymentIntentClientSecret: intentPaymentData!["client_secret"],
        style: ThemeMode.dark,
        merchantDisplayName: "Limon Islam"
      )
    ).then((val){
      print(val);
    });

    showPaymentSheet();


    }catch(errorMsg){
      if(kDebugMode){
        print(errorMsg);
      }
      print(errorMsg.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              paymentSheetInitilization(
                amount.round().toString(),
                "USD"
              );
            },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green
                ),
                child: Text("Pay Now USD ${amount.toString()}",
                style:const TextStyle(
                  color: Colors.white
                ),))
          ],
        ),
      ),
    );
  }
}
