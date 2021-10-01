### This script tests segmentation models on test sets with varying sizes ###

import io, argparse, statistics, math, os, random

def gather_words(resource, lang):

	words = {}

	if lang in ['mayo', 'nahuatl', 'wixarika']:

		with io.open(resource + lang + '_tgt', encoding = 'utf-8') as f:

			for line in f:

				toks = line.strip().split()

				target = ''.join(c for c in toks)
				target = target.replace('!', '')

				seg = ''.join(c for c in toks).split('!')

				if target not in words:
					words[target] = ' '.join(c for c in seg)

	if lang in ['eng', 'fin', 'tur']:

		with io.open(resource + 'goldstd_combined.segmentation.' + lang, encoding = "latin-1") as f:
			for line in f:
				toks = line.strip().split('\t')

				target = toks[0]

				surface_seg = []

				new_toks = toks[-1].split(',')[0].split()

				for m in new_toks:

					m = m.replace("\:", '$')
					m = m.split(':')
					if m[0] != '~':
						surface_m = m[0]

						surface_m = surface_m.replace("$", ":")

						surface_seg.append(surface_m)

				if target not in words:
					words[target] = ' '.join(c for c in surface_seg)


	if lang in ['ger', 'ind', 'zul']:

		with io.open(resource + lang + '/trn', encoding = "latin-1") as f:
			for line in f:
				toks = line.strip().split('\t')

				target = toks[0]

				seg = []

				for m in toks[1].split():
					m = m.split(':')[0]
					seg.append(m)

				if target not in words:
					words[target] = ' '.join(c for c in seg)

		with io.open(resource + lang + '/tst', encoding = "latin-1") as f:
			for line in f:
				toks = line.strip().split('\t')

				target = toks[0]

				seg = []

				for m in toks[1].split():
					m = m.split(':')[0]
					seg.append(m)

				if target not in words:
					words[target] = ' '.join(c for c in seg)


	if lang in ['ru']:

		with io.open(resource + 'train_Tikhonov_reformat.txt', encoding = "utf-8") as f:
			for line in f:
				toks = line.strip().split('\t')

				target = toks[0]

				seg = []

				for m in toks[1].split('/'):
					m = m.split(':')[0]
					seg.append(m)

				if target not in words:
					words[target] = ' '.join(c for c in seg)

		with io.open(resource + 'test_Tikhonov_reformat.txt', encoding = "utf-8") as f:
			for line in f:
				toks = line.strip().split('\t')

				target = toks[0]

				seg = []

				for m in toks[1].split('/'):
					m = m.split(':')[0]
					seg.append(m)
				
				if target not in words:
					words[target] = ' '.join(c for c in seg)


	if lang in ['persian']:

		with io.open(resource + 'persian', encoding = 'utf-8') as f:

			for line in f:

				toks = line.strip().split()
				seg = toks[4 : ]

				target = ''.join(m for m in seg)

				if target not in words:
					words[target] = ' '.join(c for c in seg)

	return words


def gather_sample_words(path, lang, split, replacement):

	sample_words = {}

	with io.open(path + replacement + '/' + lang + '_train_tgt_' + split, encoding = 'utf-8') as f:
		for line in f:
			toks = line.strip().split()

			seg = ''.join(c for c in toks).split('!')

			target = ''.join(c for c in toks)
			target = target.replace('!', '')

			if target not in sample_words:
				sample_words[target] = ' '.join(c for c in seg)


#	with io.open(path + replacement + '/' + lang + '_dev_tgt_' + split, encoding = 'utf-8') as f:
#		for line in f:
#			toks = line.strip().split()

#			seg = toks

#			target = ''.join(c for c in toks)
#			target = target.replace('!', '')

#			if target not in sample_words:
#				sample_words[target] = ' '.join(c for c in seg)


	with io.open(path + replacement + '/' + lang + '_test_tgt_' + split, encoding = 'utf-8') as f:
		for line in f:
			toks = line.strip().split()

			seg = ''.join(c for c in toks).split('!')

			target = ''.join(c for c in toks)
			target = target.replace('!', '')

			if target not in sample_words:
				sample_words[target] = ' '.join(c for c in seg)

	return sample_words


def exclude(all_words, sample_words):

	test_words = []

	for word, seg in all_words.items():
		if word not in sample_words and word not in test_words:
			test_words.append(seg)

	return test_words



