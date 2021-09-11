import sys
from os import path
import re


def main():
    if not input_valid():
        return

    components = dict()
    found_same_components = True
    with open(sys.argv[1], 'r') as iPregel_result, open(sys.argv[2], 'r') as networkit_result:
        for line in zip(iPregel_result, networkit_result):
            c_iPre = re.split(r"[\t ]+", line[0].rstrip('\n'))[1]
            c_net = re.split(r"[\t ]+", line[1].rstrip('\n'))[1]
            if c_iPre in components:
                if components[c_iPre] != c_net:
                    print("Different components for {}".format(line))
                    print("Component in networkit mapping should be: {} according to previous mapping.".format(components[c_iPre]))
                    found_same_components = False
                    break
            elif c_net in components.values():
                print("Networkit component {} mapped to iPregel components {} and {}.".format(c_net, list(components.keys())[list(components.values()).index(c_net)],c_iPre))
                print("Relevant vertex mapping (iPregel / networkit) => {}".format(line))
                found_same_components = False
            else:
                components[c_iPre] = c_net
        if found_same_components:
            print("No difference in component assignment detected.")

def input_valid():
    """checks if the correct parameters were given and prints error message if not"""

    valid = True
    if len(sys.argv) <= 2:
        valid = False
    else:
        if not path.exists(sys.argv[1]):
            print(f"The given graph file '{sys.argv[1]}' doesn't exist.")
            valid = False
        elif not path.exists(sys.argv[2]):
            print(f"The given graph file '{sys.argv[2]}' doesn't exist.")
            valid = False

    if not valid:
        print(f"usage: {sys.argv[0]} <iPregel_cc_result_file> <networkit_cc_result_file>")
    return valid

if __name__ == "__main__":
    main()
