library code_story_2013;

import 'dart:io';
import 'dart:json';
import 'dart:math';
import 'package:decimal/decimal.dart';

void launchServer() {
  final server = new HttpServer();
  final portEnv = Platform.environment['PORT'];
  final host = portEnv != null ? '0.0.0.0' : '192.168.0.11';
//  final host = portEnv != null ? '0.0.0.0' : '192.168.0.16';
  final port = portEnv != null ? int.parse(portEnv) : 8080;
  server.listen(host, port);

  new Q9Handler().register(server);
  new Q8Handler().register(server);
  new LastEnonce2GetHandler().register(server);
  new Enonce2Handler().register(server);
  new Enonce2PostHandler().register(server);
  new Q7Handler().register(server);
  new OperationsHandler().register(server);
  new Q6Handler().register(server);
  new Enonce1Handler().register(server);
  new Enonce1PostHandler().register(server);
  new Q5Handler().register(server);
  new PostHandler().register(server);
  new Q4Handler().register(server);
  new Q3Handler().register(server);
  new Q2Handler().register(server);
  new Q1Handler().register(server);

  [new Q4Handler(), new Q3Handler(), new Q2Handler(), new Q1Handler()].forEach((e) => e.register(server));
  server.defaultRequestHandler = (HttpRequest request, HttpResponse response) {
    print('receive query: ${request.method} ${host}:${request.connectionInfo.localPort}${request.path}?${request.queryString} from ${request.connectionInfo.remoteHost}:${request.connectionInfo.remotePort}');
    sendResponse(response, "I don't know (yet)...", HttpStatus.NOT_IMPLEMENTED);
  };
}

void sendResponse(HttpResponse response, String content, [int statusCode = HttpStatus.OK]){
  response.statusCode = statusCode;
  response.outputStream.writeString(content);
  response.outputStream.close();
}

abstract class Handler {
  bool accept(HttpRequest request);
  void handle(HttpRequest request, HttpResponse response);
  void register(HttpServer server) {
    server.addRequestHandler(accept, handle);
  }
}

abstract class QuestionHandler extends Handler {
  bool handleQuestion(String queryString);
  String answer(String queryString);
  bool accept(HttpRequest request) => request.method.toUpperCase() == 'GET' && this.handleQuestion(request.queryString);
  void handle(HttpRequest request, HttpResponse response){
    sendResponse(response, this.answer(request.queryString));
  }
}

class Q1Handler extends QuestionHandler {
  bool handleQuestion(String queryString) => queryString == 'q=Quelle+est+ton+adresse+email';
  String answer(String queryString) => "alexandre.ardhuin@gmail.com";
}

class Q2Handler extends QuestionHandler {
  bool handleQuestion(String queryString) => queryString == 'q=Es+tu+abonne+a+la+mailing+list(OUI/NON)';
  String answer(String queryString) => "OUI";
}

class Q3Handler extends QuestionHandler {
  bool handleQuestion(String queryString) => queryString == 'q=Es+tu+heureux+de+participer(OUI/NON)';
  String answer(String queryString) => "OUI";
}

class Q4Handler extends QuestionHandler {
  bool handleQuestion(String queryString) => queryString == 'q=Es+tu+pret+a+recevoir+une+enonce+au+format+markdown+par+http+post(OUI/NON)';
  String answer(String queryString) => "OUI";
}

class Q5Handler extends QuestionHandler {
  bool handleQuestion(String queryString) => queryString == 'q=Est+ce+que+tu+reponds+toujours+oui(OUI/NON)';
  String answer(String queryString) => "NON";
}

class Q6Handler extends QuestionHandler {
  bool handleQuestion(String queryString) => queryString == 'q=As+tu+bien+recu+le+premier+enonce(OUI/NON)';
  String answer(String queryString) => "OUI";
}

