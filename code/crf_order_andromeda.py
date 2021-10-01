
import io, argparse, os


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'path to data set folder (e.g. 2000, 3000)')
	parser.add_argument('--lang', type = str, help = 'language')
	parser.add_argument('--r', type = str, help = 'with or without replacement')
	parser.add_argument('--order', type = str, help = 'order of CRF')

	args = parser.parse_args()

	choices = ['A', 'B', 'C', 'D', 'E']

	lang = args.lang

	with io.open(args.input + 'crf_order' + args.order + '_' + args.r + '.sh', 'w', encoding = 'utf-8') as f:		

		for z in range(1, 51):
			for choice in choices:
				split = str(z) + choice

				if lang + '_test_eval_order' + args.order + '_' + split not in os.listdir(args.input + args.r + '/') and 'crf_order' + args.order + '_' + split + '.model' not in os.listdir(args.input + args.r + '/'):

					print('crf_order' + args.order + '_' + split + '.model')
					
				#	f.write('python3 /Users/Silverlining/Documents/GitHub/generalize/code/prep_crf_data.py --input ' + args.r + '/ --split ' + split + ' --state g --lang ' + lang + '\n')

					f.write('python3 /mmfs1/data/liuaal/generalize/code/prep_crf_data.py --input ' + args.r + '/ --split ' + split + ' --state g --lang ' + lang + '\n')

					f.write('\n')

					f.write('crfsuite learn --type=semim -p feature.max_seg_len=1 -p feature.max_order=' + args.order + ' -m ' + args.r + '/' + 'crf_order' + args.order + '_' + str(z) + choice + '.model ' + args.r + '/' + lang + '_train_crfv_' + str(z) + choice + '\n')

					f.write('\n')

					f.write('crfsuite tag --type=semim -m ' + args.r + '/' + 'crf_order' + args.order + '_' + str(z) + choice + '.model ' + args.r + '/' + lang + '_test_crfv_' + str(z) + choice + ' > ' + args.r + '/' + lang + '_test_order' + args.order + '_labels_' + str(z) + choice)

					f.write('\n')

				#	f.write('python3 /Users/Silverlining/Documents/GitHub/generalize/code/prep_crf_data.py --input ' + args.r + '/ --split ' + split + ' --state r --lang ' + lang + ' --m order' + args.order + '\n')

					f.write('python3 /mmfs1/data/liuaal/generalize/code/prep_crf_data.py --input ' + args.r + '/ --split ' + split + ' --state r --lang ' + lang + ' --m order' + args.order + '\n')

					f.write('\n')

				#	f.write('python3 /Users/Silverlining/Documents/GitHub/generalize/code/eval.py --input ' + '/Users/Silverlining/Documents/GitHub/generalize/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + split + ' --m order' + args.order + '\n')
					
					f.write('python3 /mmfs1/data/liuaal/generalize/code/eval.py --input ' + '/mmfs1/data/liuaal/generalize/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + split + ' --m order' + args.order + '\n')
					
				if lang + '_test_eval_order' + args.order + '_' + split not in os.listdir(args.input + args.r + '/') and 'crf_order' + args.order + '_' + split + '.model' in os.listdir(args.input + args.r + '/'):
				
					print('crf_order' + args.order + '_' + split + '.model')

					f.write('crfsuite tag --type=semim -m ' + args.r + '/' + 'crf_order' + args.order + '_' + str(z) + choice + '.model ' + args.r + '/' + lang + '_test_crfv_' + str(z) + choice + ' > ' + args.r + '/' + lang + '_test_order' + args.order + '_labels_' + str(z) + choice)

					f.write('\n')

					f.write('python3 /mmfs1/data/liuaal/generalize/code/prep_crf_data.py --input ' + args.r + '/ --split ' + split + ' --state r --lang ' + lang + ' --m order' + args.order + '\n')

					f.write('\n')
					
					f.write('python3 /mmfs1/data/liuaal/generalize/code/eval.py --input ' + '/mmfs1/data/liuaal/generalize/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + split + ' --m order' + args.order + '\n')
					