# !/usr/bin/env hython

import argparse
import sys
import os
import hou
import re


def _msg(msg):
    sys.stdout.write(msg + '\n')


def _err(msg):
    sys.stderr.write(msg + '\n')


def main():
    exitCode = 0

    # _msg("0 " +str(sys.argv[0]))
    # _msg("1 " +str(sys.argv[1]))
    _msg("arg1: {}".format(sys.argv[2]))
    _msg("arg2: {}".format(sys.argv[3]))

    hipf = str(sys.argv[2])
    hou.hipFile.load(hipf)

    # igy inditod a bulit, ez egy kontener
    for geocnt in hou.node("/obj/prop").children():  # iteration
        _msg("Points in {}".format(geocnt.path()))  # string format
        for point in geocnt.displayNode().geometry().points():  # foreach point
            _msg("{}".format(point.position()))  # print vector
        _msg(" ")
        psz = "{}/sweet".format(geocnt.path())  # path to image
        _msg(psz)  # /obj/prop/geo1/sweet - path to parm
        _msg(geocnt.name())  # geo1 - nodename

        _msg(str(hou.parm(psz).eval()))  # resolved path Q:/Work/../image.png
        _msg(" -- - ")
        _msg(str(geocnt.parm('szoveg').eval()))  # string typed into the field

        # RAW string path   $JOB/.../image.png
        _msg(str(geocnt.parm('sweet').rawValue()))

        # in the hip i attached an expression: 7.12 * ch("intgr")
        _msg(str(geocnt.parm('flott').expression()))

        # username spaced padded with _
        _msg(hou.userName(alpha=True))

        # current node - since nothing is selected we get /
        # after that every relative path works from pwd()
        _msg(str(hou.pwd()))
        # type of an object < class 'hou.Node' >
        print(type(hou.pwd()))

    for geocnt in hou.node("/obj/nagy").children():
        _msg(" {}".format(geocnt.path()))

    # split into two string at once
    # the is MaxSplit. Default value is -1, which is "all occurrences"
    lhs, rhs = "sommas_bubuka".split("_", 1)

    # classic split example
    splz = "aaa bsbs kdkd sdfs".split(" ")
    _msg("type of the split array:")
    print(type(splz))
    _msg("nof items in array:")
    print(len(splz))

    # some regexp
    # regular expression "[a-m]+" means the lowercase letters a through m that occur one or more times are matched as a delimiter
    atext = 'zzzzzzabczzzzzzdefzzzzzzzzzghizzzzzzzzzzzz'
    alist = re.split("[a-m]+", atext)

    # this is how you print a list
    print(alist)  # ['zzzzzz', 'zzzzzz', 'zzzzzzzzz', 'zzzzzzzzzzzz']

    # chomp one at a time
    atext = "theres coffee in that nebula"

    mytuple = atext.partition(" ")

    print type(mytuple)  # <type 'tuple' >
    print mytuple  # ('theres', ' ', 'coffee in that nebula')
    print mytuple[0]  # theres
    print mytuple[2]  # coffee in that nebula

    readLineDemo()
    readLineDemoPro()
    _msg("exitcode:" + str(exitCode))
    _msg("bye!")
    return exitCode



# demonstrate readlines()
def readLineDemo():
    exitCode = 0
    L = ["kisdoboz tojasos\n", "nagydoboz sonkas\n", "uveg mustaros\n"]

    # writing to file
    file1 = open('myfile.txt', 'w')
    file1.writelines(L)
    file1.close()

    # Using readlines()
    file1 = open('myfile.txt', 'r')
    Lines = file1.readlines()

    count = 0
    # Strips the newline character
    for line in Lines:
        # print(line.strip())
        lintoks = line.strip()
        print("Line{}: {}".format(count, lintoks))
        count +=1
    return exitCode

def readLineDemoPro():
    filepath = 'myfile.txt'
    with open(filepath) as fp:
        line = fp.readline()
        cnt = 0
        while line:
            print("Line {}: {}".format(cnt, line.strip()))
            line = fp.readline()
            cnt += 1



if __name__ == "__main__":
    # Restore signal handling defaults to allow output redirection and the like.
    import platform
    if platform.system() != 'Windows':
        import signal
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    sys.exit(main())