class Closing {
  final String s;
  int startIndex;
  int endIndex;
  Closing(this.s) {
    startIndex = s.indexOf('(');
    int countOpen = 1;
    int currentIndex = startIndex;
    while(true){
      int nextOpen = s.indexOf('(', currentIndex + 1);
      int nextClose = s.indexOf(')', currentIndex + 1);
      if (nextClose == -1) {
        endIndex = -1;
        break;
      }
      if(nextOpen == -1 || nextClose < nextOpen) {
        if (countOpen == 1){
          endIndex = nextClose;
          break;
        } else {
          currentIndex = nextClose;
          countOpen--;
        }
      } else {
        currentIndex = nextOpen;
        countOpen++;
      }
    }
  }
  bool match() => startIndex >= 0 && startIndex < endIndex;
  String left() => s.substring(0, startIndex);
  String middle() => s.substring(startIndex + 1, endIndex);
  String right() => s.substring(endIndex + 1);
}
typedef num ApplyFunc(num left, num right);
class OpBinary {
  final String _op;
  final ApplyFunc apply;
  OpBinary(this._op, this.apply);
  bool match(String s) => s.indexOf(_op) > 0 && s.length >= _op.length + 2;
  String left(String s) => s.substring(0, s.indexOf(_op));
  String right(String s) => s.substring(s.indexOf(_op) + 1);
}
final opsBinary = [
  new OpBinary('+', (l, r) => l + r),
  new OpBinary('-', (l, r) => l - r),
  new OpBinary('*', (l, r) => l * r),
  new OpBinary('/', (l, r) => (l is int && r is int && l % r == 0) ? l ~/ r : l / r),
];
class OperationsHandler extends QuestionHandler {
  bool handleQuestion(String queryString) => queryString !=null && queryString.startsWith("q=") && resolve(queryString.substring("q=".length)) != null;

  String answer(String queryString){
    final number = resolve(queryString.substring("q=".length));
    return number.toString().replaceAll('.', ',');
  }

  Decimal resolve(String s) {
    // print("parse ${s}");
    final closing = new Closing(s);
    if (closing.match()) {
      final middleValue = resolve(closing.middle());
      return middleValue == null ? null : resolve('${closing.left()}${middleValue}${closing.right()}');
    }
    for (final opBinary in opsBinary) {
      if (opBinary.match(s)) {
        final leftValue = resolve(opBinary.left(s));
        final rightValue = resolve(opBinary.right(s));
        return leftValue == null || rightValue == null ? null : opBinary.apply(leftValue, rightValue);
      }
    }
    try {
      return new Decimal(s.replaceFirst(',', '.'));
    } on FormatException {
        print('Bad number:${s}');
        return null;
    }
  }
}

class Q7Handler extends QuestionHandler {
  bool handleQuestion(String queryString) => queryString == 'q=As+tu+passe+une+bonne+nuit+malgre+les+bugs+de+l+etape+precedente(PAS_TOP/BOF/QUELS_BUGS)';
  String answer(String queryString) => "PAS_TOP";
}

class PostHandler extends Handler {
  bool accept(HttpRequest request) => request.method.toUpperCase() == 'POST';
  void handle(HttpRequest request, HttpResponse response) {
    readStreamAsString(request.inputStream).then((content) {
      print("------------------- receive POST");
      print(content.replaceAll('\n', '<aa:br/>'));
      print("------------------- receive POST </end>");
      sendResponse(response, "WAT!", HttpStatus.NOT_IMPLEMENTED);
    });
  }
}

class Enonce1PostHandler extends Handler {
  bool accept(HttpRequest request) => request.method.toUpperCase() == 'POST' && request.path == '/enonce/1';
  void handle(HttpRequest request, HttpResponse response) {
    response.headers.add(HttpHeaders.LOCATION, '/scalaskel/change');
    response.statusCode = HttpStatus.CREATED;
    response.outputStream.writeString("come on!");
    response.outputStream.close();
  }
}

class FooBarQixBaz {
  static final FOO = 1;
  static final BAR = 7;
  static final QIX = 11;
  static final BAZ = 21;
  int foo, bar, qix, baz;
  FooBarQixBaz({this.foo:0, this.bar:0, this.qix:0, this.baz:0});
  toJson() {
    final map = new Map();
    if (foo > 0) map['foo'] = foo;
    if (bar > 0) map['bar'] = bar;
    if (qix > 0) map['qix'] = qix;
    if (baz > 0) map['baz'] = baz;
    return map;
  }
  bool operator ==(FooBarQixBaz other) => foo == other.foo && bar == other.bar && qix == other.qix && baz == other.baz ;
  int get value => FOO * foo + BAR * bar + QIX * qix + BAZ * baz;
}
class Enonce1Handler extends Handler {
  bool accept(HttpRequest request) => request.method.toUpperCase() == 'GET' && request.path.startsWith('/scalaskel/change/');
  void handle(HttpRequest request, HttpResponse response) {
    final param = request.path.substring('/scalaskel/change/'.length);
    try {
      final number = int.parse(param);
      if (number < 1 || number > 100) {
        sendBadParam(response, param);
      } else {
        final result = split(number);
        response.statusCode = HttpStatus.OK;
        response.outputStream.writeString(JSON.stringify(new List.from(result)));
        response.outputStream.close();
      }
    } on FormatException {
      sendBadParam(response, param);
    }
  }

