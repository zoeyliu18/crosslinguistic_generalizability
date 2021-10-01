import io, os, argparse, random, statistics, codecs

def check(tok):

	c = 0

	for m in tok:
		if m.islower() is False:
			c += 1

	if c != 0:
		return False

	else:
		return True


def generate_vocab(segmentation_list):

	vocab = []

	for tok in segmentation_list:
		tok = set(list(''.join(m for m in tok)))
		for c in tok:
			vocab.append(c)

	return set(vocab)


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'e.g. .txt file of Seneca morphology')
	parser.add_argument('--output', type = str, help = 'path to generated segmentation data')
	parser.add_argument('--lang', type = str, help = 'language')
	parser.add_argument('--r', type = str, help = 'with or without replacement')
	parser.add_argument('--k', type = str, help = 'sample size')

	args = parser.parse_args()

	lang = args.lang

	all_form = []
	all_seg = []

	all_canonical_form = []
	all_canonical_seg = []

	coarse_form = []
	coarse_seg = []

	grammar_form = []
	grammar_seg = []

	coarse_surface_form = []
	coarse_surface_seg = []
	coarse_canonical_form = []
	coarse_canonical_seg = []

	all_morphs = []
	num_morph = []


	if lang == 'grammar':

		with io.open(args.input + 'all-forms-from-spreadsheet.txt', encoding = 'utf-8') as f:
			for line in f:
				toks = line.split()
				seg = toks[-2]
				seg = seg.replace('-', '!')
				seg = seg.replace("'", "’")
				seg = seg.replace("’", "’")
				seg = seg.replace("‘", "’")
				seg = seg.replace("´", "’")
				seg = seg.replace("Ë", "ë")
				seg = seg.replace("I", "i")
				seg = seg.replace("b", "h")
				seg = seg.replace("W", "w")
				seg = seg.replace("(", "")
				seg = seg.replace(")", "")
				seg = seg.replace("T", "t")
				seg = seg.replace(" ", "")
				seg = seg.replace("+", "")

				target = seg
				target = target.replace("!", "")

				seg = list(seg)

				coarse_seg.append(seg)
				coarse_form.append(target)


		if len(coarse_form) != 0:
			for i in range(len(coarse_form)):

				### only sample unique ones ###

				if coarse_form[i] not in all_form:
					all_form.append(coarse_form[i])
					all_seg.append(coarse_seg[i])


	if lang == 'robbie':

		with io.open(args.input + 'all-forms-from-spreadsheet.txt', encoding = 'utf-8') as f:
			for line in f:
				toks = line.split()
				seg = toks[-2]
				seg = seg.replace('-', '!')
				seg = seg.replace("'", "’")
				seg = seg.replace("’", "’")
				seg = seg.replace("‘", "’")
				seg = seg.replace("´", "’")
				seg = seg.replace("Ë", "ë")
				seg = seg.replace("I", "i")
				seg = seg.replace("b", "h")
				seg = seg.replace("W", "w")
				seg = seg.replace("(", "")
				seg = seg.replace(")", "")
				seg = seg.replace("T", "t")
				seg = seg.replace(" ", "")
				seg = seg.replace("+", "")

				target = seg
				target = target.replace("!", "")

				seg = list(seg)

				grammar_seg.append(seg)
				grammar_form.append(target)

		with io.open(args.input + 'tgt.txt', encoding = 'utf-8') as f:
			for line in f:
				toks = line.strip().split()

				seg = ''.join(c for c in toks)
				seg = seg.replace(" ", "")
				seg = seg.replace("+", "")

				target = seg.replace('!', '')

				coarse_seg.append(list(seg))
				coarse_form.append(target)

	
	### filter out OR NOT words that have already been documented in the grammar book; different segmentations ###

		if len(coarse_form) != 0:
			for i in range(len(coarse_form)):
				if coarse_form[i] not in grammar_form and coarse_form[i] not in all_form:
					all_form.append(coarse_form[i])
					all_seg.append(coarse_seg[i])

	if lang in ['eng', 'fin', 'tur']:

		with io.open(args.input + 'goldstd_combined.segmentation.' + lang, encoding = "latin-1") as f:
			for line in f:
				toks = line.strip().split('\t')

				target = toks[0]

				surface_seg = []
				canonical_seg = []

				new_toks = toks[-1].split(',')[0].split()

				for m in new_toks:

					m = m.replace("\:", '$')
					m = m.split(':')
					if m[0] != '~':
						surface_m = m[0]
						canonical_m = m[0]

						if '_' not in m[1] and '+' not in m[1]:
							if check(m[1]) != False:
								canonical_m = m[1]

						if '_' in m[1]:
							new_m = m[1].split('_')
							temp = []
							for t in new_m:
								if check(t) != False:
									temp.append(t)
							if temp != []:
								canonical_m = temp[0]

						surface_m = surface_m.replace("$", ":")
						canonical_m = canonical_m.replace("$", ":")

						surface_seg.append(surface_m)
						canonical_seg.append(canonical_m)

				if ''.join(m for m in surface_seg) != target:
					print(target, surface_seg)

				coarse_surface_seg.append(list('!'.join(m for m in surface_seg)))
				coarse_surface_form.append(target)

				coarse_canonical_seg.append(list('!'.join(m for m in canonical_seg)))
				coarse_canonical_form.append(target)

		for i in range(len(coarse_surface_form)):

			if coarse_surface_form[i] not in all_form:
				all_form.append(coarse_surface_form[i])
				all_seg.append(coarse_surface_seg[i])
		
			if coarse_canonical_form[i] not in all_canonical_form:
				all_canonical_form.append(coarse_canonical_form[i])
				all_canonical_seg.append(coarse_canonical_seg[i])


	if lang in ['ger', 'ind', 'zul']:

		with io.open(args.input + lang + '/trn', encoding = "latin-1") as f:
			for line in f:
				toks = line.strip().split('\t')

				target = toks[0]

				seg = []

				for m in toks[1].split():
					m = m.split(':')[0]
					seg.append(m)

				if ''.join(m for m in seg) != target:
					print(target, seg)

				coarse_seg.append(list('!'.join(m for m in seg)))
				coarse_form.append(target)

		with io.open(args.input + lang + '/tst', encoding = "latin-1") as f:
			for line in f:
				toks = line.strip().split('\t')

				target = toks[0]

				seg = []

				for m in toks[1].split():
					m = m.split(':')[0]
					seg.append(m)

				if ''.join(m for m in seg) != target:
					print(target, seg)

				coarse_seg.append(list('!'.join(m for m in seg)))
				coarse_form.append(target)

		if len(coarse_form) != 0:
			for i in range(len(coarse_form)):
				if coarse_form[i] not in all_form:
					all_form.append(coarse_form[i])
					all_seg.append(coarse_seg[i])

	if lang in ['ru']:

		with io.open(args.input + 'train_Tikhonov_reformat.txt', encoding = "utf-8") as f:
			for line in f:
				toks = line.strip().split('\t')

				target = toks[0]

				seg = []

				for m in toks[1].split('/'):
					m = m.split(':')[0]
					seg.append(m)

				if ''.join(c for c in seg) != target:
					print(seg)

				coarse_seg.append(list('!'.join(m for m in seg)))
				coarse_form.append(target)

		with io.open(args.input + 'test_Tikhonov_reformat.txt', encoding = "utf-8") as f:
			for line in f:
				toks = line.strip().split('\t')

				target = toks[0]

				seg = []

				for m in toks[1].split('/'):
					m = m.split(':')[0]
					seg.append(m)
				
				if ''.join(c for c in seg) != target:
					print(seg)

				coarse_seg.append(list('!'.join(m for m in seg)))
				coarse_form.append(target)

		if len(coarse_form) != 0:
			for i in range(len(coarse_form)):
				if coarse_form[i] not in all_form:
					all_form.append(coarse_form[i])
					all_seg.append(coarse_seg[i])


	if lang in ['ger_canonical', 'ind_canonical']:

		with io.open(args.input + lang, encoding = "latin-1") as f:
			for line in f:

				toks = line.strip().split('\t')

				target = toks[0]

				seg = toks[-1].split()

				coarse_seg.append(list('!'.join(m for m in seg)))
				coarse_form.append(target)

		if len(coarse_form) != 0:
			for i in range(len(coarse_form)):
			#	if coarse_form[i] not in all_form:
				all_form.append(coarse_form[i])
				all_seg.append(coarse_seg[i])

	if lang in ['mayo', 'nahuatl', 'wixarika']:

		with io.open(args.input + lang + '_tgt', encoding = 'utf-8') as f:

			for line in f:

				toks = line.strip().split()

				coarse_seg.append(toks)

				target = ''.join(c for c in toks)
				target = target.replace('!', '')

				coarse_form.append(target)

		if len(coarse_form) != 0:
			for i in range(len(coarse_form)):
				if coarse_form[i] not in all_form:
					all_form.append(coarse_form[i])
					all_seg.append(coarse_seg[i])

	if lang in ['persian']:

		with io.open(args.input + 'persian', encoding = 'utf-8') as f:

			for line in f:

				toks = line.strip().split()
				seg = toks[4 : ]

				if ''.join(m for m in seg) == toks[0]:

					coarse_seg.append(list('!'.join(m for m in seg)))

					target = ''.join(m for m in seg)

					coarse_form.append(target)

					if ''.join(m for m in seg) != toks[0]:
						print(seg, toks[0])

		if len(coarse_form) != 0:
			for i in range(len(coarse_form)):
				if coarse_form[i] not in all_form:
					all_form.append(coarse_form[i])
					all_seg.append(coarse_seg[i])


	### selecting 1,000 words for every language 

