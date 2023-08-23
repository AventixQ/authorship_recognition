import csv
import pandas as pd

# INPUT DATA
# main_file = 'sentence_data.csv' # main file with data
# ngram_file = 'ngram_output_train_1000.csv' # file created by make.ngrams from main file

numb_of_features = 1000  # input number

# INPUT DATA
ngram_out = ['devel_200', 'devel_1000', 'train_200', 'train_1000']  # Files from perl output
len_out = ['200.devel', '1000.devel', '200.train', '1000.train']  # Files of passages given

for p in range(len(ngram_out)):
    main_file = f'length_output_{len_out[p]}.csv'  # main file with data
    ngram_file = f'ngram_output_{ngram_out[p]}.csv'  # file created by make.ngrams from main file

    for int_type in range(3, 6):
        type_of_features = ''
        if int_type == 3:
            type_of_features = 'tf'
        elif int_type == 4:
            type_of_features = 'rtf'
        elif int_type == 5:
            type_of_features = 'wtf'

        tab_features = []

        with open(ngram_file, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        i = -1
        tmp_tab = []
        for line in lines:
            if i == -1:
                i += 1
                continue
            line = line[:len(line) - 1]
            line = line.split(',')
            try:
                tab_features.append(float(line[int_type]))
            except:
                tab_features.append(0.0)

        tab_main = []
        with open(main_file, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        for line in lines:
            line = line[:len(line) - 1]
            line = line.split(',')
            tab_main.append(line)

        # print(tab_features)

        k_start = 0
        q = 0
        for i in tab_main:
            if q == 0:
                q += 1
                for j in range(numb_of_features):
                    i.append(type_of_features + str(j + 1))
                continue
            for k in range(k_start, k_start + numb_of_features + 1):
                i.append(tab_features[k])
            k_start += numb_of_features + 1
            # print(i)

        csv_file = f'merge_data_{len_out[p]}_{type_of_features}.csv'  # output file
        with open(csv_file, 'w', newline='') as file:
            writer = csv.writer(file)
            for i in tab_main:
                writer.writerow(i)
