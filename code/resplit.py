##### randomly re-splitting each data set #####

import statistics, io, argparse, random
import numpy as np


def read_data(file):

	src = []
	tgt = []

	with io.open(file, encoding = 'utf-8') as f:
		for line in f:
			toks = line.strip().split()
			toks = ''.join(c for c in toks)

			src.append(toks.replace('!', ''))
			tgt.append(toks)

	return src, tgt


def generate_vocab(segmentation_list):

	vocab = []

	for tok in segmentation_list:
		tok = set(list(''.join(m for m in tok)))
		for c in tok:
			vocab.append(c)

	return set(vocab)


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'input path')
	parser.add_argument('--lang', type = str, help = 'target language')
	parser.add_argument('--split', type = str, help = '1, 2, 3, etc')


	args = parser.parse_args()

	lang = args.lang

	original_train_src, original_train_tgt = read_data(args.input + lang + '_train_tgt_' + args.split)
	original_dev_src, original_dev_tgt = read_data(args.input + lang + '_dev_tgt_' + args.split)
	original_test_src, original_test_tgt = read_data(args.input + lang + '_test_tgt_' + args.split)

	all_src = original_train_src + original_dev_src + original_test_src
	all_tgt = original_train_tgt + original_dev_tgt + original_test_tgt

	index = []

	i = 0

	while i < len(all_src):
		index.append(i)
		i += 1

	choice = ['B', 'C', 'D', 'E']

	heldout_size = 0.6

	for z in range(4):
		random.shuffle(index)

		total = 1000
		num_train = total - int(heldout_size * total)
		num_dev = int(num_train / 2)

		train_src = io.open(args.input + lang + '_' + 'train_src' + '_' + args.split + choice[z], 'w', encoding = 'utf-8')
		train_trg = io.open(args.input + lang + '_' + 'train_tgt' + '_' + args.split + choice[z], 'w', encoding = 'utf-8')

		train_src_vocab = io.open(args.input + lang + '_' + 'vocab_src' + '_' + args.split + choice[z], 'w', encoding = 'utf-8')
		train_trg_vocab = io.open(args.input + lang + '_' + 'vocab_tgt' + '_' + args.split + choice[z], 'w', encoding = 'utf-8')

		train_src_vocab.write('<blank>' + '\n')
		train_src_vocab.write('<s>' + '\n')
		train_src_vocab.write('</s>' + '\n')

		train_trg_vocab.write('<blank>' + '\n')
		train_trg_vocab.write('<s>' + '\n')
		train_trg_vocab.write('</s>' + '\n')


		dev_src = io.open(args.input + lang + '_' + 'dev_src' + '_' + args.split + choice[z], 'w', encoding = 'utf-8')
		dev_trg = io.open(args.input + lang + '_' + 'dev_tgt' + '_' + args.split + choice[z], 'w', encoding = 'utf-8')

		test_src = io.open(args.input + lang + '_' + 'test_src' + '_' + args.split + choice[z], 'w', encoding = 'utf-8')
		test_trg = io.open(args.input + lang + '_' + 'test_tgt' + '_' + args.split + choice[z], 'w', encoding = 'utf-8')

	
		final_seg = []
		final_form = []

		for i in index[ : num_train]:
			seg = all_tgt[i]
			form = seg
			train_src.write(' '.join(c for c in form if c != '!') + '\n')
			train_trg.write(' '.join(m for m in seg) + '\n')

			final_seg.append(seg)
			final_form.append(form)

		final_form_vocab = generate_vocab(final_form)
		final_seg_vocab = generate_vocab(final_seg)

		assert len(final_form_vocab) == len(final_seg_vocab)

		for c in final_form_vocab:
			if c != '!':
				train_src_vocab.write(c + '\n')

		for c in final_seg_vocab:
			train_trg_vocab.write(c + '\n')

		heldout_index = index[num_train : ]

		for i in heldout_index[ : num_dev]:
			seg = all_tgt[i]
			form = seg
			dev_src.write(' '.join(c for c in form if c != '!') + '\n')
			dev_trg.write(' '.join(m for m in seg) + '\n')


		for i in heldout_index[num_dev : ]:
			seg = all_tgt[i]
			form = seg
			test_src.write(' '.join(c for c in form if c != '!') + '\n')
			test_trg.write(' '.join(m for m in seg) + '\n')
