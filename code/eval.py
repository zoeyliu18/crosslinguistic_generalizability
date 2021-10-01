import statistics, io, argparse, random
import numpy as np
from collections import Counter


def accuracy(gold_word, pred_word):

	correct = 0

	if gold_word == pred_word:
		correct = 1

	return correct * 100 


def F1(gold_word, pred_word):

	correct_total = 0

	for m in pred_word:
		if m in gold_word:
			correct_total += 1

	gold_total = len(gold_word)
	pred_total = len(pred_word)

	precision = correct_total / pred_total
	recall = correct_total / gold_total

	F1 = 0

	try:
		F1 = 2 * (precision * recall) / (precision + recall)
		F1 = round(F1 * 100, 2)
	except:
		F1 = 0

	return round(precision * 100, 2), round(recall * 100, 2), F1

def call_counter(func):
    def helper(*args, **kwargs):
        helper.calls += 1
        return func(*args, **kwargs)
    helper.calls = 0
    helper.__name__= func.__name__

    return helper

def memoize(func):
    mem = {}
    def memoizer(*args, **kwargs):
        key = str(args) + str(kwargs)
        if key not in mem:
            mem[key] = func(*args, **kwargs)
        return mem[key]
    return memoizer

@call_counter
@memoize    
def levenshtein(s, t):
    if s == "":
        return len(t)
    if t == "":
        return len(s)
    if s[-1] == t[-1]:
        cost = 0
    else:
        cost = 1
    
    res = min([levenshtein(s[:-1], t)+1,
               levenshtein(s, t[:-1])+1, 
               levenshtein(s[:-1], t[:-1]) + cost])

    return res

def copy(gold_word, pred_word):

	gold_word = ''.join(m for m in gold_word)
	pred_word = ''.join(m for m in pred_word)

	correct = 0

	if len(gold_word) <= len(pred_word):

		for i in range(len(gold_word)):
			if gold_word[i] == pred_word[i]:
				correct += 1

	if len(gold_word) > len(pred_word):

		for i in range(len(pred_word)):
			if gold_word[i] == pred_word[i]:
				correct += 1

	return round(correct * 100 / len(gold_word), 2)


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'input path')
	parser.add_argument('--lang', type = str, help = 'target language')
	parser.add_argument('--split', type = str, help = '1, 2, 3, etc')
	parser.add_argument('--m', help = 'model type')
	parser.add_argument('--test', action = 'store_true', help = 'whether evaluating test files of varying sizes')
	parser.add_argument('--z', type = str, help = 'random sample; a number between 1 to 50')


	args = parser.parse_args()

	gold_list = []
	pred_list = []

	n = args.split

	test_n = ''

	if args.test:
		test_n = args.split + '_' + str(args.z)

	lang = args.lang

	gold_file = ''

	if args.test:
		gold_file = io.open(args.input + lang + '_test_tgt_' + test_n, encoding = 'utf-8')
	else:
		gold_file = io.open(args.input + lang + '_test_tgt_' + n, encoding = 'utf-8')

	for line in gold_file:
		toks = line.strip().split()
		toks = ''.join(c for c in toks)
		morphs = toks.split('!')
		gold_list.append(morphs)

	pred_file = ''

	if args.m:

		if args.test:
			pred_file = io.open(args.input + lang + '_test_pred_' + args.m + '_' + test_n, encoding = 'utf-8')
		else:
			pred_file = io.open(args.input + lang + '_test_pred_' + args.m + '_' + n, encoding = 'utf-8')

	else:

		if args.test:
			pred_file = io.open(args.input + lang + '_test_pred_' + test_n, encoding = 'utf-8')
		else:
			pred_file = io.open(args.input + lang + '_test_pred_' + n, encoding = 'utf-8')

	for line in pred_file:
		toks = line.strip().split()
		toks = ''.join(c for c in toks)
		morphs = toks.split('!')
		pred_list.append(morphs)

	all_accuracy = []
	all_precision = []
	all_recall = []
	all_f1 = []	
	all_dist = []
	all_copy = []


	for i in range(len(gold_list)):
		all_accuracy.append(accuracy(gold_list[i], pred_list[i]))
		precision, recall, f1 = F1(gold_list[i], pred_list[i])
		dist = levenshtein(' '.join(m for m in gold_list[i]), ' '.join(m for m in pred_list[i]))

		all_precision.append(precision)
		all_recall.append(recall)
		all_f1.append(f1)
		all_dist.append(dist)
		all_copy.append(copy(gold_list[i], pred_list[i]))

	outfile = ''

	if args.m:
		if args.test:
			outfile = io.open(args.input + lang + '_test_eval_' + args.m + '_' + test_n, 'w', encoding = 'utf-8')
		else:
			outfile = io.open(args.input + lang + '_test_eval_' + args.m + '_' + n, 'w', encoding = 'utf-8')

	else:
		if args.test:
			outfile = io.open(args.input + lang + '_test_eval_' + test_n, 'w', encoding = 'utf-8')
		else:
			outfile = io.open(args.input + lang + '_test_eval_' + n, 'w', encoding = 'utf-8')

	outfile.write('Average accuracy: ' + str(round(statistics.mean(all_accuracy), 2)) + '\n')
	outfile.write('Average precision: ' + str(round(statistics.mean(all_precision), 2)) + '\n')
	outfile.write('Average recall: ' + str(round(statistics.mean(all_recall), 2)) + '\n')
	outfile.write('Average F1: ' + str(round(statistics.mean(all_f1), 2)) + '\n')
	outfile.write('Average distance: ' + str(round(statistics.mean(all_dist), 2)) + '\n')
	outfile.write('Average copy: ' + str(round(statistics.mean(all_copy), 2)) + '\n')


