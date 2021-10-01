### preparing data for testing trained CRF models on the command line ###

import io, argparse

def read_data(file):
    pred = []
    for line in file:
        line = line.strip('\n')
        toks = line.split()
        if len(toks) == 0:
            return pred
        else:
            pred.append(toks[0])
    return None


### Gathering data ###

def gather_data(input, test):   # *_tgt files 

    ### COLLECT DATA AND LABELLING ###

    test_dict = {}

    input_files = [test] 
    dictionaries = test_dict

    test_words = []

    counter = 0
    
    for file in input_files:
        data = []

        with io.open(args.input + file, encoding = 'utf-8') as f:
            for line in f:
                toks = line.strip().split()
                morphs = (''.join(c for c in toks)).split('!')

                word = ''.join(m for m in morphs)

                if file == test:
                    test_words.append(word)

                label = ''

                for morph in morphs:
                    if len(morph) == 1:
                        label += 'S'
                    else:
                        label += 'B'

                        for i in range(len(morph)-2):
                            label += 'M'

                        label += 'E'

                w_dict = {}
                dictionaries[''.join(m for m in morphs)] = label

    return dictionaries, test_words


### Computing features ###


def features(word_dictonary, original_words, delta):

    X = [] # list (learning set) of list (word) of dics (chars), INPUT for crf
    Y = [] # list (learning set) of list (word) of labels (chars), INPUT for crf
    words = [] # list (learning set) of list (word) of chars

    for word in original_words:
        word_plus = '[' + word + ']' # <w> and <\w> replaced with [ and ]
        word_list = [] # container of the dic of each character in a word
        word_label_list = [] # container of the label of each character in a word
    
        for i in range(len(word_plus)):
            char_dic = {} # dic of features of the actual char
        
            for j in range(delta):
                char_dic['right_' + word_plus[i:i + j + 1]] = 1
        
            for j in range(delta):
                if i - j - 1 < 0: break
                char_dic['left_' + word_plus[i - j - 1:i]] = 1
            char_dic['pos_start_' + str(i)] = 1  # extra feature: left index of the letter in the word
            # char_dic['pos_end_' + str(len(word) - i)] = 1  # extra feature: right index of the letter in the word
        #    if word_plus[i] in ['a', 's', 'o']: # extra feature: stressed characters (discussed in the report)
        #        char_dic[str(word_plus[i])] = 1
            word_list.append(char_dic)
        
            if word_plus[i] == '[': word_label_list.append('[') # labeling start and end
            elif word_plus[i] == ']': word_label_list.append(']')
            else: word_label_list.append(word_dictonary[word][i-1]) # labeling chars

        X.append(word_list)
        Y.append(word_label_list)
        temp_list_word = [char for char in word_plus]
        words.append(temp_list_word)

    return (X, Y, words)


def output_features(data, labels_list):

    output = []

    for i in range(len(data)):
        features = data[i]
        labels = labels_list[i]

        word_out = []

        for z in range(len(features)):
            out = []
            out.append(labels[z])
            for f in features[z]:
                f = f.split('_')

                new_f = []

                if f[0] in ['right', 'left']:
                    new_f.append(f[0])
                    new_f.append('[')
                    new_f.append(len(f[1]))
                    new_f.append(']')
                    new_f.append('=')
                    if f[1] == ":’ë:":
                        new_f.append("_’ë:")
                    else:
                        new_f.append(f[1])

                if f[0] in ['pos']:
                    new_f.append('pos')
                    new_f.append('_start')
                    new_f.append('=')
                    new_f.append(f[-1])
                
                out.append(''.join(str(t) for t in new_f))

            word_out.append(out)

        output.append(word_out)

    return output


### Output feature data for training CRF models on the command line ###

def generate(dictionaries, test_words, delta):

    test_dict = dictionaries

    X_test, Y_test, words_test = features(test_dict, test_words, delta)

    test_out = output_features(X_test, Y_test)

    return test_out


def reconstruct(pred_labels, tgt):

    words = []

    with io.open(tgt, encoding = 'utf-8') as f:
        for line in f:
            toks = line.strip().split()
            toks = ''.join(c for c in toks)
            word = toks.replace('!', '')
            words.append(word)

    data = []

    with io.open(pred_labels, encoding = 'utf-8') as f:

        pred = read_data(f)
        
        while pred is not None:
            data.append(pred)
            pred = read_data(f)

    pred_list = []

    for idx in range(len(data)):
        pred = data[idx]
        word = words[idx]

        labels = ''.join(w for w in pred[1 : -1])
        labels = labels.split('E')
    
        if '' in labels:
            labels.remove('')
        new_labels = []

        for tok in labels:
        #    print(tok, word)
            if 'S' not in tok:
                tok += 'E'
                new_labels.append(tok)

            else:
                c = tok.count('S')

                if c == len(tok):
                    for z in range(c):
                        new_labels.append('S')

                else:
                    tok = tok.split('S')

                    new_tok = []

                    for z in tok:
                        if z == '':
                            new_labels.append('S')
                        else:
                            new_labels.append(z + 'E')

        morphs = []

        for i in range(len(new_labels)):
            tok = new_labels[i]

            l = len(tok)

            if i == 0:
                morphs.append(word[0 : l])

            else:
                pre = len(''.join(z for z in new_labels[ : i]))
                morphs.append(word[pre: pre + l])

        pred_list.append(morphs)

    return pred_list




if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type = str, help = 'input path')
    parser.add_argument('--lang', type = str, help = 'target language')
    parser.add_argument('--split', type = str, help = '1, 2, 3, etc')
    parser.add_argument('--state', type = str, help = 'g (generate data for training)/ r (reconstruct data for evaluation')
    parser.add_argument('--z', type = str, help = 'random sample; a number between 1 to 50')
    parser.add_argument('--d', type = int, default = 4)
    parser.add_argument('--m', help = 'model type')


    args = parser.parse_args()

    lang = args.lang 
    n = args.split
    z = str(args.z)

    test_f = lang + '_test_tgt_' + n + '_' + z

    if args.state == 'g':

        dictionaries, test_words = gather_data(args.input, test_f)

        test_dict = dictionaries

        test_out = generate(dictionaries, test_words, args.d)

        with io.open(args.input + lang + '_test_crfv_' + n + '_' + z, 'w', encoding = 'utf-8') as f:
            for tok in test_out:
                for l in tok:
                    f.write('\t'.join(c for c in l) + '\n')
         
                f.write('\n')

    if args.state == 'r':
    
        words = args.input + lang + '_test_tgt_' + n + '_' + z
        pred_labels = args.input + lang + '_test_' + args.m + '_labels_' + n + '_' + z

        predictions = reconstruct(pred_labels, words)

        with io.open(args.input + lang + '_test_pred_' + args.m + '_' + n + '_' + z, 'w', encoding = 'utf-8') as f:
            for tok in predictions:
                tok = '!'.join(m for m in tok)
                tok = list(tok)
                f.write(' '.join(c for c in tok) + '\n')

