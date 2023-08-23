import csv
import math

# INPUT DATA
name_out = ['devel_200', 'devel_1000', 'train_200', 'train_1000']  # Files from perl output
name_pass = ['200.devel', '1000.devel', '200.train', '1000.train']  # Files of passages given
passages_number_tab = [2152,431, 6751,1352]
number_of_features = 1000

for p in range(len(name_out)):
    passages_file = f'passages.s{name_pass[p]}.xml'  # main file with data
    ngram_file = f'ngrams_{name_out[p]}_dfcf.output'  # file created by make.ngrams from main file
    csv_file = f'ngram_output_{name_out[p]}.csv'  # output file
    passages_number = passages_number_tab[p]  # number of passages in main file
    #print(passages_number)
    features = []
    cf_dict = dict()
    df_dict = dict()
    tf_dict = dict()


    def is_in_dict(dict, token):
        if token not in dict:
            dict[token] = 1
        else:
            dict[token] += 1


    with open(ngram_file, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    i = 0
    for line in lines:
        if i == 0:
            i = 1
            continue
        try:
            data = line.split("\t")
            #
            # print(data[1])
            features.append(data[1])
            cf_dict[data[1]] = int(data[2])
            df_dict[data[1]] = int(data[3])
            # print(cf_dict[data[1]])
        except:
            None

    with open(csv_file, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['pid', 'cf', 'df', 'tf', 'rtf', 'wtf'])
        pid = 0
        counter = 0
        token_two = ''
        token_three = ''
        last_token = ''
        token_three_value = 0
        all_terms_in_passage = 0
        with open(passages_file, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        for line in lines:
            if '<passage pid' in line:
                pid_start = line.find('pid="') + len('pid="')
                pid_end = line.find('"', pid_start)
                pid = line[pid_start:pid_end]
                token_two = ''
                token_three = ''
                token_three_value = 0
                last_token = ''
                all_terms_in_passage = 0
            elif '</s>' in line:
                continue
            elif '<token>' in line:
                token_start = line.find('<token>') + len('<token>')
                token_end = line.find('</token>', token_start)
                token = line[token_start:token_end] + ' '
                # print(token)
                is_in_dict(tf_dict, token)
                all_terms_in_passage += 1
                if token_two != '':
                    token_two += token
                    # print(token_two)
                    is_in_dict(tf_dict, token_two)
                    all_terms_in_passage += 1
                token_two = token
                if token_three_value == 2:
                    token_three += token
                    # print(token_three)
                    is_in_dict(tf_dict, token_three)
                    all_terms_in_passage += 1
                    list = token_three.split(' ')
                    token_three = list[1] + ' ' + list[2] + ' '
                elif token_three_value < 2:
                    token_three += token
                    token_three_value += 1
            elif '</passage>' in line:
                for key in cf_dict:
                    # print(key)
                    if key not in tf_dict:
                        writer.writerow([pid, cf_dict[key], df_dict[key], 0.0, 0.0, 0.0])
                    else:
                        #print(math.log(passages_number / df_dict[key]))
                        #print(math.log(passages_number / df_dict[key]) * tf_dict[key])
                        writer.writerow([pid, cf_dict[key], df_dict[key], tf_dict[key],
                                         tf_dict[key] / all_terms_in_passage,
                                         math.log(passages_number / df_dict[key]) * tf_dict[key]])
                    if counter == number_of_features:
                        counter = 0
                        break
                    counter += 1
                tf_dict = dict()
