import io, argparse, os


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'path to config folder')
	parser.add_argument('--lang', type = str, help = 'language')
	parser.add_argument('--r', type = str, help = 'with or without replacement')

	args = parser.parse_args()

	if not os.path.exists(args.input + args.r + '/config/'):
		os.makedirs(args.input + args.r + '/config/')

	choices = ['A', 'B', 'C', 'D', 'E']

	lang = args.lang

	for i in range(1, 51):
		for choice in choices:

			with io.open(args.input + args.r + '/config/' + lang + str(i) + choice + '.yaml', 'w', encoding = 'utf-8') as f:
				f.write('save_data: ' + args.r + '\n')
				f.write('src_vocab: ' + args.r + '/' + lang + '_vocab_src_' + str(i) + choice + '\n')
				f.write('tgt_vocab: ' + args.r + '/' + lang + '_vocab_tgt_' + str(i) + choice + '\n')
				f.write('overwrite: False' + '\n')
				f.write('\n')
				f.write('data:' + '\n')
				f.write('  ' + 'train:' + '\n')
				f.write('  ' + '  ' + 'path_src: ' + args.r + '/' + lang + '_train_src_' + str(i) + choice + '\n')
				f.write('  ' + '  ' + 'path_tgt: ' + args.r + '/' + lang + '_train_tgt_' + str(i) + choice + '\n')
				f.write('  ' + 'valid:' + '\n')
			#	f.write('  ' + '  ' + 'path_src: ' + args.r + '/' + lang + '_dev_src_' + str(i) + choice + '\n')
			#	f.write('  ' + '  ' + 'path_tgt: ' + args.r + '/' + lang + '_dev_tgt_' + str(i) + choice + '\n')
				f.write('  ' + '  ' + 'path_src: ' + args.r + '/' + lang + '_train_src_' + str(i) + choice + '\n')
				f.write('  ' + '  ' + 'path_tgt: ' + args.r + '/' + lang + '_train_tgt_' + str(i) + choice + '\n')

