import io, os, argparse, random, statistics, codecs


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'input path to data')
	parser.add_argument('--output', type = str, help = 'output path')
	parser.add_argument('--lang', type = str, help = 'language')
	parser.add_argument('--k', type = str, help = 'sample size')

	args = parser.parse_args()

	lang = args.lang

	self_train = []
	
	selected_form = []

	grammar_form = []

	coarse_form = []


	if lang == 'grammar':

		with io.open(args.input, encoding = 'utf-8') as f:
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

				target = seg
				target = target.replace("!", "")

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

				target = seg
				target = target.replace("!", "")

				grammar_form.append(target)

		with io.open(args.input + 'src.txt', encoding = 'utf-8') as f:
			for line in f:
				toks = line.strip().split()

				target = ''.join(c for c in toks)
				coarse_form.append(target)
		print(len(coarse_form))
		with io.open(args.input + lang + '_train_src_1', encoding = 'utf-8') as f:
			for line in f:
				toks = line.strip().split()

				target = ''.join(c for c in toks)
				selected_form.append(target)

		with io.open(args.input + lang + '_dev_src_1', encoding = 'utf-8') as f:
			for line in f:
				toks = line.strip().split()

				target = ''.join(c for c in toks)
				selected_form.append(target)

		with io.open(args.input + lang + '_test_src_1', encoding = 'utf-8') as f:
			for line in f:
				toks = line.strip().split()

				target = ''.join(c for c in toks)
				selected_form.append(target)


		for i in range(len(coarse_form)):
			if coarse_form[i] not in selected_form and coarse_form[i] not in grammar_form and coarse_form[i] not in self_train:
				self_train.append(coarse_form[i])
		print(len(self_train))
	
		with io.open(args.output + lang + '_additional_' + args.k, 'w', encoding = 'utf-8') as f:
			select = random.sample(self_train, k = int(args.k))
			print(len(select))
			print(len(set(select)))
			for tok in select:
				f.write(' '.join(c for c in tok) + '\n')


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
				#	print(target, ''.join(c for c in seg))

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
			#		print(target, ''.join(c for c in seg))

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
				if coarse_form[i] not in all_form:
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

