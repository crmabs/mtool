# !/usr/bin/env hython

import argparse
import sys
import os
import hou
import re
from datetime import datetime

def _msg(msg):
    sys.stdout.write(msg + '\n')


def _err(msg):
    sys.stderr.write(msg + '\n')

 


def main():
    exitCode = 0
    
    _msg("-------------------------------")
    _msg("running " + __file__)
    _msg(" ")
 
    _msg("arg1: hip           {}".format(sys.argv[1]))
    _msg("arg2: rop           {}".format(sys.argv[2]))
    _msg("arg3: start         {}".format(sys.argv[3]))
    _msg("arg5: end           {}".format(sys.argv[4]))
    _msg("arg5: step          {}".format(sys.argv[5]))
    _msg("-------------------------------")
    _msg("Just a reminder:")
    _msg("    Skip the first / defining the ROP!")

    hip = str(sys.argv[1])
    rop = str(sys.argv[2])
    start = str(sys.argv[3])
    end = str(sys.argv[4])
    step = str(sys.argv[5])
    
    # for some reason it replaces the input / to some cmder root path... or so
    #if rop.startswith("/") :
    #    ropToRender = rop
    #else:
    #    ropToRender = "/out/" + rop
    ropToRender = "/" + rop

    _msg("final ROP:" + ropToRender )

    #hou.hipFile.load(hip)
    try:
        hou.hipFile.load(hip)
    except hou.LoadWarning:
        _msg("scene load had some trabl")

    bossrop = hou.node(ropToRender)
    if bossrop is None:
        _msg("ERROR rop not found!")
        return 1

    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    _msg("render starts " + current_time)

    # do the render
    bossrop.render(verbose=True, output_progress=True, frame_range=(int(start),int(end),int(step)))

    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    _msg("render ends " + current_time)
    
    _msg("bye! " + __file__)
    return exitCode
 


if __name__ == "__main__":
    # Restore signal handling defaults to allow output redirection and the like.
    import platform
    if platform.system() != 'Windows':
        import signal
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    sys.exit(main())
