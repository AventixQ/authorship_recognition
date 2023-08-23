import csv

cf_dict = dict()
df_dict = dict()
tf_dict = dict()

#passages_file = 'passages.s1000.train.xml'
#csv_file = 'sentence_data.csv'
#ngram_file = 'ngram.output'

def extract_sentence_data(passages_file):
    with open(passages_file, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    sentence_data = []
    author = None
    length = 0
    length_pass = 0
    pid = 0
    avg_len = []
    how_many_sentences = 0
    for line in lines:
        if '<passage pid' in line:
            pid_start = line.find('pid="') + len('pid="')
            pid_end = line.find('"', pid_start)
            pid = line[pid_start:pid_end]

            author_start = line.find('author="') + len('author="')
            author_end = line.find('"', author_start)
            author = line[author_start:author_end]

            length_start = line.find('length="') + len('length="')
            length_end = line.find('"', length_start)
            length_pass = int(line[length_start:length_end])

        elif '</s>' in line:
            how_many_sentences += 1
            avg_len.append(length)
            length = 0

        elif '<token>' in line:
            length += 1
        elif '</passage>' in line:
            avg = 0
            for i in avg_len:
                avg += i
            avg = round(avg/how_many_sentences,3)
            sentence_data.append((pid, author, length_pass, avg))
            how_many_sentences = 0
            avg_len = []


    return sentence_data

#INPUT DATA
name_pass = ['200.devel', '1000.devel', '200.train', '1000.train'] #Files of passages given
for p in range(len(name_pass)):
    passages_file = f'passages.s{name_pass[p]}.xml' # main file with data
    csv_file = f'length_output_{name_pass[p]}.csv' # output file

    sentence_data = extract_sentence_data(passages_file)

    with open(csv_file, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['pid','author', 'len_pass','aveg_len_sen'])
        writer.writerows(sentence_data)

    #print("Sentence data saved to", csv_file)
