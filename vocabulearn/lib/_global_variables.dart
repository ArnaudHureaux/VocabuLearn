var speak = 'FRENCH';
var learn = 'ENGLISH';

//ids
String file_learning = 'list_learning.txt';
String file_notlearn = 'list_notlearning.txt';
String file_learned = 'list_learned.txt';
//mots fr & en
String file_learn_learning = 'list_learn_learning.txt';
String file_speak_learning = 'list_speak_learning.txt';
String file_learn_learned = 'list_learn_learned.txt';
String file_speak_learned = 'list_speak_learned.txt';
//settings
String settings =
    'nb_batch,6,nb_questions,5,similarity_threshold,80,step_1,true,step_2,true,step_3,true,difficulty,2,nb_words_max,1000000,prefer_multi,true,speak,FRENCH,learn,ENGLISH';
//settings index :
// nb_batch->0
// 6->1
// nb_questions->2
// 5->3
// similarity_threshold->4
// 80->5
// step_1->6
// true->7
// step_2->8
// true->9
// step_3->10
// true->11
// difficulty->12
// 2->13
// nb_words_max->12
// 20->15
// prefer_multi->16
// true->17
// speak->18
// FRENCH->19
// learn->20
// ENGLISH->21
//ids
get_file_learning(speak, learn) {
  String file_name = speak + '_' + learn + '_' + file_learning;
  return file_name;
}

get_file_notlearn(speak, learn) {
  String file_name = speak + '_' + learn + '_' + file_notlearn;
  return file_name;
}

get_file_learned(speak, learn) {
  String file_name = speak + '_' + learn + '_' + file_learned;
  return file_name;
}

//mots fr & en
get_file_learn_learning(learn) {
  String file_name = file_learn_learning.replaceFirst("learn", learn);
  return file_name;
}

get_file_speak_learning(speak) {
  String file_name = file_speak_learning.replaceFirst("speak", speak);
  return file_name;
}

get_file_learn_learned(learn) {
  String file_name = file_learn_learned.replaceFirst("learn", learn);
  return file_name;
}

get_file_speak_learned(speak) {
  String file_name = file_speak_learned.replaceFirst("speak", speak);
  return file_name;
}

//settings
get_default_settings() {
  return settings;
}