  Set<FooBarQixBaz> split(int number) {
    Set<FooBarQixBaz> combinations = new Set<FooBarQixBaz>.from([new FooBarQixBaz(foo:number)]);
    combinations = _change(combinations, FooBarQixBaz.BAR, (fooBarQixBaz, numberOfDeal) => new FooBarQixBaz(foo : fooBarQixBaz.foo - numberOfDeal * FooBarQixBaz.BAR, bar : fooBarQixBaz.bar + numberOfDeal, qix : fooBarQixBaz.qix, baz : fooBarQixBaz.baz));
    combinations = _change(combinations, FooBarQixBaz.QIX, (fooBarQixBaz, numberOfDeal) => new FooBarQixBaz(foo : fooBarQixBaz.foo - numberOfDeal * FooBarQixBaz.QIX, bar : fooBarQixBaz.bar, qix : fooBarQixBaz.qix + numberOfDeal, baz : fooBarQixBaz.baz));
    combinations = _change(combinations, FooBarQixBaz.BAZ, (fooBarQixBaz, numberOfDeal) => new FooBarQixBaz(foo : fooBarQixBaz.foo - numberOfDeal * FooBarQixBaz.BAZ, bar : fooBarQixBaz.bar, qix : fooBarQixBaz.qix, baz : fooBarQixBaz.baz + numberOfDeal));
    // print("${number} : ${JSON.stringify(new List.from(combinations))}");
    return combinations;
  }

  Set<FooBarQixBaz> _change(combinations, int numberOfFooToDeal, FooBarQixBaz deal(FooBarQixBaz fooBarQixBaz, int numberOfDeal)) {
    final newCombinations = new Set<FooBarQixBaz>.from(combinations);
    for (final fooBarQixBaz in combinations) {
      int i = 0;
      while (true) {
        i++;
        if(fooBarQixBaz.foo >= i * numberOfFooToDeal) {
          newCombinations.add(deal(fooBarQixBaz, i));
        } else {
          break;
        }
      }
    }
    return newCombinations;
  }

  void sendBadParam(HttpResponse response, String param) {
    response.statusCode = HttpStatus.BAD_REQUEST;
    response.outputStream.writeString("you said a number between 1 and 100 but '${param}' is incorrect.");
    response.outputStream.close();
  }
}

class Enonce2PostHandler extends Handler {
  bool accept(HttpRequest request) => request.method.toUpperCase() == 'POST' && request.path == '/enonce/2';
  void handle(HttpRequest request, HttpResponse response) {
    response.headers.add(HttpHeaders.LOCATION, '/jajascript/optimize');
    response.statusCode = HttpStatus.CREATED;
    response.outputStream.writeString("come on!");
    response.outputStream.close();
  }
}
class Order {
  final String vol;
  final int depart, duree, prix;
  Order(this.vol, this.depart, this.duree, this.prix);
  int get arrivee => depart + duree;
  List<Order> get path => [this];
  String toString() => '${vol}(${depart}-${arrivee}/${prix})';
  toJson() => {
    'VOL': vol,
    'DEPART': depart,
    'DUREE': duree,
    'PRIX': prix
  };
}
class CompositeOrder extends Order {
  final List<Order> _orders;
  CompositeOrder(List<Order> orders) : super('composite', orders.first.depart, orders.last.depart + orders.last.duree - orders.first.depart, Enonce2Handler.computePrix(orders)), this._orders = orders;
  List<Order> get path => _orders;
  String toString() => Strings.join(_orders.map((e) => e.toString()), ', ');
}
String lastEnonce2 = "";
class LastEnonce2GetHandler extends Handler {
  bool accept(HttpRequest request) => request.method == 'GET' && request.path == '/jajascript/optimize';
  void handle(HttpRequest request, HttpResponse response) {
    response.statusCode = HttpStatus.OK;
    response.outputStream.writeString(lastEnonce2);
    response.outputStream.close();
  }
}
class Enonce2Handler extends Handler {
  int queryCount = 1;
  bool accept(HttpRequest request) => request.method == 'POST' && request.path == '/jajascript/optimize';
  void handle(HttpRequest request, HttpResponse response) {
    final queryId = queryCount++;
    final swReadInput = new Stopwatch()..start();
    readStreamAsString(request.inputStream).then((content) {
      print("$queryId : input read in ${swReadInput.elapsedMicroseconds}µs");
      lastEnonce2 = content;

      try {
        final List<Order> orders = mesure('$queryId : read JSON', () => deserialize(content));
        print('$queryId : received optimize request with ${orders.length} orders');
        final List<Order> bestTrip = mesure('$queryId : findBestTrip', () => findBestTrip(orders));

        // send response
        response.statusCode = HttpStatus.OK;
        response.headers.add(HttpHeaders.CONTENT_TYPE, "application/json");
        mesure('$queryId : send response', () => response.outputStream.writeString(mesure('$queryId : getResultAsString', () => getResultAsString(bestTrip))));
      } catch (e) {
        print('bad json $e');
        response.statusCode = HttpStatus.BAD_REQUEST;
        response.outputStream.writeString("You send me bad json");
      }
      response.outputStream.close();
      print("$queryId : all has been done in ${swReadInput.elapsedMicroseconds}µs");
    });
  }

