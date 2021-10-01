### This script splits data for mophological segmentation based on heuristics ###
### Calculate for train and test sets separately ###
### Calculate for combined data in case of doing heuristic splitting later###


### EXAMPLE HEURISTICS ###

### e.g. unique types of words ###
### e.g. unique types of morpheme strings ###
### e.g. number of morphemes per word, then average across the data set ###
### e.g. average morpheme length per word, then average across the data set ###


### Overlap between train and test sets ###

### e.g. word overlap ratio ###
### e.g. difference between unique types of words ###
### e.g. difference between unique types of morpheme strings ###
### e.g. difference between average number of morphemes per word ###
### e.g. difference between average morpheme length per word ###
### e.g. distance between distribution of number of morphemes per word ###
### e.g. distance between distribution of average morpheme length per word ###


### e.g. morphological complexity measure; entropy(morpheme type); Caveat: one morpheme could mean different things; BUT the model still has to segment it ###
### For morphological complexity, might need to apply inflection models then calculate it ###

import io, argparse, os, random, statistics
from collections import Counter
from scipy.stats import wasserstein_distance

import collections
import random
from typing import Dict, Generator, Iterator, List, Set, Text, Tuple

from absl import logging
import numpy as np
import pandas as pd
from scipy import stats
from sklearn import feature_extraction
from sklearn import neighbors


def ave_morph_len_stats(seg):

	c = 0

	for i in range(len(seg)):
		c += len(seg[i])

	return c / len(seg)

def Sort(sub_li):  
	# reverse = None (Sorts in Ascending order)
	# key is set to sort using second element of 
	# sublist lambda has been used

	sub_li.sort(key = lambda x: x[0])

	return sub_li

def gather_data(path, lang, split):

	train_data = []
	train_words = []
	train_num_morph_info = []
	train_ave_morph_len_info = []
	train_morph_types = []

	test_data = []
	test_words = []
	test_num_morph_info = []
	test_ave_morph_len_info = []
	test_morph_types = []

	data = {}
	words = []
	num_morph_info = []
	ave_morph_len_info = []
	morph_types = []


	with io.open(path + lang + '_train_tgt_' + split, encoding = 'utf-8') as f:
		for line in f:
			toks = line.strip().split()
			toks = ''.join(c for c in toks)
			seg = toks.split('!')
		
			num_morph = len(seg)
			ave_morph_len = round(ave_morph_len_stats(seg), 2)

			for m in seg:
				train_morph_types.append(m)
				morph_types.append(m)

			train_num_morph_info.append(num_morph)			
			train_ave_morph_len_info.append(ave_morph_len)
			train_data.append([toks, num_morph, ave_morph_len])
			train_words.append(toks)

			num_morph_info.append(num_morph)			
			ave_morph_len_info.append(ave_morph_len)
			data[toks] = [num_morph, ave_morph_len]
			words.append(toks)

	with io.open(path + lang + '_test_tgt_' + split, encoding = 'utf-8') as f:
		for line in f:
			toks = line.strip().split()
			toks = ''.join(c for c in toks)
			seg = toks.split('!')
		
			num_morph = len(seg)
			ave_morph_len = round(ave_morph_len_stats(seg), 2)

			for m in seg:
				test_morph_types.append(m)
				morph_types.append(m)

			test_num_morph_info.append(num_morph)			
			test_ave_morph_len_info.append(ave_morph_len)
			test_data.append([toks, num_morph, ave_morph_len])
			test_words.append(toks)

			num_morph_info.append(num_morph)
			ave_morph_len_info.append(ave_morph_len)
			data[toks] = [num_morph, ave_morph_len]
			words.append(toks)

	word_overlap = 0

	for w in test_words:
		if w in train_words:
			word_overlap += 1

	word_overlap = round(word_overlap * 100 / len(test_words) ,2)

	morph_overlap = 0

	for m in test_morph_types:
		if m in train_morph_types:
			morph_overlap += 1

	morph_overlap = round(morph_overlap * 100 / len(test_morph_types), 2)

	train_num_morph_info

	return train_data, len(set(train_words)), train_num_morph_info, train_ave_morph_len_info, len(set(train_morph_types)), test_data, len(set(test_words)), test_num_morph_info, test_ave_morph_len_info, len(set(test_morph_types)), word_overlap, data, len(set(words)), num_morph_info, ave_morph_len_info, len(set(morph_types)), train_words, test_words, words, morph_overlap


def transform(tok):

	new = []

	for p in tok:
		new.append(str(p[0]) + ':' + str(p[1]))

	return new


### Splitting by threshold of number of morphemes ###

