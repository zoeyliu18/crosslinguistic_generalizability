
import io, argparse


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'path to data set folder (e.g. 2000, 3000)')
	parser.add_argument('--lang', type = str, help = 'language')

	args = parser.parse_args()

	choices = ['A', 'B', 'C', 'D', 'E']

	lang = args.lang

	file_name = lang + '_'+ args.input.split('/')[-2] + '_morf_eval.sh'

	with io.open(file_name, 'w', encoding = 'utf-8') as f:		

		for z in range(1, 51):
			for choice in choices:
				split = str(z) + choice			

			#	f.write('python3 /Users/Silverlining/Documents/GitHub/model_generalizability/code/eval.py --input ' + '/Users/Silverlining/Documents/GitHub/model_generalizability/' + args.input + 'with/ --lang ' + lang + ' --split ' + split + ' --m morf' + '\n')
				f.write('python3 code/eval.py --input ' + '/data/liuaal/model_generalizability/' + args.input + 'with/ --lang ' + lang + ' --split ' + split + ' --m morf' + '\n')

				f.write('\n')

			#	f.write('python3 /Users/Silverlining/Documents/GitHub/model_generalizability/code/eval.py --input ' + '/Users/Silverlining/Documents/GitHub/model_generalizability/' + args.input + 'without/ --lang ' + lang + ' --split ' + split + ' --m morf' + '\n')
				f.write('python3 code/eval.py --input ' + '/data/liuaal/model_generalizability/' + args.input + 'without/ --lang ' + lang + ' --split ' + split + ' --m morf' + '\n')

				f.write('\n')