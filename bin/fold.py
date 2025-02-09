import argparse

from ImmuneBuilder import ABodyBuilder2

parser = argparse.ArgumentParser()
parser.add_argument("-h", type=str, required=True)
parser.add_argument("-l", type=str, required=True)
parser.add_argument("-o", type=str, required=True)
args = parser.parse_args()

predictor = ABodyBuilder2()

output_file = args.o
sequences = {
  'H': args.h,
  'L': args.l}

antibody = predictor.predict(sequences)
antibody.save(output_file)