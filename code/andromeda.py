
import io, argparse, os


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'input to data set folder (e.g. 2000, 3000)')
	parser.add_argument('--lang', type = str, help = 'language')
	parser.add_argument('--r', type = str, help = 'with or without replacement')

	args = parser.parse_args()

	choices = ['A', 'B', 'C', 'D', 'E']

	lang = args.lang

	size = args.input.split('/')[-2]

	name = args.input.split('/')[-3]


	for t in range(1, 26):

		with io.open(args.input + 'seq2seq_' + args.r + str(t) + '.pbs', 'w', encoding = 'utf-8') as f:
			f.write('#!/bin/tcsh' + '\n')
			f.write('#SBATCH --job-name=' + 'seq2seq_' + args.r + str(t) + 'pbs' + '\n')
			f.write('#SBATCH --ntasks 1 --cpus-per-task 4' + '\n')
			f.write('#SBATCH --mem=35gb' + '\n')
			f.write('#SBATCH --time=24:00:00' + '\n')
			f.write('#SBATCH --mail-type=BEGIN,END,FAIL.' + '\n')
			f.write('#SBATCH --partition=gpuv100' + '\n')
			f.write('source /mmfs1/data/liuaal/accio/bin/activate.csh' + '\n')
			f.write('cd /mmfs1/data/liuaal/model_generalizability/' + name + '/' + size + '\n')

			for z in range((t - 1) * 2 + 1, t * 2 + 1):
				for choice in choices:
				
					if args.r == 'with':
						if lang == 'robbie':
							if 'seneca_' +  lang + str(z) + choice + '_with_step_10000.pt' not in os.listdir():
								f.write('onmt_train -config ' + args.r + '/config/' + lang + str(z) + choice + '.yaml -gpu_ranks 0 -keep_checkpoint 1 -save_model seneca_' +  lang + str(z) + choice + '_with --seed 1234 -early_stopping 5000 -batch_size 16 -layers 2 -src_word_vec_size 300 -tgt_word_vec_size 300 -enc_rnn_size 100 -dec_rnn_size 100 —rnn_type GRU -optim adadelta -encoder_type brnn --train_steps 10000 -share_vocab -global_attention mlp' + '\n')
								f.write('\n')
								f.write('onmt_translate -model seneca_' + lang + str(z) + choice + '_with_step_10000.pt -src ' + args.r + '/' + lang + '_test_src_' + str(z) + choice + ' -output ' + args.r + '/' + lang + '_test_pred_' + str(z) + choice + ' -gpu 0 --n_best 1')
								f.write('\n')
								f.write('python3 /mmfs1/data/liuaal/model_generalizability/code/eval.py --input ' + '/data/liuaal/model_generalizability/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + str(z) + choice + '\n')
								f.write('\n')

						else:
							if lang + str(z) + choice + '_with_step_10000.pt' not in os.listdir():
								f.write('onmt_train -config ' + args.r + '/config/' + lang + str(z) + choice + '.yaml -gpu_ranks 0 -keep_checkpoint 1 -save_model ' +  lang + str(z) + choice + '_with --seed 1234 -early_stopping 5000 -batch_size 16 -layers 2 -src_word_vec_size 300 -tgt_word_vec_size 300 -enc_rnn_size 100 -dec_rnn_size 100 —rnn_type GRU -optim adadelta -encoder_type brnn --train_steps 10000 -share_vocab -global_attention mlp' + '\n')
								f.write('\n')
								f.write('onmt_translate -model ' + lang + str(z) + choice + '_with_step_10000.pt -src ' + args.r + '/' + lang + '_test_src_' + str(z) + choice + ' -output ' + args.r + '/' + lang + '_test_pred_' + str(z) + choice + ' -gpu 0 --n_best 1')
								f.write('\n')
								f.write('python3 /mmfs1/data/liuaal/model_generalizability/code/eval.py --input ' + '/data/liuaal/model_generalizability/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + str(z) + choice + '\n')
								f.write('\n')
						
					if args.r == 'without':
						if lang == 'robbie':
							if 'seneca_' +  lang + str(z) + choice + '_step_10000.pt' not in os.listdir():
								f.write('onmt_train -config ' + args.r + '/config/' + lang + str(z) + choice + '.yaml -gpu_ranks 0 -keep_checkpoint 1 -save_model seneca_' +  lang + str(z) + choice + ' --seed 1234 -early_stopping 5000 -batch_size 16 -layers 2 -src_word_vec_size 300 -tgt_word_vec_size 300 -enc_rnn_size 100 -dec_rnn_size 100 —rnn_type GRU -optim adadelta -encoder_type brnn --train_steps 10000 -share_vocab -global_attention mlp' + '\n')
								f.write('\n')
								f.write('onmt_translate -model seneca_' + lang + str(z) + choice + '_step_10000.pt -src ' + args.r + '/' + lang + '_test_src_' + str(z) + choice + ' -output ' + args.r + '/' + lang + '_test_pred_' + str(z) + choice + ' -gpu 0 --n_best 1')
								f.write('\n')
								f.write('python3 /mmfs1/data/liuaal/model_generalizability/code/eval.py --input ' + '/data/liuaal/model_generalizability/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + str(z) + choice + '\n')
								f.write('\n')
						
						else:
							if lang + str(z) + choice + '_step_10000.pt' not in os.listdir():
								f.write('onmt_train -config ' + args.r + '/config/' + lang + str(z) + choice + '.yaml -gpu_ranks 0 -keep_checkpoint 1 -save_model ' +  lang + str(z) + choice + ' --seed 1234 -early_stopping 5000 -batch_size 16 -layers 2 -src_word_vec_size 300 -tgt_word_vec_size 300 -enc_rnn_size 100 -dec_rnn_size 100 —rnn_type GRU -optim adadelta -encoder_type brnn --train_steps 10000 -share_vocab -global_attention mlp' + '\n')
								f.write('\n')
								f.write('onmt_translate -model ' + lang + str(z) + choice + '_step_10000.pt -src ' + args.r + '/' + lang + '_test_src_' + str(z) + choice + ' -output ' + args.r + '/' + lang + '_test_pred_' + str(z) + choice + ' -gpu 0 --n_best 1')
								f.write('\n')
								f.write('python3 /mmfs1/data/liuaal/model_generalizability/code/eval.py --input ' + '/data/liuaal/model_generalizability/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + str(z) + choice + '\n')
								f.write('\n')
						
					f.write('\n')
