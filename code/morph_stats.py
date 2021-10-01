import io, os, argparse, random, statistics, codecs


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'input to language folder (e.g. persian)')
	parser.add_argument('--output', type = str, help = 'output file for descriptive statistics')
	parser.add_argument('--lang', type = str, help = 'language')

	args = parser.parse_args()


	lang = args.lang

	choices = ['A']  ### number of morphs and average morphs per word are the same across the five random splits of each data set)

	replacement = ['with', 'without']

	files = [lang + '_train_tgt_' + '1A', lang + '_dev_tgt_' + '1A', lang + '_test_tgt_' + '1A']

	data = []

	outfile = io.open(args.output, 'w', encoding = 'utf-8')
	outfile.write(' '.join(w for w in ['Language', 'Size', 'Replacement', 'Morphs', 'morphs_per_word']) + '\n')

	for d in os.listdir(args.input):
		for r in replacement:			

			all_morphs = 0
			all_morphs_per_word = 0

			for n in range(1, 51):

				morphs = []
				morphs_per_word = 0

				for choice in choices:

					split = str(n) + choice

					train = []
					dev = []
					test = []

					for f in files:
						with io.open(args.input + d + '/' + r + '/' + f, encoding = 'utf-8') as f:

							for line in f:

								toks = ''.join(c for c in line.split())
								toks = toks.split('!')

								for morph in toks:
									morphs.append(morph)

								morphs_per_word += len(toks)

				morphs = len(set(morphs))
				all_morphs += morphs

				morphs_per_word = morphs_per_word / int(d)
				all_morphs_per_word += morphs_per_word

			all_morphs = round(all_morphs / 50, 2)
			all_morphs_per_word = round(all_morphs_per_word / 50, 2)

			outfile.write(' '.join(str(w) for w in [lang, d, r, all_morphs, all_morphs_per_word]) + '\n')



