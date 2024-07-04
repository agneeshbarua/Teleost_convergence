import argparse


def read_mapping_file(mapping_file):
    mapping = {}
    with open(mapping_file, "r") as f:
        for line in f:
            key, value = line.strip().split()
            mapping[key] = value
            #print(mapping)
    return mapping


def modify_fasta_headers(input_file, output_file, mapping):
    with open(input_file, "r") as infile, open(output_file, "w") as outfile:
        for line in infile:
            if line.startswith(">"):
                header_key = line[1:].strip("\n")
                print(header_key) #check
                if header_key in mapping:
                    print(mapping[header_key]) #check
                    outfile.write(">" + mapping[header_key] + "_" + line[1:])
                else:
                    outfile.write(line)
            else:
                outfile.write(line)

def main():
    parser = argparse.ArgumentParser(description="Modify FASTA headers with a mapping file.")
    parser.add_argument("input_file", help="Path to the input FASTA file.")
    parser.add_argument("output_file", help="Path to the output FASTA file.")
    parser.add_argument("mapping_file", help="Path to the mapping file with keys and values.")

    args = parser.parse_args()

    mapping = read_mapping_file(args.mapping_file)
    modify_fasta_headers(args.input_file, args.output_file, mapping)


if __name__ == "__main__":
    main()

