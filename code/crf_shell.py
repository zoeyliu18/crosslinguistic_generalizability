
import io, argparse


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'path to data set folder (e.g. 2000, 3000)')
	parser.add_argument('--lang', type = str, help = 'language')
	parser.add_argument('--r', type = str, help = 'with or without replacement')

	args = parser.parse_args()

	choices = ['A', 'B', 'C', 'D', 'E']

	lang = args.lang

	with io.open(args.input + 'crf_' + args.r + '.sh', 'w', encoding = 'utf-8') as f:		

		for z in range(1, 51):
			for choice in choices:
				split = str(z) + choice

				f.write('python3 /Users/Silverlining/Documents/GitHub/model_generalizability/code/crf.py --input ' + '/Users/Silverlining/Documents/GitHub/model_generalizability/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + split + '\n')

				f.write('\n')

				f.write('python3 /Users/Silverlining/Documents/GitHub/model_generalizability/code/eval.py --input ' + '/Users/Silverlining/Documents/GitHub/model_generalizability/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + split + ' --m crf' + '\n')
