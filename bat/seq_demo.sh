#!/bin/bash

"${JOB}/bat/seq_make.sh" 'demo' '1' '140' 'f';
"${JOB}/bat/seq_racer.sh" 'RacerA' &
"${JOB}/bat/seq_racer.sh" 'RacerB' &
"${JOB}/bat/seq_racer.sh" 'RacerC' &
"${JOB}/bat/seq_racer.sh" 'RacerD' &
exit

