import io, os, argparse, random

def replicate(file, k, upsample, add = None):

	src = []
	tgt = []

	augmented_src = []
	augmented_tgt = []

	with io.open(file, encoding = 'utf-8') as f:
		for line in f:
			toks = line.strip().split()
			seg = ''.join(c for c in toks)
		
			tgt.append(seg)
			src.append(seg.replace('!', ''))
		
			augmented_tgt.append(seg)
			augmented_src.append(seg.replace('!', '') + 'Y')

	if upsample:

		for i in range(k - 1):
			for z in range(len(src)):
				augmented_src.append(src[z] + 'Y')
				augmented_tgt.append(tgt[z])

	if add != None:

		with io.open(add, encoding = 'utf-8') as f:
			for line in f:
				toks = line.strip().split()
				toks = ''.join(c for c in toks)
				augmented_src.append(toks + 'Z')
				augmented_tgt.append(toks)

	else:
		for i in range(k):
			for z in range(len(src)):
				augmented_src.append(src[z] + 'Z')
				augmented_tgt.append(tgt[z].replace('!', ''))

	return augmented_src, augmented_tgt

def prep_dev(file, path):

	src = []

	with io.open(path + file, encoding = 'utf-8') as f:
		for line in f:
			toks = line.strip()
			src.append(toks + ' Y')

	return src


def hallucinate(pred_file):

	all_pred = []

	new_src_list = []
	new_tgt_list = []

	vocab = []

	with io.open(pred_file, encoding = 'utf-8') as f:
		for line in f:
			toks = line.strip().split()
			for c in toks:
				if c != '!':
					vocab.append(c)
			pred = (''.join(c for c in toks)).split('!')
			all_pred.append(pred)

	vocab = list(set(vocab))

	
	for pred in all_pred:

		for z in range(len(pred)):
			new_pred_list = []
		
			m = pred[z]

			
			if len(m) < 3:
				seg = ' '.join(m for m in pred)
				if seg not in new_pred_list:
					new_pred_list.append(seg)

			if len(m) >= 3:
				pre = ''
				if z != 0:
					pre = ' '.join(tok for tok in pred[ : z])

				rest = ''
				if z != len(pred) - 1:
					rest = ' '.join(m for m in pred[z + 1 : ])


				for i in range(len(m[1 : -1])):
					new_m = [m[0 : i + 1]]
					print(new_m)
					c = m[i]
					new_c = c

					while new_c == c:
						new_c = random.sample(vocab, k = 1)[0]

					new_m.append(new_c)
					print(new_m)

					morph_rest = m[i + 2 : ]

					new_m.append(morph_rest)
					print(new_m)
					new_m = ''.join(c for c in new_m)

					seg = pre + ' ' + new_m + ' ' + rest
					print(pred, seg, new_m)

					if seg not in new_pred_list:
						new_pred_list.append(seg)

				for tok in new_pred_list:
					if tok not in new_tgt_list:
						tok = tok.split()
						new_tgt_list.append('!'.join(m for m in tok))

	for tok in all_pred:
		tok = '!'.join(m for m in tok)
		if tok not in new_tgt_list:
			new_tgt_list.append(tok)

	for tok in new_tgt_list:
		tok = tok.replace('!', '')
		new_src_list.append(tok)

	return new_src_list, new_tgt_list


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--data', type = str, help = '*.tgt data to be augmented')
	parser.add_argument('--output', type = str, help = 'output for augmented data')
#	parser.add_argument('--k', type = str, help = 'size of replication')
#	parser.add_argument('--upsample', type = str, help = 'upsampling')
#	parser.add_argument('--add', type = str, help = 'additional data from other languages')

	args = parser.parse_args()


	src, tgt = hallucinate(args.data)

	with io.open(args.output + '/robbie_train_src_hallucinate_1', 'w', encoding = 'utf-8') as f:
		for tok in src:
			f.write(' '.join(c for c in tok) + '\n')

	with io.open(args.output + '/robbie_train_tgt_hallucinate_1', 'w', encoding = 'utf-8') as f:
		for tok in tgt:
			f.write(' '.join(c for c in tok) + '\n')


'''
	augmented_src, augmented_tgt = replicate(args.data, int(args.k), args.upsample)#, args.add)

	match = {'1': 'one', '5': 'five', '10': 'ten', '11': 'eleven', '20': 'twenty'}

	dev_tgt = args.data.split('/')[-1].replace('train', 'dev')
	dev_src = dev_tgt.replace('tgt', 'src')
	dev_path = '/'.join(t for t in args.data.split('/')[: -1]) + '/'

	with io.open(args.output + dev_src + '_replicate_' + match[args.k], 'w', encoding = 'utf-8') as f:
		for tok in prep_dev(dev_src, dev_path):
			f.write(tok + '\n')

	train_tgt = args.data.split('/')[-1] + '_replicate_' + match[args.k]
	train_src = (args.data.split('/')[-1] + '_replicate_' + match[args.k]).replace('tgt', 'src')

	with io.open(args.output + train_src, 'w', encoding = 'utf-8') as f:
		for tok in augmented_src:
			f.write(' '.join(c for c in tok) + '\n')

	with io.open(args.output + train_tgt, 'w', encoding = 'utf-8') as f:
		for tok in augmented_tgt:
			f.write(' '.join(c for c in tok) + '\n')

'''
