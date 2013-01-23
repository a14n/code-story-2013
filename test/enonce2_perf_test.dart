import 'package:code_story_2013/server.dart';
import 'package:unittest/unittest.dart';
import 'dart:json' as JSON;
import 'dart:math';
import 'dart:io';
import 'dart:uri';
import 'package:benchmark_harness/benchmark_harness.dart';

main() {
//  final orders = generate(5000);
//  final json = JSON.stringify(orders);
//  final json = JSON.stringify(codeStory60());
//  new File('data.json').writeAsStringSync(json);
//  Benchmark.main();
//  final json = new File('data.json').readAsStringSync();
  final json = new File('data-50000.json').readAsStringSync();
//  testRemote(json, 'http://code-story-a14n-2013.herokuapp.com/jajascript/optimize');
  testRemote(json, 'http://192.168.0.11:8080/jajascript/optimize');
//  testLocal(json);
}

testRemote(String json, String uri) {
  final client = new HttpClient();
  final hcc = client.postUrl(new Uri.fromString(uri));
  hcc.onRequest = (request) {
    request.contentLength = json.length;
    request.outputStream.writeString(json);
  };
  hcc.onResponse = (response) {
    response.inputStream.pipe(stderr);
  };
}

class Benchmark extends BenchmarkBase {

  const Benchmark() : super("Template");

  static void main() {
    new Benchmark().report();
  }