if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'input path')
	parser.add_argument('--data', type = str, help = 'resource path')
	parser.add_argument('--lang', type = str, help = 'target language')
	parser.add_argument('--n', type = str, help = 'number of test sets to sample give each sample size')
	parser.add_argument('--r', type = str, help = 'with or without replacement')
	parser.add_argument('--k', type = str, help = 'new test set sample size')

	args = parser.parse_args()

	lang = args.lang

	choices = ['A', 'B', 'C', 'D', 'E']

	r = args.r

	k = args.k

	size = args.input.split('/')[-2]

	if not os.path.exists(args.input + args.r + '/test/'):
		os.makedirs(args.input + args.r + '/test/')

	if not os.path.exists(args.input + args.r + '/test/' + str(k) + '/'):
		os.makedirs(args.input + args.r + '/test/' + str(k) + '/')


	outfile = io.open('/data/liuaal/model_generalizability/yayyy/' + lang + '_seq2seq_test_' + r + '_' + size + '_' + k + '_results.txt', 'w', encoding = 'utf-8')
	outfile.write(' '.join(w for w in ['Split', 'N', 'Accuracy', 'Precision', 'Recall', 'F1', 'Distance', 'Copy', 'Sample_size', 'Size', 'Replacement']) + '\n')

	all_words = gather_words(args.data, lang)

	### For each data set, construct 100 test samples of size k ###
	### test set is the same for 1A, 1B, 1C, 1D, 1E, etc ###

	for n in range(1, 51):
		temp_split = str(n) + 'A'
		sample_words = gather_sample_words(args.input, lang, temp_split, r)
		test_words = exclude(all_words, sample_words)

		for z in range(1, int(args.n) + 1): #### number of test sample size, e.g. 100
			sample = random.sample(test_words, k = int(k))

			for choice in choices:
				split = str(n) + choice

				if lang + '_test_src_' + split + '_' + str(z) not in os.listdir(args.input + r + '/test/' + str(k) + '/'):
					print(lang + '_test_src_' + split + '_' + str(z))
					with io.open(args.input + r + '/test/' + str(k) + '/' + lang + '_test_src_' + split + '_' + str(z), 'w', encoding = 'utf-8') as f:
						for seg in sample:
							seg = seg.split()
							seg = ''.join(m for m in seg)
							f.write(' '.join(c for c in list(seg)) + '\n')

				if lang + '_test_tgt_' + split + '_' + str(z) not in os.listdir(args.input + r + '/test/' + str(k) + '/'):
					print(lang + '_test_tgt_' + split + '_' + str(z))
					with io.open(args.input + r + '/test/' + str(k) + '/' + lang + '_test_tgt_' + split + '_' + str(z), 'w', encoding = 'utf-8') as f:
						for seg in sample:
							seg = seg.split()
							seg = '!'.join(m for m in seg)
							f.write(' '.join(c for c in list(seg)) + '\n')


	for n in range(1, 51):   ## data set number, e.g. 1, 2, 3, 4....

		choices_scores = []

		for choice in choices:

			split = str(n) + choice   #### random split numer, e.g. 1A, 2E, ...

			for z in range(1, int(args.n) + 1): #### number of test sample size

				if lang + '_test_eval_' + split + '_' + str(z) not in os.listdir(args.input + '/' + r + '/test/' + str(k) + '/'):
				
					print(lang + '_test_eval_' + split + '_' + str(z))

					os.system('onmt_translate -model ' + args.input + '/' + lang + split + '_with_step_10000.pt -src ' + args.input + '/' + args.r + '/test/' + str(k) + '/' + lang + '_test_src_' + split + '_' + str(z) + ' -output ' + args.input + '/' + args.r + '/test/' + str(k) + '/' + lang + '_test_pred_' + split + '_' + str(z) + ' -gpu 0 --n_best 1')

					os.system('python3 /data/liuaal/model_generalizability/code/eval.py --input ' + '/data/liuaal/model_generalizability/' + args.input + '/' + r + '/test/' + str(k)  + '/ --lang ' + lang + ' --split ' + split + ' --test --z ' + str(z) + '\n')

				scores = []

				with io.open(args.input + '/' + r + '/test/' + str(k) + '/' + lang + '_test_eval_' + split + '_' + str(z), encoding = 'utf-8') as f:
					for line in f:
						toks = line.strip().split(': ')
						scores.append(toks[-1])

				outfile.write(' '.join(str(w) for w in [split, z, scores[0], scores[1], scores[2], scores[3], scores[4], scores[5], k, size, r]) + '\n')


