# authorship_recognition

I. The authorship recognition task and the data

The developed data originally comes from the data provided by the Czech National Library and consists 
of a collection of 25 books of varying lengths, belonging to 6 different authors, each of whom wrote 
5 books.

Such data, specifically scanned pages, were converted to text using Optical Character Recognition 
(OCR) technology. OCR is a technology that enables the recognition and conversion of text from 
images, such as book scans, into editable and searchable digital forms.
Subsequently, the texts underwent cleaning, such as removing hyphens at the end of lines or headers 
etc.

The processed text was then passed through UDPipe, a natural language processing tool. UDPipe 
performs morphosyntactic analysis and establishes dependencies between words in sentences. It 
improved the quality and structure of the text, facilitating further analysis.
Delexicalization is the process of removing or replacing specific lexical information, such as specific 
names, numbers, dates, etc., with general or abstract representations. After applying UDPipe, 
delexicalization can be used for text data processing, allowing for more general and abstract  information processing.

The prepared data was divided into smaller segments through a segmentation process and then  randomly split into train, dev, and test subsets. They were also loaded into a simple .xml structure as  text passages.

The available datasets used for model creation and evaluation are as follows:
• Train1000 - passage size: 1000, number of passages: 1352
• Train200 - passage size: 200, number of passages: 6751
• Devel1000 - passage size: 1000, number of passages: 431
• Devel200 - passage size: 200, number of passages: 2152

Additionally, the following dataset was unavailable during model creation:
• Test1000 - passage size: 1000, number of passages: 431
• Test200 - passage size: 200, number of passages: 2152

Each file consists of so-called "passages" comprising a specific number of tokens enclosed within sentences.

II. Sentence length model

For the analysis of sentence lengths, I have created a Python program that takes data files in the .xml  format, following the structure mentioned above. For each passage, it counts the number of tokens in  each sentence and calculates the average sentence length per passage, which is then saved to a CSV  file. This file can be further analyzed using an SVM model, where sentence length serves as a feature.

III. N-gram model

When preparing the feature table for each passage, I initially used the make-ngrams package available  on the website. The provided Perl script counted the document frequency, collection frequency, and  term frequency (for a specific passage). I modified the script slightly, keeping only the n-gram number,  n-gram name, DF (collection frequency), and DF (document frequency).

The aforementioned file is under the name makev2.n-grams.
By executing the following command in the console: "cat name_of_file.xml | ./makev2.n-grams 20 > 
name_output_file.output", I was able to generate cf and df values for every n-gram at the token level 
of 1, 2, and 3.

I then incorporated these generated files into a Python script, where I calculated the term frequency 
for each n-gram in the passages. With this data, I was also able to calculate the weighted term 
frequency (TF * IDF = TF * log(N / DF)) and the relative term frequency (TF / number of terms in a given 
passage).

More specifically, during the creation of the .csv file, I utilized the default .xml data as well as the data 
generated from the ngrams_xxxxx_XXXX_dfcf.output files, where xxxxx represents train/dev and XXXX 
represents 200/1000.



 
