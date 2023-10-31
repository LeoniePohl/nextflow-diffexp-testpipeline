#!/usr/bin/env python
import sys
import csv
from collections import defaultdict

# Function to merge the last columns based on the first column
# todo cut .bam from sample names
def merge_columns(input_files, output_path, output_path2):
    data = {}
    headers = []

    # Read data from input files
    for input_file in input_files:
        with open(input_file, 'r') as file:
            unique_genes = []
            header = None
            for line in file:
                if line.startswith('#'):
                    continue
                parts = line.strip().split('\t')
                if header is None:
                    header = parts[-1].split(".")[0]
                    headers.append(header)
                else:
                    gene_id = parts[0]
                    value = int(parts[-1])

                    if gene_id not in data:
                        data[gene_id] = [value]
                    elif gene_id in data and gene_id not in unique_genes:
                        data[gene_id].append(value)
                    elif gene_id in data and gene_id in unique_genes:
                        data[gene_id][-1] += value
                    unique_genes.append(gene_id)




    # Write the merged data to an output file
    with open(output_path, 'w') as output_file, open(output_path2, 'w') as output_file2:
        output_file.write('\t'.join(['gene_id'] + headers) + '\n')
        output_file2.write('\t'.join(['gene_id'] + headers) + '\n')
        for gene_id, values in data.items():
            output_file.write('\t'.join([gene_id] + [str(x) for x in values]) + '\n')
            output_file2.write('\t'.join([gene_id] + [str(x) for x in values]) + '\n')




if __name__ == "__main__":
    print('in combine feature script')
    if len(sys.argv) < 4:
        print("Usage: combine_feature_counts.py output.tsv input1.tsv input2.tsv ...")
        sys.exit(1)

    output_file = sys.argv[1]
    output_file2 = sys.argv[2]
    input_files = sys.argv[3:]

    merge_columns(input_files, output_file, output_file2)

