import pandas as pd
import io, os


test_heuristics = pd.read_csv('/data/liuaal/model_generalizability/yayyy/ru_new_test_heuristics.txt', sep='\\\t', encoding = 'utf-8')
full = pd.read_csv('/data/liuaal/model_generalizability/yayyy/russian_test_full.csv', encoding = 'utf-8')

test_heuristics = pd.DataFrame(test_heuristics)
full = pd.DataFrame(full)

samples = set(test_heuristics['Sample'].tolist())
language = test_heuristics['Language'].tolist()[0]
sample_sizes = set(full['Sample_size'].tolist())
splits = set(test_heuristics['Split'].tolist())
replacements = ['with', 'without']
metrics = ['Accuracy', 'Precision', 'Recall', 'F1', 'Distance']


together = pd.DataFrame()

for sample in samples:
	for sample_size in sample_sizes:
		for split in splits:
			for replacement in replacements:
				for metric in metrics:
					results = full[(full['Metric'] == metric) & (full['Sample_size'] == sample_size) & (full['Split'] == split) & (full['Size'] == sample) & (full['Replacement'] == replacement)]
					new_test_heuristics = test_heuristics[(test_heuristics['Test_size'] == sample_size) & (test_heuristics['Split'] == split) & (test_heuristics['Feature'] == 'morph_overlap') & (test_heuristics['Sample'] == sample) & (test_heuristics['Replacement'] == replacement)]
					del new_test_heuristics['Feature']
					del new_test_heuristics['Caveat']
					new_test_heuristics = new_test_heuristics.rename(columns = {'Language': 'Language', 'Sample': 'Sample', 'Replacement': 'Replacement', 'Split': 'Split', 'Test_size': 'Test_size', 'Test_id': 'Test_id', 'Set': 'Set', 'Value': 'morph_overlap'}, errors = 'raise')
					
					for feature in ['ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio']:
						subset = test_heuristics[(test_heuristics['Test_size'] == sample_size) & (test_heuristics['Split'] == split) & (test_heuristics['Feature'] == feature) & (test_heuristics['Sample'] == sample) & (test_heuristics['Replacement'] == replacement)]
						values = subset['Value'].tolist()
						new_test_heuristics[feature] = values

					results = results.reset_index()
					new_test_heuristics = new_test_heuristics.reset_index()
					del results['index']
					del new_test_heuristics['index']

					together = pd.concat([together, pd.concat([results, new_test_heuristics], axis = 1)])

together.to_csv('/data/liuaal/model_generalizability/yayyy/russian_test_together.csv', encoding = 'utf-8', index = False)