def split_by_length_threshold(num_morph_list, test_set_size):

	current_count = 0
	check = 'no'

	# Start from the longest texts.
	for i in range(max(num_morph_list), 0, -1):
		current_count += num_morph_list.count(i)
	
		if current_count > test_set_size:
			ratio = current_count / len(num_morph_list)
		
			if ratio >= heldout_size - 0.02 and ratio <= heldout_size + 0.02:
				check = 'yes'
		
			return i, round(ratio * 100, 2), check


### Adversarial splitting ###

"""
Finds test sets by maximizing Wasserstein distances among the given texts.
This is separating the given texts into training/dev and test sets based on an
approximate Wasserstein method. First all texts are indexed in a nearest
neighbors structure. Then a new test centroid is sampled randomly, from which
the nearest neighbors in Wasserstein space are extracted. Those constitute
the new test set.
Similarity is computed based on document-term counts.
Args:
	texts: Texts to split into training/dev and test sets.
	test_set_size: Number of elements the new test set should contain.
	no_of_trials: Number of test sets requested.
	min_df: Mainly for speed-up and memory efficiency. All tokens must occur at
	  least this many times to be considered in the Wasserstein computation.
	leaf_size: Leaf size parameter of the nearest neighbor search. Set high
	  values for slower, but less memory-heavy computation.
Returns:
	Returns a List of test set indices, one for each trial. The indices
	correspond to the items in `texts` that should be part of the test set.
"""
			
