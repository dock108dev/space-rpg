"""Interface capture or explicit retained before-source replay."""
import argparse
from interface_capture import SIZES, capture_interface


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('variant', choices=('before', 'after'))
    parser.add_argument('size', choices=SIZES, nargs='?', default=SIZES[0])
    arguments = parser.parse_args()
    print(capture_interface('UI-04', arguments.variant, arguments.size))


if __name__ == '__main__':
    main()
