library server_tests;

import 'package:code_story_2013/server.dart';
import 'package:unittest/unittest.dart';
import 'dart:json';

main() {
  test('q1', () {
      final q = new Q1Handler();
      final question = 'q=Quelle+est+ton+adresse+email';
      final answer = 'alexandre.ardhuin@gmail.com';
      expect(q.handleQuestion(question), equals(true));
      expect(q.handleQuestion('${question}fail'), equals(false));
      expect(q.answer(question), equals(answer));
  });
  test('q2', () {
      final q = new Q2Handler();
      final question = 'q=Es+tu+abonne+a+la+mailing+list(OUI/NON)';
      final answer = 'OUI';
      expect(q.handleQuestion(question), equals(true));
      expect(q.handleQuestion('${question}fail'), equals(false));
      expect(q.answer(question), equals(answer));
  });
  test('q3', () {
    final q = new Q3Handler();
    final question = 'q=Es+tu+heureux+de+participer(OUI/NON)';
    final answer = 'OUI';
    expect(q.handleQuestion(question), equals(true));
    expect(q.handleQuestion('${question}fail'), equals(false));
    expect(q.answer(question), equals(answer));
  });
  test('q4', () {
    final q = new Q4Handler();
    final question = 'q=Es+tu+pret+a+recevoir+une+enonce+au+format+markdown+par+http+post(OUI/NON)';
    final answer = 'OUI';
    expect(q.handleQuestion(question), equals(true));
    expect(q.handleQuestion('${question}fail'), equals(false));
    expect(q.answer(question), equals(answer));
  });
  test('q5', () {
    final q = new Q5Handler();
    final question = 'q=Est+ce+que+tu+reponds+toujours+oui(OUI/NON)';
    final answer = 'NON';
    expect(q.handleQuestion(question), equals(true));
    expect(q.handleQuestion('${question}fail'), equals(false));
    expect(q.answer(question), equals(answer));
  });
  test('enonce1', () {
    final q = new Enonce1Handler();
    for(int i=1; i<7; i++){
      expect(q.split(i).length, equals(1));
    }
    for(int i=7; i<11; i++){
      expect(q.split(i).length, equals(2));
    }
    for(int i=11; i<14; i++){
      expect(q.split(i).length, equals(3));
    }
    for(int i=14; i<18; i++){
      expect(q.split(i).length, equals(4));
    }
    expect(q.split(18).length, equals(5));
    expect(q.split(19).length, equals(5));
    expect(q.split(20).length, equals(5));
    expect(q.split(21).length, equals(7));
  });
  test('q6', () {
    final q = new Q6Handler();
    final question = 'q=As+tu+bien+recu+le+premier+enonce(OUI/NON)';
    final answer = 'OUI';
    expect(q.handleQuestion(question), equals(true));
    expect(q.handleQuestion('${question}fail'), equals(false));
    expect(q.answer(question), equals(answer));
  });
  test('operations', () {
    final q = new OperationsHandler();
    final map = {
      'q=1+1': '2',
      'q=2+2': '4',
      'q=1+5': '6',
      'q=2*5': '10',
      'q=6/2': '3',
      'q=5-2': '3',
      'q=(1+2)*2': '6',
      'q=(1+2)/2': '1,5',
      'q=(4+2)/(1+1)': '3',
      'q=((4+2)/(1+1))+2.3': '5,3',
      'q=((4+2)/(1+1))+(2.3': null,
      'q=(1000.2*4)': '4000,8',
      'q=(1000,2*4)': '4000,8',
      'q=((1+2)+3+4+(5+6+7)+(8+9+10)*3)/2*5': '272,5',
      'q=1,5*4': '6',
      'q=((1,1+2)+3,14+4+(5+6+7)+(8+9+10)*4267387833344334647677634)/2*553344300034334349999000': '31878018903828899277492024491376690701584023926880',
      'q=(-1)+(1)': '0',
    };
    map.forEach((question, answer){
      if(answer != null){
        expect(q.handleQuestion(question), equals(true));
        expect(q.handleQuestion('${question}fail'), equals(false));
        expect(q.answer(question), equals(answer));
      }else{
        expect(q.handleQuestion(question), equals(false));
      }
    });
  });
  test('q7', () {
    final q = new Q7Handler();
    final question = 'q=As+tu+passe+une+bonne+nuit+malgre+les+bugs+de+l+etape+precedente(PAS_TOP/BOF/QUELS_BUGS)';
    final answer = 'PAS_TOP';
    expect(q.handleQuestion(question), equals(true));
    expect(q.handleQuestion('${question}fail'), equals(false));
    expect(q.answer(question), equals(answer));
  });
  test('enonce2', () {
    final q = new Enonce2Handler();
    final orders = new List<Order>()
        ..add(new Order("MONAD42", 0, 5, 10))
        ..add(new Order("META18", 3, 7, 14))
        ..add(new Order("LEGACY01", 5, 9, 8))
        ..add(new Order("YAGNI17", 5, 9, 7))
        ;
    expect(Strings.join(q.findBestTrip(orders).map((e)=>e.vol), ', '), equals("MONAD42, LEGACY01"));
  });
  test('q8', () {
    final q = new Q8Handler();
    final question = 'q=As+tu+bien+recu+le+second+enonce(OUI/NON)';
    final answer = 'OUI';
    expect(q.handleQuestion(question), equals(true));
    expect(q.handleQuestion('${question}fail'), equals(false));
    expect(q.answer(question), equals(answer));
  });
}
