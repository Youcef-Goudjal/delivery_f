import 'package:delivery_f/models/client.dart';
import 'package:delivery_f/models/facture.dart';
import 'package:delivery_f/models/order.dart';
import 'package:delivery_f/services/localstorage.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class PrintTest with ChangeNotifier {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  PrinterBluetooth printer;

  PrintTest() {
    scan();
  }

  setPrinter(PrinterBluetooth pb) {
    printer = pb;
    notifyListeners();
  }

  List<PrinterBluetooth> scan() {
    printerManager.startScan(Duration(seconds: 4));
    printerManager.scanResults.listen((event) {
      if (event != null) {
        for (final printe in event) {
          if (printe.name == storage.getItem("printer")) {
            printer = printe;
            notifyListeners();
          }
        }
        if (printer == null && event.isNotEmpty) {
          printer = event.first;
          notifyListeners();
        }
      }
      return event;
    });
  }

  Order facturetoorder(Facture f) {
    return Order(
      client: Client(
        id: f.supplier.id,
        credits: f.supplier.credits,
        phone: f.supplier.phone,
        fullname: f.supplier.fullname,
      ),
      id: f.id,
      pricing: 0,
      products: f.products,
      orderDate: f.orderDate,
      paid: f.paid,
      paymentDate: f.paymentDate,
    );
  }

  testPrint(PrinterBluetooth printer, {Order order}) async {
    printerManager.selectPrinter(printer);
    const PaperSize paper = PaperSize.mm80;
    final PosPrintResult res = await printerManager.printTicket(
      await demoReceipt(paper, order),
    );

    Fluttertoast.showToast(msg: res.msg);
  }

  printCredits(PrinterBluetooth printer, Order order) async {
    printerManager.selectPrinter(printer);
    const PaperSize paper = PaperSize.mm80;
    final Ticket ticket = Ticket(paper);

    bool logo = storage.getItem("logo");
    logo = logo == null
        ? false
        : logo == false
            ? false
            : true;
    if (logo) {
      final image = storage.getItem("image");
      if (image != null) {
        ticket.image(image);
      }
    }
    ticket.text('${storage.getItem("company") ?? ""}',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size3,
          width: PosTextSize.size3,
        ));
    ticket.text('${storage.getItem("fullName") ?? ""}',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    ticket.text('Tel: ${storage.getItem("phone") ?? ""}',
        styles: PosStyles(align: PosAlign.center));

    ticket.text("id    : ${order.client.id}");
    ticket.text(
      "name  : ${order.client.fullname}",
    );
    ticket.text(
      'Tel   : 0${order.client.phone}',
    );
    ticket.text(
      'credit: ${order.client.credits.toStringAsFixed(2)} DA',
    );
    ticket.hr();
    ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: '${order.total.toStringAsFixed(2)} DA',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);
    ticket.hr(ch: '=', linesAfter: 1);
    ticket.row([
      PosColumn(
          text: 'Paid :', width: 6, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '${order.paid} DA',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: 'Rest :', width: 6, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '${order.rest} DA',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);

    final now = order.paymentDate;
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    ticket.cut();

    await printerManager.printTicket(ticket);
  }

  Future<Ticket> arabicTest(PaperSize paper) async {
    final Ticket ticket = Ticket(paper);
    ticket.text("يوسف0",
        styles: PosStyles(
          codeTable: PosCodeTable.arabic,
        ));
    ticket.text("يوسف1",
        styles: PosStyles(
          codeTable: PosCodeTable.pc1001_2,
        ));
    ticket.text("2يوسف",
        styles: PosStyles(
          codeTable: PosCodeTable.wp1256,
        ));
    ticket.text("يوسف3",
        styles: PosStyles(
          codeTable: PosCodeTable.pc720,
        ));

    ticket.cut();
  }

  Future<Ticket> demoReceipt(PaperSize paper, Order order) async {
    final Ticket ticket = Ticket(paper);
    bool logo = storage.getItem("logo");
    logo = logo == null
        ? false
        : logo == false
            ? false
            : true;
    if (logo) {
      final image = storage.getItem("image");
      if (image != null) {
        ticket.image(image);
      }
    }
    try {
      ticket.text('${storage.getItem("company") ?? ""}',
          styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));
      ticket.text('${storage.getItem("fullName") ?? ""}',
          styles: PosStyles(align: PosAlign.center));
      ticket.text('Tel: ${storage.getItem("phone") ?? ""}',
          styles: PosStyles(align: PosAlign.center));

      ticket.text("id    : ${order.client.id}");
      ticket.text(
        "name  : ${order.client.fullname}",
      );
      ticket.text(
        'Tel   : 0${order.client.phone}',
      );
      ticket.text(
        'credit: ${order.client.credits.toStringAsFixed(2)} DA',
      );
      ticket.hr();
      ticket.row([
        PosColumn(text: 'box', width: 1),
        PosColumn(text: 'item', width: 5),
        PosColumn(
          text: 'qty',
          width: 1,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: 'prix',
          width: 2,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: 'total',
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);

      for (final product in order.products) {
        ticket.row([
          PosColumn(
            text: product.box.toString(),
            width: 1,
          ),
          PosColumn(
            text: product.name,
            width: 5,
            styles: PosStyles(
              codeTable: PosCodeTable.arabic,
            ),
            containsChinese: true,
          ),
          PosColumn(
              text: product.quantity.toString(),
              width: 1,
              styles: PosStyles(align: PosAlign.right)),
          PosColumn(
              text: product.price().toStringAsFixed(2),
              width: 2,
              styles: PosStyles(align: PosAlign.right)),
          PosColumn(
              text: product.total.toStringAsFixed(2),
              width: 3,
              styles: PosStyles(align: PosAlign.right)),
        ]);
      }
      ticket.hr();

      ticket.row([
        PosColumn(
            text: 'TOTAL',
            width: 6,
            styles: PosStyles(
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            )),
        PosColumn(
            text: '${order.total.toStringAsFixed(2)} DA',
            width: 6,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            )),
      ]);

      ticket.hr(ch: '=', linesAfter: 1);
      ticket.text(
        '${order.count} articles',
      );

      final now = order.paymentDate;
      final formatter = DateFormat('dd/MM/yyyy H:m');
      final String timestamp = formatter.format(now);
      ticket.text("date de payment: $timestamp",
          styles: PosStyles(align: PosAlign.center), linesAfter: 2);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red);
    }
    ticket.cut();
    return ticket;
  }
}
