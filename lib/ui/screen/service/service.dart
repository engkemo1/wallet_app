import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet_app/ui/screen/bank_accounts/bank_accounts.dart';

import '../../../generated/l10n.dart';
import '../../../util/button_widget.dart';
import '../../../util/constant.dart';
import '../j.dart';

class Service extends StatelessWidget {
  final int id;

  final String name;
  final String collectionName;

  final String logo;

  const Service(
      {super.key, required this.name, required this.logo, required this.id, required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [

            Row(children: [
              IconButton(onPressed: () {
                Navigator.pop(context);
              }, icon: const Icon(Icons.arrow_back, color: Colors.black,)),

            ],),
            Image.asset(logo
            ,height: 100,
            ),
            const SizedBox(height: 10,),

            Text(name,style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 18),),
            const SizedBox(height: 60,),
            SizedBox(width: 300,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_)=>BankAccounts(collectionName:collectionName,name: name,id: id,) ));
                    },   style: const ButtonStyle(backgroundColor:WidgetStatePropertyAll(COLOR_PRIMARY)),
                  child:  Text(S.of(context).add,style: TextStyle(color: Colors.white),),)),
            const SizedBox(height: 20,),

            SizedBox(width: 300,
                child: ElevatedButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>WalletDetailsScreen(collectionName: collectionName,title:name,id: id.toString(),) ));

                },
                  style: const ButtonStyle(backgroundColor:WidgetStatePropertyAll(COLOR_PRIMARY)),
                  child:  Text(S.of(context).showALL,style: TextStyle(color: Colors.white),),)),

          ],
        ),
      ),
    );
  }
}
