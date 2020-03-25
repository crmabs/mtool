@echo off

IF [%BMF_RENDERNODE%] == [] (
set BMF_RENDERNODE="c:\Program Files\Blackmagic Design\Fusion Render Node 16\FusionRenderNode.exe"
echo fusion render node path fallback to: "c:\Program Files\Blackmagic Design\Fusion Render Node 16\FusionRenderNode.exe"
echo      set env var
echo      BMF_RENDERNODE 
echo      to avoid this behaviour!
)  

REM echo %BMF_RENDERNODE% %1 -render -start %2 -end %3 -step %4  -pri high -quiet -quit
%BMF_RENDERNODE% %1 -render -start %2 -end %3 -step %4  -pri high -quiet -quit