#	old_all_form = all_form
#	old_all_seg = all_seg
#	all_form = []
#	all_seg = []

#	old_all_canonical_form = all_canonical_form
#	old_all_canonical_seg = all_canonical_seg
#	all_canonical_form = []
#	all_canonical_seg = []

#	index = []
#	i = 0
#	while i < len(old_all_seg):
#		index.append(i)
#		i += 1

	### change k for minimal resource settings, or for experiments on languages other than seneca ###

#	select = random.sample(index, k = int(args.k))

#	select = random.sample(index, k = 1000)

#	for i in select:
#		all_form.append(old_all_form[i])
#		all_seg.append(old_all_seg[i])

#		if len(old_all_canonical_form) != 0:
#			all_canonical_form.append(old_all_canonical_form[i])
#			all_canonical_seg.append(old_all_canonical_seg[i])


	##### generating train/dev/test split  #####

	temp = []
	for tok in all_seg:
		temp.append(' '.join(m for m in tok))

	print(len(temp))
	print(len(set(temp)))


	heldout_size = 0.4

	all_index = []
	i = 0
	while i < len(all_seg):
		all_index.append(i)
		i += 1

	random.shuffle(all_index)


	assert len(set(temp)) == len(set(all_index)) 

	choices = ['A', 'B', 'C', 'D', 'E']

	print('Generating data')

	for z in range(1, 51):

		select_index = []
		select = []
		select_canonical = []

		if args.r == 'with':  ### With replacement ###
			select_index = random.choices(all_index, k = int(args.k))

		if args.r == 'without': ### Without replacement ###
			select_index = random.sample(all_index, k = int(args.k))

		for idx in select_index:
			select.append(all_seg[idx])

		if len(all_canonical_seg) != 0:
			for idx in select_index:
				select_canonical.append(all_canonical_seg[idx])

		temp = []
		for tok in select:
			temp.append(' '.join(m for m in tok))
		

		if args.r == 'yes':
			assert len(set(temp)) <= int(args.k)

		if args.r == 'no':
			assert len(set(temp)) == int(args.k)

		for choice in choices:

			index = []
			i = 0
			while i < len(select): 
				index.append(i)
				i += 1

			random.shuffle(index)

			total = int(args.k)
			num_train = total - int(heldout_size * total)
			num_dev = int(num_train / 2)

			train_src = io.open(args.output + args.k + '/' + args.r + '/' + lang + '_' + 'train_src' + '_' + str(z) + choice, 'w', encoding = 'utf-8')
			train_trg = io.open(args.output + args.k + '/' + args.r + '/' + lang + '_' + 'train_tgt' + '_' + str(z) + choice, 'w', encoding = 'utf-8')

			train_src_vocab = io.open(args.output + args.k + '/' + args.r + '/' + lang + '_' + 'vocab_src' + '_' + str(z) + choice, 'w', encoding = 'utf-8')
			train_trg_vocab = io.open(args.output + args.k + '/' + args.r + '/' + lang + '_' + 'vocab_tgt' + '_' + str(z) + choice, 'w', encoding = 'utf-8')

			train_src_vocab.write('<blank>' + '\n')
			train_src_vocab.write('<s>' + '\n')
			train_src_vocab.write('</s>' + '\n')

			train_trg_vocab.write('<blank>' + '\n')
			train_trg_vocab.write('<s>' + '\n')
			train_trg_vocab.write('</s>' + '\n')

		#	dev_src = io.open(args.output + lang + '_' + 'dev_src' + '_' + str(z) + choice, 'w', encoding = 'utf-8')
		#	dev_trg = io.open(args.output + lang + '_' + 'dev_tgt' + '_' + str(z) + choice, 'w', encoding = 'utf-8')

			test_src = io.open(args.output + args.k + '/' + args.r + '/' + lang + '_' + 'test_src' + '_' + str(z) + choice, 'w', encoding = 'utf-8')
			test_trg = io.open(args.output + args.k + '/' + args.r + '/' + lang + '_' + 'test_tgt' + '_' + str(z) + choice, 'w', encoding = 'utf-8')
	
			final_seg = []
			final_form = []

			for i in index[ : num_train]:
				seg = select[i]
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
				seg = select[i]
				form = seg
			#	dev_src.write(' '.join(c for c in form if c != '!') + '\n')
			#	dev_trg.write(' '.join(m for m in seg) + '\n')
				test_src.write(' '.join(c for c in form if c != '!') + '\n')
				test_trg.write(' '.join(m for m in seg) + '\n')


			for i in heldout_index[num_dev : ]:
				seg = select[i]
				form = seg
				test_src.write(' '.join(c for c in form if c != '!') + '\n')
				test_trg.write(' '.join(m for m in seg) + '\n')