  List<Order> deserialize(String json) => JSON.parse(json).map((e) => new Order(e['VOL'], e['DEPART'], e['DUREE'], e['PRIX']));
  String getResultAsString(List<Order> orders) => JSON.stringify({
    "gain" : computePrix(orders),
    "path" : orders.map((e) => e.vol),
  });

  static int computePrix(List<Order> trip) => trip.reduce(0, (int previousValue, e) => previousValue + e.prix);

  List<Order> findBestTrip(List<Order> _orders) {
    if (_orders.isEmpty) return [];

    List<Order> orders = new List<Order>.from(_orders);

    // sort
    orders.sort((e1, e2) {
      int departComp = e1.depart.compareTo(e2.depart);
      return departComp != 0 ? departComp : e1.duree.compareTo(e2.duree);
    });

    // construct result
    for (int i = 0; i < orders.length;) {
      final index = i;

      // looking for range with same depart
      final depart = orders[i].depart;
      while (++i < orders.length && depart == orders[i].depart) {
      }

      // search cleanables : order with arrivee before depart
      final cleanableIndexes = new List<int>();
      final cleanables = new List<Order>();
      for (int j = 0; j < index; j++) {
        final order = orders[j];
        if (order.arrivee <= depart) {
          cleanableIndexes.add(j);
          cleanables.add(order);
        }
      }

      // compose cleanable with orders starting at depart
      if (cleanables.length > 0) {
        final bestBeforeLastDepart = _findBestOrder(cleanables);
        for (int j = cleanableIndexes.length - 1; j >= 0; j--) {
          final cleanable = cleanables[j];
          if (cleanable != bestBeforeLastDepart) {
            orders.removeAt(cleanableIndexes[j]);
          }
        }
        i -= cleanables.length - 1;

        //
        for (int j = index - (cleanables.length - 1); j < i; j++) {
          orders[j] = new CompositeOrder(new List<Order>.from(bestBeforeLastDepart.path)..addAll(orders[j].path));
        }
      }
    }

    // exit or refine one  more time
    final best = _findBestOrder(orders);
    return  best == null ? [] : best.path;
  }
  Order _findBestOrder(List<Order> orders) => orders.isEmpty ? null :
    orders.reduce(orders.first, (Order best, Order order) =>
        order.prix > best.prix || (order.prix == best.prix && order.duree < best.duree) ? order : best);
}

class Q8Handler extends QuestionHandler {
  bool handleQuestion(String queryString) => queryString == 'q=As+tu+bien+recu+le+second+enonce(OUI/NON)';
  String answer(String queryString) => "OUI";
}

class Q9Handler extends QuestionHandler {
  bool handleQuestion(String queryString) => queryString == 'q=As+tu+copie+le+code+de+ndeloof(OUI/NON/JE_SUIS_NICOLAS)';
  String answer(String queryString) => "NON";
}

Future<String> readStreamAsString(InputStream stream) {
  final completer = new Completer();
  final sb = new StringBuffer();
  final sis = new StringInputStream(stream);
  sis
    ..onData = () { sb.add(sis.read()); }
    ..onClosed = () { completer.complete(sb.toString()); }
    ..onError = (e) { completer.completeException(e); };
  return completer.future;
}

dynamic mesure(String desc, f()) {
  final sw = new Stopwatch()..start();
  final result = f();
  print('$desc done in ${sw.elapsedMicroseconds}µs');
  return result;
}
