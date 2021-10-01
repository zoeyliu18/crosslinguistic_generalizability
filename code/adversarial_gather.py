### This script gathers the output from all data for plot ###

import io, argparse, statistics, math, os
from collections import Counter


def entropy(best_models_list):

	H = 0

	for m in set(best_models_list):
		prob = best_models_list.count(m) / len(best_models_list)
		H += -1 * (prob * math.log2(prob))

	return H


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--input', type = str, help = 'input path')
	parser.add_argument('--lang', type = str, help = 'target language')
	parser.add_argument('--full', type = str, help = 'full evaluation results including entropy measure')
	parser.add_argument('--short', type = str, help = 'output summary file')
	parser.add_argument('--long', type = str, help = 'output file of best model for each split')

	args = parser.parse_args()


	full_data = [['Language', 'Model', 'Metric', 'Split', 'Score', 'Size', 'Replacement']]

	data = []
	

	lang = args.lang


#	lang = lang.capitalize()

	choices = ['A']

	replacement = ['with', 'without']


	for d in os.listdir(args.input):
		for r in replacement:


		####################### CRF ######################

			for n in range(1, 51):

				choices_scores = []

				for choice in choices:
					with io.open(args.input + d + '/' + r + '/higher_orders/' + lang + '_test_eval_order0_' + str(n) + choice, encoding = 'utf-8') as f:

						scores = []
						for line in f:
							toks = line.strip().split(': ')
							scores.append(float(toks[-1]))

						choices_scores.append(scores)

						full_data.append([lang, '0-CRF', 'Accuracy', str(n) + choice, scores[0], d, r])
						full_data.append([lang, '0-CRF', 'Precision', str(n) + choice, scores[1], d, r])
						full_data.append([lang, '0-CRF', 'Recall', str(n) + choice, scores[2], d, r])
						full_data.append([lang, '0-CRF', 'F1', str(n) + choice, scores[3], d, r])
						full_data.append([lang, '0-CRF', 'Avg. Distance', str(n) + choice, 1 - scores[4], d, r])


				accuracy = []
				precision = []
				recall = []
				F1 = []
				dist = []

				for scores in choices_scores:
					accuracy.append(float(scores[0]))
					precision.append(float(scores[1]))
					recall.append(float(scores[2]))
					F1.append(float(scores[3]))
					dist.append(float(scores[4]))

				data.append([lang, '0-CRF', 'Accuracy', n, statistics.mean(accuracy), d, r])
				data.append([lang, '0-CRF', 'Precision', n, statistics.mean(precision), d, r])
				data.append([lang, '0-CRF', 'Recall', n, statistics.mean(recall), d, r])
				data.append([lang, '0-CRF', 'F1', n, statistics.mean(F1), d, r])
				data.append([lang, '0-CRF', 'Avg. Distance', n, 1 - statistics.mean(dist), d, r])

		####################### CRF-Order1 ######################

			for n in range(1, 51):

				choices_scores = []

				for choice in choices:
					with io.open(args.input + d + '/' + r + '/higher_orders/' + lang + '_test_eval_order1_' + str(n) + choice, encoding = 'utf-8') as f:
						
						scores = []
						for line in f:
							toks = line.strip().split(': ')
							scores.append(float(toks[-1]))

						choices_scores.append(scores)

						full_data.append([lang, '1-CRF', 'Accuracy', str(n) + choice, scores[0], d, r])
						full_data.append([lang, '1-CRF', 'Precision', str(n) + choice, scores[1], d, r])
						full_data.append([lang, '1-CRF', 'Recall', str(n) + choice, scores[2], d, r])
						full_data.append([lang, '1-CRF', 'F1', str(n) + choice, scores[3], d, r])
						full_data.append([lang, '1-CRF', 'Avg. Distance', str(n) + choice, 1 - scores[4], d, r])
			
				accuracy = []
				precision = []
				recall = []
				F1 = []
				dist = []

				for scores in choices_scores:
					accuracy.append(float(scores[0]))
					precision.append(float(scores[1]))
					recall.append(float(scores[2]))
					F1.append(float(scores[3]))
					dist.append(float(scores[4]))

				data.append([lang, '1-CRF', 'Accuracy', n, statistics.mean(accuracy), d, r])
				data.append([lang, '1-CRF', 'Precision', n, statistics.mean(precision), d, r])
				data.append([lang, '1-CRF', 'Recall', n, statistics.mean(recall), d, r])
				data.append([lang, '1-CRF', 'F1', n, statistics.mean(F1), d, r])
				data.append([lang, '1-CRF', 'Avg. Distance', n, 1 - statistics.mean(dist), d, r])

		####################### CRF-Order2 ######################

			for n in range(1, 51):

				choices_scores = []

				for choice in choices:
					with io.open(args.input + d + '/' + r + '/higher_orders/' + lang + '_test_eval_order2_' + str(n) + choice, encoding = 'utf-8') as f:
						scores = []
						for line in f:
							toks = line.strip().split(': ')
							scores.append(float(toks[-1]))

						choices_scores.append(scores)

						full_data.append([lang, '2-CRF', 'Accuracy', str(n) + choice, scores[0], d, r])
						full_data.append([lang, '2-CRF', 'Precision', str(n) + choice, scores[1], d, r])
						full_data.append([lang, '2-CRF', 'Recall', str(n) + choice, scores[2], d, r])
						full_data.append([lang, '2-CRF', 'F1', str(n) + choice, scores[3], d, r])
						full_data.append([lang, '2-CRF', 'Avg. Distance', str(n) + choice, 1 - scores[4], d, r])		

				accuracy = []
				precision = []
				recall = []
				F1 = []
				dist = []

				for scores in choices_scores:
					accuracy.append(float(scores[0]))
					precision.append(float(scores[1]))
					recall.append(float(scores[2]))
					F1.append(float(scores[3]))
					dist.append(float(scores[4]))

				data.append([lang, '2-CRF', 'Accuracy', n, statistics.mean(accuracy), d, r])
				data.append([lang, '2-CRF', 'Precision', n, statistics.mean(precision), d, r])
				data.append([lang, '2-CRF', 'Recall', n, statistics.mean(recall), d, r])
				data.append([lang, '2-CRF', 'F1', n, statistics.mean(F1), d, r])
				data.append([lang, '2-CRF', 'Avg. Distance', n, 1 - statistics.mean(dist), d, r])

		####################### CRF-Order3 ######################

			for n in range(1, 51):

				choices_scores = []

				for choice in choices:
					with io.open(args.input + d + '/' + r + '/higher_orders/' + lang + '_test_eval_order3_' + str(n) + choice, encoding = 'utf-8') as f:
						
						scores = []
						for line in f:
							toks = line.strip().split(': ')
							scores.append(float(toks[-1]))

						choices_scores.append(scores)

						full_data.append([lang, '3-CRF', 'Accuracy', str(n) + choice, scores[0], d, r])
						full_data.append([lang, '3-CRF', 'Precision', str(n) + choice, scores[1], d, r])
						full_data.append([lang, '3-CRF', 'Recall', str(n) + choice, scores[2], d, r])
						full_data.append([lang, '3-CRF', 'F1', str(n) + choice, scores[3], d, r])
						full_data.append([lang, '3-CRF', 'Avg. Distance', str(n) + choice, 1 - scores[4], d, r])

				accuracy = []
				precision = []
				recall = []
				F1 = []
				dist = []

				for scores in choices_scores:
					accuracy.append(float(scores[0]))
					precision.append(float(scores[1]))
					recall.append(float(scores[2]))
					F1.append(float(scores[3]))
					dist.append(float(scores[4]))

				data.append([lang, '3-CRF', 'Accuracy', n, statistics.mean(accuracy), d, r])
				data.append([lang, '3-CRF', 'Precision', n, statistics.mean(precision), d, r])
				data.append([lang, '3-CRF', 'Recall', n, statistics.mean(recall), d, r])
				data.append([lang, '3-CRF', 'F1', n, statistics.mean(F1), d, r])
				data.append([lang, '3-CRF', 'Avg. Distance', n, 1 - statistics.mean(dist), d, r])


		####################### CRF-Order4 ######################

			for n in range(1, 51):

				choices_scores = []

				for choice in choices:
					with io.open(args.input + d + '/' + r + '/higher_orders/' + lang + '_test_eval_order4_' + str(n) + choice, encoding = 'utf-8') as f:
						scores = []
						for line in f:
							toks = line.strip().split(': ')
							scores.append(float(toks[-1]))

						choices_scores.append(scores)

						full_data.append([lang, '4-CRF', 'Accuracy', str(n) + choice, scores[0], d, r])
						full_data.append([lang, '4-CRF', 'Precision', str(n) + choice, scores[1], d, r])
						full_data.append([lang, '4-CRF', 'Recall', str(n) + choice, scores[2], d, r])
						full_data.append([lang, '4-CRF', 'F1', str(n) + choice, scores[3], d, r])
						full_data.append([lang, '4-CRF', 'Avg. Distance', str(n) + choice, 1 - scores[4], d, r])

				accuracy = []
				precision = []
				recall = []
				F1 = []
				dist = []

				for scores in choices_scores:
					accuracy.append(float(scores[0]))
					precision.append(float(scores[1]))
					recall.append(float(scores[2]))
					F1.append(float(scores[3]))
					dist.append(float(scores[4]))

				data.append([lang, '4-CRF', 'Accuracy', n, statistics.mean(accuracy), d, r])
				data.append([lang, '4-CRF', 'Precision', n, statistics.mean(precision), d, r])
				data.append([lang, '4-CRF', 'Recall', n, statistics.mean(recall), d, r])
				data.append([lang, '4-CRF', 'F1', n, statistics.mean(F1), d, r])
				data.append([lang, '4-CRF', 'Avg. Distance', n, 1 - statistics.mean(dist), d, r])


	outfile = io.open(args.short, 'w', encoding = 'utf-8')
	outfile.write('\t'.join(str(w) for w in ['Language', 'Index', 'Proportion', 'Summary', 'Size', 'Replacement', 'Metric']) + '\n')


	details = io.open(args.long, 'w', encoding = 'utf-8')
	details.write('Language' + '\t' + 'Split' + '\t' + 'Size' + '\t' + 'Replacement' + '\t' + 'Model' + '\t' + 'Metric' + '\t' + 'Value' + '\n')

	metrics = ['Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance']

	for d in os.listdir(args.input):
		for r in replacement:

			rankings = {}
			rankings_scores = {}
			first_rank = ''

			simple_rankings = {}
			simple_rankings_scores = {}
			simple_first_rank = ''

			for metric in metrics:
				for n in range(1, 51):

					scores = []
					models = []
					simple_models = []

					for tok in data:
						if tok[3] == n and tok[2] == metric and tok[-2] == d and tok[-1] == r:
							scores.append(tok[4])
							models.append(tok[1])

							if tok[1] in ['0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF']:
								simple_models.append('CRF')
							else: simple_models.append(tok[1])


					z = [model for score, model in sorted(zip(scores, models))]
					score_z = [score for score, model in sorted(zip(scores, models))]

					rankings[n] = z 
					rankings_scores[n] = score_z

					simple_z = [model for score, model in sorted(zip(scores, simple_models))]
					simple_score_z = [score for score, model in sorted(zip(scores, simple_models))]

					simple_rankings[n] = simple_z 
					simple_rankings_scores[n] = simple_score_z


				for k, v in rankings.items():
					if k == 1:
						first_rank = v

				for k, v in simple_rankings.items():
					if k == 1:
						simple_first_rank = v

				first_count = 0
				rank_count = 0

				top_two_rank = 0

				best_models = []
				best_model_rankings = []

	
				for k, v in rankings.items():

					all_scores = rankings_scores[k]

					for i in range(len(v)):
						details.write('\t'.join(str(w) for w in [lang, k, d, r, v[i], metric, all_scores[i]]) + '\n')
			
					if v[-1] == first_rank[-1]:
						first_count += 1
					if v == first_rank:
						rank_count += 1	
					if v[-2 : ] == first_rank[-2 : ]:
						top_two_rank += 1

					best_models.append(v[-1])
					best_model_rankings.append(' '.join(r for r in v))

				best_model = Counter(best_models).most_common()[0]
				best_model_ranking = Counter(best_model_rankings).most_common()[0]

				simple_first_count = 0
				simple_rank_count = 0

				simple_best_models = []
				simple_best_model_rankings = []

	
				for k, v in simple_rankings.items():

					all_scores = simple_rankings_scores[k]

					if v[-1] == simple_first_rank[-1]:
						simple_first_count += 1
					if v == simple_first_rank:
						simple_rank_count += 1	

					simple_best_models.append(v[-1])
					simple_best_model_rankings.append(' '.join(r for r in v))

				best_model = Counter(best_models).most_common()[0]
				best_model_ranking = Counter(best_model_rankings).most_common()[0]

				simple_best_model = Counter(simple_best_models).most_common()[0]
				simple_best_model_ranking = Counter(simple_best_model_rankings).most_common()[0]


				outfile.write('\t'.join(str(w) for w in [lang, 'Same best model', round(first_count * 100 / 50, 2), 'Best model: ' + first_rank[-1], d, r, metric]) + '\n')
				outfile.write('\t'.join(str(w) for w in [lang, 'Same top two model', round(top_two_rank * 100 / 50, 2), 'Best top two model: ' + ' '.join(w for w in first_rank[-2 : ]), d, r, metric]) + '\n')
				outfile.write('\t'.join(str(w) for w in [lang, 'Same model ranking', round(rank_count * 100 / 50, 2), 'First ranking: ' + ' '.join(w for w in first_rank), d, r, metric]) + '\n')

				outfile.write('\t'.join(str(w) for w in [lang, 'A best model', round(best_model[1] * 100 / 50, 2), 'What is it: ' + best_model[0], d, r, metric]) + '\n')
				outfile.write('\t'.join(str(w) for w in [lang, 'A best model ranking', round(best_model_ranking[1] * 100 / 50, 2), 'What is it: ' + best_model_ranking[0], d, r, metric]) + '\n')				
				outfile.write('\t'.join(str(w) for w in [lang, 'Best model entropy', entropy(best_models), '', d, r, metric]) + '\n')

				outfile.write('\t'.join(str(w) for w in [lang, 'Simple best model', round(simple_best_model[1] * 100 / 50, 2), 'What is it: ' + simple_best_model[0], d, r, metric]) + '\n')
				outfile.write('\t'.join(str(w) for w in [lang, 'Simple best model ranking', round(simple_best_model_ranking[1] * 100 / 50, 2), 'What is it: ' + simple_best_model_ranking[0], d, r, metric]) + '\n')				
				outfile.write('\t'.join(str(w) for w in [lang, 'Simple model entropy', entropy(simple_best_models), '', d, r, metric]) + '\n')


	with io.open(args.full, 'w', encoding = 'utf-8') as full:
		for tok in full_data:
			full.write('\t'.join(str(w) for w in tok) + '\n')

