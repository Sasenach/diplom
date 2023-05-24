import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kurskafedesktop/cubit/acces_level_cubit.dart';
import 'package:kurskafedesktop/model/chekk.dart';
import 'package:kurskafedesktop/model/employee.dart';
import 'package:kurskafedesktop/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageNewtable extends StatefulWidget {
  const PageNewtable({super.key});

  @override
  State<PageNewtable> createState() => _PageNewtableState();
}

class _PageNewtableState extends State<PageNewtable> {
  int _widgetCount = 0;
  TextEditingController txtTableNumber = TextEditingController();
  TextEditingController txtPersonCount = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Employee;
    final double skWidth = MediaQuery.of(context).size.width;
    final double skHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (txtPersonCount.text.isEmpty ||
              txtTableNumber.text.isEmpty ||
              int.tryParse(txtPersonCount.text) == null) {
            const bar = SnackBar(
              content: Text('Выберите стол и количество персон числами'),
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(bar);
          } else {
            int result = await HTTPRequests().createChekk(
                int.parse(txtPersonCount.text), txtTableNumber.text, args.id!);
            setState(() {
              txtPersonCount.text = '';
              txtTableNumber.text = '';
            });
          }
        },
        child: const Icon(Icons.add_circle_outline_rounded),
      ),
      body: SafeArea(
          child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: skWidth * 0.4,
                  child: TextField(
                    controller: txtTableNumber,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Номер стола'),
                  ),
                ),
                SizedBox(
                  width: skWidth * 0.4,
                  child: TextField(
                    controller: txtPersonCount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Персон'),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Chekk>>(
                future:
                    context.read<AccesLevelCubit>().state is AccesLevelInitial
                        ? HTTPRequests().getAllChekks(args.id!)
                        : HTTPRequests().getAllChekksForAdmin(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Chekk>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (snapshot.data!.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      _widgetCount++;
                      Chekk chekk =
                          snapshot.data![snapshot.data!.length - index - 1];
                      return ListTile(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString(
                              'selectedTable', chekk.id.toString());
                          var bar = SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text("Выбран ${chekk.tablee} столик"),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(bar);
                        },
                        title: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person,
                                size: 32,
                              ),
                              Text(
                                chekk.persons.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  child: const Icon(
                                    Icons.table_bar_outlined,
                                    size: 32,
                                  )),
                              Text(
                                chekk.tablee.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Итог:",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      chekk.amount.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              const Expanded(
                                  child: SizedBox(
                                height: 0,
                              )),
                              Text(
                                DateFormat('dd.MM.yyyy HH:mm')
                                    .format(chekk.curentDate!)
                                    .toString(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}
