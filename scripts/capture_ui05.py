"""Current interface capture with portable synthetic fixtures."""
import argparse
from interface_capture import SIZES, capture_interface


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('size', choices=SIZES, nargs='?', default=SIZES[0])
    arguments = parser.parse_args()
    print(capture_interface('UI-05', 'after', arguments.size))


if __name__ == '__main__':
    main()
