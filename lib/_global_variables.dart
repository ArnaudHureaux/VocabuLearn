//ids
String file_learning = 'list_learning.txt';
String file_notlearn = 'list_notlearning.txt';
String file_learned = 'list_learned.txt';
//mots fr & en
String file_en_learning = 'list_en_learning.txt';
String file_fr_learning = 'list_fr_learning.txt';
String file_en_learned = 'list_en_learned.txt';
String file_fr_learned = 'list_fr_learned.txt';
//settings
String settings =
    'nb_batch,6,nb_questions,5,similarity_threshold,80,step_1,true,step_2,true,step_3,true,difficulty,2,nb_words_max,20,prefer_multi,true';

//ids
get_file_learning() {
  return file_learning;
}

get_file_notlearn() {
  return file_notlearn;
}

get_file_learned() {
  return file_learned;
}

//mots fr & en
get_file_en_learning() {
  return file_en_learning;
}

get_file_fr_learning() {
  return file_fr_learning;
}

get_file_en_learned() {
  return file_en_learned;
}

get_file_fr_learned() {
  return file_fr_learned;
}

//settings
get_default_settings() {
  return settings;
}
