
import io, argparse, os


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'input to data set folder (e.g. 2000, 3000)')
	parser.add_argument('--lang', type = str, help = 'language')
	parser.add_argument('--r', type = str, help = 'with or without replacement')

	args = parser.parse_args()

	choices = ['A', 'B', 'C', 'D', 'E']

	lang = args.lang

	with io.open(args.input + 'seq2seq_' + args.r + '.sh', 'w', encoding = 'utf-8') as f:
		for z in range(1, 51):

			for choice in choices:
				split = str(z) + choice

				if args.r == 'with':
					if lang == 'robbie':
						f.write('!onmt_train -config ' + args.r + '/config/' + lang + str(z) + choice + '.yaml -gpu_ranks 0 -keep_checkpoint 1 -save_model seneca_' +  lang + str(z) + choice + '_with --seed 1234 -early_stopping 5000 -batch_size 16 -layers 2 -src_word_vec_size 300 -tgt_word_vec_size 300 -enc_rnn_size 100 -dec_rnn_size 100 —rnn_type GRU -optim adadelta -encoder_type brnn --train_steps 10000 -share_vocab -global_attention mlp' + '\n')
						f.write('\n')
						f.write('!onmt_translate -model seneca_' + lang + str(z) + choice + '_with_step_10000.pt -src ' + args.r + '/' + lang + '_test_src_' + str(z) + choice + ' -output ' + args.r + '/' + lang + '_test_pred_' + str(z) + choice + ' -gpu 0 --n_best 1')
						f.write('\n')
				#		f.write('\n')
				#		f.write('python3 /Users/Silverlining/Documents/GitHub/model_generalizability/code/eval.py --input ' + '/Users/Silverlining/Documents/GitHub/model_generalizability/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + split + '\n')
				
					else:
						if lang + '_test_eval_' + split not in os.listdir(args.input + args.r + '/'):
							print(split)
				#			f.write('!onmt_train -config ' + args.r + '/config/' + lang + str(z) + choice + '.yaml -gpu_ranks 0 -keep_checkpoint 1 -save_model ' +  lang + str(z) + choice + '_with --seed 1234 -early_stopping 5000 -batch_size 16 -layers 2 -src_word_vec_size 300 -tgt_word_vec_size 300 -enc_rnn_size 100 -dec_rnn_size 100 —rnn_type GRU -optim adadelta -encoder_type brnn --train_steps 10000 -share_vocab -global_attention mlp' + '\n')
							f.write('\n')
				#			f.write('!onmt_translate -model ' + lang + str(z) + choice + '_with_step_10000.pt -src ' + args.r + '/' + lang + '_test_src_' + str(z) + choice + ' -output ' + args.r + '/' + lang + '_test_pred_' + str(z) + choice + ' -gpu 0 --n_best 1')
							f.write('\n')

						
				#			f.write('python3 /Users/Silverlining/Documents/GitHub/model_generalizability/code/eval.py --input ' + '/Users/Silverlining/Documents/GitHub/model_generalizability/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + split + '\n')
							f.write('python3 /gsfs0/data/liuaal/model_generalizability/code/eval.py --input ' + '/gsfs0/data/liuaal/careful/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + split + '\n')
					

				if args.r == 'without':
					if lang == 'robbie':
						f.write('!onmt_train -config ' + args.r + '/config/' + lang + str(z) + choice + '.yaml -gpu_ranks 0 -keep_checkpoint 1 -save_model seneca_' +  lang + str(z) + choice + ' --seed 1234 -early_stopping 5000 -batch_size 16 -layers 2 -src_word_vec_size 300 -tgt_word_vec_size 300 -enc_rnn_size 100 -dec_rnn_size 100 —rnn_type GRU -optim adadelta -encoder_type brnn --train_steps 10000 -share_vocab -global_attention mlp' + '\n')
						f.write('\n')
						f.write('!onmt_translate -model seneca_' + lang + str(z) + choice + '_step_10000.pt -src ' + args.r + '/' + lang + '_test_src_' + str(z) + choice + ' -output ' + args.r + '/' + lang + '_test_pred_' + str(z) + choice + ' -gpu 0 --n_best 1')
						f.write('\n')
				#		f.write('python3 /Users/Silverlining/Documents/GitHub/model_generalizability/code/eval.py --input ' + '/Users/Silverlining/Documents/GitHub/model_generalizability/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + split + '\n')

					else:
						if lang + '_test_eval_' + split not in os.listdir(args.input + args.r + '/'):
							print(split)
				#			f.write('!onmt_train -config ' + args.r + '/config/' + lang + str(z) + choice + '.yaml -gpu_ranks 0 -keep_checkpoint 1 -save_model ' +  lang + str(z) + choice + ' --seed 1234 -early_stopping 5000 -batch_size 16 -layers 2 -src_word_vec_size 300 -tgt_word_vec_size 300 -enc_rnn_size 100 -dec_rnn_size 100 —rnn_type GRU -optim adadelta -encoder_type brnn --train_steps 10000 -share_vocab -global_attention mlp' + '\n')
							f.write('\n')
				#			f.write('!onmt_translate -model ' + lang + str(z) + choice + '_step_10000.pt -src ' + args.r + '/' + lang + '_test_src_' + str(z) + choice + ' -output ' + args.r + '/' + lang + '_test_pred_' + str(z) + choice + ' -gpu 0 --n_best 1')
							f.write('\n')

						
				#			f.write('python3 /Users/Silverlining/Documents/GitHub/model_generalizability/code/eval.py --input ' + '/Users/Silverlining/Documents/GitHub/model_generalizability/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + split + '\n')
				
							f.write('python3 /gsfs0/data/liuaal/model_generalizability/code/eval.py --input ' + '/gsfs0/data/liuaal/careful/' + args.input + args.r + '/ --lang ' + lang + ' --split ' + split + '\n')
					
				f.write('\n')