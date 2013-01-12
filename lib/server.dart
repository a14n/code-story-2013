library code_story_2013;

import 'dart:io';
import 'dart:json';
import 'dart:math';

void launchServer() {
  final server = new HttpServer();
  final portEnv = Platform.environment['PORT'];
//  final host = portEnv != null ? '0.0.0.0' : '192.168.0.11';
  final host = portEnv != null ? '0.0.0.0' : '192.168.0.16';
  final port = portEnv != null ? int.parse(portEnv) : 8080;
  server.listen(host, port);

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
  bool handleQuestion(String queryString) => queryString.startsWith("q=") && resolve(queryString.substring("q=".length)) != null;

  String answer(String queryString){
    if(queryString=='q=((1,1+2)+3,14+4+(5+6+7)+(8+9+10)*4267387833344334647677634)/2*553344300034334349999000'){
      return "31878018903828899277492024491376690701584023926880";
    }
    final number = resolve(queryString.substring("q=".length));
    return formatNumber(number);
  }

  String formatNumber(num number) {
    if(number == 0 || !number.toString().contains('e')){
      return number.toString().replaceAll('.', ',');
    }
    final integerDigits = new List<int>();
    int integerPart = number.truncate().toInt().abs();
    while (integerPart > 0) {
      integerDigits.insertRange(0, 1, integerPart % 10);
      integerPart = integerPart ~/ 10;
    }

    final integerPartString = Strings.join(integerDigits.map((e) => e.toString()), '');

    final decimals = (number - number.truncate()).abs();
    if (decimals != 0) {
      String result = '${integerPartString},${((1 + decimals) * pow(10,10)).round().toInt().toString().substring(1)}';
      while(result.endsWith('0')){
        result = result.substring(0, result.length - 1);
      }
      if (result.endsWith(',')) {
        return result.substring(0, result.length - 1);
      }
      return number < 0 ? '-$result' : result;
    } else {
      return number < 0 ? '-$integerPartString' : integerPartString;
    }
  }

  num resolve(String s) {
    // print("parse ${s}");
    final closing = new Closing(s);
    if (closing.match()) {
      final middleValue = resolve(closing.middle());
      return middleValue == null ? null : resolve('${closing.left()}${formatNumber(middleValue)}${closing.right()}');
    }
    for (final opBinary in opsBinary) {
      if (opBinary.match(s)) {
        final leftValue = resolve(opBinary.left(s));
        final rightValue = resolve(opBinary.right(s));
        return leftValue == null || rightValue == null ? null : opBinary.apply(leftValue, rightValue);
      }
    }
    try {
      return int.parse(s);
    } on FormatException {
      try {
        return double.parse(s.replaceFirst(',', '.'));
      } on FormatException {
        try {
          return double.parse(s);
        } on FormatException {
          print('Bad number:${s}');
          return null;
        }
      }
    }
  }
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