  // The benchmark code.
  void run() {
    final orders = readJson(new File('data.json').readAsStringSync());
    final q = new Enonce2Handler();
    final best = q.findBestTrip(orders);
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() { }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { }
}

testLocal(String json) {
  optimize(readJson(json));
}

progressive(List<Order> orders) {
  for(int i=0; i<orders.length; i++){
    final subOrders = orders.getRange(0, i);
    print(subOrders);
    optimize(subOrders);
  }
}

optimize(List<Order> orders) {
  final sw = new Stopwatch()..start();
  final q = new Enonce2Handler();
  final best = q.findBestTrip(orders);
  print(best);
  print(q.getResultAsString(best));
  print("${orders.length} : ${sw.elapsedMicroseconds}");
}

List<Order> generate(int numOrders) {
  final rnd = new Random();
  final orders = new List<Order>();
  for (int i = 0; i < numOrders; i++) {
    orders.add(new Order('v-$i', (i*rnd.nextDouble()).toInt(), 1 + (60*rnd.nextDouble()).toInt(), 1 + (50*rnd.nextDouble()).toInt()));
  }
  return orders;
}

List<Order> codeStory60() {
  final json = '[{"VOL":"annoying-suburbanite-50","DEPART":0,"DUREE":4,"PRIX":12},{"VOL":"hilarious-drop-26","DEPART":1,"DUREE":2,"PRIX":3},{"VOL":"real-lemon-40","DEPART":2,"DUREE":6,"PRIX":6},{"VOL":"thankful-infantry-45","DEPART":4,"DUREE":5,"PRIX":20},{"VOL":"aggressive-lake-13","DEPART":5,"DUREE":2,"PRIX":26},{"VOL":"melodic-scoreboard-4","DEPART":5,"DUREE":4,"PRIX":7},{"VOL":"tough-reptile-66","DEPART":6,"DUREE":2,"PRIX":9},{"VOL":"terrible-stalker-57","DEPART":7,"DUREE":6,"PRIX":4},{"VOL":"old-fashioned-servant-96","DEPART":9,"DUREE":5,"PRIX":23},{"VOL":"helpless-ballerina-99","DEPART":10,"DUREE":2,"PRIX":25},{"VOL":"teeny-tiny-rowboat-23","DEPART":10,"DUREE":4,"PRIX":7},{"VOL":"homeless-mushroom-87","DEPART":11,"DUREE":2,"PRIX":1},{"VOL":"wrong-freight-1","DEPART":12,"DUREE":6,"PRIX":2},{"VOL":"frantic-herb-27","DEPART":14,"DUREE":5,"PRIX":9},{"VOL":"clear-ware-75","DEPART":15,"DUREE":2,"PRIX":29},{"VOL":"brainy-robot-95","DEPART":15,"DUREE":4,"PRIX":8},{"VOL":"teeny-tiny-nectarine-99","DEPART":16,"DUREE":2,"PRIX":2},{"VOL":"melodic-tourism-95","DEPART":17,"DUREE":6,"PRIX":4},{"VOL":"curved-tweed-63","DEPART":19,"DUREE":5,"PRIX":10},{"VOL":"helpless-bar-10","DEPART":20,"DUREE":2,"PRIX":9},{"VOL":"arrogant-block-94","DEPART":20,"DUREE":4,"PRIX":9},{"VOL":"encouraging-bonbon-33","DEPART":21,"DUREE":2,"PRIX":4},{"VOL":"moaning-anorexic-83","DEPART":22,"DUREE":6,"PRIX":6},{"VOL":"ugliest-metropolitan-16","DEPART":24,"DUREE":5,"PRIX":14},{"VOL":"gentle-numerate-96","DEPART":25,"DUREE":2,"PRIX":6},{"VOL":"clever-polygamy-2","DEPART":25,"DUREE":4,"PRIX":10},{"VOL":"terrible-flashbulb-2","DEPART":26,"DUREE":2,"PRIX":6},{"VOL":"melodic-surfer-63","DEPART":27,"DUREE":6,"PRIX":5},{"VOL":"light-radiologist-77","DEPART":29,"DUREE":5,"PRIX":23},{"VOL":"faithful-factory-2","DEPART":30,"DUREE":2,"PRIX":14},{"VOL":"faithful-zephyr-13","DEPART":30,"DUREE":4,"PRIX":12},{"VOL":"deafening-loft-31","DEPART":31,"DUREE":2,"PRIX":1},{"VOL":"hungry-banker-27","DEPART":32,"DUREE":6,"PRIX":2},{"VOL":"slow-barnacle-73","DEPART":34,"DUREE":5,"PRIX":12},{"VOL":"melodic-chef-46","DEPART":35,"DUREE":2,"PRIX":15},{"VOL":"agreeable-knob-11","DEPART":35,"DUREE":4,"PRIX":15},{"VOL":"graceful-nomad-25","DEPART":36,"DUREE":2,"PRIX":6},{"VOL":"wrong-moon-11","DEPART":37,"DUREE":6,"PRIX":6},{"VOL":"condemned-steward-16","DEPART":39,"DUREE":5,"PRIX":14},{"VOL":"wrong-teepee-92","DEPART":40,"DUREE":2,"PRIX":7},{"VOL":"dizzy-servitude-39","DEPART":40,"DUREE":4,"PRIX":12},{"VOL":"lucky-alcoholic-54","DEPART":41,"DUREE":2,"PRIX":2},{"VOL":"blue-easel-78","DEPART":42,"DUREE":6,"PRIX":7},{"VOL":"vast-stove-59","DEPART":44,"DUREE":5,"PRIX":22},{"VOL":"repulsive-peak-22","DEPART":45,"DUREE":2,"PRIX":6},{"VOL":"wonderful-sign-87","DEPART":45,"DUREE":4,"PRIX":15},{"VOL":"naughty-stream-75","DEPART":46,"DUREE":2,"PRIX":2},{"VOL":"proud-safari-25","DEPART":47,"DUREE":6,"PRIX":1},{"VOL":"creepy-harvester-40","DEPART":49,"DUREE":5,"PRIX":16},{"VOL":"repulsive-loudmouth-28","DEPART":50,"DUREE":2,"PRIX":29},{"VOL":"different-quintuple-88","DEPART":50,"DUREE":4,"PRIX":6},{"VOL":"lonely-repairman-54","DEPART":51,"DUREE":2,"PRIX":9},{"VOL":"gleaming-mesquite-34","DEPART":52,"DUREE":6,"PRIX":5},{"VOL":"frail-porterhouse-59","DEPART":54,"DUREE":5,"PRIX":21},{"VOL":"colorful-rhinestone-77","DEPART":55,"DUREE":2,"PRIX":7},{"VOL":"grieving-percussionist-43","DEPART":55,"DUREE":4,"PRIX":9},{"VOL":"hungry-knickknack-73","DEPART":56,"DUREE":2,"PRIX":6},{"VOL":"crooked-teamwork-18","DEPART":57,"DUREE":6,"PRIX":6},{"VOL":"quiet-queen-29","DEPART":59,"DUREE":5,"PRIX":6},{"VOL":"whispering-harp-4","DEPART":60,"DUREE":2,"PRIX":6}]';
  //final json = '[{"VOL":"annoying-suburbanite-50","DEPART":0,"DUREE":4,"PRIX":12},{"VOL":"hilarious-drop-26","DEPART":1,"DUREE":2,"PRIX":3},{"VOL":"real-lemon-40","DEPART":2,"DUREE":6,"PRIX":6},{"VOL":"thankful-infantry-45","DEPART":4,"DUREE":5,"PRIX":20},{"VOL":"aggressive-lake-13","DEPART":5,"DUREE":2,"PRIX":26},{"VOL":"melodic-scoreboard-4","DEPART":5,"DUREE":4,"PRIX":7},{"VOL":"tough-reptile-66","DEPART":6,"DUREE":2,"PRIX":9},{"VOL":"terrible-stalker-57","DEPART":7,"DUREE":6,"PRIX":4},{"VOL":"old-fashioned-servant-96","DEPART":9,"DUREE":5,"PRIX":23},{"VOL":"helpless-ballerina-99","DEPART":10,"DUREE":2,"PRIX":25},{"VOL":"teeny-tiny-rowboat-23","DEPART":10,"DUREE":4,"PRIX":7},{"VOL":"homeless-mushroom-87","DEPART":11,"DUREE":2,"PRIX":1},{"VOL":"wrong-freight-1","DEPART":12,"DUREE":6,"PRIX":2},{"VOL":"frantic-herb-27","DEPART":14,"DUREE":5,"PRIX":9},{"VOL":"clear-ware-75","DEPART":15,"DUREE":2,"PRIX":29},{"VOL":"brainy-robot-95","DEPART":15,"DUREE":4,"PRIX":8},{"VOL":"teeny-tiny-nectarine-99","DEPART":16,"DUREE":2,"PRIX":2},{"VOL":"melodic-tourism-95","DEPART":17,"DUREE":6,"PRIX":4},{"VOL":"curved-tweed-63","DEPART":19,"DUREE":5,"PRIX":10},{"VOL":"helpless-bar-10","DEPART":20,"DUREE":2,"PRIX":9},{"VOL":"arrogant-block-94","DEPART":20,"DUREE":4,"PRIX":9},{"VOL":"encouraging-bonbon-33","DEPART":21,"DUREE":2,"PRIX":4},{"VOL":"moaning-anorexic-83","DEPART":22,"DUREE":6,"PRIX":6},{"VOL":"ugliest-metropolitan-16","DEPART":24,"DUREE":5,"PRIX":14},{"VOL":"gentle-numerate-96","DEPART":25,"DUREE":2,"PRIX":6},{"VOL":"clever-polygamy-2","DEPART":25,"DUREE":4,"PRIX":10},{"VOL":"terrible-flashbulb-2","DEPART":26,"DUREE":2,"PRIX":6},{"VOL":"melodic-surfer-63","DEPART":27,"DUREE":6,"PRIX":5},{"VOL":"light-radiologist-77","DEPART":29,"DUREE":5,"PRIX":23},{"VOL":"faithful-factory-2","DEPART":30,"DUREE":2,"PRIX":14},{"VOL":"faithful-zephyr-13","DEPART":30,"DUREE":4,"PRIX":12},{"VOL":"deafening-loft-31","DEPART":31,"DUREE":2,"PRIX":1},{"VOL":"hungry-banker-27","DEPART":32,"DUREE":6,"PRIX":2},{"VOL":"slow-barnacle-73","DEPART":34,"DUREE":5,"PRIX":12},{"VOL":"melodic-chef-46","DEPART":35,"DUREE":2,"PRIX":15},{"VOL":"agreeable-knob-11","DEPART":35,"DUREE":4,"PRIX":15},{"VOL":"graceful-nomad-25","DEPART":36,"DUREE":2,"PRIX":6},{"VOL":"wrong-moon-11","DEPART":37,"DUREE":6,"PRIX":6},{"VOL":"condemned-steward-16","DEPART":39,"DUREE":5,"PRIX":14},{"VOL":"wrong-teepee-92","DEPART":40,"DUREE":2,"PRIX":7},{"VOL":"dizzy-servitude-39","DEPART":40,"DUREE":4,"PRIX":12},{"VOL":"lucky-alcoholic-54","DEPART":41,"DUREE":2,"PRIX":2},{"VOL":"blue-easel-78","DEPART":42,"DUREE":6,"PRIX":7},{"VOL":"vast-stove-59","DEPART":44,"DUREE":5,"PRIX":22},{"VOL":"repulsive-peak-22","DEPART":45,"DUREE":2,"PRIX":6},{"VOL":"wonderful-sign-87","DEPART":45,"DUREE":4,"PRIX":15},{"VOL":"naughty-stream-75","DEPART":46,"DUREE":2,"PRIX":2},{"VOL":"proud-safari-25","DEPART":47,"DUREE":6,"PRIX":1},{"VOL":"creepy-harvester-40","DEPART":49,"DUREE":5,"PRIX":16},{"VOL":"repulsive-loudmouth-28","DEPART":50,"DUREE":2,"PRIX":29},{"VOL":"different-quintuple-88","DEPART":50,"DUREE":4,"PRIX":6},{"VOL":"lonely-repairman-54","DEPART":51,"DUREE":2,"PRIX":9},{"VOL":"gleaming-mesquite-34","DEPART":52,"DUREE":6,"PRIX":5},{"VOL":"frail-porterhouse-59","DEPART":54,"DUREE":5,"PRIX":21}]';
  return readJson(json);
}
List<Order> readJson(json) => new Enonce2Handler().deserialize(json);
