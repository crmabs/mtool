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


def setuprop(rop, smpQuality, outScale):
    
    _msg(rop.name())
    if smpQuality == "lo":
        rop.parm("ar_enable_adaptive_sampling").set(False)
        _msg("   sampling quality: lo")
    else:
        rop.parm("ar_enable_adaptive_sampling").set(True)
        _msg("   sampling quality: hi")
    #_msg("outScale " + outScale)
    resfrac = "1"
    if outScale == "2":
        resfrac = "0.5"
    
    if outScale == "4":
        resfrac = "0.25"
    
    if outScale == "8":
        resfrac = "0.125"

    _msg("   resolution fraction: " + resfrac)

    if outScale == "1":
        rop.parm("override_camerares").set(False)
    else:
        rop.parm("override_camerares").set(True)
        rop.parm("res_fraction").set(resfrac)




def main():
    exitCode = 0
    
    _msg("-------------------------------")
    _msg("running " + __file__)
    _msg(" ")
    # masterHip currentHip sceneSign smpQuality outScale ropToRender activeObj mapNames
    _msg("arg1: masterHip     {}".format(sys.argv[1]))
    _msg("arg2: currentHip    {}".format(sys.argv[2]))
    _msg("arg3: sceneSign     {}".format(sys.argv[3]))
    _msg("arg5: smpQuality    {}".format(sys.argv[4]))
    _msg("arg5: outScale      {}".format(sys.argv[5]))
    _msg("arg6: ropToRender   {}".format(sys.argv[6]))
    _msg("arg7: frame         {}".format(sys.argv[7]))
    _msg("arg8: activeObj     {}".format(sys.argv[8]))
    _msg("arg9: mapNames      {}".format(sys.argv[9]))
    _msg("-------------------------------")

    

    masterHip = str(sys.argv[1])
    currentHip = str(sys.argv[2])
    sceneSign = str(sys.argv[3])
    smpQuality = str(sys.argv[4])
    outScale = str(sys.argv[5])
    ropToRender = str(sys.argv[6])
    frame = str(sys.argv[7])
    activeObj = str(sys.argv[8])
    mapNames = str(sys.argv[9])
    
    # for some reason it replaces the input / to some cmder root path... or so
    ropToRender = "/out/" + ropToRender

    # param check
    objs = activeObj.split(",", -1)
    texs = mapNames.split(",", -1)
    nofObj = len(objs)
    nofTex = len(texs)

    if nofObj != nofTex:
        _err("nof active objects / maps mismatch. objects:" + str(nofObj) + "  textures:" + str(nofTex))
        return 1
    else:
        _msg("nof active objects " + str(nofObj ))

    hou.hipFile.load(masterHip)

    bossrop = hou.node(ropToRender)
    if bossrop is None:
        _msg("ERROR boss rop missing!")
        return 1

    _msg("boss rop exists: " + bossrop.name())



    # set signature on studio
    studio_node = hou.node("/obj/studio")
    psz = "{}/shotn".format(studio_node.path())
    hou.parm(psz).set(sceneSign)
    _msg("scene signature set:[" + sceneSign + "]")
    
    # hide all in props bundle
    props = hou.nodeBundle("props")
    _msg("hiding bundle:" +  props.name() + " " + str(len(props.nodes())) + " objects" )
    for bn in props.nodes():
        # _msg(bn.name()) 
        bn.setDisplayFlag(False)
    
    _msg("unhiding starts")
    # unhide objects / set textures
    for i in range(0, len(objs)):
        _msg("   " + objs[i] + " -> " + texs[i])
        ts = hou.node("/obj/" + objs[i])
        ts.setDisplayFlag(True)
        tx = "${JOB}/Asset/prop/Texture/" + texs[i]
        ts.parm("colval").set(tx)

    _msg("unhiding done")

    # get render rops
    subrops = bossrop.inputs()
    for rn in subrops:
        setuprop(rn, smpQuality, outScale)

     

   

    #save generated
    hou.hipFile.setName(currentHip)
    hou.hipFile.save()

    _msg("new hip file saved: " + currentHip)
    _msg("  ")
 


    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    _msg("render starts " + current_time)

    # do the render
    bossrop.render(verbose=False, output_progress=False, frame_range=(int(frame),int(frame),1))


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