def split_with_wasserstein(texts, test_set_size, no_of_trials, min_df, leaf_size): 
	vectorizer = feature_extraction.text.CountVectorizer(dtype=np.int8, min_df=min_df)
	logging.info('Creating count vectors.')
	text_counts = vectorizer.fit_transform(texts)
	text_counts = text_counts.todense()
	logging.info('Count vector shape %s.', text_counts.shape)
	logging.info('Creating tree structure.')
	nn_tree = neighbors.NearestNeighbors(n_neighbors=test_set_size, algorithm='ball_tree', leaf_size=leaf_size, metric=stats.wasserstein_distance)
	nn_tree.fit(text_counts)
	logging.info('Sampling test sets.')
	test_set_indices = []

	for trial in range(no_of_trials):
		logging.info('Trial set: %d.', trial)
		# Sample random test centroid.
		sampled_poind = np.random.randint(
			text_counts.max().max() + 1, size=(1, text_counts.shape[1]))
		nearest_neighbors = nn_tree.kneighbors(sampled_poind, return_distance=False)
		# We queried for only one datapoint.
		nearest_neighbors = nearest_neighbors[0]
		logging.info(nearest_neighbors[:10])
		test_set_indices.append(nearest_neighbors)

	return test_set_indices


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'input path')
	parser.add_argument('--output', type = str, help = 'output path')
	parser.add_argument('--lang', type = str, help = 'target language')
	parser.add_argument('--split', type = str, help = 'A, B, C ,D, E; to help run multiple adversarial splits')
	parser.add_argument('--generate', action = 'store_true', help = 'whether to generate data based on new ways of splitting data')

	args = parser.parse_args()

	lang = args.lang

	heldout_size = 0.4

	outfile = io.open(args.output + lang + '_heuristics.txt', 'w', encoding = 'utf-8')
	header = ['Language', 'Sample', 'Replacement', 'Split', 'Set', 'Feature', 'Value', 'Caveat']
	outfile.write('\t'.join(w for w in header) + '\n')

	len_outfile = ''
	adv_outfile = ''


	len_outfile = io.open(args.output + lang + '_split_len.txt', 'w', encoding = 'utf-8')
	header = ['Language', 'Sample', 'Replacement', 'Split', 'Threshold', 'Ratio', 'Check']
	len_outfile.write('\t'.join(w for w in header) + '\n')

	adv_outfile = io.open(args.output + lang + '_split_adv.txt', 'w', encoding = 'utf-8')
	header = ['Language', 'Sample', 'Replacement', 'Split', 'Overlap']
	adv_outfile.write('\t'.join(w for w in header) + '\n')


	for sample_size in os.listdir(args.input):
		for r in os.listdir(args.input + sample_size + '/'):
			if r in ['with', 'without']:	

				len_check = 0
				adv_check = 0

				heldout_size = 0.4

				choices = ['A', 'B', 'C', 'D', 'E']

				for n in range(1, 51):

					everything = []  ### to store all words later for adversarial spliting

					test_set_indices = ''
					temp_test_words = []


					for choice in choices:
						split = str(n) + choice

					#	print(gather_data(args.input + sample_size + '/' + r + '/', lang, split))
						train_data, train_word_type, train_num_morph_info, train_ave_morph_len_info, train_morph_type, test_data, test_word_type, test_num_morph_info, test_ave_morph_len_info, test_morph_type, word_overlap, data, word_type, num_morph_info, ave_morph_len_info, morph_type, train_words, test_words, words, morph_overlap = gather_data(args.input + sample_size + '/' + r + '/', lang, split)

						train_total = len(train_num_morph_info)
						test_total = len(test_num_morph_info)
						total = len(num_morph_info)

						assert total == int(sample_size)

						train_new_num_morph_info = []
						train_new_ave_morph_len_info = []

						for tok in Counter(train_num_morph_info).items():
							train_new_num_morph_info.append([tok[0], round(tok[1] * 100 / train_total, 2)])
			
						train_new_num_morph_info = Sort(train_new_num_morph_info)
						train_new_num_morph_info = transform(train_new_num_morph_info)

						for tok in Counter(train_ave_morph_len_info).items():
							train_new_ave_morph_len_info.append([tok[0], round(tok[1] * 100 / train_total, 2)])
			
						train_new_ave_morph_len_info = Sort(train_new_ave_morph_len_info)
						train_new_ave_morph_len_info = transform(train_new_ave_morph_len_info)


						test_new_num_morph_info = []
						test_new_ave_morph_len_info = []

						for tok in Counter(test_num_morph_info).items():
							test_new_num_morph_info.append([tok[0], round(tok[1] * 100 / test_total, 2)])
			
						test_new_num_morph_info = Sort(test_new_num_morph_info)
						test_new_num_morph_info = transform(test_new_num_morph_info)

						for tok in Counter(test_ave_morph_len_info).items():
							test_new_ave_morph_len_info.append([tok[0], round(tok[1] * 100 / test_total, 2)])
			
						test_new_ave_morph_len_info = Sort(test_new_ave_morph_len_info)
						test_new_ave_morph_len_info = transform(test_new_ave_morph_len_info)


						new_num_morph_info = []
						new_ave_morph_len_info = []

						for tok in Counter(num_morph_info).items():
							new_num_morph_info.append([tok[0], round(tok[1] * 100 / total, 2)])
			
						new_num_morph_info = Sort(new_num_morph_info)
						new_num_morph_info = transform(new_num_morph_info)

						for tok in Counter(ave_morph_len_info).items():
							new_ave_morph_len_info.append([tok[0], round(tok[1] * 100 / total, 2)])
			
						new_ave_morph_len_info = Sort(new_ave_morph_len_info)
						new_ave_morph_len_info = transform(new_ave_morph_len_info)

						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'train', 'unique_word_type',  train_word_type]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'train', 'unique_morph_type',  train_morph_type]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'train', 'ave_num_morph', round(statistics.mean(train_num_morph_info), 2), ' '.join(w for w in train_new_num_morph_info)]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'train', 'ave_morph_len', round(statistics.mean(train_ave_morph_len_info), 2), ' '.join(w for w in train_new_ave_morph_len_info)]) + '\n')

						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'test', 'unique_word_type',  test_word_type]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'test', 'unique_morph_type',  test_morph_type]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'test', 'ave_num_morph', round(statistics.mean(test_num_morph_info), 2), ' '.join(w for w in test_new_num_morph_info)]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'test', 'ave_morph_len', round(statistics.mean(test_ave_morph_len_info), 2), ' '.join(w for w in test_new_ave_morph_len_info)]) + '\n')

						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'word_overlap', word_overlap]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'morph_overlap', morph_overlap]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'unique_word_type',  word_type]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'unique_word_type_ratio',  train_word_type / test_word_type]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'diff_unique_word_type', train_word_type - test_word_type]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'unique_morph_type',  morph_type]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'unique_morph_type_ratio', train_morph_type / test_morph_type]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'diff_unique_morph_type', train_morph_type - test_morph_type]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'ave_num_morph', round(statistics.mean(num_morph_info), 2), ' '.join(w for w in new_num_morph_info)]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'ave_num_morph_ratio', round(statistics.mean(train_num_morph_info) / statistics.mean(test_num_morph_info), 2)]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'diff_ave_num_morph', round(statistics.mean(train_num_morph_info) - statistics.mean(test_num_morph_info), 2)]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'dist_ave_num_morph', round(wasserstein_distance(train_num_morph_info, test_num_morph_info), 2)]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'ave_morph_len', round(statistics.mean(ave_morph_len_info), 2), ' '.join(w for w in new_ave_morph_len_info)]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'ave_morph_len_ratio', round(statistics.mean(train_ave_morph_len_info) / statistics.mean(test_ave_morph_len_info), 2)]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'diff_ave_morph_len', round(statistics.mean(train_ave_morph_len_info) - statistics.mean(test_ave_morph_len_info), 2)]) + '\n')
						outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, 'all', 'dist_ave_morph_len', round(wasserstein_distance(train_ave_morph_len_info, test_ave_morph_len_info), 2)]) + '\n')

						### To split, or not to split ###

						if split.endswith(args.split):
							threshold, ratio, check = split_by_length_threshold(num_morph_info, heldout_size * int(sample_size))
							len_outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, threshold, ratio, check]) + '\n')

							if check == 'yes':
								len_check += 1

								if args.generate:
									if not os.path.exists(args.input + sample_size + '/' + r + '/heuritics_split/'):
										os.makedirs(args.input + sample_size + '/' + r + '/heuritics_split/')

									new_train_data = []
									new_test_data = []

									print(sample_size)
									print(len(train_data))
									print(len(test_data))

									assert len(train_data) + len(test_data) == int(sample_size)

									for w in train_data:
										if w[0].count('!') + 1 >= threshold:
											new_test_data.append(w[0])

										else:
											new_train_data.append(w[0])

									for w in test_data:
										if w[0].count('!') + 1 >= threshold:
											new_test_data.append(w[0])

										else:
											new_train_data.append(w[0])

									for w in new_train_data:
										src = w
										while '!' in src:
											src = w.replace('!', '')

										with io.open(args.input + sample_size + '/' + r + '/heuritics_split/' + lang + '_train_src_' + split, 'w', encoding = 'utf-8') as f:
											f.write(' '.join(c for c in src) + '\n')

										with io.open(args.input + sample_size + '/' + r + '/heuritics_split/' + lang + '_train_tgt_' + split, 'w', encoding = 'utf-8') as f:
											f.write(' '.join(c for c in w) + '\n')

									for w in new_test_data:
										src = w
										while '!' in src:
											src = w.replace('!', '')

										with io.open(args.input + sample_size + '/' + r + '/heuritics_split/' + lang + '_test_src_' + split, 'w', encoding = 'utf-8') as f:
											f.write(' '.join(c for c in src) + '\n')

										with io.open(args.input + sample_size + '/' + r + '/heuritics_split/' + lang + '_test_tgt_' + split, 'w', encoding = 'utf-8') as f:
											f.write(' '.join(c for c in w) + '\n')


									
							### Check whether could be split by adversarial features ###
							### Generate data based on split if necessary ###

							for w in words:
								w = w.split('!')
								everything.append(' '.join(m for m in w))

							print(heldout_size)
							print(int(heldout_size * int(sample_size)))

							assert len(everything) == int(sample_size)

							test_set_indices = split_with_wasserstein(everything, int(heldout_size * int(sample_size)), 1, 1, 3)[0]

							for idx in test_set_indices:
								temp_test_words.append(words[idx])

						test_overlap = 0

						for w in temp_test_words:
							if w in test_words:
								test_overlap += 1

						if len(temp_test_words) != 0:
							test_overlap = round(test_overlap * 100 / len(temp_test_words), 2)
							adv_outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, split, test_overlap]) + '\n')

							if test_overlap <= 90:
								adv_check += 1

							if args.generate and split.endswith(args.split):
								if not os.path.exists(args.input + sample_size + '/' + r + '/adversarial_split/'):
									os.makedirs(args.input + sample_size + '/' + r + '/adversarial_split/')
							
								new_train_data = []
								new_test_data = temp_test_words

								for idx in range(len(words)):
									if idx not in test_set_indices:
										new_train_data.append(words[idx])

								adv_train_src = io.open(args.input + sample_size + '/' + r + '/adversarial_split/' + lang + '_train_src_' + split, 'w', encoding = 'utf-8')
								adv_train_tgt = io.open(args.input + sample_size + '/' + r + '/adversarial_split/' + lang + '_train_tgt_' + split, 'w', encoding = 'utf-8')
							
								for w in new_train_data:
									src = w
									while '!' in src:
										src = w.replace('!', '')

									adv_train_src.write(' '.join(c for c in src) + '\n')
									adv_train_tgt.write(' '.join(c for c in w) + '\n')
								
								adv_test_src = io.open(args.input + sample_size + '/' + r + '/adversarial_split/' + lang + '_test_src_' + split, 'w', encoding = 'utf-8')
								adv_test_tgt = io.open(args.input + sample_size + '/' + r + '/adversarial_split/' + lang + '_test_tgt_' + split, 'w', encoding = 'utf-8')
							
								for w in new_test_data:
									src = w
									while '!' in src:
										src = w.replace('!', '')
								
									adv_test_src.write(' '.join(c for c in src) + '\n')
									adv_test_tgt.write(' '.join(c for c in w) + '\n')

				len_outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, 'EVERYTHING', '-', '-', round(len_check * 100 / 250, 2)]) + '\n')
				adv_outfile.write('\t'.join(str(w) for w in [lang, sample_size, r, 'EVERYTHING', str(round(adv_check * 100 / 250, 2))])  + '\n')