'''

	boots_accuracy = []
	boots_precision = []
	boots_recall = []
	boots_f1 = []	
	boots_dist = []
	boots_copy = []

	index = []
	i = 0
	while i < len(gold_list): 
		index.append(i)
		i += 1

	random.shuffle(index)

	for z in range(10000):

		select = random.choices(index, k = len(gold_list))

		all_accuracy = []
		all_precision = []
		all_recall = []
		all_f1 = []	
		all_dist = []
		all_copy = []


		for i in select:
			all_accuracy.append(accuracy(gold_list[i], pred_list[i]))
			precision, recall, f1 = F1(gold_list[i], pred_list[i])
			dist = levenshtein(' '.join(m for m in gold_list[i]), ' '.join(m for m in pred_list[i]))
			all_precision.append(precision)
			all_recall.append(recall)
			all_f1.append(f1)
			all_dist.append(dist)
			all_copy.append(copy(gold_list[i], pred_list[i]))

		ave_accuracy = round(statistics.mean(all_accuracy), 2)
		ave_precision = round(statistics.mean(all_precision), 2)
		ave_recall = round(statistics.mean(all_recall), 2)
		ave_f1 = round(statistics.mean(all_f1), 2)
		ave_dist = round(statistics.mean(all_dist), 2)
		ave_copy = round(statistics.mean(all_copy), 2)

		boots_accuracy.append(ave_accuracy)
		boots_precision.append(ave_precision)
		boots_recall.append(ave_recall)
		boots_f1.append(ave_f1)
		boots_dist.append(ave_dist)
		boots_copy.append(ave_copy)

	boots_accuracy.sort()
	boots_precision.sort()
	boots_recall.sort()
	boots_f1.sort()
	boots_dist.sort()
	boots_copy.sort()

	print('')

	print('Bootstrap: ')

	print('')

	print('Accuracy: ' + str(round(statistics.mean(boots_accuracy), 2)) + ' ' + str(round(boots_accuracy[250], 2)) +  ' ' + str(round(boots_accuracy[9750], 2)))
	print('Precision: ' + str(round(statistics.mean(boots_precision), 2)) + ' ' + str(round(boots_precision[250], 2)) + ' ' + str(round(boots_precision[9750], 2)))
	print('Recall: ' + str(round(statistics.mean(boots_recall), 2)) + ' ' + str(round(boots_recall[250], 2)) + ' ' + str(round(boots_recall[9750], 2)))
	print('F1: ' + str(round(statistics.mean(boots_f1), 2)) + ' ' + str(round(boots_f1[250], 2)) + ' ' + str(round(boots_f1[9750], 2)))
	print('Distance: ' + str(round(statistics.mean(boots_dist), 2)) + ' ' + str(round(boots_dist[250], 2)) + ' ' + str(round(boots_dist[9750], 2)))
	print('Copy: ' + str(round(statistics.mean(all_copy), 2)) + ' ' + str(round(boots_copy[250], 2)) + ' ' + str(round(boots_copy[9750], 2)))
	
'''