'''

			if len(all_canonical_form) != 0:

				train_src = io.open(args.output + lang + '_canonical_' + 'train_src' + '_' + str(z) + choice, 'w', encoding = 'utf-8')
				train_trg = io.open(args.output + lang + '_canonical_' + 'train_tgt' + '_' + str(z) + choice, 'w', encoding = 'utf-8')

				train_src_vocab = io.open(args.output + lang + '_canonical_' + 'vocab_src' + '_' + str(z) + choice, 'w', encoding = 'utf-8')
				train_trg_vocab = io.open(args.output + lang + '_canonical_' + 'vocab_tgt' + '_' + str(z) + choice, 'w', encoding = 'utf-8')

				train_src_vocab.write('<blank>' + '\n')
				train_src_vocab.write('<s>' + '\n')
				train_src_vocab.write('</s>' + '\n')

				train_trg_vocab.write('<blank>' + '\n')
				train_trg_vocab.write('<s>' + '\n')
				train_trg_vocab.write('</s>' + '\n')

				dev_src = io.open(args.output + lang + '_canonical_' + 'dev_src' + '_' + str(z) + choice, 'w', encoding = 'utf-8')
				dev_trg = io.open(args.output + lang + '_canonical_' + 'dev_tgt' + '_' + str(z) + choice, 'w', encoding = 'utf-8')

				test_src = io.open(args.output + lang + '_canonical_' + 'test_src' + '_' + str(z) + choice, 'w', encoding = 'utf-8')
				test_trg = io.open(args.output + lang + '_canonical_' + 'test_tgt' + '_' + str(z) + choice, 'w', encoding = 'utf-8')

				final_seg = []
				final_form = []

				for i in index[ : num_train]:
					seg = select_canonical[i]
					form = select[i]
					train_src.write(' '.join(c for c in form if c != '!') + '\n')
					train_trg.write(' '.join(m for m in seg) + '\n')

					final_seg.append(seg)
					final_form.append(form)

				final_form_vocab = generate_vocab(final_form)
				final_seg_vocab = generate_vocab(final_seg)

			#	assert len(final_form_vocab) == len(final_seg_vocab)

				for c in final_form_vocab:
					if c != '!':
						train_src_vocab.write(c + '\n')

				for c in final_seg_vocab:
					train_trg_vocab.write(c + '\n')

				heldout_index = index[num_train : ]

				for i in heldout_index[ : num_dev]:
					seg = select_canonical[i]
					form = select[i]
					dev_src.write(' '.join(c for c in form if c != '!') + '\n')
					dev_trg.write(' '.join(m for m in seg) + '\n')


				for i in heldout_index[num_dev : ]:
					seg = select_canonical[i]
					form = select[i]
					test_src.write(' '.join(c for c in form if c != '!') + '\n')
					test_trg.write(' '.join(m for m in seg) + '\n')

'''