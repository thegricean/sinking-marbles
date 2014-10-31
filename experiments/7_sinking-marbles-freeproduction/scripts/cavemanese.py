import jsonrpc
from json import loads
import csv
import re
import sys

server = jsonrpc.ServerProxy(jsonrpc.JsonRpc20(),
                             jsonrpc.TransportTcpIp(addr=("127.0.0.1", 8080)))

def is_pronoun(possible_pronoun):
  return possible_pronoun in ["he", "him", "his",
                              "she", "her", "hers",
                              "it", "its",
                            "they", "them", "their", "theirs",
                            "we", "us", "our"
                            ]

def is_possessive(pronoun, pronoun_coref, sentences):
  sentence_index = pronoun_coref[1]
  word_index = pronoun_coref[3]
  sentence = sentences[sentence_index]
  #print sentence
  words = sentence["words"]
  #print words
  word = words[word_index]
  #print word
  pos = word[1]["PartOfSpeech"]
  #print pos
  if pronoun == "her":
    #print words
    #print pronoun_index
    #print words[pronoun_index]
    #print words[pronoun_index][1]
    #print words[pronoun_index][1]["PartOfSpeech"]
    #return pos == "PRP$"
    return False
  else:
    return pronoun in ["his", "hers", "its", "their", "theirs", "our"]

def sent_length(sentence):
  no_quote_sentence = re.sub("'", " '", sentence)
  return len(no_quote_sentence.split(" "))

def sent_replace(sentence, index, replacement):
  no_quote_sentence = re.sub("'", " ", sentence)
  new_sentence = no_quote_sentence.split(" ")
  new_sentence[index] = replacement
  return " ".join(new_sentence)

def clean(word):
  w = re.sub(" 's$", "", word)
  w = re.sub("'s$", "", w)
  return w

def lemmatize(element, words):
  for word in words:
    if word[0] == element:
      return word[1]["Lemma"]
  print "error 7"

def cavemanify(text):
  result = loads(server.parse(text))
  sentence = result["sentences"][0]
  dependencies = sentence["dependencies"]
  words = sentence["words"]
  tense = "future"
  p_raw = ""
  p_prime_raw = ""
  s = ""
  n = ""
  p = ""
  o = ""
  s_prime = ""
  n_prime = ""
  p_prime = ""
  o_prime = ""
  baby_cavemanese = ""
  cavemanese = ""
  has_passive_agent = False
  for dependency in dependencies:
    if dependency[0] == "root":
      p_raw = dependency[2]
      p = lemmatize(p_raw, words)
  for dependency in dependencies:
    if dependency[0][:5] == "nsubj" and dependency[1] == p_raw and (not dependency[0] == "nsubjpass"):
      s = lemmatize(dependency[2], words)
    if (dependency[0] == "dobj" or dependency[0][:4] == "prep") and dependency[1] == p_raw:
      o = lemmatize(dependency[2], words)
    if dependency[0] == "xcomp" and dependency[1] == p_raw:
      p_prime_raw = dependency[2]
      p_prime = lemmatize(p_prime_raw, words)
    if dependency[0] == "neg" and dependency[1] == p_raw:
      n = "not"
  for dependency in dependencies:
    if dependency[0] == "agent" and dependency[1] == p_raw:
      has_passive_agent = True
      s = lemmatize(dependency[2], words)
  for dependency in dependencies:
    if dependency[0] == "nsubjpass" and dependency[1] == p_raw:
      if has_passive_agent:
        o = lemmatize(dependency[2], words)
      else:
        s = lemmatize(dependency[2], words)
        p = p_raw
  if p_prime != "":
    for dependency in dependencies:
      if dependency[0][:5] == "nsubj" and dependency[1] == p_prime_raw:
        s_prime = lemmatize(dependency[2], words)
      if (dependency[0] == "dobj" or dependency[0][:4] == "prep") and dependency[1] == p_prime_raw:
        o_prime = lemmatize(dependency[2], words)
      if dependency[0] == "neg" and dependency[1] == p_prime_raw:
        n_prime = "not"
  just_main_verb = p
  baby_cavemanese = " ".join([x for x in [s, n, p] if x != ""])
  cavemanese = " ".join([x for x in [s, n, p, s_prime, n_prime, p_prime, o_prime, o] if x != ""])
  return (just_main_verb, baby_cavemanese, cavemanese)

def main():
  if len(sys.argv) > 1:
    data_file = sys.argv[1]
  else:
    data_file = raw_input("what file is your data in?\n")

  target_column = ""
  new_csv_rows = []

  try:
    with open(data_file, 'rb') as csvfile:
      header = True
      reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
      target_index = 0
      target_column = raw_input("what is the name of the column you want me to cavemanify?\n")
      # max_iter = 60
      # my_iter = 0
      for row in reader:
        # my_iter += 1
        # if my_iter < max_iter:
          if header:
            new_csv_rows = ["\t".join(row + [target_column + "_just_main_verb",
                                  target_column + "_baby_cavemanese",
                                  target_column + "_cavemanese"])]
            header = False
            try:
              target_index = row.index(target_column)
            except ValueError:
              print "I can't find that column. Try again."
              return False
          else:
            elem = row[target_index]
            clean_elem = re.sub("&quotechar", "'", elem)
            just_main_verb, baby_cavemanese, cavemanese = cavemanify(clean_elem)
            new_csv_rows.append("\t".join(row + [just_main_verb, baby_cavemanese, cavemanese]))
  except IOError:
    print "I can't find that file. Try again."
    return False

  write_file = re.sub("\.tsv", "_cavemanese.tsv", data_file)
  w = open(write_file, "w")
  w.write("\n".join(new_csv_rows))

main()
